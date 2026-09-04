---
node: records-spec-tier-triage
layer: record
related: [records/README, records/doc-rot, records/findings, elements/ledger, examples/INDEX, decisions/decision-scope, status-ledger, index]
status: current
updated: 2026-09-04
---

# SPEC-tier triage — is the change plan still executable?

Every file in `docs/elements/specs/` opened at HEAD `3f6259b`, 2026-09-04, and
sorted into one of four buckets. The citation-repointing pass that preceded this
one found that the rot runs deeper than citations: a SPEC can carry correct
prose, a correct baseline and an `audited` frontmatter and still aim its whole
change plan at a compiler that was cut, or describe work that is already in the
tree.

**129 SPECs. 1 EXECUTABLE, 104 DONE-ALREADY, 8 NEEDS-REPLAN, 16 DEAD.**

This file carries no build-state authority. `docs/elements/ledger.md` and
`records/conformance-map.md` hold that, and where this pass measured a
disagreement with them it is written down below rather than corrected here.

## What the buckets mean

- **EXECUTABLE** — the change plan's targets resolve at HEAD and the work named
  is not in the tree. Ready for an implementation run.
- **DONE-ALREADY** — the tree already carries the SPEC's deliverable, in whole or
  in part. Queueing it produces phantom work. Where a slice is genuinely
  outstanding the row says so.
- **NEEDS-REPLAN** — some steps name a target that was cut or moved, and the plan
  cannot be run as written. The element's intent may still survive; each row says
  whether it does.
- **DEAD** — every step names a target the 2026-08-31 migration or
  `docs/decisions/decision-scope.md` removed. The SPEC is an artifact of a
  pipeline that no longer exists.

`exec/steps` counts steps whose target resolves at HEAD **and** whose work is not
already done, over the total step count.

## One finding above the buckets: `status:` is not a readiness signal

114 of the 129 files carry `status: audited` (111), `specced` (2) or `draft` (1),
and 10 more carry no frontmatter at all. Only four read `implemented` (E91,
E131, E144, E166) and one reads `superseded` (E86).
`docs/examples/INDEX.md` defines `audited` as "spec audit passed; implement-ready",
so on the frontmatter alone this tier reads as a 111-deep implementation queue.
It is not one. The frontmatter was never advanced when work landed, and the
advance is not mechanical: `docs/examples/INDEX.md` and `docs/elements/ledger.md`
were kept current instead, and they disagree with the SPECs beneath them in 104
cases. **No `status:` field was changed by this pass**, because a DEAD SPEC that
reads `audited` is precisely the thing this triage exists to surface.

## Every SPEC

