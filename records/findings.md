---
node: records-findings
layer: navigation
related: [records/README, status-ledger, bug-classes, open-edges, index]
status: current
updated: 2026-09-05
---

# Findings

Dated investigations that belong to no single arc. Row format, states and the
rules for adding, changing and retiring a row are in [[records/README]]. Prefix
is `FD`.

Every row here was a `.planning/FINDING-*.md` file, written into a gitignored
directory where a second reader could not find it. The investigation itself is
long-form and stays where it is written; the row is the part that survives a
fresh clone. `evidence:` names the investigation file **and** the live tree
spans, because the investigation is untracked and the tree is not.

⚑ Two of these investigations cite `scaffold/` paths and Python modules that the
migration evicted. Where that is so, the row says it, and the `measured:` line
carries a span in the live tree instead. A citation nobody can open is not
evidence.

## Compiler defects found while building tools

### FD-01 `str-sub` clamps, says a load-bearing comment

- state:    OPEN
- claim:    `lib/prelude/string.chiral:14` says "str-sub clamps, so a too-long prefix is just false", and `str-starts-with` is written to depend on it.
- measured: two range cases were unguarded. `end < start` computed a negative length, reached the allocator and killed the process (`(str-len (str-sub "abc" 2 1))`, SIGSEGV, exit 139). `end > len` did not clamp: `(str-len (str-sub "abc" 0 99))` returned 99, a `Str` of length 99 over a 3-byte buffer, 96 bytes of adjacent memory, no error and no truncation. The inverted-range half was FIXED 2026-08-31: `nb-bslice-t` clamps an inverted range to the empty slice, fixpoint held at gen2==gen3 at 1,102,200 B and the promoted binary rebuilt byte-identically. **The `end > len` half is untouched**, so the cited comment is still false and `str-starts-with` still depends on a read past the buffer returning differing bytes. That is why this row is OPEN and not FIXED.
- evidence: `lib/prelude/string.chiral:14-17`, `lib/lowering/tal/erase.chiral:114`, `lib/lowering/tal/bytes.chiral` (`nb-bslice`, `nb-bslice-t`), `.planning/FINDING-str-sub-range-2026-08-31.md`
- checked:  2026-09-01
- element:  UNASSIGNED

### FD-02 a `let` over a `case` on a computed comparison cannot be proven

- state:    OPEN
- claim:    refinement checking accepts a two-line minimum function. Found porting `tools/paren-audit/paren-audit.py` to `prog/paren-audit.prog`, which needed one and could not have one.
- measured: `(let (m (case (<i a b) (true a) (false b))) m)` fails with "cannot prove refinement". The trigger needs all four at once: a `case`, a **computed** comparison as scrutinee rather than a `Bool` that arrived as a variable, arms returning **bound variables** rather than literals, and a `let`-bound result rather than a direct return. Any one of the four removed and it passes. `cond` fails identically, as expected, since it desugars to `case`. The first hypothesis in the investigation was REFUTED by its own diagnosis section; the mechanism is recorded there. Three coherent fixes exist and they differ in what they preserve, so this needs a blueprint rather than a patch.
- measured (diagnostic half): the *message* cannot be improved cheaply either. No `Reason` arm fits, and adding one costs an arm in all seven exhaustive `case`s over `Reason` in `diag.chiral` (there is deliberately no `_`). Nothing in the tree can print a surface `Term`: `dg-mismatch-msg` is `(lam (w) "type mismatch")`, E158 has zero code in `lib/` or `prog/`, and `lib/typing/pretty.chiral` declares its own private 5-former `Term` and has no importers. Binder names are gone from `Ctx`. The one cheap real improvement is splitting `jg-refine-unproved` into two arms, because `kernel.chiral:1439-1440` collapses two different refusals into one string.
- evidence: `lib/typing/kernel.chiral:1439-1440`, `lib/typing/diag.chiral:20-25`, `:314-315`, `:346`, `lib/typing/pretty.chiral:15-20`, `prog/paren-audit.prog`, `.planning/FINDING-let-bound-case-refinement-2026-08-31.md`
- checked:  2026-09-01
- element:  UNASSIGNED

## Refuted premises

### FD-03 the closure refusal is about a bare lambda, not about capture

