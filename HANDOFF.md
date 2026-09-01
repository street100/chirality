# chirality: handoff

Start here. This file is a **router**. It says where a session starts and what
is live. It holds no arc detail: that moved into `docs/` on 2026-09-01.

`MAP.md` is the contract (tree, extensions, module key, doc roles).

## The three tiers

| tier | unit | home |
|---|---|---|
| goal | a broad thing this project claims it is doing | `docs/goals/` |
| arc | the elements assembled toward one goal, with requirements and resume state | `docs/arcs/` |
| element | one catalog item, an `E#` | `docs/elements/`, `docs/elements/catalog.md` |

Hubs: `docs/goals/README.md` and `docs/arcs/README.md`. Both are tracked, which
`.planning/` is not.

## Live arcs

| arc | goal | resume from |
|---|---|---|
| diagnostics and formatting | self-tooling | `docs/arcs/diagnostics-arc.md`, record beside it |
| enforcement | enforcement | `docs/arcs/enforcement-arc.md` |
| file types | self-tooling | `docs/arcs/file-types-arc.md` |
| zero Python | self-tooling | `docs/arcs/zero-python-arc.md` |
| baseline alignment | honest claims | `docs/arcs/baseline-alignment-arc.md` |
| the binary split | **UNWRITTEN** | `docs/arcs/binary-split-arc.md` |

One stated goal has no arc at all: `docs/goals/independent-judgment.md`.

## What moved on 2026-09-01

Root carried roughly 55K of arc state. It moved into `docs/`, with `git mv` so
history follows.

| was | is |
|---|---|
| `HANDOFF-DIAGNOSTICS-ARC.md` | `records/diagnostics-arc-record.md` |
| `docs/elements/diagnostics-arc.md` | `docs/arcs/diagnostics-arc.md` |
| `docs/elements/enforcement-arc.md` | `docs/arcs/enforcement-arc.md` |

`HANDOFF-LANE-A.md` and `LANES.md` did not move. Both are open in a live
session.

## How to work here

**Read `LANES.md` first.** The work is split into two lanes with their own
element bands (A: E184-E189, B: E190-E195), gate phases and file ownership.
Lane A is diagnostics and errors and resumes from `HANDOFF-LANE-A.md`. Lane B is
file types. Minting outside your band collides; two sessions already minted
`E173` independently.

**Another agent shares this repo.** Two lanes run in the same working tree.

- **Serial dispatch: exactly ONE subagent at a time.** Standing user directive.
  Launch one, wait, merge, launch the next.
- **The main session dispatches; it does not implement.** Hold the queue, write
  the prompt, verify what returns. That includes troubleshooting: when an agent
  fails, re-dispatch it with what it learned.
- **Pathspec every commit** (`git commit -- <paths>`). A bare commit sweeps the
  other agent's staged work. That happened twice on 2026-08-31.
- **Verify what an agent returns before keeping it.** One scored a file to zero
  findings by inserting the word "but" six times. Another byte-compared a file to
  itself and reported it identical.

## Where a finding goes: `records/`

A defect found mid-task, outside your own task, goes in a checklist row. A commit
message loses it. `records/README.md` states the format, the four states,
and the rules. Any agent may edit a checklist without asking.

`records/baseline-alignment.md` holds what this repo claims about itself
beside what was measured. It has no reserved element block; rows needing one
carry `UNASSIGNED`.

## Where it is

A working, self-hosting language. The migration out of `/workspace/metis-the-lang`
is complete; that tree is reference only.

| | |
|---|---|
| source | 299 files under `lib/` and `prog/`, measured 2026-09-01 after the C-backend drop |
| compiler | `bin/chirality-bin`, 1,147,256 B, committed. E181 promoted it 2026-09-01 |
| resolver | `bin/chirality-resolve.sh` plus `lib/module/resolve.chiral`, a matched pair |
| tests | `bin/chirality test`, 303 assertions, 0 failed, 11 phases, 87 roots, gate PASSED |
| record | `.planning/MIGRATION-MAP.tsv`, 869 rows; `tools/test/map-integrity.sh` checks every `new_path` exists |
| lint | `python3 tools/ledger-lint/ledger-lint.py`, 19 checks. Failing checks and their reasons are rows in `records/baseline-alignment.md` |
| licence | AGPL-3.0-or-later plus `LICENSE.EXCEPTION.md`; `docs/decisions/decision-license.md` |
| python | 14 files, 4,654 LOC, re-measured 2026-08-31. Target is zero, absolute |

### Measured, and re-runnable

- **Fixpoint** verified at 1,147,256 B after E181's promotion, `N1 == N2` at
  generation one. Check each artifact non-empty before the `cmp`.