| SPEC | `status:` | bucket | exec/steps | INDEX | ledger |
|---|---|---|---|---|---|
| `E01-sexp-reader-SPEC` | audited | **DONE-ALREADY** | 0/7 | implemented | built |
| `E02-row-inference-SPEC` | audited | **DONE-ALREADY** | 0/3 | part | part |
| `E02-surface-elaborator-SPEC` | audited | **DONE-ALREADY** | 0/5 | part | part |
| `E03-nbe-normalize-SPEC` | audited | **DONE-ALREADY** | 0/5 | implemented | built |
| `E04-bidir-universes-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E04-full-adt-kernel-SPEC` | audited | **DONE-ALREADY** | 0/0 | implemented | built |
| `E05-qtt-semiring-SPEC` | audited | **DONE-ALREADY** | 0/2 | implemented | built |
| `E06-data-ctors-coverage-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented-core | built |
| `E07-strict-positivity-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E08-linear-kinds-SPEC` | audited | **DONE-ALREADY** | 0/2 | implemented | built |
| `E09-refinement-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E10-occurrence-typing-SPEC` | audited | **DONE-ALREADY** | 0/5 | implemented | built |
| `E100-FIX-CHECKLIST` | (none) | **DONE-ALREADY** | 0/0 | audited | built |
| `E100-two-type-param-calls-SPEC` | audited | **DONE-ALREADY** | 0/12 | audited | built |
| `E101-sexp-error-context-SPEC` | audited | **DONE-ALREADY** | 0/5 | audited | built |
| `E102-sexp-enhancements-SPEC` | audited | **DONE-ALREADY** | 0/5 | audited | flight |
| `E103-term-raw-SPEC` | audited | **DONE-ALREADY** | 0/5 | implemented | built |
| `E104-pty-crossings-SPEC` | audited | **DONE-ALREADY** | 0/6 | implemented | built |
| `E106-linear-cap-collection-SPEC` | audited | **DONE-ALREADY** | 0/5 | audited | built |
| `E107-cap-close-SPEC` | audited | **DONE-ALREADY** | 0/3 | audited | built |
| `E108-shift-ops-SPEC` | audited | **DONE-ALREADY** | 0/3 | audited | built |
| `E109-bput-u16-le-SPEC` | audited | **DONE-ALREADY** | 0/2 | audited | built |
| `E11-totality-checker-SPEC` | audited | **DONE-ALREADY** | 0/6 | implemented | built |
| `E110-cloexec-pty-SPEC` | audited | **DONE-ALREADY** | 0/2 | audited | built |
| `E111-cell-store-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E112-apc-sidechannel-SPEC` | audited | **DONE-ALREADY** | 0/5 | implemented | built |
| `E113-pool-read-SPEC` | audited | **DONE-ALREADY** | 0/4 | audited | flight |
| `E12-effect-membrane-SPEC` | audited | **DONE-ALREADY** | 0/3 | implemented | built |
| `E120-native-pool-SPEC` | audited | **DONE-ALREADY** | 0/5 | implemented | built |
| `E121-fcntl-SPEC` | audited | **DONE-ALREADY** | 0/3 | audited | built |
| `E122-native-pool-create-SPEC` | audited | **DONE-ALREADY** | 0/2 | implemented | built |
| `E123-native-porttype-carrier-SPEC` | audited | **DONE-ALREADY** | 0/3 | audited | built |
| `E124-adopt-fd-SPEC` | audited | **DONE-ALREADY** | 0/3 | audited | built |
| `E125-sock-use-SPEC` | audited | **DONE-ALREADY** | 0/3 | implemented | built |
| `E126-socketpair-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E127-sock-connect-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E128-apc-handshake-SPEC` | audited | **NEEDS-REPLAN** | 0/4 | audited | design |
| `E129-sock-connect-in-SPEC` | audited | **DONE-ALREADY** | 0/5 | audited | design |
| `E13-debruijn-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E130-http-native-SPEC` | audited | **DONE-ALREADY** | 0/4 | audited | design |
| `E131-sse-stream-SPEC` | implemented | **DONE-ALREADY** | 0/5 | implemented | built |
| `E133-manas-core-types-SPEC` | audited | **DONE-ALREADY** | 0/1 | implemented | built |
| `E134-gate-SPEC` | audited | **DONE-ALREADY** | 0/2 | implemented | built |
| `E135-bind-SPEC` | audited | **DONE-ALREADY** | 0/2 | implemented | built |
| `E136-match-assemble-stop-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E138-run-loop-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E139-be-log-SPEC` | audited | **DONE-ALREADY** | 0/3 | implemented | built |
| `E14-pretty-printer-SPEC` | audited | **DONE-ALREADY** | 0/3 | implemented | built |
| `E140-profiles-docrefine-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E141-golden-conformance-SPEC` | audited | **DONE-ALREADY** | 0/3 | implemented | built |
| `E144-str-porttype-carrier-SPEC` | implemented | **DONE-ALREADY** | 0/3 | implemented | built |
| `E15-reference-interpreter-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E150-argv-SPEC` | specced | **NEEDS-REPLAN** | 1/7 | specced | design |
| `E151-ord-dedup-SPEC` | audited | **DONE-ALREADY** | 0/7 | audited | built |
| `E156-sort-adopt-SPEC` | audited | **DONE-ALREADY** | 0/6 | audited | built |
| `E157-typed-diagnostics-SPEC` | audited | **DONE-ALREADY** | 0/6 | audited | built |
| `E158-doc-formatter-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E16-lowering-SPEC` | audited | **DONE-ALREADY** | 0/5 | implemented | built |
| `E161-kind-identifier-SPEC` | audited | **DONE-ALREADY** | 0/8 | audited | built |
| `E166-mach-c-SPEC` | implemented | **DEAD** | 0/7 | implemented | built |
| `E168-test-floor-SPEC` | audited | **DONE-ALREADY** | 0/6 | implemented | built |
| `E17-AUTOSPEC-V2-SPEC` | (none) | **DEAD** | 0/5 | implemented | built |
| `E17-optimizer-SPEC` | audited | **DONE-ALREADY** | 0/5 | implemented | built |
| `E170-corpus-migration-SPEC` | audited | **DEAD** | 0/0 | audited | design |
| `E173-total-matcher-SPEC` | audited | **DONE-ALREADY** | 0/7 | implemented | BUILT |
| `E174-r-row-width-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E175-face-restore-SPEC` | audited | **DONE-ALREADY** | 0/3 | implemented | built |
| `E18-tal-check-SPEC` | audited | **DONE-ALREADY** | 0/5 | implemented | built |
| `E181-pretty-term-doc-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | BUILT |
| `E182-arity-evidence-SPEC` | audited | **DONE-ALREADY** | 0/5 | implemented | built |
| `E185-type-preserving-upper-SPEC` | audited | **DONE-ALREADY** | 0/7 | built | built |
| `E20-loader-SPEC` | audited | **NEEDS-REPLAN** | 1/4 | audited | built |
| `E21-arena-SPEC` | audited | **DONE-ALREADY** | 0/4 | audited | built |
| `E22-regions-SPEC` | audited | **NEEDS-REPLAN** | 0/4 | audited | design |
| `E24-i64-arith-SPEC` | audited | **NEEDS-REPLAN** | 1/2 | audited | built |
| `E25-byte-cells-SPEC` | audited | **DONE-ALREADY** | 0/2 | audited | built |
| `E26-alarm-control-flow-SPEC` | audited | **DEAD** | 0/5 | audited | built |
| `E27-dict-set-to-maps-SPEC` | audited | **DONE-ALREADY** | 0/6 | implemented | built |
| `E28-mmap-crossings-SPEC` | audited | **DONE-ALREADY** | 0/3 | implemented | built |
| `E29-sockets-SPEC` | audited | **DONE-ALREADY** | 0/6 | implemented | built |
| `E30-fd-passing-SPEC` | audited | **DONE-ALREADY** | 0/5 | implemented | built |
| `E31-poll-SPEC` | audited | **DONE-ALREADY** | 0/6 | audited | built |
| `E32-clock-exit-env-SPEC` | audited | **DONE-ALREADY** | 0/6 | implemented | built |
| `E33-process-spawn-SPEC` | audited | **DONE-ALREADY** | 0/6 | audited | built |
| `E34-elf-writer-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E38-graded-cost-SPEC` | audited | **DEAD** | 0/4 | audited | design |
| `E39-effect-row-SPEC` | audited | **DEAD** | 0/7 | audited | design |
| `E41-region-types-SPEC` | audited | **NEEDS-REPLAN** | 2/4 | audited | design |
| `E42-alarm-supervisor-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E45-reflective-floor-SPEC` | audited | **DONE-ALREADY** | 0/4 | audited | design |
| `E47-sized-types-SPEC` | audited | **DEAD** | 0/4 | audited | design |
| `E48-telescopes-SPEC` | audited | **DEAD** | 0/4 | audited | design |
| `E50-mutual-lex-termination-SPEC` | audited | **DEAD** | 0/5 | implemented | built |
| `E51-sys-linkage-SPEC` | audited | **DONE-ALREADY** | 0/5 | audited | built |
| `E52-certificate-split-SPEC` | audited | **NEEDS-REPLAN** | 1/5 | implemented | design |
| `E53-ddc-bootstrap-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E57-staging-modality-SPEC` | draft | **DEAD** | 0/5 | specced | design |
| `E69-closure-conversion-DESIGN` | (none) | **DEAD** | 0/5 | audited | design |
| `E69-closure-conversion-SPEC` | audited | **DEAD** | 0/4 | audited | design |
| `E70-effectful-lowering-DESIGN` | (none) | **DEAD** | 0/0 | audited | design |
| `E70-effectful-lowering-SPEC` | audited | **DEAD** | 0/4 | audited | design |
| `E71-golden-restructure-SPEC` | audited | **DONE-ALREADY** | 2/4 | audited | design |
| `E72-re-bootstrap-SPEC` | audited | **DONE-ALREADY** | 1/4 | audited | design |
| `E80-cap-to-main-SPEC` | audited | **NEEDS-REPLAN** | 2/5 | audited | design |
| `E81-alloc-seam-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E86-ioctl-crossing-SPEC` | superseded | **DEAD** | 0/8 | superseded | superseded |
| `E87-import-resolution-SPEC` | audited | **DONE-ALREADY** | 0/5 | audited | built |
| `E88-mark-region-SPEC` | audited | **DONE-ALREADY** | 0/3 | audited | built |
| `E89-arena-init-SPEC` | audited | **DONE-ALREADY** | 0/5 | implemented | built |
| `E90-arena-grow-crossing-SPEC` | audited | **DONE-ALREADY** | 0/6 | implemented | built |
| `E91-growing-allocator-SPEC` | implemented | **DONE-ALREADY** | 0/6 | implemented | built |
| `E92-effect-chain-decoupling-SPEC` | audited | **DONE-ALREADY** | 0/3 | audited | built |
| `E93-lowering-multi-pass-SPEC` | audited | **DONE-ALREADY** | 0/1 | implemented | built |
| `E94-form-type-capacity-SPEC` | audited | **DONE-ALREADY** | 0/5 | audited | flight |
| `E95-effectful-mutual-recursion-SPEC` | audited | **DONE-ALREADY** | 0/0 | implemented | built |
| `E96-bitwise-ops-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E97-skip-chain-diagnostics-SPEC` | audited | **DONE-ALREADY** | 0/4 | implemented | built |
| `E98-honest-crossing-table-SPEC` | audited | **DONE-ALREADY** | 0/5 | implemented | built |
| `E99-ioctl-out-cells-SPEC` | audited | **DONE-ALREADY** | 0/8 | implemented | built |
| `FACT-CARRYING-LOWERING-SPEC` | (none) | **DEAD** | 0/6 | — | — |
| `N01-crypto-kernels-SPEC` | audited | **EXECUTABLE** | 2/4 | audited | — |
| `S1-puffer-SPEC` | audited | **DONE-ALREADY** | 0/9 | — | — |
| `S13-vim-modes-SPEC` | (none) | **DONE-ALREADY** | 0/0 | — | — |
| `S14-manas-author-mode-SPEC` | (none) | **DONE-ALREADY** | 0/0 | — | — |
| `S15-manas-run-view-SPEC` | (none) | **DONE-ALREADY** | 0/0 | — | — |
| `S16-manas-compose-SPEC` | (none) | **DONE-ALREADY** | 0/0 | — | — |
| `S17-manas-token-streaming-SPEC` | (none) | **DONE-ALREADY** | 0/0 | — | — |
| `S18-scriba-record-SPEC` | specced | **DONE-ALREADY** | 0/2 | — | — |
| `S2-rendering-SPEC` | audited | **DONE-ALREADY** | 0/9 | — | — |