- state:    OPEN
- claim:    `.planning/USER-LAYER-GAP.md` §10 records "k>=1, real capture -> REFUSED" and reads it as a language limitation: captured closures in a record do not lower.
- measured: REFUTED in both directions by a single fixture pair. A fixture with **zero** captures and a bare `(lam ...)` written directly in a data-constructor argument position is refused; the same lambda with the same captures wrapped in `(the (-> ...) ...)` lowers, runs and exits 0, as does a call that returns a closure. The discriminator is purely syntactic: a bare `(lam ...)` in constructor position is never registered as a closure-conversion site. A second, independent limitation is real and separate: the closure-returning projector shape works at one instance and fails at two, exactly as `specialize-singleton.chiral` documents. **Nothing has been applied.** The run's write surface was the finding plus fixtures under a `scaffold/tests/samples/_wip/` path the migration has since evicted, so the fixtures are gone and §10 still carries the wrong table.
- evidence: `lib/lowering/upper/closconv.chiral`, `lib/lowering/upper/specialize-singleton.chiral`, `.planning/FINDING-captured-closures-2026-08-30.md` (§0, §1.3, §6), `.planning/USER-LAYER-GAP.md` §10
- checked:  2026-09-01
- element:  UNASSIGNED

### FD-04 mutually-recursive `data` types are built, not missing

- state:    FIXED
- claim:    the 2026-07-31 finding says chirality's surface elaborator cannot express mutually-recursive `data` types and calls it an unbuilt prerequisite for the self-hosted checker.
- measured: built. It landed 2026-08-01 as E79 and it is chirality today, not the Python it was written against: `lib/surface/parse.chiral:1319-1446` is the data-group phase, registering every data name before any field is elaborated, and `diag.chiral` carries the `rl-parse` reason arm for it. Two deltas from the recommendation as written are recorded in the finding: plain forward (DAG) references are supported too, subsumed by SCC-topo processing at no cost, and termination needed no change because the structural token chain is type-agnostic. Strict positivity is still refused, by design, with its own judgment (`jg-not-positive`). The finding's own citations (`surface.py`, `data.py`, `scaffold/`) are all dead paths.
- evidence: `lib/surface/parse.chiral:632`, `:1319-1322`, `:1446`, `lib/typing/diag.chiral:73`, `:111`, `:469`, `.planning/archive/FINDING-mutual-data-2026-07-31.md`
- checked:  2026-09-01
- element:  E79

## Structure and doctrine

### FD-05 `ports/` named a property that is universal

- state:    FIXED
- claim:    `MAP.md` said `ports/` is "the crossings themselves". Four `.chiral` files sat there and none of them was one.
- measured: the mechanical half landed. `MAP.md:58-90` now states the test structurally: a file belongs in `ports/` iff it **declares** a crossing, an `extern` bound at link time or a `porttype` minting an opaque linear atom. Being *about* ports does not qualify. The three files moved to the directory their own importers already named: `crossing-wraps` to `lib/lowering/tal/`, `inet` and `term` to `lib/protocol/`. `ports/ports.chiral` stays as the façade over the nine `.port` registries. Confirmed by `ls lib/ports/`: nine `.port` files and `ports.chiral`, nothing else. ⚑ `MAP.md:86` states plainly that nothing checks this and that prose is how the three got there.
- evidence: `MAP.md:58-90`, `lib/ports/`, `lib/lowering/tal/crossing-wraps.chiral`, `lib/protocol/inet.chiral`, `lib/protocol/term.chiral`, `.planning/FINDING-ports-role-2026-08-31.md`
- checked:  2026-09-01
- element:  none

### FD-06 whether to condense the five principles to "everything is a port boundary"

- state:    OPEN
- claim:    the same finding proposes the boundary, not the process, as the atom, and shows each of P1-P5 reading as a case of it.
- measured: undecided, and author-tier by the finding's own statement. The test it has to pass is `CLAUDE.md`'s own: an abstraction that does not constrain is overhead, and "everything is X" forbids nothing by itself. One concrete thing it decides is already banked as FD-05, which is evidence it is not vacuous but is only one. The finding says nothing here should be edited into `PRINCIPLES.md` before the call, and names the 2026-07-20 seven-to-five pass as the precedent for how. Separately: the author's note that `PRINCIPLES.md` has more problems than audit 1 surfaced is taken and there is no queue entry for that second kind of pass.
- evidence: `PRINCIPLES.md`, `.planning/FINDING-ports-role-2026-08-31.md` (§"The principle question", §"Not the whole audit"), `.planning/DOC-AUDIT-QUEUE.md`
- checked:  2026-09-01
- element:  none

