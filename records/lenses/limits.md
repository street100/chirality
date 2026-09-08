# limits

One row per entry. The schema, the states and the two axes are in `README.md`.

### LIM-01 ledger-lint H and M are VACUOUS by decision

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/ledger-lint/ledger-lint.py
- claim:    `ledger-lint` runs 36 checks, A through AJ, re-measured 2026-09-05. It ran 19 when this row was written.
- measured: RE-MEASURED 2026-09-07 against the reporting model `e3ecd85` landed: **the vacuity holds, the tool stopped calling it clean, and this row's own check count is stale.** `ledger-lint` runs **37** checks, **A through AK**. `d5b8fad` added `check_ak` at `:2208`, which reads `records/author-calls.md`, so the 36 and the A-through-AJ the claim above carries were current on 2026-09-05 and are superseded. H and M both still raise `Vacuous`, and `git diff d5b8fad^ HEAD` leaves both function bodies untouched. Only their positions moved, +28 lines under the new `Owed` class at `:106`: H sits at `:545` where this row cited `:517`, and M at `:757` where it cited `:729`. **The subject of the row held still and the report of it moved.** Under the old tool a run whose only residue was H and M printed the two `[VACUOUS]` lines, then the footer paragraph, then `ledger-lint: clean`. `_verdict` at `:2578` now builds the last line from three counts and yields `ledger-lint: clean` only when all three read zero, so the same run today ends `ledger-lint: 2 checks that checked nothing`. **The exit code held.** `main` ends `return 2 if owed else 0` at `:2698`, `Vacuous` is collected apart from `Owed`, and a vacuous-only run still exits 0. A check that checks nothing still passes the gate, which keeps this a limit at `accepted`. What `e3ecd85` changed is that the tool's last word names the two rather than counting them into a clean verdict, which serves this row's claim rather than bounding it.
- evidence: re-runnable: `python3 tools/ledger-lint/ledger-lint.py --only H,M` prints VACUOUS for both and ends `ledger-lint: 2 checks that checked nothing` at exit 0; the same invocation of the tool at `git show d5b8fad^:tools/ledger-lint/ledger-lint.py`, run over this tree, ends `ledger-lint: clean` at exit 0. `python3 tools/ledger-lint/ledger-lint.py | grep -cE '^ +\[(ok|VACUOUS|FAIL|OWED)\]'` returns 37. `tools/ledger-lint/ledger-lint.py:545` (check H), `:757` (check M), `:106` (`Owed`), `:2208` (check AK), `:2578` (`_verdict`), `:2696-2698` (the three exit codes); commits `d5b8fad`, `e3ecd85` ⚑ **Superseded within the day, and check AI cannot see it.** `d5b8fad` added AK and this row was re-measured against 37 checks, then check **AL** landed the same day: `ledger-lint` now runs **38, A through AL**, 36 live and 2 vacuous. AI compares a row's `checked` date against the file's, so a same-day change to `tools/ledger-lint/ledger-lint.py` moves neither and the row reads current while its figure is one behind. The vacuity this row is about is unchanged: H and M still raise `Vacuous` with byte-identical bodies, and AL raises it too whenever `docs/translations/` holds no artifact.
- checked:  2026-09-07
- owner:    none
- from:     BA-03

### LIM-02 `cmd_check` runs the whole compiler, and defends it

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    records/baseline-alignment.md
- claim:    recorded here because BA-05 has a considered defense, quoted below.
- measured: `cmd_check` compiles the unit with the real compiler and discards the ELF. Its header states the reason: "checking is compiling and throwing the ELF away, the same front end, no second implementation to drift." That is a real argument and it is why BA-05 is a classification defect rather than an architecture defect. A second front end that only type-checks would drift from the one that compiles.
- evidence: `bin/chirality:155-159`, `bin/chirality:173`
- checked:  2026-09-01
- owner:    none
- from:     BA-06

### LIM-03 the port floor is a naming boundary and buys zero bytes