## DEAD — 16

Every step names a target the oracle eviction or the 2026-09-01 backend cut
removed. None of these can be run, and none should be queued.

| SPEC | exec/steps | evidence, and what has to happen next |
|---|---|---|
| `E166-mach-c-SPEC` | 0/7 | The `Mach`-to-C backend was cut 2026-09-01; the SPEC records a build that no longer exists. |
| `E17-AUTOSPEC-V2-SPEC` | 0/5 | Retire or re-found: its baseline is `optimize.autospec` in the oracle and all three of its named dependencies are DEAD. |
| `E170-corpus-migration-SPEC` | 0/0 | The 709-function corpus it migrates was deleted with `scaffold/`; only the `or-python` retirement survives as intent. |
| `E26-alarm-control-flow-SPEC` | 0/5 | Re-found on the built effect row; Step 1's `KontMsg` already landed under E42. |
| `E38-graded-cost-SPEC` | 0/4 | Re-example against `lib/typing/kernel.chiral` before any SPEC is written again. |
| `E39-effect-row-SPEC` | 0/7 | Re-example: the row algebra it plans already exists in `lib/typing/effects.chiral`. |
| `E47-sized-types-SPEC` | 0/4 | Re-example against `lib/typing/totality.chiral`. |
| `E48-telescopes-SPEC` | 0/4 | Re-example against `lib/surface/data.chiral`. |
| `E50-mutual-lex-termination-SPEC` | 0/5 | Nothing to run; the ledger already reads `built` on `lib/typing/totality.chiral`. |
| `E57-staging-modality-SPEC` | 0/5 | Re-example from scratch; five oracle modules, no live successor named. |
| `E69-closure-conversion-DESIGN` | 0/5 | Design companion to the DEAD SPEC; keep as rationale, do not queue. |
| `E69-closure-conversion-SPEC` | 0/4 | Nothing to run: closure conversion is live at `lib/lowering/upper/closconv.chiral`. |
| `E70-effectful-lowering-DESIGN` | 0/0 | Design companion to the DEAD SPEC; keep as rationale, do not queue. |
| `E70-effectful-lowering-SPEC` | 0/4 | Nothing to run: the `=>` gate is live in `lib/module/sig-driver.chiral`. |
| `E86-ioctl-crossing-SPEC` | 0/8 | Already `superseded` in all three registers; no action. |
| `FACT-CARRYING-LOWERING-SPEC` | 0/6 | Unnumbered, unfrontmattered, six steps at `tal.py`/`lower.py`. Retire or re-example. |

