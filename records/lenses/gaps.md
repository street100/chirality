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

- state:    closed
- author:   ruled 2026-09-06
- note:     "native tests and harnesses". The gate tier becomes chirality, not only the Python tools.
- level:    arc
- about:    enforcement/req5
- claim:    docs/arcs/enforcement-arc.md REQUIREMENTS 5: "Chirality's own tooling is chirality's."
- measured: RULED 2026-09-06 and measured the same day: **10,719 lines of shell in `tools/test/` against 1,775 native `.prog` lines.** The ruling widens this beyond zero-python, which covers the nine `.py` tools and not the shell gate tier. `prog/prose-lint.prog` and `prog/test-runner.prog` are the worked precedents: the checks moved into chirality and the shell kept only the front end. converting the arc to the 8-column roster on 2026-09-05 showed requirement 5 served by none of N1 to N9. Every row is a compiler-side element and the requirement is about the gate tier, so it needs rows this arc has not written.
- evidence: tools/test/ (10,719 lines), prog/prose-lint.prog, prog/test-runner.prog, docs/goals/enforcement.md requirement 5, docs/arcs/zero-python-arc.md
- checked:  2026-09-06
- owner:    enforcement/N10
- from:     none

### GAP-03 enforcement-arc requirement 6 has no roster row

- state:    closed
- author:   ruled 2026-09-06
- note:     "native tests and harnesses". Carried with GAP-02: a native harness is what makes a mutant checkable mechanically.
- level:    arc
- about:    enforcement/req6
- claim:    docs/arcs/enforcement-arc.md REQUIREMENTS 6: "Every gate row names a mutant that is actually run."
- measured: converting the arc to the 8-column roster on 2026-09-05 showed requirement 6 served by none of N1 to N9. It is a property every gate must carry rather than a deliverable, so whether it takes its own row is an author call.
- evidence: docs/arcs/enforcement-arc.md
- checked:  2026-09-06
- owner:    enforcement/N11
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
- measured: RE-MEASURED 2026-09-06: **unchanged in shape. The arc doubled its roster on 2026-09-06 and requirement 1 still has no row.** `docs/arcs/presentability-arc.md` went from three roster rows to six at `23cd212`, which added `D4`, `D5` and `D6`, and all three carry `req` **2**. The `req` column over all six rows reads **2, 5, 4, 2, 2, 2**, so the served set is **{2, 4, 5}** and requirement 1 is absent from it. The Coverage paragraph at `:66-69` still names this row for requirement 1 and `GAP-10` for requirement 3. Requirement 1 now sits at `:33-34`. A grep for `presentability/req1` over `docs/`, `records/` and `.planning/` returns one line, this row's own `about:` field, so no sibling arc delegates it the way `docs/arcs/binary-split-arc.md:115` takes requirement 6 through `binary-split/B5`. `B5` does exercise the BUILD RULE, over the split binaries, and its `req` cell names `presentability/req6` alone. `docs/goals/presentability.md:38-41` draws the same split: done-condition 2 cites this arc's requirement 1 for the clean-clone build and `B5` for the split binaries. The 2026-09-05 reading holds. Requirement 1 is a standing property of the tree that running the build observes, and it has no deliverable behind it. ⚑ One citation inside the arc has drifted, in a document this row may edit nothing of. Requirement 1 reads "The BUILD RULE in `CLAUDE.md`", and the root `CLAUDE.md` carries the rule nowhere: its table at `:14` routes it to `docs/definitions/working-discipline.md`, where it is the section at `:15`. Reported and left standing. RE-VERIFIED 2026-09-07 after `CLAUDE.md` gained rows for the translation tier: `grep -n 'build rule' CLAUDE.md` still returns 14 and `:14` still routes to `docs/definitions/working-discipline.md`. The rows added are in the harness and orientation tables below it. Substance unchanged.
- evidence: re-runnable: `awk -F'|' '$2 ~ /presentability/' docs/arcs/presentability-arc.md | wc -l` returns 6, and the same awk printing field 7 through `sort -u` returns 2, 4 and 5. `grep -n 'Fresh-clone build' docs/arcs/presentability-arc.md` returns 33. `grep -rn 'presentability/req1' docs/ records/ .planning/ | wc -l` returns 1. `grep -n 'build rule' CLAUDE.md` returns 14 and `grep -n '## The build rule' docs/definitions/working-discipline.md` returns 15. `docs/arcs/presentability-arc.md:33-34`, `:57-62`, `:66-69`; `docs/arcs/binary-split-arc.md:115`; `docs/goals/presentability.md:38-41`; commit `23cd212`
- checked:  2026-09-07
- owner:    none
- from:     none

