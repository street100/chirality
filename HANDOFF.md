# chirality: handoff

**Rewritten 2026-08-31, end of the second session.** Start here. `MAP.md` is
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
| lint | `python3 tools/ledger-lint/ledger-lint.py` → **exits 1**, 19 checks (H and M VACUOUS by decision). The one FAIL is check I: `docs/definitions/FRONTIER.md` is stale because `frontier.py:62` globs `docs/decisions/decision-*.md` and the other agent's untracked note is in that glob. Do **not** run `frontier condense` to clear it; that bakes their in-flight file into the digest. It clears when their work lands |
| licence | **AGPL-3.0-or-later** + `LICENSE.EXCEPTION.md`; `docs/decisions/decision-license.md` |
| python | 14 files / 4,654 LOC, re-measured 2026-08-31. Target is zero, **absolute** (author call this session). `.planning/ZERO-PYTHON-SCOPE.md` |

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

## ⚑ SCOPE, set by the author 2026-08-31: self-hosting only

The ownership and trust model is a **separate track, deferred**: the
re-bootstrap climb, DDC, the secure datum model, the register root, the cascade.
Do not pull any of it into current work, and do not audit its documents. What is
in scope is the language compiling and checking itself, and being good enough to
write its own tooling (zero Python).

## Answered this session, no longer blocking

| | |
|---|---|
| `refs/gen-*.py`, 502 LOC | **Zero Python is absolute.** Not "zero Python chirality is built from". Drop everything not required, then catalog what must be built to replace the rest with chirality forms. Renaming to `.py.txt` was rejected as a dodge. ⚑ These four are sliced into pipeline bundles by `pack` as the OURS baselines, so deleting them costs four worked examples their comparison. Decide that before the deletion |
| the hash shape | **A small pure function**, a deterministic digest over `bget`. No element, no ledger row. The LEDGER's CRY category stays reserved and empty |

## Deferred with the ownership model, not answered

| | |
|---|---|
| datum model threat split | DMA **write** is in scope and CPU code execution is out; on no-IOMMU hardware write subsumes execution. Ownership track |
| two bootstrap documents | `docs/definitions/bootstrap.md` (106 L) is the re-bootstrap climb; `bootstrap-sequence.md` (55 L) is the runtime on-ramp and says of itself "nothing here is built yet". Verified as **two unrelated concepts sharing a word**. Both ownership track. ⚑ `bootstrap.md` cites three paths that are all stale post-hoist: `scaffold/lib/climb.chiral`, `examples/refs/`, and `docs/tal-spec.md` (four times, as "the golden object"; it is `docs/definitions/tal-spec.md`) |

## Still blocked on the author, in scope

| | |
|---|---|
| Principle 1 has no Honest limit | The broadest claim in the file, the only one without one |
| P5's present tense | "a split value whose only exit is a guarded combine-process" : CONFORMANCE-MAP calls it vapor beyond the seed |
| P3 vs open-edges | P3's limit says the membrane's inward reach is open; `open-edges` records it largely answered |
| `decision-split-checker` | `status: draft`, while PRINCIPLES states its content settled |

## Queue: dispatchable, one agent at a time

1. **`let`-bound case, diagnosed 2026-08-31. The join hypothesis is REFUTED.**
   There is no join: the verdict depends on **source arm order**, and a join is
   commutative. It is first-arm-wins. A branch-local assumption from the narrow
   hook escapes as the case's inferred result type, and later arms must entail an
   assumption false in them. Refusal at `kernel.chiral:1440`. `let` is the trigger
   because `check-let` (`kernel.chiral:983`) is the only construct that drops into
   infer mode. **Fix (b), widening, is unsound** and the finding carries the
   counterexample. Three coherent shapes remain, so this **needs a blueprint**:
   run the pipeline, mint the element in the change that fixes it. ⚑ **E174 is not free** — it has a worked example (`r-row-width`), as do E175 and E181. Highest artifact anywhere is E181, so next free is **E182**.
   `.planning/FINDING-let-bound-case-refinement-2026-08-31.md`
2. **`str-sub`'s second half.** `end > len` reads past the buffer.
   ⚑ `str-starts-with` currently depends on that read returning differing bytes.
3. ~~Three ROUND-OFF OWED flags in `status-ledger`.~~ **Discharged 2026-08-31**
   (`16f939a`), all three verified by grep first. E171 re-scoped: the seams are
   already in the tree and already generalized, so what it owes is the **caller**.
   Termination is **SEEDED**, a built classifier nothing imports; wiring it is
   E11's remaining work. Secret custody type-checks and lowers with no referent,
   the same shape as `http-request` and `backend-open`.
4. **Zero-python**, sized per file in `.planning/ZERO-PYTHON-SCOPE.md`. The order
   is forced by the measurement: **E173 matcher** (141 sites, 13 of 14 files),
   then **E148** `getdents64` (22), then **E150** argv (20).
   ⚑ **Wave 0 is NOT done**, contrary to what this file said before. Wave 0 is
   two files. `prog/paren-audit.prog` exists but `tools/paren-audit/paren-audit.py`
   is still on disk at 154 LOC and their equivalence is **unverified**;
   `tools/scriba-run-smoke/scriba-run-smoke.py` (51 LOC) was never ported at all.
   `prose-lint` had no `.py` left to replace, so citing it as wave-0 evidence
   inflated the claim. E173 has a drafted worked example
   (`docs/examples/E173-total-matcher.md`), audit gate not yet run.
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
- **`lib/typing/effects.chiral:1-6` still says "effects.py stays the oracle."**
  The oracle is CUT. `lib/` was off-limits during the round-off pass because the
  other agent holds the resolver; fix it on the next `lib/` slice.
- **`.planning/LEDGER.md:86` files E11 as `built`** while its classifier is
  imported by nothing. `:95` (E12) and `:103` (E171) still cite
  `scaffold/chirality/effects.py` and `scaffold/lib/effects.chiral`.
- **~40 `docs/examples/E*.md` carry `ours_source: scaffold/…`** paths that no
  longer exist. Frozen-rationale tier, so a bulk rewrite is its own call.
- **`.planning/USER-LAYER-GAP.md` §6** names four pre-rename tool scripts and
  LOC counts (1033/650/636/619/313) against live (1128/651/831/620/330), and a
  total of "3,251 L of Python" against a measured 4,654.
- **`ledger-lint` check H is VACUOUS** because it verified `_CHEATSHEET.md`
  against the deleted `refine.py`. After the 2026-08-31 cheatsheet repoint it can
  aim at `lib/typing/refine.chiral:11` and `lib/module/loader.chiral:20`, both
  live. That is a measured repoint rather than a guess, so it is now allowed.
- **`op->symop` falls through to `s-ne` for any unrecognized token**, so `!=` is
  never refused; it silently reads as `<>`. Measured during the cheatsheet fix.
- **`CLAUDE.md`'s ⚑ saying `ledger-lint` is "partly blocked, 7 of 14 inputs are
  path mismatches" is stale.** That repoint landed; the mismatch count is 0. The
  file is gitignored, so fix it in place.