## NEEDS-REPLAN — 8

| SPEC | exec/steps | evidence, and what has to happen next |
|---|---|---|
| `E128-apc-handshake-SPEC` | 0/4 | Every target is a `TUI/` path; repoint at `lib/protocol/apc.chiral` and `tools/test/samples/`. Intent survives whole. |
| `E150-argv-SPEC` | 1/7 | Only B1 resolves. B3's stated home is wrong: `read`/`write-fd` are `lib/ports/fd.port:34-35`, not the process block. |
| `E20-loader-SPEC` | 1/4 | Only Step 2 (`nb-blit`) survives; the code loader is unbuilt and the ledger's `built` is a mis-read of the module loader. |
| `E22-regions-SPEC` | 0/4 | Three steps name `lib/mem-region.chiral`, which moved to `lib/memory/`; the fourth is a cut test file. Intent survives. |
| `E24-i64-arith-SPEC` | 1/2 | Step 1 is executable at `lib/prelude/prelude.chiral`; Step 2's gate must be rehomed on `tools/test/`. |
| `E41-region-types-SPEC` | 2/4 | Steps 2-3 resolve; Step 1 (`refine.py`) and Step 4 (`scaffold/tests/`) need new homes. |
| `E52-certificate-split-SPEC` | 1/5 | Already self-annotated DEAD TARGET on A1-A4; B1 partly landed. Intent survives, gate does not. |
| `E80-cap-to-main-SPEC` | 2/5 | Steps 1-2 resolve at `lib/ports/ports.chiral`; Steps 3-5 need a live home for the profile clause and the mint. |

## DONE-ALREADY — 104

The dangerous bucket. A row marked ⚑ is one whose `docs/examples/INDEX.md`
status still reads implement-ready (`audited` or `specced`) while the work is
in the tree: those 31 are the ones a scheduler would pick up.

