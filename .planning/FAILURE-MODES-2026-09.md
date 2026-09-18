# Failure modes measured in one orchestrating session, 2026-09-10 to 2026-09-18

Raw session capture, written by the orchestrating session before its context was
lost. Every row is an instance that happened in this tree, with what caught it.
`records/` is where a claim sits beside its measurement; this file is the
unshaped material a later pass turns into rows there.

The session ran 20 dispatches and moved the element rung from 42 of 187 to 142
of 188. Every failure below is from that run.

## A. The orchestrator's own, and the shape they share

| # | what happened | what caught it |
|---|---|---|
| A1 | Verified that a design's citations RESOLVED and passed it. `bin/chirality:171-172` really does append a `compile-main` stub, so the quote was exact. Never asked whether `target-linux.manifest` conformed; it fails requirements 3 and 4 of its own design map. Done twice on the same artifact | the author |
| A2 | Asserted an author ruling no tracked document carried: E149 routed to `zero-python`, and E41 ruled to `enforcement` on 2026-09-14 | the dispatched agent, both times, because the prompt said to re-verify |
| A3 | Handed over a measurement taken with a fragile parse: "19 of 70 `lib/` modules declare a coordinate" was a grep for the string anywhere, five hits being comments. True figure 14 of 95 | the dispatched agent |
| A4 | Asked a question as a false binary: "is E43 wanted whole, or does it split" | the author, who answered that the point is a pluggable seam, which neither branch offered |
| A5 | Asked a question the tree already answered. Whether E44's totality half had a home, when totality is enforcement's business | the author |
| A6 | Invented a vocabulary gap. Proposed a new state token for "holds a number, owes the pipeline" when `open` beside an `E#` already means exactly that, and the ledger glosses `design` as `unbuilt` rather than as a stage that ran | the author |
| A7 | Lost a ruling given in session. The `superseded` homing exemption was never written down; a later agent correctly refused to act on it and reported a count wrong by one | the agent's refusal |
| A8 | Scoped a question to a slice of the real population, twice: 32 unhomed elements when the set was 144, and 55 self-hosting elements when the set was 81 | measurement, once prompted |
| A9 | Dispatched a design run on a row whose design was five author calls | the author |
| A10 | Did the first measurement inline instead of dispatching it | the author |
| A11 | Reported between units instead of continuing the queue | the author, twice |

**The shape A1, A3 and A8 share**: a check that tests presence, resolution or a
string where the claim needed testing. That is the same defect as A-side tooling
below, one tier up.

## B. Agent failures the verification pattern caught

| # | what happened | how |
|---|---|---|
| B1 | Claimed E42 has no ledger row. It has one; the row's cell is the file's only bolded `**E42**` and the agent's parser anchored on a bare `E\d+` | orchestrator cross-checked all 144 rows' state against the ledger; one disagreement |
| B2 | Wrote `level: tool`, outside the lens's closed set | `lens.py check` |
| B3 | Wrote roster state `design`, outside the closed state vocabulary. Three arcs in a row did this | `ledger-lint` check AG |
| B4 | Overstated its own finding: said a 2026-08 ruling "drops half of what this arc rosters" when the arc rostered none of what was dropped | orchestrator read the arc against the ruling |
| B5 | Cited a call site where the definition was wanted. Three separate runs | `ledger-lint` check R |
| B6 | Set `author: ruled` from a quote it had not witnessed, and said so | the agent flagged itself |
| B7 | Asserted a parking ruling's date wrongly, and the substance with it | the next agent measured it |

**B6 is the pattern working**: an agent recording that its own evidence came
through a prompt rather than from the tree.

## C. Tool and tree failures the homing pass exposed

| # | what | measured |
|---|---|---|
| C1 | `ledger-lint` check AE built its `named` set with a regex over the whole arc file, so `tool-authority`'s boundary section REFUSING E148 and E149 read as ownership. It also skipped `built` and `superseded` | reported nothing on a tree where 143 of 187 elements held no roster row. `PRB-83`, rewritten `8a7b644` |
| C2 | check AI is keyed on a file, so refreshing one row's `checked:` date clears findings on rows that did not move, and editing a file stales every row citing it | 13 ruled rows cleared 8 violations at once |
| C3 | check AH globs the bare element form while single-digit SPECs are zero-padded on disk | nine existing SPECs misreported absent in one arc |
| C4 | A reproduce recipe in a record compared unpadded catalog numbers against zero-padded filenames | nine false orphans, and the record's own count wrong by nine for ten days |
| C5 | `pack.py` compared a whole roster cell to one element id | a two-element row matched neither, so E56 held a row the tool could not see. Fixed `6e9c76a` |
| C6 | One invariant stated in eight places. Correcting it took three commits and still missed a carrier that REASONS from the rule without quoting it | `PRB-85`, and `FD-28` measured that fourteen of fifteen surveyed mechanisms miss that carrier |
| C7 | Eight catalog cells stale in the direction no check reads, every one UNDERSTATING what is built | found by four arc-opening runs; check AB reports zero issues on all of them |
| C8 | Nothing measured the goal-arc-element chain. Four gates stood green over 99 unhomed elements, 12 unserved requirements and 4 unanchored arcs, because each gate reports the UNADMITTED hole and every rung gives a hole an escape | `PRB-86`, `lens.py chain` added |
| C9 | Strict positivity refuses a direct negative occurrence and accepts the same occurrence through a mutual cycle, in an element the ledger reads `built (ENFORCED)` | reproduced by the orchestrator in two three-line probes |
| C10 | The fixpoint compare runs in 1.6 s and no phase runs it. Phase 11's stated blocker names an input the compare does not take | reproduced: `C1 == C2`, blob 17,797 lines |

## What the pattern is, stated once

Two contexts cannot share a hallucination unless one hands it to the other as a
premise. Every catch in section B, and every one in A2 and A3, came from one
instruction in the prompt: re-verify each fact at its location and report what
drifted. The single time it was omitted, A2's error propagated into an arc file.

So the prompt is the leak, and the prompt is written by the party whose errors
section A records.