- **The compiler's import closure is 59 modules, 16,463 LOC**, out of `lib/`'s
  103 and 25,559. 1,680 LOC of checking machinery sits outside it, including
  `lowering/tal/check`, `typing/effects` and `typing/totality`.
- **A `native-lib` change must be verified at GEN3.**
  `lib/lowering/compile-emit.chiral:295` prepends the compiler's own compiled-in
  runtime to every image, so gen1 and gen2 compiling proves nothing. This cost
  one wrong fix on 2026-08-31.
- 1,025 import sites, 0 unresolved.
- The 5 unported phases print every run with their reason.

## Decisions (do not re-litigate without reading these)

`MAP.md` carries the tree contract: extension is the kind, directory is the role,
the module key is the root-relative path, importability is the partition,
`.manifest` is declared rather than sniffed, and `ports/` holds declarations
only. `PRINCIPLES.md` §3 is why that last one is a rule rather than taste.

Beyond `MAP.md`:

1. **External judgment is cut** (Rocq, CompCert, the Python oracle). The
   replacement is `docs/goals/independent-judgment.md`, and it is unbuilt. The
   `Mach`-to-C backend went with it on 2026-09-01 (`d8bcec5`, `d0c5dd5`).
2. **`bin/chirality-bin` is committed**, with the tree and harness that rebuild
   it. Build-new, test, promote. Nothing replaces itself in place.
3. **The four rungs measure reach rather than substrate.** SEEDED means nothing
   calls it, IMPLEMENTED means reached and ungated, ENFORCED means gated.

## SCOPE, set by the author 2026-08-31: self-hosting only

The ownership and trust model is a separate track, deferred:
`docs/goals/ownership-and-trust.md`. Do not pull any of it into current work,
and do not audit its documents.

## Still blocked on the author, in scope

| | |
|---|---|
| Principle 1 has no Honest limit | The broadest claim in the file, the only one without one |
| P5's present tense | "a split value whose only exit is a guarded combine-process": CONFORMANCE-MAP calls it vapor beyond the seed |
| P3 vs open-edges | P3's limit says the membrane's inward reach is open; `open-edges` records it largely answered |
| `decision-split-checker` | `status: draft`, while PRINCIPLES states its content settled |
| what a `docs/elements/` file holds | one file per element, one per band, or a tracked index. `docs/elements/README.md` states the fork |
| `LANES.md`'s home | it sits at root and is orthogonal to the goal-arc-element tiers. Left at root because two live sessions read it |
| the binary split's goal | `docs/arcs/binary-split-arc.md` ladders up to nothing written down |

## Findings on disk, none actioned

`.planning/FINDING-*.md`: the datum-model write adversary, the `let`-bound case
refinement, the ports role, `str-sub` range.

The `let`-bound case one is the sharpest. The join hypothesis is **refuted**:
the verdict depends on source arm order and a join is commutative, so it is
first-arm-wins. Refusal at `kernel.chiral:1440`. `let` is the trigger because
`check-let` (`kernel.chiral:983`) is the only construct that drops into infer
mode. Fix (b), widening, is unsound, and the finding carries the counterexample.
Three coherent shapes remain, so it needs a blueprint: run the pipeline, mint the
element in the change that fixes it. Next free element number is **E185**.

## Owed, with no arc

- **Audit queue**, `.planning/DOC-AUDIT-QUEUE.md`. Done: PRINCIPLES,
  status-ledger. Next: MAP, LAYOUT, README, HANDOFF, then the design base.
- **Prose cleanup**: PRINCIPLES 24, MAP 15, LAYOUT 7, PERSONA 6.
  `tools/prose-lint/prose-lint.sh --regress` holds the baseline.
- **Phases 9 and 12**: fixtures landed in slice 8, the phase scripts are owed.
- **`prog/climb.manifest` is misfiled.** `prog/` is deliverable programs, climb
  is data, and nothing imports it. Same class as the `ports/` fix.
- **`make-public`** for the new remote.
- **`lib/typing/effects.chiral:1-6` still says "effects.py stays the oracle."**
  The oracle is cut.
- **~40 `docs/examples/E*.md` carry `ours_source: scaffold/…`** paths that no
  longer exist. Frozen-rationale tier, so a bulk rewrite is its own call.
- **`op->symop` falls through to `s-ne` for any unrecognized token**, so `!=` is
  never refused and silently reads as `<>`.
- **`docs/elements/ledger.md:86` files E11 as `built`** while its classifier is
  imported by nothing. `:95` (E12) and `:103` (E171) cite paths that are gone.
- **`.planning/USER-LAYER-GAP.md` §6** names four pre-rename tool scripts and LOC
  counts against live ones, and a total that no longer measures.
