# Handoff: the doc tier, for a second session

**Resume from this file.** Tracked, so a fresh clone gets it. You need nothing
from the session that wrote it.

Opened 2026-09-02. A compiler session is running in parallel on
`docs/arcs/enforcement-arc.md`. This file is the other lane.

## Do not touch

That session owns these and edits them while you work:

| path | why |
|---|---|
| `lib/`, `prog/` | compiler source. A comment-only edit owes a fixpoint rebuild |
| `tools/test/` | the gate scripts |
| `docs/elements/catalog.md`, `docs/elements/ledger.md` | it is correcting element rows |
| `docs/arcs/enforcement-arc.md` | its arc |

Everything else in `docs/`, `records/` and `.planning/` is yours.

⚑ `HANDOFF-LANE-A.md` and `LANES.md` left the root on 2026-09-03. `LANES.md`
moved to `docs/decisions/decision-lane-split.md`; the Lane A resume state lives
in `docs/arcs/diagnostics-arc.md` and `docs/arcs/enforcement-arc.md`.

## Rules

- **Pathspec every commit.** `git commit -F - -- <paths>`. A bare commit sweeps
  the other session's work. That has happened twice in this tree.
- **Do not mint an element number.** `docs/decisions/decision-lane-split.md`
  reserves `E184-E189` and `E190-E195` for other lanes. Anything owed writes
  `UNASSIGNED`.
- **Never cut an honest limit.** `⚑`, "unbuilt", "UNVERIFIED", "VACUOUS",
  "SEEDED", and every measured number with its date.
- **Do not run `tools/test/run-tests.sh`.** 3.85 GB, no swap, and it has
  OOM-killed several sessions. Nothing here touches code, so no gate has a
  subject.
- `.planning/protocol/tone.md` binds every sentence. `X, not Y` trips
  `antithesis`; `(is|are|was|were) not [a-z]` trips `copula-negation`.
- Run `python3 tools/ledger-lint/ledger-lint.py` before and after. Baseline
  2026-09-02: `A(6) B(5) C(1) F(27) G(77) I(1) N(1) R(131) T(1)`, `H,M VACUOUS`,
  **J and V both `[ok] 0`**. Report any delta with its cause.

## The work, highest value first

### 1. Both benchmark documents are stale, and one argues from a refuted instrument

**`docs/benchmarks/text-matcher-allocation.md`** has two defects.

Its section "Why `memory.peak` is the right instrument here" now has a measured
counterexample. `7341ddf` added `(extern heap-allocated (=> Unit I64))` to
`lib/ports/process.port`, which reads `heapptr - heapbase`, the allocator's own
cursor. Measured against it: the counter said 81,932,784 B allocated where
`memory.peak` read 74,133,504, **9.5% low**, because arena bytes allocated and
never touched never become resident. `memory.peak` also moved 28,672 B between
two runs of the same binary while the counter was bit-identical.

So every figure in that file is derived from an instrument that understates.
**The counter exists now and has zero residue** (predicted and measured agreed
exactly at 0, 24,008, 48,008 and 72,016 B from the emitter's own `8*(1+fields)`
formula). The document should be re-measured with it, or carry a `⚑` saying it
was not.

Second defect: it cites `lib/text/matcher.chiral:396` for `scan-go`, and
`9f46c6c` moved the definition to `:450`. That is the single `R` issue above the
old 130 baseline.

**`docs/benchmarks/text-matcher-prose-lint.md`** reports the native matcher at
15x the awk tool. That was measured before `9f46c6c` cut its allocation 58%,
from 1,070 MB to 451 MB on the same corpus. The ratio is stale and the file does
not say so. Its method note is worth keeping: min-of-N, the spread, and the
machine load named.

⚑ Both files were written under an author ruling to **record the wall clock
rather than gate on it**, so an honest bad number is the point. Do not soften
one.

### 2. Six goal files cite README line numbers that moved

`docs/goals/README.md` states the rule: *"Adding a goal means citing where the
project already claims it."* Six goal files discharge it by citing
`README.md:44-46` and similar. **`eeb3228` rewrote the README**, so every one of
those line numbers is wrong.

The fix is a stable anchor rather than a line: `README.md#the-questions`,
`#scope`, `#claims-state-and-limits`, `#how-goals-are-handled`. Those headings
exist now. Whatever a goal quotes must still be stated in the README **in the
words the goal quotes** — check `U` stays at zero, since it is exactly that
check and three goal files already broke it once.

### 3. `docs/definitions/totality.md` describes a compiler that no longer exists

Its "Classify now, enforce later" and profile-gate sections name `sig.totality`,
`sig.require_total` and a `chirality verify` subcommand. Those were Python
oracle fields and the oracle is cut.

`aedf555` landed a native caller: `(total)` on a profile now refuses a
definition the classifier cannot prove, and `tot-of-def : (-> Str Term Verdict)`
is the pure function a caller reads. `sig.require_total` has **no native
referent**. The doc should describe what the compiler does.

⚑ One measured finding belongs in it: over the compiler's own 1,469 defs the
classifier proves all but **40**. The class is real rather than a bug — index
loops whose bound is a *call* (`(str-len s)`) rather than a bare variable, merge
sort's two-list measure, and `conv` (the SN axiom). Clustered in
`sexp.chiral` (10), `prelude/string.chiral` (6), `emit-core.chiral` (5). The
consequence: a `(total)` profile over any closure containing
`lib/prelude/string.chiral` is refused today, naming `su-pad-go`, which genuinely
diverges on an empty `pad`.

### 4. The lint worklist

`A(6)` evidence paths, `B(5)` principle numbers, `C(1)` CONTENTS counts,
`F(27)` link graph, `I(1)` frontier staleness, `T(1)` registry rows. Small,
mechanical, and each names its own subject when the tool runs.

**`G(77)` and `R(131)` are a different class and are `record, do not chase`.**
They are `file:line` citations whose line numbers rot. `records/baseline-alignment.md`
BA-20, BA-21 and BA-22 already hold this class, and the structural fix is the
stable address, P4 in `docs/arcs/text-tools-arc.md`, which is `UNASSIGNED`.
Repointing 208 line numbers by hand is undone by the next insertion above them.

### 5. `records/baseline-alignment.md` has 31 open rows

Read before adding: a finding may already be there. The three newest are
**BA-39** (E173's mutant M3 asserted a termination refusal the compiler could not
make — its cause is now fixed by `aedf555`, so the row is a candidate for
FIXED once someone verifies it), **BA-40** (`prose-lint.sh` carries two divergent
check sets, `_scan` at `:95-104` with ten checks against `cmd_lines` at `:164`
missing `parallel-no` plus four branches), and **BA-41** (a guard over two
let-bound `I64`s leaves an obligation nothing discharges).

## Blocked on the author, do not work around

- **A reserved element block.** Five arcs and the three drafted local-ai arcs
  cannot mint. `records/author-calls.md` holds it.
- **Python inside or outside the tree.** Gates the local-ai tuning arc.
- **The promotion.** Two compiler changes are unpromoted with verified
  fixpoints. Not a doc concern, listed so you do not trip on the blob size
  changing under you.