- state:    accepted
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/ports/ports.chiral
- claim:    nine port registries under `lib/ports/`, one per concern, with `ports/ports.chiral` as the façade.
- measured: RE-MEASURED 2026-09-06: unchanged, and the seam widened. `lib/ports/ports.chiral` has **46** importers under `lib/` and `prog/`. The file's own header still says the split is worth exactly 0 bytes at runtime, because the image is `native-lib` prepended to `link-lib` prepended to the object unconditionally. The floor is a naming boundary, which is why this is a limit at `accepted` and not a defect.
- evidence: re-runnable: `grep -rl 'ports/ports' --include='*.chiral' lib/ prog/ | wc -l` returns 46. `lib/ports/ports.chiral`
- checked:  2026-09-06
- owner:    none
- from:     BA-12

### LIM-04 `lib/evidence/ddc.chiral` has no callers for its DDC half

- state:    accepted
- author:   unreviewed
- note:     none
- level:    source
- about:    lib/evidence/ddc.chiral
- claim:    already recorded as open edge 21. Cross-referenced here rather than restated.
- measured: RE-MEASURED 2026-09-06: unchanged. `ddc-fold` and `ddc-compare` appear in exactly one file, `lib/evidence/ddc.chiral` itself, so the DDC half has zero callers. Kept on purpose: it is the quorum machinery [[goals/independent-judgment]] needs and nothing schedules yet.
- evidence: re-runnable: `grep -rl 'ddc-fold\|ddc-compare' --include='*.chiral' lib/ prog/` returns only `lib/evidence/ddc.chiral`. `lib/evidence/ddc.chiral`
- checked:  2026-09-06
- owner:    none
- from:     BA-14

### LIM-05 `lib/memory/alloc-fixed.chiral` has zero importers

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    docs/definitions/open-edges.md
- claim:    already recorded as open edge 22. Cross-referenced here rather than restated.
- measured: RE-MEASURED 2026-09-06: unchanged. `grep -rl 'memory/alloc-fixed' lib prog tools` returns **0** importers. Kept on purpose so a future program can take it or `alloc-growing`, and no gate compiles it. `memory-discipline/M6` is the row that would reach it or move it to SEEDED with a reason.
- evidence: re-runnable: `grep -rl 'memory/alloc-fixed' lib prog tools | wc -l` returns 0. `lib/memory/alloc-fixed.chiral`, `docs/arcs/memory-discipline-arc.md`
- checked:  2026-09-06
- owner:    none
- from:     BA-15

### LIM-06 161 bare `:NN` spans have no subject a check can name

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/ledger-lint/ledger-lint.py
- claim:    the banks' detached convention is `ports.chiral` … (`:19`), a bare line span resolving against the last file named.
- measured: **RE-MEASURED 2026-09-07: unchanged in shape, and neither commit that staled this row touched the instrument.** `ledger-lint --census` reads **4,655 line-numbered spans, 2,002 of them bare `:NN`, and 937 bare with no file in the paragraph**, against 4,653 / 2,002 / 937 on 2026-09-06. The bare figures are identical and the total gained 2, which is corpus: the tool at `d5b8fad^`, run over this same tree, prints the four figures byte-identically, and `git diff d5b8fad^ HEAD` leaves `_find_src` and `check_g` alone. Both citations drifted +28 lines under the new `Owed` class at `:106`: `_find_src` sits at `:397` where this row cited `:369`, and `check_g` at `:407` where it cited `:379`. The claim the row exists to carry is unchanged: a bare span read against the wrong file is a guess, and BA-02's ctx fix is what stopped it being read against whatever resolved last.
- evidence: re-runnable: `python3 tools/ledger-lint/ledger-lint.py --census` prints 4655, 2002, 937 and 3063. The same run against `git show d5b8fad^:tools/ledger-lint/ledger-lint.py` prints the identical four. `tools/ledger-lint/ledger-lint.py:397` (`_find_src`), `:407` (check G, whose walker the census reuses); commits `d5b8fad`, `e3ecd85`
- checked:  2026-09-07
- owner:    none
- from:     BA-21