### FD-07 the secure-datum model's threat split is drawn in the wrong place

- state:    OPEN
- claim:    `docs/definitions/secure-datum-model.md` §2 puts peripheral DMA **write** (tamper, replay/rollback) in scope and CPU code execution out of scope, and §1 says the register root "is unreachable by the threat".
- measured: on the stated hardware (no TPM, no IOMMU relied on) DMA write is arbitrary physical memory write, which is a routine path to CPU code execution: overwrite kernel text, a function pointer or a page-table entry. PCILeech, which §2 names as the in-scope tool, ships kernel implants that do exactly this. So the out-of-scope list is a consequence of a power the model grants rather than a power the attacker lacks, and the document's own §1 supplies the verdict, that N layers sharing one dependency collapse to one. What survives intact is the whole model against a **read-only** DMA adversary, the evil-maid and Thunderbolt-snapshot case: register root, derive-not-store, the interrupt-disabled window and every §4 confidentiality multiplier are sound there. Three edits are owed and none applied: split §2 into A_read and A_write with a guarantee per half, move write/tamper/rollback out of the confidentiality stack into an integrity section whose verb is *detect*, and say that A_write requires the IOMMU the document lists as optional.
- evidence: `docs/definitions/secure-datum-model.md` §1, §2, §4, `.planning/FINDING-datum-model-write-adversary-2026-08-31.md`
- checked:  2026-09-01
- element:  none. Document-tier, not an element. If the split becomes a language obligation, that mints a row.

⚑ FD-07 is on the ownership-and-trust track, which is [[goals/ownership-and-trust]],
deferred out of scope for *work* on 2026-08-31. The row is here because the
document is in the reader-facing tier and is wrong today. Deferred is not deleted:
`.planning/FINDING-datum-model-write-adversary-2026-08-31.md` stays where it is.

## The committed compiler

### FD-08 the shipped binary trails its sources by one generation

- state:    FIXED
- claim:    the build rule requires `build-new -> test -> promote`, and `docs/decisions/decision-lane-split.md:112-116` makes a precondition of it: on the unmodified tree `B1(blob)` must already equal `bin/chirality-bin`, so a staleness inherited from a merge is caught as a merge's and not blamed on the element promoting next. The arc file records that precondition passing for E181 on 2026-09-01.
- measured: it does not hold on master at `3be8915`, and the reason is ordinary rather than a defect. The tree reproduces itself at generation two. Blob 804,277 B. `bin/chirality-bin` is 1,147,256 B and was last promoted at `58603c3` (E181, 2026-09-01). `B1 = bin/chirality-bin(blob)` is 1,184,120 B and differs from the shipped binary at char 98. `B1 != B2`, differing at char 1,180,606; `B2 == B3`, so the tree reaches a fixpoint at generation two rather than generation one. Every artifact was checked non-empty before its `cmp`. 13 commits have touched `lib/` or `prog/` since that promotion, spanning three arcs (`aedf555` E11, `13a1362`-`e882568` E173, `7341ddf` ports, `d8bcec5` the C backend drop), so the lag belongs to no one element. `B1 != B2` is the expected two-generation bootstrap: `7341ddf` made the arena counter readable by a compiled program, which changes emitted code, so the old binary does not emit that body and `B1` does. Convergence at `B2 == B3` is the fixpoint. Nothing here is broken. The one consequence that survives is attribution: an element promoting from this base reports blob and binary deltas that carry 13 commits of other arcs' work, so it either promotes once beforehand or reports the two deltas separately. E182 is the next such element. ⚑ **FIXED 2026-09-02 at `4047a66`, and the side that moved is the tree.** E182 entered the closure and promoted. Its commit 3 (`e42d3af`) shipped generation one while measuring the fixpoint at generation two, which would have re-created this condition deliberately rather than inheriting it; commit 3b promoted the fixpoint instead. Verified independently on the unmodified tree afterwards: blob 806,827 B, `B1` 1,188,216 B, `cmp B1 bin/chirality-bin` **EQUAL**. The precondition at `docs/decisions/decision-lane-split.md:112-116` holds for the first time since E181. The inherited `1,147,256 → 1,184,120` is now folded into a shipped binary that reproduces itself, so the next element in the closure separates its own delta with a single `cmp`.
- evidence: `docs/definitions/working-discipline.md:19-42`, `docs/decisions/decision-lane-split.md:105-119`, `docs/arcs/diagnostics-arc.md:68`, `records/diagnostics-arc-record.md:162-164`, `git log 58603c3..HEAD -- lib prog`
- checked:  2026-09-02
- element:  E182, whose promotion at `4047a66` fixed it

