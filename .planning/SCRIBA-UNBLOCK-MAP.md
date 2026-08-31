# scriba unblock — scoped slices through the pipeline

> **⚑ RESCOPED 2026-08-11 — see `TUI/docs/SCRIBA-TERMINAL-RESCOPE.md`.** The E99/E103/
> E104/E105 "terminal substrate" below is now the **`(R)` backend material for the
> `Terminal` port**; the `(M)` chirality-emulator backend + `Pty` cap + child-wiring
> crossings are a **separate emulator lane** (`TUI/`), not a scriba slice. VT parsing
> = `vt-core` (chirality-native, libghostty-vt as oracle); multiplexing mechanism = `mux`;
> compositing = `surface`. scriba is the resident above the port. Source now in
> `TUI/scriba/`. Architecture: `TUI/README.md` + `TUI/docs/TERMINAL-PORT-DESIGN.md`.

> **⚑ TERMINAL SUBSTRATE COMPLETE 2026-08-10.** The terminal-ownership layer
> chirality needs to host scriba is built + verified on real hardware: **E99** (ioctl
> surface) · **E103** (cfmakeraw raw-mode fidelity — pure test exit 42, root-caused
> the `bput-u32-le` truncation bug) · **E104** (native pty acquisition — chirality opens
> its own `/dev/ptmx` pair) · **E105** (`write-fd` to arbitrary fds). They compose:
> `e103_pty_roundtrip.chiral` opens a pty, raws the slave, writes the master, reads
> it back un-echoed/unbuffered — **exit 42 on real `/dev/ptmx`**. B1 rebuilt +
> self-hosts (fixpoint 803192B), native floor green, tree==binary. This is the
> SUBSTRATE, not scriba-the-editor — buffer/render/keybind/port-viewer remain
> (DeepSeek's lane). **E100** (2-type-param call lowering) is still the open
> compiler blocker under scriba. Bugs/gaps found in passing: `.planning/BUGS-AND-GAPS.md`.

> **⚑ STATUS 2026-08-10 — THE PY SUITE REDS BELOW ARE NOW ADVISORY, NOT
> GATING.** The floor architecture landed (`docs/testing-floors.md`,
> `.planning/RUNG1-CHECKLIST.md` Phase C): `chirality test` gates on native+rocq and
> runs the python oracle advisory-only. So the 74-err/29-fail forensics below no
> longer block anything — scriba proceeds on the **native floor** (band / pty
> probe / term-raw are all behavioral, fully native-testable, zero python).
> The named py-red causes (S12/S13 rulings, retired-extern sweep) are still worth
> clearing to keep the advisory floor legible, but they are no longer a gate and
> no longer a precondition for scriba slices S1–S5. New scriba work ships a
> native sample per the sample-with-feature discipline.
>
> **STATUS UPDATE 2026-08-09 (commit+sync executed):** the-lang working tree
> committed in 9 units (0088230..2e9e034 + make-public fix); mach-x64 band
> amputation REVERTED (ff5232d stands — band was fully landed, the 4am removal
> only appeased the stale mirror); ports data-before-extern ordering fixed
> (broke py suite loading since cd8334a). Export synced; mirror debris removed;
> **new self-hosting fixpoint 684274B (gen2==gen3, band-capable) is bin/chirality-bin
> in the mirror AND scaffold/build/B1 here.** Verified through it: `(band n 12)`
> compiles, **term-raw compiles (first time)**, tiocgwinsz probe returns live
> pty dims (31×117). E96 therefore SHRINKS to {bor,bxor,shl} + tests — band is
> done. S6 partially done (make-public rsync fallback; drift-refusal guard
> still owed). C.3 probe did NOT run (arms restored before sync) — coverage
> enforcement still unproven, keep it in E96/E97. Py suite: pre-existing rot,
> NOT from this train — 295 errors at old HEAD → 105 err/28 fail now; strata:
> staging tests vs py floor (`static`/`next` unknown), extern host impls
> missing (ioctl/mmap/mremap/null-port/read-key/read-keyseq — S12a territory),
> message drift. Slices S1–S5 pipeline runs still await go.
>
> **Suite forensics (harness-confirmed):** canonical harness = `bin/chirality
> test-python` (cwd=scaffold, `-p '*.py'`) — same result as direct discover, so
> the red is real, not harness error. Proof of window: fixpoint commit 84256f0
> = **671 tests OK** with the same invocation; rot enters 84256f0..e9e5aae.
> Causes: (1) ports extern-before-data (FIXED this session, ~190 errors
> recovered); (2) `test_staging.py` (26 red) tests E57 staging the py floor
> never implemented — it entered via commit c990523 "sync from public mirror",
> i.e. a REVERSE sync of tests authored in the mirror against an unbuilt
> feature (second stupid-order artifact, alongside the band amputation);
> (3) the six impl-less externs (ioctl/mmap/mremap/null-port/read-key/
> read-keyseq) trip the load-time runtime alarm across many old modules
> (test_effectful_lowering 13E, test_closconv 11E, test_kernel 16,
> test_backend, test_process_externs, test_fd_passing…) — py host bindings in
> impl_ports.py are the missing piece (S12a decision); (4) residual
> assert-message drift. Quarantine-or-implement for test_staging is an author
> call: the tests are a spec sketch for E57, not a regression.
>
> **Red classification (are tests stale over purposeful change?):**
> (A) ~113/132: PURPOSEFUL chirality-floor iteration, py harness not taught — the
> six externs + syscall rows + crossing tables grew Aug 6-8 WITHOUT the
> documented openat pattern (8380c42 taught oracle LIB_SIGS + SYSCALL_TABLE +
> the 2 crossing-list assertions in the SAME commit). Includes the alarm
> cluster, e2e/nodes subprocess alarms, both bound-crossings asserts,
> table-mirrors-oracle, and real-sys-lib 'sbad' (py oracle default-denies the
> new rows). The two floors now disagree with each other, not just the tests.
> Fix = openat pattern ×6 or S12a retirement.
> (B) 7 kernel linearity FAILs: NOT stale tests — commit 014e0a7 (Aug 7)
> "ports: change Sock from porttype to data, fixes spawn" demoted Sock's
> linearity to unblock spawn; the tests are correctly objecting to a membrane
> regression. With E98 retiring the spawn stub, reverting Sock to porttype is
> the aligned move — author decision (d) added to S12.
> (C) 26 staging reds: aspirational (no VStatic implementation in ANY history,
> either repo) — E57 spec sketch via worktree-export→mirror-backup→reverse-
> recovery. Quarantine or schedule E57.
> (D) trivially stale: test_resolve blob-size threshold (lib legitimately
> shrank under it).

> **STATUS 2026-08-09 EVE — E97 IMPLEMENTED, fixpoint 721146B, binaries
> straightened.** Both repos: committed tree == built tree == shipped binary
> (private B1 == public chirality-bin, zero dirty). E97 blame chain live (success
> silent, entry-drop names its chain). The deepseek-era "B1 nested-case" and
> "Asm grammar" blockers were ONE globally-balanced paren slip in prune-pass +
> duplicate function generations (postmortem: commit 98b8c79) — phantom-B1-bug
> diagnoses #5 and #6. E91 UNBLOCKED + implement-ready; fresh-session brief =
> `.planning/handoffs/E91-IMPLEMENT-HANDOFF.md` (existing pieces, re-opened
> SPEC decisions #2/#6, py-stub rax/rcx FLAG-4 still live, discipline). E89
> stub-v3 chirality side + E81 growing instance + E100 remain behind it.

> **SUITE SNAPSHOT 2026-08-09 late (post-E97, 721146B): 665 collected, 74
> err / 29 fail — ALL SCOPED, five named causes, zero mysteries:**
> (1) test_staging 26 — S12 ruled quarantine, NOT YET EXECUTED (file still in
> tests/); (2) KeyError 'nb-get-u64' ~46 across closconv/native/optimize/
> compile_run/effectful_lowering/fd_passing — E90's new TAL crossings never
> taught to the py floor (openat-pattern skipped AGAIN; S13 lane);
> (3) SurfaceError 'unknown name env-get' ~45 — E98 retired externs but their
> CALLERS in lib (wl-client.chiral:143 etc.) were not swept (E98 residue);
> (4) 7 kernel linearity FAILs — S12 ruled Sock porttype revert, NOT YET
> EXECUTED (ports.chiral:12 still `data Sock`); (5) residual e2e/nodes
> follow-ons of 2+3. Last-green baseline for comparison: 671 OK at 84256f0.
> Executing the two recorded S12 rulings + teaching nb-get/put-u64 + sweeping
> retired-extern callers ≈ the whole distance back to green (S16).

Date: 2026-08-09 (v3 — v1 rejected: workarounds; v2 rejected: implement-first.
This version maps SLICES routed through example → audit → spec → audit, with
implement gated on explicit per-slice go.)

## Ground truth (verified this session, by running B1 — not inherited)

- `(band n 12)` alone → `no emitted label for entry compile-main`; term-raw
  fails only via `termios-set-raw` → `band`. tcgetattr/tcsetattr/two-ioctls/
  case-on-effectful-result all compile. Root cause of the scriba cascade.
- band is a HALF-LANDED FEATURE: prelude extern + `op-band` ctor + tal-erase
  parse arm exist in chirality only (unsynced, Aug 8); mach-x64 emitter
  arms were never written; B1's build tree (chirality) has no band anywhere,
  so its `op-bytes` was exhaustive when compiled. Not a checker escape.
- ioctl crossing compiles (04:00 rebuild, uncommitted in chirality) and works
  at runtime: tiocgwinsz probe under a 24×80 pty prints `24080`.
- Class defect behind three straight misdiagnoses (mutual recursion → ioctl →
  band): B1 silently drops any def hitting an unknown prim (`er-skip`,
  discarded at compile-back.chiral:225) and the drop cascades to the entry with
  zero diagnostics.
- Stub crossings registered as live rows (04:00 sys-tal additions):
  `nb-read-key`/`nb-read-keyseq` = `read(fd, cell, 0)` with NO bptr;
  `nb-sys-spawn` → -1; `nb-null-port` → -1; `nb-sys-env-get` → empty cell.
- Repos diverged 8 files, chirality = authority/superset on every one
  (verified per-file); chirality additionally carries a stale duplicate flat
  scriba set at lib top-level; B1 provenance murky (built from tree missing
  E94/E89-v2). Py floor has NO ioctl (handoff claim "LIB_SIGS ✓ SYSCALL_TABLE
  ✓" never true of the committed tree) and NO band in `_PRIMS`/`_STR2OP`.

## Sync audit (2026-08-09, pre-implement)

Fine-grained check for out-of-order repo updates. Method: every diverged
chirality file hashed against chirality's full git history; untracked
snapshots diffed line-direction against the-lang's current working tree.

- **No reverse-order edits anywhere.** All 8 diverged tracked lib files in
  chirality match an older committed the-lang state (collections = Jul 28
  pre-case-on-call-train; compile-emit = Aug 5 48GB era; rest Aug 4–7).
- chirality's `scaffold/lib/scriba/` is fully UNTRACKED there; its 4 diverged
  files match no the-lang commit but their unique lines are all pre-fix-era
  content (old 5-param signatures, the stub render-puffer E95 removed) —
  stale snapshots of the-lang's uncommitted intermediate states, subsumed.
- The flat scriba set at chirality lib top-level: 13/15 files identical-or-
  subset of the-lang's current `scriba/` (list-utils byte-identical); the 3
  with unique lines carry only the same pre-fix-era content. Deletable debris.
- `chirality/.planning/SELF-IMPLEMENT-CATALOG.md` is NOT a leak — it is
  tracked and deliberately carried by the export commits; currently behind
  (the-lang has uncommitted catalog edits).
- The 04:00 crossing-wraps/sys-tal edits are byte-identical uncommitted in
  BOTH working trees; lang `bin/chirality-bin` (tracked-modified) = the Aug-8
  fixpoint 671986B; `chirality-bin.new` 680178B = the 04:05 build = the-lang B1.
- **The real hazard is not cross-repo order — it is that the single source of
  truth (chirality's working tree) is largely UNCOMMITTED**: all scriba
  fixes, ports/bytes-tal/term ioctl work, catalog + planning edits. Nothing
  may `git checkout`/stash there; commit-train before or as part of S8.
- Safe sync direction for every diverged file: the-lang → lang, zero loss.

## Slice map — FINAL (v4, post-forensics)

Statuses: DONE = executed this session. Catalog slices run example → audit →
spec → audit; implement fires ONLY on explicit per-slice go.

| Slice | Lane | Scope (one deliverable) | Status / Depends |
|---|---|---|---|
| S8 | mechanics | Commit train (10 units), the-lang→lang export, mirror debris purge, band amputation reverted, ports ordering fix, refixpoint 684274B both repos | **DONE 2026-08-09** |
| S12 | decision | Author docket — mostly resolved by **python = ADVISORY** (docs/testing-floors.md; user runs python→rocq migration separately with own agents). **(a) RESOLVED 2026-08-10: do NOT teach the oracle crossings, do NOT gate on it → dissolves S13.** **(b) RESOLVED: stubs retire freely (advisory oracle, no parity to keep).** **(c) RESOLVED: E99 shipped — per-request wrappers in sys-tal + term.chiral.** (d) **RESOLVED 2026-08-10 (reasoned, web-grounded): `Sock` STAYS `porttype` (linear, q=1) — already live (ports.chiral:12), checker-enforced, B1 self-hosts.** Sockets are unique system resources = the textbook linear-type case (use-after-close / double-close / leak all untypeable; session types require linearity). The `014e0a7` `data` demotion was a CATEGORY ERROR — it discarded the whole resource-safety invariant to dodge spawn *transfer* ergonomics. **GUARDRAIL for when real spawn/fork returns:** socket→child is a TRANSFER crossing that CONSUMES the linear Sock (fd inheritance / SCM_RIGHTS / pidfd = a move across the membrane — the port-transfer/RecvR pattern), NEVER a re-demotion to `data`. Affine (drop=close, Rust-style) considered+rejected: chirality wants explicit close over silent drop. **(e) RESOLVED: quarantine test_staging (advisory suite, non-gating).** | **ALL RESOLVED** |
| S6 | infra | Export guard hardening in make-public.sh: refuse (or loudly flag) DIRTY-worktree export — kills the accidental-backup/reverse-sync class (test_staging, cell-new both entered that way); reverse-newer refusal on DEST | rsync fallback DONE; guards owed. No deps — do early |
| S1 = E96 | catalog | Bitwise family completion: {bor,bxor,shl} all layers both floors (band DONE at ff5232d, restored + fixpointed). Carries S7 coverage probe in its gate: build with Op ctor minus emitter arm must be REJECTED — proves B1 case-coverage enforcement, still unproven | pipeline ready |
| S2 = E97 | catalog | Lowering skip-chain diagnostics: er-skip reasons accumulate, entry-label drop reports blame chain root-first; `native-prim?` one-authority resolution (delete-if-dead) | pipeline ready |
| S3 = E98 | catalog | Honest crossing table: real `nb-read-key` (bnew+bptr+read(0,ptr,n), raw bytes out; scriba pure key-parser owns parsing); RETIRE read-keyseq/spawn/null-port/env-get externs+rows+wrappers everywhere. Shrinks the extern-alarm surface from 6 to ~3. **RESIDUE (the current wall): env-get callers were NOT swept → scriba fails to compile with `unknown name env-get`; that sweep is the remaining E98 work.** | ready — S12(b)/S13 resolved (python advisory) |
| S14 | defect | Sock linearity restoration | **DONE — `(porttype Sock)` is live (ports.chiral:12); demotion reverted, spawn stub retired, linearity checker-enforced, B1 self-hosts. (Membrane tests are the python-advisory spec; the invariant itself is now structurally enforced.)** |
| ~~S13~~ | — | **DISSOLVED 2026-08-10 (S12a resolved).** Python is advisory → NO oracle-parity gate. The ~113 "cluster A" reds are ADVISORY, non-gating. Teaching the oracle the new crossings is optional cleanup, never a blocker; the user owns the python→rocq migration separately. | N/A — not gating |
| S4 = E99 | catalog | Honest ioctl surface: per-request crossings allocating out-cells INSIDE (nb-tcgets fd→60B, nb-winsz fd→8B; TCSETS stays value-in); term.chiral reworked; removes the kernel-mutates-pure-value hole before fold/CSE strengthening can weaponize it | needs S12(c); term-raw now compiles so gate is runnable |
| S5 = E100 | catalog | 2-type-param + fn-param call lowering (alist-get/put from compile-main); done includes DELETING every inlined copy from scriba files | independent |
| S17 | umbrella | **Arena dynamism** — NOT one slice; six sub-slices under EXISTING catalog elements (E91×2, E90, E89, E81 + battery). Full makeup, discoveries, and resolved design in the dedicated section below | needs S1–S2 cadence; before S9 |
| S15 | tests | Staging disposition per S12(e): quarantine test_staging (explicit skip with E57 pointer) or mint E57 and pipeline it. Also the two micro-stales: test_resolve blob threshold, residual message-drift asserts | needs S12(e) |
| S9 | verify | Re-measure the broken-lens claims through the NEW B1: "4+ effectful ops" threshold (wire lookup-scribaop 4th), E88 str-edit/mark-region recompile, full scriba blob → ELF → pty run (keys dispatch, cooked restore, no fd leaks), file-io end-to-end | needs S1–S3 implemented |
| S16 | gate | **REFRAMED 2026-08-10: the standing gate is native+rocq (docs/testing-floors.md), NOT python-suite-green.** `chirality test` gates native+rocq; python runs advisory. make-public.sh guards on native+rocq green. Python-green is optional cleanup, never the export gate. | needs S14 only |
| S10 | doc | Correct the record: E95 catalog row + SPEC closed with true root cause (band amputation + silent skip, NOT mutual recursion/ioctl); SCRIBA-DISPATCH-BLOCKER superseded banner; SCRIBA-SYSCALL-HANDOFF (oracle claims, sig drift); SCRIBA-SLICES; NATIVE-TOOLCHAIN-SLICES; INDEX states | needs S9 (results feed it) |
| S11 | cleanup | Scratch fleet: `.scratch/` (86 files, already relocated) deleted after S9 gates pass; keepers graduate into scaffold/tests/ first; root test_e95_*.py investigation scripts same rule | needs S9 |

## Execution order

Decisions first, guards early, compiler before crossings, oracle after the
table shrinks, measurement before docs, cleanup last:

1. **S12** — rule (a)–(e). Everything blocked on taste/scope sits here.
2. **S6** — export dirty-tree guard (30 min, prevents recurrence while the
   rest proceeds).
3. **Pipeline wave** (parallelizable pre-runs, then audits, then specs, then
   spec-audits; `--no-index` per agent): **S1, S2, S3, S4, S5**. S3/S4 specs
   consume S12 rulings.
4. **Implement on per-slice go**, this order:
   **S1** (E96 + coverage probe) → **S2** (E97 diagnostics — everything after
   this self-diagnoses) → **S17** (arena dynamism: reserve-commit grow; the
   sub-MB footprint story lands here) → **S3** (E98 table shrink; also retires
   the pointerless mremap rows) → **S14** (Sock revert, 7 tests green) →
   **S13** (oracle parity over the SURVIVING externs only) → **S4** (E99) →
   **S5** (E100).
5. **S15** — staging disposition (independent; any time after S12e).
6. **S9** — re-measure sweep through the new B1.
7. **S16** — suite-green capstone + pre-export gate wiring.
8. **S10** — docs corrected from S9/S16 results.
9. **S11** — scratch deletion, keepers graduated.

Current pipeline state: E88 audited(blocked→re-test in S9) · E89/90/91/94
implemented · E92/93 audited · E95 investigated-with-wrong-premise (S10 owns
correction, author-gated). Catalog rows E96–E100 drafted below, appended on
the wave-3 go.

## S17 makeup — arena dynamism, the actual decomposition

Two structural discoveries (verified in mach-x64.chiral this session) shape it:

1. **Write-before-check**: both allocation shapes — `x-alo` (boxed cells,
   :232-243) and `x-bnw` (dynamic byte cells, :283-291) — STORE the object at
   the bump address FIRST, then `cmp` against heapend, then `ud2`. Benign
   today only because the whole 16GB placeholder is mapped RW (stores past
   heapend land in owned-but-unused pages; heapptr never commits). Under
   reserve-commit the stores SIGSEGV on the PROT_NONE page before any grow
   hook can fire. Check-first reordering is therefore a PREREQUISITE slice,
   not a detail. The py JIT arena (real 1MB mmap via `nb-sys-mmap`,
   native.py:554/637) has the same hazard shape (overflow = SIGSEGV on
   unmapped VA, not a trap).
2. **The policy hook already exists**: E81's seam is `scaffold/lib/alloc.chiral`
   — an `Alloc` policy record with `alo-cell`/`alo-bytes` selectors over Mach
   (d6ad519, byte-identical). The growing discipline is a SECOND Alloc
   instance, not a mach-x64 hack.

Resolved design (research-backed; see S17 sources in git log 831e083):
reserve-commit — PROT_NONE reservation (RESERVE_BYTES ~64GB, VA-only,
unaccounted under all overcommit modes) + mprotect'd RW prefix
(INIT_COMMIT 256KB — the sub-megabyte ethos extended to runtime footprint:
684KB compiler + sub-MB initial heap) + mprotect-doubling growth. mremap
REJECTED (MAYMOVE relocates → every absolute heap pointer dangles; no-MAYMOVE
growth unreliable). Grow calls are SUB-SEMANTIC (memory is substrate, not an
effect — same tier as the entry stub; they do NOT ride the effect membrane,
but the mprotect syscall IS E76-registered and preserve-checked like every
sys-lib crossing).

| Sub | Home | Deliverable | Depends |
|---|---|---|---|
| S17-A | E91-REV step 1 | Check-first allocation sequences: reorder `x-alo` + `x-bnw` (bound-check BEFORE stores), still trap policy, no grow yet. Standalone correctness slice; byte-diff expected → refixpoint; suite green | — |
| S17-B | E90-REV | `nb-arena-grow` TAL crossing in sys-tal: mprotect(committed-end, delta, RW) + heapend cell update; E76-registered (mprotect row 10 exists); PLUS the shared out-of-line grow stub (assembly glue: preserve scratch, SysV call, ret-to-retry). E90 example+spec REVISED mremap→mprotect through the pipeline; must not touch the mremap fiction (S3 retires those rows) | S17-A |
| S17-C | E91-REV step 2 | Slow-path wiring: per-site trap byte → `jbe`-to-shared-stub + retry loop (re-load heapptr, re-check); ONE shared stub per image, per-site rel32 — keeps binaries sub-MB vs inline calls at every alloc site; the slot-form emitter makes retry safe (live values in slots, rax/rcx scratch-only) | S17-B |
| S17-D | E89 step 3 | Entry-stub v3 both floors: PROT_NONE reserve + mprotect INIT_COMMIT + heapend=committed-end (reserve-end constant or third cell — spec decides); constants SINGLE-SOURCED (chirality authority, py mirrors + a cross-check test — fixes the 16G/64M must-match drift from b7b4d5e for good); py JIT `_map_rw` either adopts reserve-commit or pins the fixed discipline (spec decides, gated by S17-E semantics) | S17-C |
| S17-E | E81-ext | `growing` as a named Alloc instance beside `fixed-trap` in alloc.chiral; ELF default flips to growing, JIT/tests pin fixed; byte-identity preserved when the discipline is unchanged (E81's standing claim re-verified) | S17-C |
| S17-F | battery | Verification woven through + capstone: per-floor differential alloc goldens; grow-soak (allocate >INIT_COMMIT, watch the doubling); failure injection (RLIMIT_AS → mprotect ENOMEM → clean exit 1 + message, never OOM-kill); **the self-compile IS the real soak** — from 256KB through ~9 doublings to its ~128MB peak, fixpoint must hold byte-identical; scriba pty long-run rides S9 | each sub gates; capstone after S17-E |

Catalog hygiene: NO new E numbers — the work maps onto existing elements
(E89 ext, E90 rev, E91 rev ×2 steps, E81 ext). E90/E91 examples + specs exist
and are WRONG (mremap design, single-step E91) — they go back through
example-revision → audit → spec-revision → audit before any implement, which
is exactly what the audit gates are for. The DISPATCH-BLOCKER handoff's
"E90/E91 implemented, fixpoint" claim is false (docs-only; zero code in any
commit) — S10 owns that correction, plus a reserve-commit revision note in
MEMORY-DISCIPLINE-ARC.md.

Implement order within the wave (replaces the single S17 step):
S1 → S2 → **S17-A → S17-B → S17-C → S17-D → S17-E → S17-F capstone** → S3 →
S14 → S13 → S4 → S5. Rationale: A is a standalone correctness fix worth
landing even if the rest stalls; B/C/D each end refixpoint-able; F's capstone
doubles as the refixpoint of the whole arc.

## Dispatch queue — pipeline runs (example → audit → spec → audit, NO implement)

Nine elements, each flowing 4 stages serially; elements run parallel,
**max 3 agents live at once, Opus, worktree-isolated, --no-index**; the
orchestrator (main session) merges artifacts + appends INDEX rows as agents
return, then feeds the next stage/element into the free slot.

Element priority (mirrors implement order):
1. E96 bitwise-ops (new example)
2. E97 skip-chain-diagnostics (new example)
3. E91-REV growing-allocator (REVISION: check-first prerequisite + two-step + shared out-of-line stub)
4. E90-REV arena-grow-crossing (REVISION: mremap → mprotect reserve-commit)
5. E89-EXT arena-init (REVISION: stub v3 reserve/commit split, single-sourced constants)
6. E81-EXT alloc-discipline (REVISION: `growing` as second Alloc instance)
7. E98 honest-crossing-table (new example)
8. E99 ioctl-out-cells (new example)
9. E100 two-type-param-calls (new example)

Stage flow per element: example → `--audit example` (FIX/FLAG) → `--mark
reviewed` → `--spec` → `--audit spec` → `--mark audited` → **STOP** (implement
is a separate, explicitly-gated go per slice). E98/E99 specs carry S12(a-d)
decisions as NEEDS-AUTHOR until ruled.

## Draft catalog rows (append to SELF-IMPLEMENT-CATALOG.md §IV on go — schema-conformant)

| E96 | Bitwise op family: complete {`band`,`bor`,`bxor`,`shl`} through surface extern (`prelude.chiral`), Op ctors + printer, interp (`impl_pure.py`), py shuttle (`native.py` `_PRIMS`/`_STR2OP`) + fold list (`optimize.py:705`), erase parse (`tal-erase.chiral` op-parse), and mach-x64 reg+imm encodings with `op-bytes`/`bini-body` arms | Partially built — `band` has extern + `op-band` + erase arm (chirality only, unsynced); NO emitter arms; `bor`/`bxor`/`shl` absent everywhere; B1 built from a band-free tree | `OURS` (mach-x64.chiral:72,169,362,423; lower.chiral:143) |

| E97 | B1 lowering skip-chain diagnostics: accumulate `er-skip` reasons with blamed callee in `lower-defs` (compile-back.chiral:211-226); on missing entry label, report the drop chain root-first to stderr; resolve `native-prim?` (lower.chiral:143, apparently uncalled) to one documented authority or delete | Not built — skip reasons exist as strings, discarded at compile-back.chiral:225; `no emitted label` is the only signal | `OURS` (compile-back.chiral, lower.chiral, tal-erase.chiral:87 boundary comment) |

| E98 | Honest crossing table: implement `nb-read-key` as a real raw read (ti-bnew + ti-bptr + `read(0,ptr,n)` + return cell, matching `nb-sys-read-t`); retire `nb-read-keyseq`/`nb-sys-spawn`/`nb-null-port`/`nb-sys-env-get` stubs — remove externs (ports.chiral), wraps rows (crossing-wraps.chiral), sys-lib entries (sys-tal.chiral), sys-rows (target-linux.chiral); scriba key-sequence assembly moves to its pure key-parser | Partially built — stubs exist behind live rows: read-key/keyseq issue `read(fd,cell,0)` with NO bptr; spawn/null-port return -1; env-get returns empty cell | `OURS` (sys-tal.chiral:384-427, crossing-wraps.chiral, ports.chiral) |

| E99 | Honest ioctl surface: per-request-family crossings that allocate out-cells INSIDE the wrapper and return fresh values (`nb-tcgets` fd→60B cell, `nb-winsz` fd→8B cell; TCSETS keeps value-in shape); rework term.chiral on top so no surface-allocated Bytes is kernel-mutated (removes the pure-fragment immutability violation that fold/CSE strengthening would miscompile) | Partially built — one generic 3-arg ioctl crossing works at runtime (pty-verified) but mutates a `cell-new` (pure `->`) Bytes in place; every other kernel-writing crossing already uses the alloc-inside idiom | `OURS` (sys-tal.chiral nb-sys-read-t idiom, term.chiral, ports.chiral:150); Rust nix ioctl_read!/ioctl_write! (`IMPL`) |

| E100 | 2-type-param + fn-param call lowering: `alist-get`/`alist-put` (2 type params + fn param) callable from compile-main through B1, completing the case-on-call fix train; conformance includes deleting every inlined alist copy from scriba files | Partially built — 1-type-param + fn works (`find`, post e9e5aae); 2-type-param + fn fails; workaround copies inlined across scriba files | `OURS` (collections.chiral, lower.chiral, scriba/*.chiral; scriba-test-b1 tests 2/3 are the ready-made gate) |