### LIM-07 the declared matrix, re-run and reconciled

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/test/mutant.sh
- claim:    `tools/test/mutant.sh:156-196` declares seven mutants, each with the rule it is expected to convict.
- measured: **RE-RUN 2026-09-06, `mutant.sh --matrix`, and reconciled at the new base.** All seven declared mutants built, all seven differ from base, and all seven reach a self-hosting fixpoint `C1 == C2`. **Every mutant is convicted by at least one phase**: `qfits-q1-accepts-all` and `strip-binder-off` by three, `qfits-q0-accepts-all` and `close-binder-off` by two, and `qjoin-q1-no-saturate`, `qjoin-q0-no-saturate` and `port-purity-off` by one each. No mutant walks.
- evidence: re-runnable: `bash tools/test/mutant.sh --matrix` (builds seven mutant compilers). `tools/test/mutant.sh:156-196`, `:198-223`
- checked:  2026-09-06
- owner:    none
- from:     GA-02

### LIM-08 syscall-manifest.sh honours the rule in its own idiom

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/test/syscall-manifest.sh
- claim:    a pre-dispatch grep scored this script at 0 gate rows and 0 mutants.
- measured: both halves of that count are wrong, and the correction belongs here because it changes where the hole is. `bash tools/test/syscall-manifest.sh` reports **12 passed, 0 failed**. Its assertion helpers are `prof` (`tools/test/syscall-manifest.sh:49`) and `poison` (`tools/test/syscall-manifest.sh:79`), which a grep for `check` or `ok` misses. `poison` is a mutant harness built into the phase: it seds the compiler's own blob, rebuilds a compiler from the poisoned stream, and asserts the rebuilt compiler refuses to emit. Four call sites at `tools/test/syscall-manifest.sh:113`, `:115`, `:118`, `:121`, of which the first is the positive control (`p;d`, the clean blob still compiles) and three are real mutants of the registry rows in `lib/lowering/tal/target-linux.manifest:23`, reached through the compiler's own blob. The harness closes three of `mutant.sh`'s four silent failures independently: `cmp -s` against the base blob refuses a poison that matched nothing (`tools/test/syscall-manifest.sh:83-85`), a build failure is reported as its own FAIL (`tools/test/syscall-manifest.sh:86-89`), and the control row runs first. It carries no equivalent of `mutant_differs` at the binary level, and the blob `cmp` stands in for it at the source level.
- evidence: `tools/test/syscall-manifest.sh:49`, `:79-101`, `:113-123`
- checked:  2026-09-04
- owner:    none
- from:     GA-06

### LIM-09 size and the fixpoint carry no signal, re-measured

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/test/mutant.sh
- claim:    `tools/test/mutant.sh:34-41` records, measured 2026-08-31, that five semantic mutants of the QTT usage audit each produced a compiler of exactly 1,098,104 B and four reached a byte-identical self-hosting fixpoint.
- measured: **RE-RUN 2026-09-06 and the claim holds at a new base.** `bin/chirality-bin` is **1,241,464 B**, against the 1,188,216 B this row recorded. **All seven mutants built at exactly 1,241,464 B**, byte-size-identical to the base, and **all seven reached a self-hosting fixpoint**. So neither size nor the fixpoint separates a mutated compiler from a correct one, which is what this row exists to say, and the new base changes nothing about it.
- evidence: re-runnable: `bash tools/test/mutant.sh --matrix` (builds seven mutant compilers). `tools/test/mutant.sh:34-41`, `:125`, `:142-147`
- checked:  2026-09-06
- owner:    none
- from:     GA-09

### LIM-10 pretty.sh runs all seventeen of the mutants it names

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/test/pretty.sh
- claim:    `tools/test/pretty.sh:22-38` maps thirteen gate rows G1 to G13 onto seventeen mutants M1 to M17, and every one of the seventeen is named in a row heading.
- measured: RE-RUN 2026-09-06: `bash tools/test/pretty.sh` reads **71 passed, 0 failed**, exit 0. The row's claim that it runs all seventeen of the mutants it names holds against a green gate.
- evidence: re-runnable: `bash tools/test/pretty.sh` reads 71 passed, 0 failed. `tools/test/pretty.sh`
- checked:  2026-09-06
- owner:    none
- from:     GA-12

### LIM-11 face.sh honours the rule on all thirteen

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/test/face.sh
- claim:    `tools/test/face.sh:56` reads that EVERY ROW CARRIES A NAMED MUTANT THAT IS RUN, and `:50-53` that the thirteenth mutant exists because G7(c)'s arity scan was the one row here nothing could redden.
- measured: RE-RUN 2026-09-06: `bash tools/test/face.sh` reads **38 passed, 0 failed**, exit 0. It honours the rule on all thirteen.
- evidence: re-runnable: `bash tools/test/face.sh` reads 38 passed, 0 failed. `tools/test/face.sh`
- checked:  2026-09-06
- owner:    none
- from:     GA-14