### GAP-10 presentability-arc requirement 3 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    presentability/req3
- claim:    docs/arcs/presentability-arc.md REQUIREMENTS 3: "Every number in the spine is current or dated."
- measured: RE-MEASURED 2026-09-07: **unchanged in shape. Requirement 3 still has no roster row, and this row's own evidence command has stopped measuring what it was written for.** The roster is still six rows and the served set is still **{2, 4, 5}**; requirement 3 sits at `docs/arcs/presentability-arc.md:39-40` and the Coverage flag at `:66-69` still names this row. ⚑ **`grep -rn 'presentability/req3' docs/ records/ .planning/ | wc -l` now returns 3 where this row recorded 1, and all three hits are this row's own block**, `records/lenses/gaps.md:137`, `:139` and `:140`. The 2026-09-06 re-measurement wrote the string into `measured:` and `evidence:`, so the command counts its own prose. The measurement it was for is `grep -rn 'presentability/req3' docs/ .planning/ | wc -l`, which returns **0** and says the same thing without the self-reference. **The mechanical coverage is unchanged and the lint reporting it moved.** `--only AA` still finds 0 issues and now prints a second line, `ledger-lint: clean`, which is `e3ecd85`'s summary verdict; `check_aa` drifted from `:2174` to `:2250`. The check set now runs A through **AK**: `d5b8fad` added AK, which reads `records/author-calls.md` for unruled forks and observes nothing about a figure in the spine, so nothing in A to AK observes the requirement as the arc states it. `docs/goals/presentability.md:32-52` still states five done-conditions and none of them is this one, so the requirement rests at the arc tier alone. ⚑ That goal's first condition at `:36` is observed by ``ledger-lint`` exiting 0, and `e3ecd85` put exit 0 out of reach while an author call stands `unreviewed`; the tree reads exit 2 today. That sits in a document this row may not edit and is reported.
- evidence: re-runnable: `awk -F'|' '$2 ~ /presentability/ {gsub(/ /,"",$7); print $7}' docs/arcs/presentability-arc.md | sort -u` returns 2, 4 and 5. `grep -n 'Every number in the spine' docs/arcs/presentability-arc.md` returns 39. `grep -rn 'presentability/req3' docs/ .planning/ | wc -l` returns 0, and adding `records/` returns 3, all three inside this row. `python3 tools/ledger-lint/ledger-lint.py --only AA` prints `[ok] AA superseded figures (0 issue(s))` and then `ledger-lint: clean`, at exit 0. `docs/arcs/presentability-arc.md:39-40`, `:57-62`, `:66-69`; `docs/goals/presentability.md:32-52`, `:36`; `tools/ledger-lint/ledger-lint.py:2250`; commits `23cd212`, `d5b8fad`, `e3ecd85`
- checked:  2026-09-07
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

- state:    closed
- author:   ruled 2026-09-06
- note:     "no fucking python in the language". Author call A ruled: Python is outside the tree, a spawned external process reached through a typed port.
- level:    arc
- about:    tuning/req1
- claim:    docs/arcs/tuning-arc.md REQUIREMENTS 1: "Chirality holds a typed port for each verb the criterion names."
- measured: CLOSED 2026-09-06 by the roster tuning-arc could not write while the call was open. the arc carries zero rows on purpose. Its opening proposal measured that the two readings of author call A share no first row, so any row written now prejudges the call. Blocked whole in records/author-calls.md.
- evidence: docs/arcs/tuning-arc.md, records/author-calls.md
- checked:  2026-09-06
- owner:    tuning/U1 through tuning/U5
- from:     none

### GAP-15 tuning-arc requirement 2 has no roster row

- state:    closed
- author:   ruled 2026-09-06
- note:     "no fucking python in the language". Author call A ruled: Python is outside the tree, a spawned external process reached through a typed port.
- level:    arc
- about:    tuning/req2
- claim:    docs/arcs/tuning-arc.md REQUIREMENTS 2: "The external side is reaped under linear obligation."
- measured: CLOSED 2026-09-06 by the roster tuning-arc could not write while the call was open. the arc carries zero rows on purpose. Its opening proposal measured that the two readings of author call A share no first row, so any row written now prejudges the call. Blocked whole in records/author-calls.md.
- evidence: docs/arcs/tuning-arc.md, records/author-calls.md
- checked:  2026-09-06
- owner:    tuning/U1 through tuning/U5
- from:     none

### GAP-16 tuning-arc requirement 3 has no roster row