## The judgment

### FD-09 the demanded statement is prose, and the judgment's decomposition is unreached

- state:    OPEN
- claim:    [[certificate-discipline]] states that a certificate's one surviving vacuity is whether the demanded statement is meaningful, and pins it by fixing that statement at the socket as part of the small audited spec, so vacuity "lives in exactly one place ... one small thing audited once". [[decisions/decision-split-checker]] names `kernel-spec` as "the type theory as a small, human-audited requirement type" and one of the three parts the checker splits into.
- measured: the statement is a `Str`. `(data SpecRule () (spec-rule (form JForm) (name Str) (statement Str)))`, so the artifact the whole scheme's non-vacuity rests on is unstructured prose, and nothing can check it says anything. The decomposition beside it is unreached: the six `JForm` constructors (`j-check`, `j-infer`, `j-conv`, `j-usage`, `j-data`, `j-membrane`) have **one use each**, their own declaration line; `JForm` 2, `SpecRule` 2, `Spec` 3. No file imports `typing/kernel-core`; the only mention of it anywhere in `lib`, `prog`, `tools` or `bin` is a comment at `reflect-floor.chiral:16` calling it work the port "must carry". It compiles clean standalone (`chirality check` exits 0) and no suite phase runs it, so `recheck` has never been executed against a populated `Spec`. Two live checking concerns have no `JForm` at all: totality (`typing/totality.chiral`, `typing/totality-check.chiral`) is presumably folded into `j-data` and nothing says so, and refinement (`typing/refine.chiral`, `t-refine` at 29 uses across 7 modules) has no form. `docs/arcs/independent-judgment-arc.md` already records the module as "written, unreached" and row `J2` owns wiring it; what is new here is that the statement is prose and that the form set is both inert and incomplete.
- evidence: `lib/typing/kernel-core.chiral:27-29`, `:53-60`, `lib/typing/reflect-floor.chiral:16`, `docs/definitions/certificate-discipline.md`, `docs/decisions/decision-split-checker.md`, `docs/arcs/independent-judgment-arc.md`
- checked:  2026-09-02
- element:  UNASSIGNED

### FD-10 the effect row is supplied to lowering rather than derived by it