| SPEC | exec/steps | live evidence |
|---|---|---|
| `E01-sexp-reader-SPEC` | 0/7 | `lib/surface/sexp.chiral` carries the whole reader; Step 7's target is the cut oracle. |
| `E02-row-inference-SPEC` | 0/3 | `lib/typing/row-infer.chiral:27` carries `RowSig`; Step 3's target is the cut oracle. |
| `E02-surface-elaborator-SPEC` | 0/5 | `lib/surface/surface.chiral:291` carries `cond-to-case`; the element is `part`, the residue is named in the ledger. |
| `E03-nbe-normalize-SPEC` | 0/5 | `lib/typing/kernel.chiral:672-784` carries eval/quote/conv. |
| `E04-bidir-universes-SPEC` | 0/4 | `lib/typing/kernel.chiral` :799 `subtype`, :819 `infer`, :937 `check`, :967 `subsume`. |
| `E04-full-adt-kernel-SPEC` | 0/0 | Self-annotates slices 1-3 IMPLEMENTED; slice 4 is the residue and has no step list. |
| `E05-qtt-semiring-SPEC` | 0/2 | `lib/typing/qtt.chiral:14-71` carries the whole semiring. |
| `E06-data-ctors-coverage-SPEC` | 0/4 | `lib/surface/data.chiral:31-111` + `lib/typing/kernel.chiral:1036-1299`. |
| `E07-strict-positivity-SPEC` | 0/4 | `lib/surface/data.chiral:186-322`. |
| `E08-linear-kinds-SPEC` | 0/2 | `lib/surface/data.chiral:332-375`. |
| `E09-refinement-SPEC` | 0/4 | `lib/typing/refine.chiral:63` carries `is-empty`. |
| `E10-occurrence-typing-SPEC` | 0/5 | `lib/typing/refine.chiral:144-146` carries the atom constructors. |
| ⚑ `E100-FIX-CHECKLIST` | 0/0 | A checklist companion, no frontmatter and no steps; folded into the E100 finding. |
| ⚑ `E100-two-type-param-calls-SPEC` | 0/12 | `lib/lowering/upper/closconv.chiral:704,954,984,1104,1170` carry the E100 fix. Step 5 has no live target. |
| ⚑ `E101-sexp-error-context-SPEC` | 0/5 | `lib/surface/sexp.chiral:136-154` carries `pos-line`/`pos-col`. |
| ⚑ `E102-sexp-enhancements-SPEC` | 0/5 | `lib/surface/sexp.chiral:276-287` carries `read-all-forms`. |
| `E103-term-raw-SPEC` | 0/5 | `lib/protocol/term.chiral:72-73` carries the `RAW_*` masks. |
| `E104-pty-crossings-SPEC` | 0/6 | `lib/ports/pty.port:14-20` carries the `Pty` porttype and its result sums. |
| ⚑ `E106-linear-cap-collection-SPEC` | 0/5 | `lib/capability/lincoll.chiral:26-81` carries `SockVec`, `sv-drain`, `mux-step`. |
| ⚑ `E107-cap-close-SPEC` | 0/3 | `lib/lowering/tal/crossing-wraps.chiral:42-44` carries all three E107 pairs, commented E107. |
| ⚑ `E108-shift-ops-SPEC` | 0/3 | `lib/prelude/prelude.chiral:70-71` carries `shr` and `sar`. |
| ⚑ `E109-bput-u16-le-SPEC` | 0/2 | `lib/lowering/tal/bytes.chiral:628` carries `bput-u16-le`. |
| `E11-totality-checker-SPEC` | 0/6 | `lib/typing/totality.chiral:365-371`. |
| ⚑ `E110-cloexec-pty-SPEC` | 0/2 | `lib/lowering/tal/sys.chiral` `nb-sys-open-rw-t` has the O_CLOEXEC constant 524546. |
| `E111-cell-store-SPEC` | 0/4 | `lib/protocol/grid.chiral`; every step names a `TUI/vt-core/` path. |
| `E112-apc-sidechannel-SPEC` | 0/5 | `lib/protocol/apc.chiral:89,207` carry `enc`/`dec`; `vt-parser.chiral:25` carries `Action`. |
| ⚑ `E113-pool-read-SPEC` | 0/4 | `lib/ports/pool.port:30` carries `pool-read`, commented `E113/E120`. Steps 1-2 self-annotate DONE (E120). |
| `E12-effect-membrane-SPEC` | 0/3 | `lib/typing/effects.chiral:18-19` carries `row-sub`. |
| `E120-native-pool-SPEC` | 0/5 | The pool crossings are live in `lib/lowering/tal/sys.chiral`; `tools/test/samples/e120_pool_roundtrip.prog` exists. |
| ⚑ `E121-fcntl-SPEC` | 0/3 | `lib/ports/fd.port:36` carries `fcntl` commented `E121:`; `sys.chiral:208`; `crossing-wraps.chiral:45`; `tools/test/samples/e121_fcntl.prog`. |
| `E122-native-pool-create-SPEC` | 0/2 | `pool-create` is live at `lib/ports/pool.port:26`. |
| ⚑ `E123-native-porttype-carrier-SPEC` | 0/3 | `lib/lowering/compile-front.chiral` `term->ntalty` carries `porttype-word?`/`porttype-str?`. |
| ⚑ `E124-adopt-fd-SPEC` | 0/3 | `lib/ports/fd.port:32` carries `adopt-fd`; `lib/lowering/tal/erase.chiral:111` carries `prim2lib-table`. |
| `E125-sock-use-SPEC` | 0/3 | `lib/lowering/tal/sys.chiral:1308` `sys-lib`; the refine arm cites E125 in `compile-front.chiral`. |
| `E126-socketpair-SPEC` | 0/4 | The socketpair crossing is live; every step names `scaffold/lib/`. |
| `E127-sock-connect-SPEC` | 0/4 | `lib/lowering/tal/sys.chiral:901` `nb-sa-un-pack-t`, `:919` `nb-sock-connect-t`. |
| ⚑ `E129-sock-connect-in-SPEC` | 0/5 | `lib/protocol/inet.chiral:17-99`, `sys.chiral:961`, `crossing-wraps.chiral:41` all cite E129. |
| `E13-debruijn-SPEC` | 0/4 | The core `Term` and its de-Bruijn ops live in `lib/typing/kernel.chiral`. |
| ⚑ `E130-http-native-SPEC` | 0/4 | `lib/protocol/http.chiral:101,134,357,437` carry `parse-url`, `format-request`, `parse-response`, `http-request`. |
| `E131-sse-stream-SPEC` | 0/5 | Frontmatter already reads `implemented`; every step names `scaffold/`. |
| `E133-manas-core-types-SPEC` | 0/1 | `prog/manas/core/` exists. |
| `E134-gate-SPEC` | 0/2 | `prog/manas/core/` exists. |
| `E135-bind-SPEC` | 0/2 | `prog/manas/core/` exists. |
| `E136-match-assemble-stop-SPEC` | 0/4 | `prog/manas/core/match.chiral:25`, `assemble.chiral:14-48`, `stop.chiral:15`. |
| `E138-run-loop-SPEC` | 0/4 | `prog/manas/pipeline/plan.chiral`, `runner.chiral`, `guarded.chiral` all exist. |
| `E139-be-log-SPEC` | 0/3 | `prog/manas/pipeline/log.chiral` exists. |
| `E14-pretty-printer-SPEC` | 0/3 | The printer is live at `lib/surface/pretty.chiral`; E181 replaced its body wholesale and moved the module key. |
| `E140-profiles-docrefine-SPEC` | 0/4 | `prog/manas/profile/profiles.chiral:15-29`, `doc-refine.chiral:16-23`. |
| `E141-golden-conformance-SPEC` | 0/3 | `prog/manas/contract/` exists. |
| `E144-str-porttype-carrier-SPEC` | 0/3 | Frontmatter already reads `implemented`. |
| `E15-reference-interpreter-SPEC` | 0/4 | `lib/evidence/interp.chiral:50-100`. |
| ⚑ `E151-ord-dedup-SPEC` | 0/7 | `lib/prelude/string.chiral:209` carries `str-pad`; `lib/typing/row-infer.chiral:103` adopts `list-dedup-adj`. |
| ⚑ `E156-sort-adopt-SPEC` | 0/6 | `lib/prelude/list.chiral:186` carries `list-dedup-adj`; `tools/test/samples/e156_dedup_adj.prog` exists. Step 4's Phase number is owed, not free. |
| ⚑ `E157-typed-diagnostics-SPEC` | 0/6 | `lib/typing/diag.chiral` exists, `XErr` is retired (`lib/module/loader.chiral:63`), and Phase 13 runs `tools/test/diag.sh`. Step 6's `run-native.sh` Phase 10 does not exist. |
| `E158-doc-formatter-SPEC` | 0/4 | `lib/prelude/doc.chiral` and `lib/protocol/render-doc.chiral` exist; Phase 14 and 17 run. |
| `E16-lowering-SPEC` | 0/5 | `lib/lowering/upper/lower.chiral:98-412`. |
| ⚑ `E161-kind-identifier-SPEC` | 0/8 | `lib/typing/kernel.chiral:237` carries the ninth `sheets` field; `parse.chiral:1166` `handle-kind`; `loader.chiral:279` `SheetErr`. |
| `E168-test-floor-SPEC` | 0/6 | `lib/evidence/test-floor.chiral:51-902` carries the whole floor; `prog/test-runner.prog:37-39` adopts it. |
| `E17-optimizer-SPEC` | 0/5 | `lib/lowering/upper/optimize.chiral:108` carries `fold-block`. |
| `E173-total-matcher-SPEC` | 0/7 | `lib/text/matcher.chiral` + `tools/test/matcher.sh` (Phase 19) exist. Slice 1 only; the ledger says so. |
| `E174-r-row-width-SPEC` | 0/4 | `lib/protocol/render.chiral` + `tools/test/row.sh` (Phase 15). |
| `E175-face-restore-SPEC` | 0/3 | `lib/protocol/render.chiral:366,394` carry `face-join`/`rnd-restore`; Phase 16 runs `face.sh`. |
| `E18-tal-check-SPEC` | 0/5 | `lib/lowering/tal/check.chiral:57-200` + `lib/lowering/tal/eval.chiral:24-29`. |
| `E181-pretty-term-doc-SPEC` | 0/4 | `lib/surface/pretty.chiral` + Phase 18 `tools/test/pretty.sh`. |
| `E182-arity-evidence-SPEC` | 0/5 | `lib/typing/diag.chiral:141` carries `r-arity`; Phase 24 runs `tools/test/arity.sh`. |
| `E185-type-preserving-upper-SPEC` | 0/7 | `lib/lowering/compile-front.chiral:202` `sp-get`, `closconv.chiral:1096` `apply-ty`, `tools/test/samples/e185_apply_word.prog`. |
| ⚑ `E21-arena-SPEC` | 0/4 | `lib/memory/arena.chiral` exists; Steps 3-4 target the cut oracle. |
| ⚑ `E25-byte-cells-SPEC` | 0/2 | `lib/lowering/tal/bytes.chiral` is the cell builder. |
| `E27-dict-set-to-maps-SPEC` | 0/6 | The `Ord`/`Map`/`Set` surface is live; every step names `scaffold/lib/collections.chiral`. |
| `E28-mmap-crossings-SPEC` | 0/3 | `lib/lowering/tal/sys.chiral:99` `nb-sys-mmap-t`. |
| `E29-sockets-SPEC` | 0/6 | `lib/ports/sock.port` carries the result sums and the crossings. |
| `E30-fd-passing-SPEC` | 0/5 | Landed; every step names `scaffold/lib/`. |
| ⚑ `E31-poll-SPEC` | 0/6 | `lib/lowering/tal/sys.chiral:302` `nb-sys-poll-t`, `:310` `nb-pollfd-fill-t`, `lib/runtime/poll.chiral`. |
| `E32-clock-exit-env-SPEC` | 0/6 | `lib/ports/clock.port` + `lib/ports/process.port:13-14`. |
| ⚑ `E33-process-spawn-SPEC` | 0/6 | `lib/runtime/proc.chiral:51-103` carries `argv->pkt` and `raw-proc-spawn`. |
| `E34-elf-writer-SPEC` | 0/4 | `lib/lowering/x64/elf.chiral`; the entry stub is `lib/lowering/compile-emit.chiral:59`. |
| `E42-alarm-supervisor-SPEC` | 0/4 | `lib/runtime/supervisor.chiral:34-90` carries `KontMsg`, `notify`, `fire-earliest`. |
| ⚑ `E45-reflective-floor-SPEC` | 0/4 | `lib/typing/reflect-floor.chiral:27-54` carries `SigB`/`Frozen`/`freeze`/`reflect-formers`/`recheck`. |
| ⚑ `E51-sys-linkage-SPEC` | 0/5 | Step 2 landed as `lib/lowering/tal/sys-linkage.chiral`; Steps 1,3,4,5 name the cut `runtime.py`/`impl_ports.py`. |
| `E53-ddc-bootstrap-SPEC` | 0/4 | Step 1 landed as `lib/evidence/ddc.chiral`; the Python driver is evicted. OT track, deferred. |
| ⚑ `E71-golden-restructure-SPEC` | 2/4 | Self-annotated: Steps 3-4 SHIPPED under `docs/definitions/`. OT track, deferred, do not queue. |
| ⚑ `E72-re-bootstrap-SPEC` | 1/4 | `docs/definitions/bootstrap.md` and `prog/climb.manifest` exist. OT track, deferred, do not queue. |
| `E81-alloc-seam-SPEC` | 0/4 | `lib/memory/alloc-fixed.chiral` + `alloc-growing.chiral`; Step 2a names cut Python tests. |
| ⚑ `E87-import-resolution-SPEC` | 0/5 | `lib/module/resolve.chiral:366` carries `bundle`. |
| ⚑ `E88-mark-region-SPEC` | 0/3 | `prog/scriba/mark-region.chiral` exists. |
| `E89-arena-init-SPEC` | 0/5 | `lib/lowering/compile-emit.chiral:59-81` carries the three arena cells. |
| `E90-arena-grow-crossing-SPEC` | 0/6 | `nb-arena-commit-t`/`nb-arena-grow-t` are in `lib/lowering/tal/sys.chiral:1340`'s chain. |
| `E91-growing-allocator-SPEC` | 0/6 | Frontmatter already reads `implemented`. |
| ⚑ `E92-effect-chain-decoupling-SPEC` | 0/3 | `try-dispatch` is live; `prog/scriba/command-loop.chiral:481,687`. |
| `E93-lowering-multi-pass-SPEC` | 0/1 | The pre-scan invariant is documented in `lib/lowering/compile-back.chiral`. |
| ⚑ `E94-form-type-capacity-SPEC` | 0/5 | `lib/module/load-batch.chiral` exists. |
| `E95-effectful-mutual-recursion-SPEC` | 0/0 | A diagnosis record with no step list; its follow-on E97 landed. |
| `E96-bitwise-ops-SPEC` | 0/4 | `lib/prelude/prelude.chiral:66-68` carries `band`/`bor`/`bxor`. |
| `E97-skip-chain-diagnostics-SPEC` | 0/4 | `lib/lowering/skip-diag.chiral` exists and `SkReason` is at `:11`. |
| `E98-honest-crossing-table-SPEC` | 0/5 | The crossing table is live at `lib/lowering/tal/crossing-wraps.chiral`. |
| `E99-ioctl-out-cells-SPEC` | 0/8 | The winsize/termios wrappers are live; every step names `scaffold/lib/`. |
| `S1-puffer-SPEC` | 0/9 | `prog/scriba/puffer.chiral` carries every body the SPEC calls a stub (:55,:71,:92,:144,:150). |
| `S13-vim-modes-SPEC` | 0/0 | `prog/scriba/vim-mode.chiral` exists; no frontmatter, no step list. |
| `S14-manas-author-mode-SPEC` | 0/0 | `prog/scriba/manas-mode.chiral` + `scriba-manas-test.prog` exist. |
| `S15-manas-run-view-SPEC` | 0/0 | `prog/scriba/manas-runview.chiral` + `scriba-runview-test.prog` exist. |
| `S16-manas-compose-SPEC` | 0/0 | `prog/manas/pipeline/compose.chiral` exists. |
| `S17-manas-token-streaming-SPEC` | 0/0 | `prog/scriba/scriba-runview-stream-test.prog` exists. |
| `S18-scriba-record-SPEC` | 0/2 | `prog/scriba/editor-state.chiral` exists and cites S18 at `:3`; `dispatch.chiral:37,45` adopt it. Frontmatter still reads `specced`. |
| `S2-rendering-SPEC` | 0/9 | `lib/protocol/render.chiral:263,718,778,786` carry `diff-node` and all three `render-to-ansi*`. |