- state:    closed
- author:   ruled 2026-09-06
- note:     "no fucking python in the language". Author call A ruled: Python is outside the tree, a spawned external process reached through a typed port.
- level:    arc
- about:    tuning/req3
- claim:    docs/arcs/tuning-arc.md REQUIREMENTS 3: "Swapping ollama for llama.cpp changes a declared value."
- measured: CLOSED 2026-09-06 by the roster tuning-arc could not write while the call was open. the arc carries zero rows on purpose. Its opening proposal measured that the two readings of author call A share no first row, so any row written now prejudges the call. Blocked whole in records/author-calls.md.
- evidence: docs/arcs/tuning-arc.md, records/author-calls.md
- checked:  2026-09-06
- owner:    tuning/U1 through tuning/U5
- from:     none

### GAP-17 tuning-arc requirement 4 has no roster row

- state:    closed
- author:   ruled 2026-09-06
- note:     "no fucking python in the language". Author call A ruled: Python is outside the tree, a spawned external process reached through a typed port.
- level:    arc
- about:    tuning/req4
- claim:    docs/arcs/tuning-arc.md REQUIREMENTS 4: "The done condition of goals/self-tooling is still true."
- measured: CLOSED 2026-09-06 by the roster tuning-arc could not write while the call was open. the arc carries zero rows on purpose. Its opening proposal measured that the two readings of author call A share no first row, so any row written now prejudges the call. Blocked whole in records/author-calls.md.
- evidence: docs/arcs/tuning-arc.md, records/author-calls.md
- checked:  2026-09-06
- owner:    tuning/U1 through tuning/U5
- from:     none

### GAP-18 zero-python-arc requirement 4 has no roster row

- state:    open
- author:   unreviewed
- note:     none
- level:    arc
- about:    zero-python/req4
- claim:    docs/arcs/zero-python-arc.md REQUIREMENTS 4: "Every replacement runs on the tree's own test floor."
- measured: converting the arc to the 8-column roster on 2026-09-05 showed requirement 4 served by none of Z1 to Z9. It is a property each ported tool carries rather than a deliverable of its own.
- evidence: docs/arcs/zero-python-arc.md
- checked:  2026-09-05
- owner:    none
- from:     none

### GAP-19 the live environment names itself a goal and no goal file holds it