### LIM-12 the idiom that makes a mutant row convict its own gate row

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/test/mutant.sh
- claim:    `docs/definitions/testing-floors.md:287` binds a gate row to a mutant that is RUN, and `tools/test/mutant.sh:26-30` names the third silent failure: the mutant reddens some other row, or reddens nothing while the script still reports it as convicting.
- measured: **RE-RUN 2026-09-06.** The matrix reconciles: every mutant is convicted by at least one phase and the convicting phases are the ones whose rows re-run the judgment rather than compare a stored string. `port-purity-off` is convicted only by `profile-target`, and `qjoin`'s two mutants only by `linear-mint`, which is the single-witness shape this row names as the thing to watch.
- evidence: re-runnable: `bash tools/test/mutant.sh --matrix` (builds seven mutant compilers). `tools/test/mutant.sh:26-30`; `tools/test/pretty.sh:473`, `:501`, `:552`; `tools/test/face.sh:547-548`, `:579`, `:615`; `tools/test/row.sh:517-526`
- checked:  2026-09-06
- owner:    none
- from:     GA-15

### LIM-13 row.sh runs all thirteen, and `g4_mutant` names the row it reddens

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/test/row.sh
- claim:    `tools/test/row.sh:20-22` reads that every row that matters renders through `render-to-ansi` and READS THE EMITTED BYTE STREAM, and that every row carries a named mutant that is RUN. `:24-35` maps eight gate rows G1 to G8 onto thirteen mutants.
- measured: RE-RUN 2026-09-06: `bash tools/test/row.sh` reads **42 passed, 0 failed**, exit 0. It runs all thirteen and `g4_mutant` still names the row it convicts.
- evidence: re-runnable: `bash tools/test/row.sh` reads 42 passed, 0 failed. `tools/test/row.sh`
- checked:  2026-09-06
- owner:    none
- from:     GA-16

### LIM-14 the full-line pin closes all four silent failures, and the entry-point hazard with them

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/test/arity.sh
- claim:    `tools/test/arity.sh:75-79` reads that a build which did not happen scores `nobuild` and never `bad`, and that no pinned line below ever expects that token, so a mutant that merely fails to compile cannot wear a red row and be read as a conviction. `tools/test/mutant.sh:19-40` names the four ways the measurement fails silently, and this idiom is a second implementation of the same rule.
- measured: RE-RUN 2026-09-06: `bash tools/test/render-doc.sh` reads **20 passed, 0 failed**, exit 0. The full-line pin still closes all four silent failures.
- evidence: re-runnable: `bash tools/test/render-doc.sh` reads 20 passed, 0 failed. `tools/test/render-doc.sh`
- checked:  2026-09-06
- owner:    none
- from:     GA-18

### LIM-15 the Python tier makes no classic-tool call

- state:    accepted
- author:   unreviewed
- note:     none
- level:    doc
- about:    tools/ledger-lint/ledger-lint.py
- claim:    [[arcs/zero-python-arc]] treats the Python tier as tooling to be replaced, and enforcement requirement 5 counts its 4,786 lines in the 12,450 outside the language.
- measured: RE-MEASURED 2026-09-06: unchanged and confirmed. Every `subprocess` call across the Python tier is to `git` and there are **five** of them; zero invoke a classic Unix tool. The shape differs from the shell tier's, which is the point of this row: the Python is replaceable without composing grep, sed, sort or awk first.
- evidence: re-runnable: `grep -rhoE 'subprocess\.(run|Popen|call)' tools/*/*.py` returns 5, every one a git call. `tools/frontier/frontier.py:250-254`, `tools/doc/doc.py:204`
- checked:  2026-09-06
- owner:    none
- from:     TC-10

### LIM-16 E20 ledger says built and the pipeline index says audited