## EXECUTABLE — 1

| SPEC | exec/steps | what is left |
|---|---|---|
| `N01-crypto-kernels-SPEC` | 2/4 | Slices 3-4 (BLAKE2s, X25519) are unbuilt and their targets resolve under `lib/crypto/`; slices 1-2 already landed. |

## Where the ledger or the catalog carries a wrong build-state

Measured, not corrected. `docs/elements/ledger.md` and `docs/elements/catalog.md`
were not edited by this pass; another agent's work touches them. The authority
order is the ledger's own: `records/conformance-map.md` wins over the ledger, and
the ledger's State column is a pointer rather than a snapshot.

**A. The ledger reads `design` and the capability is in the tree.** These are the
worst of the set, because `design` reads *nothing exists yet*.

| element | ledger | measured at HEAD |
|---|---|---|
| E45 | `design` | `lib/typing/reflect-floor.chiral:27-54` — `SigB`, `Frozen`, `freeze`, `reflect-formers`, `install-former`, `install-vhook`, and the `recheck`/`stage-successor` declares. Steps 1-3 of the SPEC, all present. |
| E69 | `design` | `lib/lowering/upper/closconv.chiral:1` names itself E69 closure conversion; `lib/lowering/upper/closconv-driver.chiral:2` is "the E69 STATEFUL DRIVER (the deferred piece)". |
| E70 | `design` | `lib/module/sig-driver.chiral:61` `eff-eligible?` is "the E70 `=>` gate for a def"; `:70` `check-def-row` is "the E70 preserve-check"; `lib/lowering/compile-emit.chiral:17` imports `link-lib` for E70. |
| E129 | `design` | `lib/protocol/inet.chiral:17-99`, `lib/lowering/tal/sys.chiral:961` `nb-sock-connect-in-t`, `lib/lowering/tal/crossing-wraps.chiral:41` — all three cite E129 by name. |
| E130 | `design` | `lib/protocol/http.chiral` :101 `parse-url`, :134 `format-request`, :357 `parse-response`, :437 `http-request` as a `def`, so the extern swap of Step 4 also landed. |

