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