- state:    OPEN
- claim:    [[decisions/decision-effect-facets]] states the row is "inferred by elaboration from the transitive closure of extern crossings in the call graph", a call-graph fact rather than a consequence of port-holding. `Sheet.crossings` is marked derived, naming WHICH crossings rather than whether, and E161 derives crossings with no surface production at all. So the third leg of the triple, what happens, is documented as never authored.
- measured: on the lowering path it is authored, by being handed in. `lib/lowering/upper/eff-lower.chiral:9-15` says its two loader-derived inputs, `crossing_sigs` (the E51-bound port names) and `def_rows` (E39's inferred per-def effect rows), remain unported chirality-side, " (E39 row inference lives in the deferred E2-loader seam)", so the slice "takes them as GIVEN inputs" and "deriving them is deferred residue with an E2-loader / E51 home". The preserve-check itself is ported and real: re-derive the reached crossings from a lowered tal footprint and demand `reached <= declared`. What is missing is the `declared` side's provenance. The fallback when a def cannot lower is a prune rather than a refusal: `lib/lowering/compile-back.chiral:181-210` drops the function and records `sk-extern op` for a direct extern or `sk-callee cn` for the transitive case, iterated to a fixpoint (`lib/lowering/skip-diag.chiral`, E97). Two further gaps on the same path are DELIBERATE and fall outside this row: erased q=0 content never lowers (`lib/lowering/upper/lower.chiral:65,70`, `drop-erased-args` in `closconv.chiral:1177`), and the crossing floor is hand-authored tal that never came from upper (`lib/lowering/tal/sys.chiral`, 1343 L of `TIFn` values, whose header states the membrane argument: "lowered pure code has no surface path to ti-sys/ti-bptr").
- evidence: `lib/lowering/upper/eff-lower.chiral:1-17`, `lib/lowering/compile-back.chiral:181-210`, `lib/lowering/skip-diag.chiral:11`, `lib/lowering/tal/sys.chiral:1-12`, `docs/decisions/decision-effect-facets.md`, `lib/module/loader.chiral:280`
- checked:  2026-09-02
- element:  UNASSIGNED

### FD-11 Lane A's reserved gate phases were spent by other arcs

- state:    OPEN
- claim:    `docs/decisions/decision-lane-split.md:30` reserves gate phases **18, 19, 20** for Lane A and **21, 22, 23** for Lane B, and `:33-35` says phases 1-7 and 13-17 are taken while 8-12 are names owed to unported old-tree phases that must never be reused.
- measured: all three of Lane A's are gone as of 2026-09-02 and only one went to Lane A. Phase 18 is `pretty.sh`, E181, which is Lane A's own. **Phase 19 is `matcher.sh`, E173, the text-tools arc** (`tools/test/run-tests.sh:301`). **Phase 20 is `transport.sh`, the transport arc** (`:324`, commit `d7d7cfe`). So E182 needed a gate number and its reservation held none, while Lane B's 21-23 sit unused. The E182 SPEC was written against Phase 20 and was overtaken between its audit and its implement run. E182's gate takes **Phase 24**, outside both reservations and clear of the forbidden 8-12. Same class as the two independently minted `E173`s: a reservation that nothing enforces, discovered after the collision.
- evidence: `docs/decisions/decision-lane-split.md:30`, `:33-35`, `tools/test/run-tests.sh:301`, `:324`, `docs/elements/specs/E182-arity-evidence-SPEC.md` §5
- checked:  2026-09-02
- element:  E182 took Phase 24 and moved on. Whether Lane A gets a fresh reservation is an author call


## The pipeline tooling

### FD-12 the scaffolder wrote the INDEX SPEC link one directory too shallow

- state:    FIXED
- claim:    `docs/examples/INDEX.md` spells the SPEC cell relative to its own directory. All 119 of its SPEC-linked rows read `[SPEC](../../docs/elements/specs/…)`, and `tools/pack/pack.py --spec` is the only writer of that cell.
- measured: the scaffolder emitted `../docs/elements/specs/`, one `../` short, which resolves from `docs/examples/` to `docs/docs/elements/specs/` and lands on nothing. The line was wrong from the start and no gate sees it: ledger-lint check F checks only link-shaped targets in `examples/`, so a markdown link with a wrong prefix passes. It was repaired by hand twice with the line left untouched, at `857a005` for E187 ("E187's SPEC link resolved to docs/docs/") and again during E197's SPEC run on 2026-09-05. Measured off-tree on 2026-09-05 by scaffolding E172 into two throwaway copies: HEAD wrote `../docs/elements/specs/E172-file-kinds-SPEC.md`, normalizing to `docs/docs/elements/specs/E172-file-kinds-SPEC.md`, absent; the fixed line wrote `../../docs/elements/specs/E172-file-kinds-SPEC.md`, normalizing to `docs/elements/specs/E172-file-kinds-SPEC.md`, present. Zero INDEX rows still carry the broken spelling, so both hand repairs held. `pack.py` emits no other `../` path; its one other INDEX link, the example cell at `:877`, is a sibling filename and all 131 of those resolve. The tool side moved. `pack.py` is Python, outside the compiler's closure, so no fixpoint was owed.
- evidence: `tools/pack/pack.py:644`, `docs/examples/INDEX.md`, commit `857a005`, `docs/arcs/unit-lane-arc.md:163-170`, `tools/ledger-lint/ledger-lint.py:277`
- checked:  2026-09-05
- element:  none. The fix is the one line, landed in the same change as this row.