**B. The ledger reads `built` and the work is not there.**

| element | ledger | measured at HEAD |
|---|---|---|
| E20 | `built` | The SPEC's loader is the RW-mmap → `mprotect` → executable code loader. `lib/module/loader.chiral` is a different thing — its own header calls it "the compiler LOADER … read → elaborate → bridge Core→Term". `nb-blit`, the SPEC's Step 2, is absent from `lib/`. The `built` cell looks like a name collision between two loaders. |
| E24 | `built` | `div`, `mod`, `divmod` and `try-div` are absent from `lib/prelude/prelude.chiral`. The floor agreement under them is built; the refined safe path the SPEC delivers is not. |

**C. `docs/examples/INDEX.md` reads implement-ready and the work is in the tree.**
31 rows, every ⚑ in the DONE-ALREADY table above. The four the repointing pass
named are confirmed, each against its live line:

| element | INDEX | live line |
|---|---|---|
| E121 | `audited` | `lib/ports/fd.port:36` — `(extern fcntl …)` carrying the comment `E121:`. Also `lib/lowering/tal/sys.chiral:208`, `crossing-wraps.chiral:45`, and the fixture `tools/test/samples/e121_fcntl.prog`. |
| E113 | `audited` | `lib/ports/pool.port:30` — `pool-read`, under a comment reading `E113/E120`. The SPEC's own Steps 1 and 2 already self-annotate **DONE (E120)**, so the work landed under a different element number. |
| E124 | `audited` | `lib/ports/fd.port:32` — `(extern adopt-fd (=> I64 Fd))`, and `lib/lowering/tal/erase.chiral:111` `prim2lib-table`, the SPEC's Step 2. |
| E161 | `audited` | `lib/typing/kernel.chiral:237` — `(sheets (List Sheet))`, the ninth `Sig` field, already destructured across every `mk-sig` site in the file. |

