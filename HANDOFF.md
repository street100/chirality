# chirality: handoff

**Rewritten 2026-08-31, end of the second session.** Start here. `LAYOUT.md` is
the contract (tree, extensions, module key, doc roles); this file is state and route.

## ⚑ How to work here, before anything else

**Another agent shares this repo.** Two lanes run in the same working tree.

- **Serial dispatch: exactly ONE subagent at a time.** Standing user directive.
  Not a batch. Launch one, wait, merge, launch the next.
- **The main session dispatches; it does not implement.** Hold the queue, write
  the prompt, verify what returns. Doing the work inline is the failure mode, and
  that includes troubleshooting: when an agent fails, re-dispatch it with what it
  learned rather than finishing the job yourself.
- **Pathspec every commit** (`git commit -- <paths>`). A bare commit sweeps the
  other agent's staged work. That happened twice on 2026-08-31.
- **Verify what an agent returns before keeping it.** One scored a file to zero
  findings by inserting the word "but" six times. Another byte-compared a file to
  itself and reported it identical.
- Theirs right now: `bin/chirality-resolve.sh` (resolver caching),
  `docs/decisions/decision-self-verification.md`.

## Where it is

A working, self-hosting language. The migration out of `/workspace/metis-the-lang`
is **complete**; that tree is reference only now.

| | |
|---|---|
| source | 301 files (`.chiral` 193 · `.prog` 97 · `.port` 9 · `.manifest` 2) |
| compiler | `bin/chirality-bin`, 1,102,200 B, committed |
| resolver | `bin/chirality-resolve.sh` + `lib/module/resolve.chiral`, a matched pair |
| tests | `bin/chirality test` → **118 assertions, 0 failed**, 86 compile-only roots; 7 of 12 old phases + Phase 13 (E157) |
| fixtures | `tools/test/samples/` 98 files |
| docs | 230, sorted by role; `.planning/` 259, **untracked by design** |
| record | `.planning/MIGRATION-MAP.tsv`, 869 rows; `tools/test/map-integrity.sh` checks every `new_path` exists |
| lint | `python3 tools/ledger-lint/ledger-lint.py` → **clean**, 19 checks (H and M VACUOUS by decision) |
| licence | **AGPL-3.0-or-later** + `LICENSE.EXCEPTION.md`; `docs/decisions/decision-license.md` |
| python | 14 files / 4,629 LOC. Target is zero. `.planning/ZERO-PYTHON-SCOPE.md` |

### Verified, not asserted

- **Fixpoint**: gen2 == gen3 at 1,102,200 B, and a rebuild is byte-identical to
  the committed binary. ⚑ Check each artifact non-empty before the `cmp`.
- ⚑ **A `native-lib` change must be verified at GEN3.** `compile-emit.chiral:295`
  prepends the compiler's own compiled-in runtime to every image, so gen1 and gen2
  compiling proves nothing. This cost one wrong fix on 2026-08-31.
- 1,025 import sites, 0 unresolved.
- The 5 unported phases print every run with their reason.
- `ledger-lint` names two checks **VACUOUS** rather than ok: their subjects are
  gone (the Python oracle; the `scaffold/lib`-to-`TUI` symlink web).

## Decisions (do not re-litigate without reading these)

1. **Extension = kind, directory = role, subject matter in neither.**
2. **Module key = the root-relative path** under `lib:` or `prog:`.
3. **Importability is the partition.** `.prog` and `.profile` are not import
   targets, so the resolver probes three extensions.
4. **`.manifest` is declared, not sniffed.** E163, unbuilt.
5. **External judgment is cut** (Rocq, CompCert, the Python oracle). Replaced by
   three **semantically distinct** judgment cores that must agree: different
   formulations, not three encodings of one rule set. **Still unbuilt**, so every
   rung in `status-ledger` is enforcement against error, not against an adversary.
6. **`bin/chirality-bin` is committed**, with the tree and harness that rebuild it.
7. **`ports/` holds declarations, not code about ports.** A file belongs there iff
   it declares a crossing. Three modules left on 2026-08-31.
