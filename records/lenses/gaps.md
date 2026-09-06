# gaps

One row per entry. The schema, the states and the two axes are in `README.md`.

### GAP-01 bridge-arc requirement 3 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    bridge/req3
- claim:    docs/arcs/bridge-arc.md REQUIREMENTS 3: "Each has a mutant that is actually run. A check aimed at a guess passes by looking at nothing."
- measured: converting the arc's roster to the 8-column schema on 2026-09-05 showed requirement 3 served by none of C1 to C5. Folding the mutant into C1 and C2 would make the requirement unobservable on its own, so whether it takes its own row is an author call.
- evidence: docs/arcs/bridge-arc.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-02 enforcement-arc requirement 5 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    enforcement/req5
- claim:    docs/arcs/enforcement-arc.md REQUIREMENTS 5: "Chirality's own tooling is chirality's."
- measured: converting the arc to the 8-column roster on 2026-09-05 showed requirement 5 served by none of N1 to N9. Every row is a compiler-side element and the requirement is about the gate tier, so it needs rows this arc has not written.
- evidence: docs/arcs/enforcement-arc.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-03 enforcement-arc requirement 6 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    enforcement/req6
- claim:    docs/arcs/enforcement-arc.md REQUIREMENTS 6: "Every gate row names a mutant that is actually run."
- measured: converting the arc to the 8-column roster on 2026-09-05 showed requirement 6 served by none of N1 to N9. It is a property every gate must carry rather than a deliverable, so whether it takes its own row is an author call.
- evidence: docs/arcs/enforcement-arc.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-04 file-types-arc requirement 3 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    file-types/req3
- claim:    docs/arcs/file-types-arc.md REQUIREMENTS 3: "Codecs are derived from the declared form rather than hand-written."
- measured: converting the arc to the 8-column roster on 2026-09-05 showed requirement 3 served by none of K1, K2, K3 or E1. It is a property each declared kind must carry rather than a deliverable of its own.
- evidence: docs/arcs/file-types-arc.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-05 file-types-arc requirement 4 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    file-types/req4
- claim:    docs/arcs/file-types-arc.md REQUIREMENTS 4: "Each kind has a round-trip gate with a named mutant that is actually run."
- measured: same conversion, same measurement: a property every kind carries rather than a row, so whether it takes one is an author call.
- evidence: docs/arcs/file-types-arc.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-06 independent-judgment-arc requirement 4 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    independent-judgment/req4
- claim:    docs/arcs/independent-judgment-arc.md REQUIREMENTS 4: "`status-ledger` stops saying every rung is enforcement against error."
- measured: converting the arc to the 8-column roster on 2026-09-05 showed requirement 4 served by none of J1 to J5. It is a correction to docs/definitions/status-ledger.md rather than an element, so whether it takes a row is an author call.
- evidence: docs/arcs/independent-judgment-arc.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-07 module-split-arc requirement 3 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    module-split/req3
- claim:    docs/arcs/module-split-arc.md REQUIREMENTS 3: "A cut module rejoins through a typed connector rather than by a shared header."
- measured: converting the arc to the 8-column roster on 2026-09-05 showed requirement 3 served by none of S1 to S4. It is a property the S1 cut must satisfy rather than a deliverable of its own.
- evidence: docs/arcs/module-split-arc.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-08 ownership-and-trust-arc requirement 3 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    ownership-and-trust/req3
- claim:    docs/arcs/ownership-and-trust-arc.md REQUIREMENTS 3: "The reference semantics is reached."
- measured: converting the arc to the 8-column roster on 2026-09-05 showed requirement 3 served by none of O1 to O3. It is adoption of a built thing rather than a deliverable, and the whole arc is deferred by author call, so nothing schedules it.
- evidence: docs/arcs/ownership-and-trust-arc.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-09 presentability-arc requirement 1 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    presentability/req1
- claim:    docs/arcs/presentability-arc.md REQUIREMENTS 1: "Fresh-clone build. The BUILD RULE runs end to end."
- measured: converting the arc to the 8-column roster on 2026-09-05 showed requirement 1 served by none of D1 to D3. It is a standing property of the tree rather than a deliverable.
- evidence: docs/arcs/presentability-arc.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-10 presentability-arc requirement 3 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    presentability/req3
- claim:    docs/arcs/presentability-arc.md REQUIREMENTS 3: "Every number in the spine is current or dated."
- measured: same conversion, same measurement: a property every spine document carries rather than a row. Two instances were corrected in this session, placement.md's 255 and its check range.
- evidence: docs/arcs/presentability-arc.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-11 text-tools-arc requirement 1 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    text-tools/req1
- claim:    docs/arcs/text-tools-arc.md REQUIREMENTS 1: "Every primitive is total."
- measured: converting the arc to the 8-column roster on 2026-09-05 showed requirement 1 served by none of P1 to P4. It is a property each primitive carries rather than a deliverable, which is why the arc states it once instead of four times.
- evidence: docs/arcs/text-tools-arc.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-12 text-tools-arc requirement 2 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    text-tools/req2
- claim:    docs/arcs/text-tools-arc.md REQUIREMENTS 2: "Every primitive is pure `->`. None reads a file or a directory."
- measured: same conversion, same measurement: a per-primitive property rather than a row.
- evidence: docs/arcs/text-tools-arc.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-13 text-tools-arc requirement 4 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    text-tools/req4
- claim:    docs/arcs/text-tools-arc.md REQUIREMENTS 4: "Each replacement is verified against the tool it replaces on the same input."
- measured: same conversion, same measurement: a differential obligation each primitive owes rather than a deliverable of its own.
- evidence: docs/arcs/text-tools-arc.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-14 tuning-arc requirement 1 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    tuning/req1
- claim:    docs/arcs/tuning-arc.md REQUIREMENTS 1: "Chirality holds a typed port for each verb the criterion names."
- measured: the arc carries zero rows on purpose. Its opening proposal measured that the two readings of author call A share no first row, so any row written now prejudges the call. Blocked whole in records/author-calls.md.
- evidence: docs/arcs/tuning-arc.md, records/author-calls.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-15 tuning-arc requirement 2 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    tuning/req2
- claim:    docs/arcs/tuning-arc.md REQUIREMENTS 2: "The external side is reaped under linear obligation."
- measured: the arc carries zero rows on purpose. Its opening proposal measured that the two readings of author call A share no first row, so any row written now prejudges the call. Blocked whole in records/author-calls.md.
- evidence: docs/arcs/tuning-arc.md, records/author-calls.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-16 tuning-arc requirement 3 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    tuning/req3
- claim:    docs/arcs/tuning-arc.md REQUIREMENTS 3: "Swapping ollama for llama.cpp changes a declared value."
- measured: the arc carries zero rows on purpose. Its opening proposal measured that the two readings of author call A share no first row, so any row written now prejudges the call. Blocked whole in records/author-calls.md.
- evidence: docs/arcs/tuning-arc.md, records/author-calls.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-17 tuning-arc requirement 4 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    tuning/req4
- claim:    docs/arcs/tuning-arc.md REQUIREMENTS 4: "The done condition of goals/self-tooling is still true."
- measured: the arc carries zero rows on purpose. Its opening proposal measured that the two readings of author call A share no first row, so any row written now prejudges the call. Blocked whole in records/author-calls.md.
- evidence: docs/arcs/tuning-arc.md, records/author-calls.md
- checked:  2026-09-05
- owner:    none
- from:     none