**D. Work that landed under a different element number.** Checked because a
catalog row can be right about the capability and wrong about who built it.

- **E113** → built by **E120** (the `pool.port:30` comment says so in the source).
- **E26 Step 1** → `KontMsg` and the alarm record landed under **E42**, at
  `lib/runtime/supervisor.chiral:34`. The other four E26 steps are DEAD.
- **E51 Step 2** → `lib/lowering/tal/sys-linkage.chiral` exists and is the SPEC's
  binding table. The other four steps name the cut host runtime.
- **E14** → the printer it specs was replaced wholesale by **E181**
  (`lib/surface/pretty.chiral`), and E181's own notes record the module move.

## Two SPEC premises that are wrong rather than stale

**The `run-native.sh` phase numbers.** E156 Step 4, E157 Step 6 and E161 Step 8
each propose a new phase in a script that no longer exists;
`tools/test/MIGRATION-NOTES.md` records that 7 of 12 old phases were ported, that
numbering restarted at 13, and that **8 through 12 are names still owed**. E157's
"Phase 10" and the sibling proposals would each reuse an owed number and make an
unported gate look ported. All three elements did land, at Phases 13, 14 and
their siblings, so nothing is blocked — but the numbers in the SPECs are wrong,
not out of date.

**E150 Step B3's home.** The SPEC and the E150 example §6 both place `argv-raw`
"in the `; ---- process` block beside `read`/`write-fd`". That is two files at
HEAD: `read` and `write-fd` are `lib/ports/fd.port:34-35`, and the process block
is `lib/ports/process.port:13-18`. `lib/ports/ports.chiral` is a 63-line façade
that defines no `def` at all, so the single-pass-loader rule the SPEC leans on has
no live line to stand on.

**E100 Step 5's symbol.** The step deletes an inlined alist copy from
`lookup-renderer`. `lib/protocol/render.chiral` is the verified successor and
defines no `lookup-renderer` anywhere in the tree; the only occurrence is a
comment listing at `prog/scriba/command-loop.chiral:13`. The other eleven E100
steps are done — `lib/lowering/upper/closconv.chiral` carries the fix at :704,
:954, :984, :1104 and :1170.

## What the tree should do about it

1. **Do not schedule off `status:`.** The field is stale in 104 of 129 files and
   correcting it is a pipeline stage, not a triage. Until it is advanced, the
   readiness question is answered by `docs/examples/INDEX.md` plus the live tree,
   and this record is the join.

2. **The DEAD 16 need a disposition, not a repair.** Nine of them (E38, E39, E47,
   E48, E50, E57, E69, E70, E17-AUTOSPEC-V2) plan against oracle modules whose
   behaviour now lives in `lib/` under other element numbers. Replanning them is
   a fresh worked-example run against the live tree, not an edit. Three
   (E86, E166, E170) record builds or migrations that the scope decision cut, and
   should stay unrewritten as the record of what was decided —
   `docs/decisions/decision-scope.md` says deferred is not deleted, and the same
   reading covers cut.

3. **The 31 flagged DONE-ALREADY rows are the phantom-work risk.** Each is a SPEC
   a scheduler would read as implement-ready for work already in the tree. The
   cheapest fix is at `docs/examples/INDEX.md`, one row each, and it is an
   authored change rather than one this triage may make.

4. **Two ledger cells need an author's eye**, both in section B: E20's `built`
   against an absent `nb-blit`, and E24's `built` against an absent `div`/`mod`.
   Neither is a doc-rot repair; both are a build-state call.

5. **N01 is the only queueable SPEC in the tier.** Slices 3 and 4 (BLAKE2s,
   X25519) are unbuilt, `lib/crypto/` exists with `chacha.chiral` and
   `poly1305.chiral` beside it, and `tools/test/crypto.sh` is the gate they extend.