8. **Programming here is coordinating port boundaries and writing the logic that
   produces their inputs** (PRINCIPLES §3). This makes 7 a rule rather than taste.
9. **The four rungs measure reach, not substrate**: SEEDED = nothing calls it,
   IMPLEMENTED = reached but ungated, ENFORCED = gated.

## Blocked on the author: these do not move without an answer

| | |
|---|---|
| datum model threat split | DMA **write** is in scope and CPU code execution is out; on no-IOMMU hardware write subsumes execution. The read-only half is sound and needs nothing |
| two bootstrap documents | `docs/definitions/bootstrap.md` (106 L, the four-stage climb) and `bootstrap-sequence.md` (55 L). One concept or two? Auditing either is wasted first |
| `refs/gen-*.py`, 502 LOC | The OURS baselines. Their function is to **not** be chirality. Porting destroys them; deleting leaves four examples with no comparison. Two of four are executed, not just read |
| the hash shape | `frontier` needs staleness detection, `scriba-edit-smoke` digests screen state. Neither needs collision resistance. A few lines over `bget`, or a real element? |
| Principle 1 has no Honest limit | The broadest claim in the file, the only one without one |
| P5's present tense | "a split value whose only exit is a guarded combine-process" : CONFORMANCE-MAP calls it vapor beyond the seed |
| P3 vs open-edges | P3's limit says the membrane's inward reach is open; `open-edges` records it largely answered |
| `decision-split-checker` | `status: draft`, while PRINCIPLES states its content settled |

## Queue: dispatchable, one agent at a time

1. **`let`-bound case join.** `(let (m (case (<i a b) (true a) (false b))) m)` is
   refused, so `min` is unwritable if you name the result. Fix the join, or widen
   the bound result to the declared type. Plus `jg-refine-unproved` reports no
   term, no line and no refinement.
   `.planning/FINDING-let-bound-case-refinement-2026-08-31.md`
2. **`str-sub`'s second half.** `end > len` reads past the buffer.
   ⚑ `str-starts-with` currently depends on that read returning differing bytes.
3. **Three ROUND-OFF OWED flags** in `status-ledger`: E171 re-scoped against a
   floor that no longer exists · totality must wire termination or drop its third
   pillar · secret custody says "runs" and only type-checks.
4. **Zero-python**, sized per file in `.planning/ZERO-PYTHON-SCOPE.md`. The order
   is forced by the measurement: **E173 matcher** (141 sites, 13 of 14 files),
   then **E148** `getdents64` (22), then **E150** argv (20). Wave 0 is done:
   `prog/prose-lint.prog` and `prog/paren-audit.prog` replace their Python.
5. **Audit queue**, `.planning/DOC-AUDIT-QUEUE.md`. Done: PRINCIPLES, status-ledger.
   Next: MAP, LAYOUT, README, HANDOFF, then the design base.
6. **E158 into E146**, the pretty-printer chain. Untouched all session.
7. Prose cleanup: `PRINCIPLES` 24 · `MAP` 15 · `LAYOUT` 7 · `PERSONA` 6.
   `tools/prose-lint/prose-lint.sh --regress` holds the baseline.
8. Phases 9 and 12: fixtures landed in slice 8, the phase **scripts** are owed.
9. `prog/climb.manifest` is misfiled: `prog/` is deliverable programs, climb is
   data, and nothing imports it. Same class as the `ports/` fix.
10. `make-public` for the new remote.

## Findings on disk, none actioned

`.planning/FINDING-*.md`: the datum-model write adversary · the `let`-bound case
refinement · the ports role, `str-sub` range, whose inverted half is FIXED and
whose `j > len` half is open · two carried from the old tree (captured closures, mutual data).

## Known-wrong, small

- `syscall-map` reports `BUILT: 0`. Its regex says `TFn` where the defs say
  `TIFn`; 180 occurrences invisible. Fixing it changes what the tool measures.
- `prog/prose-lint.prog` is missing `not-but`, `parallel-no` and code-skipping,
  and **prints them as NOT-CHECKED every run**. They want E173.