- state:    open
- author:   unreviewed
- note:     none
- level:    goal
- about:    docs/definitions/live-environment.md
- claim:    docs/definitions/live-environment.md:11-14 "The first large application planned on chirality is a live, self-modifying environment used for everything a personal computing environment is used for, opened first as a flexible AI-orchestration layer. This is the hub note for that goal." Its two invariants at :23-29 are residential, the environment is the program and extends in its own language live with no edit-compile-run seam, and mesh, the substrate is isolated typed processes over ports.
- measured: swept 2026-09-08 by grep over docs/goals/ and docs/arcs/*.md for live-environment, residential and self-modif. Zero hits in either tier. Fourteen goal files exist and the nearest two carry a slice each: docs/goals/local-ai.md:56 condition 2 puts scriba over the parts of one run, and docs/goals/own-web.md:51 condition 5 puts a canvas inside the environment. Neither states the residential invariant, so a hub note points at a goal tier that holds nothing for it. Four settled decisions lean on the note by name: decision-user-layer-extensibility, decision-reflective-floor, decision-brokers and decision-deployment-custody.
- evidence: docs/definitions/live-environment.md:11-14, :23-29; docs/goals/local-ai.md:56; docs/goals/own-web.md:51; docs/decisions/decision-user-layer-extensibility.md
- checked:  2026-09-08
- owner:    none
- from:     none

### GAP-20 the user layer carries 53 rows of work and no goal covers it

- state:    open
- author:   unreviewed
- note:     none
- level:    goal
- about:    .planning/USER-LAYER-TRACKER.md
- claim:    docs/decisions/decision-scope.md:80-84, under Honest limit: "The scope sentence names two clauses, in-scope and deferred, and some real work falls in neither. The user layer is the known instance: `docs/decisions/` legitimates it, no `U#` row exists in the catalog or ledger, and work on it stopped mid-audit on 2026-08-30." The same paragraph closes by separating an unclassified body of work from a deferred one and puts the user layer outside what that decision covers.
- measured: three tracked planning documents carry the work and no goal file names any of them. USER-LAYER-GAP.md:4 mints the outline on 2026-08-30, USER-LAYER-TRACKER.md:7 counts 53 rows in its own lane, and USER-LAYER-PIPELINE-PLAN.md sorts every row into a track with a serial queue. The tracker holds a live NOW section whose last dispatched position dates to 2026-08-30, and decision-user-layer-extensibility.md is the settled decision the whole body rests on. This is the shape docs/benchmarks/OPTIMIZATIONS-TODO.md held for five weeks before docs/goals/emitted-speed.md opened: a resumption document with a named entry point and nothing in the goal tier above it. `tools/lens/lens.py overview` walks goals that exist and reports UNOPENED per condition, so it reaches none of this.
- evidence: docs/decisions/decision-scope.md:80-84; .planning/USER-LAYER-GAP.md:4-10; .planning/USER-LAYER-TRACKER.md:3-11; docs/decisions/decision-user-layer-extensibility.md:9-11
- checked:  2026-09-08
- owner:    none
- from:     none

### GAP-21 cost carried in the type is a principle and no goal condition owns it

- state:    open
- author:   unreviewed
- note:     none
- level:    goal
- about:    PRINCIPLES.md:51
- claim:    PRINCIPLES.md:51 heads principle 2, "Everything is a process, and the type is the whole cost", and :60-64 states that every effect and every unit of fuel shows up in the type. docs/definitions/thesis.md:22 restates it as the second application of the thesis. README.md carries "cost is in the type" as a row of its claims table.
- measured: swept 2026-09-08 across the fourteen goal files. No done-condition names the grade structure. docs/definitions/status-ledger.md, item 3 under the heading "Sharpest designed-vs-real gaps", reads "Cost is settled-on-paper, unbuilt. `lib/typing/qtt.chiral` still carries only 0/1/ω; the typed-cost thesis has no grade structure yet." Cover exists at two tiers below a goal and neither claims the project is doing the work: UNS-05 records that E38 is unbuilt and no arc names it, and docs/goals/emitted-speed.md:201 bounds it as an honest limit of a different claim, which is what the compiled artifact costs. docs/goals/enforcement.md:25 condition 1 reaches the ledger row for a capability and stops short of building one.
- evidence: PRINCIPLES.md:51-74; docs/definitions/thesis.md:22; docs/definitions/status-ledger.md, heading "Sharpest designed-vs-real gaps" item 3; docs/elements/catalog.md:165; records/lenses/unspoken.md:59-72; docs/goals/emitted-speed.md:201-205
- checked:  2026-09-08
- owner:    none
- from:     none

### GAP-22 the T1 rung that ttype's none arm routes to is not built

- state:    open
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/lowering/upper/lower.chiral
- claim:    `docs/decisions/decision-preserve-check.md`, settled 2026-09-08: a preserve-check is two rungs, and `ttype`'s `Maybe` is `PRINCIPLES.md` §5's tier line. A `(some t)` is **T0**, the typeable region where one source of truth is correct because the type is the proof. A `(none)` is **T1**, where proof has run out and the claim is carried by a source evaluator and a target evaluator required to agree.
- measured: **T1 is not built, so today a `(none)` drops the definition instead of routing it.** `ttype` (`lib/lowering/upper/lower.chiral:35`) is `(-> UT (Maybe TalTy))` and answers `(none)` for function types and for `u-other`. [[records/findings]] FD-16 measured no production compiler occupying that position: every surveyed translation is total on its input or aborts wholesale, and the one production partiality, a HotSpot C2 bailout, keeps the refused method running from an already-verified class file. Here the definition leaves the artifact `ck-prog` reads, and `lib/lowering/compile-back.chiral:268-269` already records the cost, `a reachable skipped def surfaces as a missing label at emit`. ⚑ **Both halves of T1 exist and neither is reached.** FD-20 measured `lib/lowering/tal/eval.chiral` (187 lines, the target evaluator) and `lib/evidence/interp.chiral` (109 lines, the source evaluator), each with zero importers, as the two independent writers §5's rung table requires for T1 to buy anything. ⚑ **This is coverage owed rather than a defect to fix in `ttype`.** The arm is the right shape and its header already half-names the routing, `or none (stays upper)`. What is missing is the destination. FD-20 also measured that the claim T1 would carry cannot be stated as FD-15's typed lemma, since that puts `[[τ]]` in its own conclusion and needs the total translation T0 covers.
- evidence: `lib/lowering/upper/lower.chiral:35`, `lib/lowering/compile-back.chiral:268-269`, `lib/lowering/tal/eval.chiral`, `lib/evidence/interp.chiral`, [[decisions/decision-preserve-check]], [[records/findings]] FD-16, [[records/findings]] FD-20
- checked:  2026-09-08
- owner:    none
- from:     FD-20