- state:    accepted
- author:   unreviewed
- note:     none
- level:    element
- about:    E20
- claim:    docs/elements/ledger.md marks E20 `built`; docs/examples/INDEX.md marks it `audited`, awaiting implementation.
- measured: records/ledger-reconciliation.md measured the two cells as naming different things. There is no nb-blit and no mmap-to-mprotect code loader under lib/; lib/module/loader.chiral is the compiler's module loader by its own header and the name is a collision. The mmap/mprotect pair in compile-emit is E89/E91's arena reserve-commit, never a W-to-X transition, and the W^X half is not held: x64/elf.chiral:59-60 emits one RWX PT_LOAD. Naming the surviving element is an author call.
- evidence: records/ledger-reconciliation.md, lib/lowering/x64/elf.chiral:59-60
- checked:  2026-09-05
- owner:    none
- from:     none

### LIM-17 E26 ledger says built and the pipeline index says audited

- state:    accepted
- author:   unreviewed
- note:     none
- level:    element
- about:    E26
- claim:    docs/elements/ledger.md marks E26 `built`; docs/examples/INDEX.md marks it `audited`.
- measured: records/ledger-reconciliation.md qualified it PARTIAL 2026-09-04. The crossing half is real, halt declared at lib/ports/process.port:14, and the typed alarm is not built: E42 built the shape instead and names the typed alarm as residue, hard-gated on E39, which is still `design`.
- evidence: records/ledger-reconciliation.md, lib/ports/process.port:14
- checked:  2026-09-05
- owner:    none
- from:     none

### LIM-18 E101 ledger says built and the pipeline index says audited

- state:    accepted
- author:   unreviewed
- note:     none
- level:    element
- about:    E101
- claim:    docs/elements/ledger.md marks E101 `built`; docs/examples/INDEX.md marks it `audited`.
- measured: records/ledger-reconciliation.md measured a genuine PARTIAL on E26's precedent. The element's title names two files: lib/surface/sexp.chiral landed in full and lib/surface/parse.chiral did not, its p-err still carrying a bare string with no position.
- evidence: records/ledger-reconciliation.md, lib/surface/sexp.chiral:137
- checked:  2026-09-05
- owner:    none
- from:     none

### LIM-19 E16 names register allocation as a deliverable and nregs is a high-water counter

- state:    to-plan
- author:   unreviewed
- note:     none
- level:    element
- about:    E16
- claim:    `docs/elements/catalog.md` E16 reads `Lowering: pure→tal, register/slot alloc, non-tail case outlining, preserve-check`, and `docs/arcs/enforcement-arc.md` states `Three of the four deliverables are built and the fourth never runs`, the fourth being the preserve-check.
- measured: **There is no register allocator, so the second deliverable is a slot count and a prologue.** [[records/findings]] FD-19 measured it and this row re-took it: `nregs` (`lib/lowering/tal/ssa.chiral:40`) is the fresh-register high-water mark, `ck-fn` binds and ignores it, `optimize` threads it unchanged through `fold` (`:140`) and `dead` (`:192`), and its one real consumer is `emit-core.chiral:533` handing it to `(mach-pro m)` (`mach.chiral:64`), which emits one stack slot per SSA register. Grepped over `lib/lowering/`: zero occurrences of colouring, interference or liveness outside `optimize.chiral:142`'s DCE fixpoint, and the single `spill` string is a comment at `emit-core.chiral:423` about the outgoing stack zone. So slot allocation exists in its most trivial form and register allocation does not exist at all. ⚑ **This is a wording defect rather than a build defect.** One slot per SSA register is a correct strategy and nothing here says the tree should have an allocator. What the row records is that a deliverable named in the element's own title is counted among the three that are built. ⚑ **And it bears on the conformance queue.** FD-19 measured the published position that where allocators exist they CONSUME the register types: CompCert's is an external oracle and `transf_function` hands `type_function`'s `regenv` to the validator (`COMPCERTALLOC`). So an allocator added later is the natural consumer of exactly the type information `.planning/TAL-CONFORMANCE-QUEUE.md` is about, and adding one before the types are total would be building the consumer first.
- evidence: `docs/elements/catalog.md` E16, `lib/lowering/tal/ssa.chiral:40`, `lib/lowering/mach/emit-core.chiral:533`, `lib/lowering/mach/mach.chiral:64`, [[records/findings]] FD-19
- checked:  2026-09-08
- owner:    none
- from:     FD-19
