---
node: arc-checker-core
layer: navigation
related: [arcs/README, goals/self-hosting, records/checker-core, arcs/enforcement-arc, arcs/diagnostics-arc, arcs/surface-syntax-arc, arcs/sys-face-arc, banks/capability, banks/erasure, banks/verification, status-ledger, bug-classes, totality, decisions/decision-scope, decisions/decision-work-ids, elements/catalog, records/homing-triage, records/lenses/problems, records/lenses/gaps, records/author-calls, index]
status: current
updated: 2026-09-23
---

# Arc: checker-core

- goals: [[goals/self-hosting]], condition 5: "Every built element of the compiler
  holds a roster row in an arc." The same goal's condition 4 is served by
  requirements 1, 2 and 6 below, which state over this arc's own code the reach
  and assertion the condition names. `docs/goals/self-hosting.md:102-107` is the
  table that names this arc as one of four subject arcs, opened 2026-09-18, and
  `:92-100` gives it both conditions in one sentence: each "rosters the elements
  of that subject that no other arc rosters, and states over the same code the
  reach and assertion requirements condition 4 names". No second goal is served.
  [[goals/readable-surface]] and [[goals/enforcement]] were each tested against
  this roster and each is refused under *What this arc does not take*.
- reserved element block: **none**. Every homeable row carries an element minted
  long before this file, and the arc-local ids per [[decisions/decision-work-ids]]
  spell the letters `CK`, for checker core, which is also this subject's category
  code in `docs/elements/ledger.md:60`: `checker-core/CK1` upward. A grep for `CK`
  followed by a digit over `docs/`, `records/` and `.planning/` returns nothing,
  verified 2026-09-18. The two-letter form follows `sys-face`'s `SF`,
  `syscall-custody`'s `SC` and `tool-authority`'s `TA`.
- build-state authority: [[status-ledger]]
- checklist: [[records/checker-core]], prefix `CK`.
- neighbour: [[arcs/diagnostics-arc]], stated in full under *What this arc does
  not take*. That arc owns the vocabulary a diagnostic is written in. This arc
  owns the register of judgments the checker can reach.

## Why this arc exists

Condition 5 is the homing invariant [[goals/README]] states at `:27`. Measured
2026-09-18 against the working tree: `docs/elements/ledger.md` §CK holds 15 rows,
one of them (`E49`) already rostered by [[arcs/surface-syntax-arc]], and
**fourteen hold no roster row anywhere**. The goal's own cell for this arc names
thirteen elements and four of them sit outside §CK: `E9`, `E10` and `E11` in §RF
and `E159` in §VAL. None of the four holds a roster row either, and each is named
in the cell's subject sentence, so this arc takes eighteen rows and the seam is
that sentence rather than the category alone.

Condition 4 reads the same claim over the compiler's parts. Its failure shape is
`docs/definitions/bug-classes.md:171-173`: a rule can be written, compile
cleanly, pass the suite, get marked built in the catalog, then run on no path.
This subject is where that shape is measurable to the arm, because the checker
already carries its judgments as a closed sum. `Judg` (`lib/typing/diag.chiral:99-111`)
has **36 constructors**, every one of them built somewhere inside the compiler's
import closure, and **4 of the 36 have their refusal read by an assertion**. All
four of those four sit in another element's gate.

## What the tree already holds

Measured 2026-09-18 against the working tree. [[banks/INDEX]] holds thirteen and
three own pieces of this territory. [[banks/capability]] shard B places the q1
linearity mechanism at `is-linear` (`lib/typing/kernel.chiral:325`) and
`linear-binder-bad` (`:360`), and calls it one of four mechanisms where "pulling
any one leaks". [[banks/erasure]] shard A holds quantity erasure at
`lib/typing/qtt.chiral` and records it built. [[banks/verification]] shard 1 is
the self-host fixpoint, which is the instrument every rule here rides under and
the reason a broken rule still reaches a byte-identical binary. None is
re-derived below. No bank holds a refraction of the judgment itself.

| group | what exists today | where | rung |
|---|---|---|---|
| G1 the reader | bytes to forms, 315 lines, and every `lib/` module parses through it. Three importers, two of which (`lib/module/resolve.chiral`, `lib/module/sig-derive.chiral`) are themselves outside the closure | `lib/surface/sexp.chiral`, importer `lib/surface/parse.chiral` | IMPLEMENTED |
| G1 | the position half of the reader's diagnostics, built: `pos-line` at `:137`, `pos-col` at `:151`, `fmt-pos` at `:164`, and `depth` plus a `last-form` context threaded through `read-form*` at `:216` and `read-list*` at `:236`, so the message reads `unexpected ) at L:C depth=N` | `lib/surface/sexp.chiral:228`, `:240` | IMPLEMENTED |
| G1 | ⚑ **the form-splitter is built and reached by nothing.** `read-all-forms` returns every top-level form with its byte offset, over a `FormPos` carrier. A grep over `lib`, `prog` and `tools` finds no consumer outside its own file | `lib/surface/sexp.chiral:286`, carrier at `:35` | SEEDED |
| G1 | ⚑ **the nesting-depth guard is a constant with no check.** `MAX-DEPTH` is `200` and the name occurs once in the file it is defined in | `lib/surface/sexp.chiral:44` | absent |
| G1 | ⚑ **the per-function paren delta is built in chirality and invoked by nothing.** 244 lines, a `PaFrm` frame per `def` and `declare` with open and close bumping. `grep` over `tools/` and `bin/` returns no invocation, which `docs/goals/enforcement.md` already measured for this file | `prog/paren-audit.prog:51`, `:111`, `:114` | SEEDED |
| G2 the surface | forms to core terms: name resolution to de Bruijn indices over an immutable context, and every surface form desugared at elab time. 321 lines plus 1466 for the top-level dispatch, both inside the closure | `lib/surface/surface.chiral`, `lib/surface/parse.chiral` | IMPLEMENTED |
| G2 | the composition manifest, which `E2`'s ledger row records as landing 2026-08-22: both toplevel forms parse and elaborate, over an 18-member closed refusal sum | `lib/surface/parse.chiral:712-764`, gated by Phase 4 at `tools/test/run-tests.sh:145` | ENFORCED |
| G2 | ⚑ **the profile's memory discipline is stored and read nowhere.** `(memory linear)` parses, validates and changes nothing. `records/lenses/problems.md` PRB-57 is the measurement and carries `owner: none` | `lib/surface/parse.chiral`, destructurings in `lib/typing/kernel.chiral` and `lib/typing/totality-check.chiral` | absent |
| G2 | ⚑ **the tree holds two core term sums.** The live one has sixteen arms and five importers; `E13`'s has five arms, zero importers, and a `t-pi` with no field for the quantity and seat the live one carries | `lib/surface/syntax.chiral:18` against `lib/surface/terms.chiral:15` | ENFORCED against SEEDED |
| G2 | ⚑ **`E13`'s two walkers are the only definitions of either name in the tree, and the module cannot be imported.** A file importing `surface/syntax` and `surface/terms` together fails `bin/chirality check` at exit 1 with `load: data redeclared: Term`, run 2026-09-18. NbE needs neither walker: the kernel evaluates to values and quotes back, and no `shift` or `subst` definition exists in `lib/typing/kernel.chiral` | `lib/surface/terms.chiral:40`, `:64`; `docs/definitions/status-ledger.md:160` already records the file as the differential artifact and the live sum as the one in the path | SEEDED |
| G2 | ⚑ **the file `E14`'s record names is gone.** `lib/typing/pretty.chiral` does not exist; `0c53875` moved it under `E181` to `lib/surface/pretty.chiral`, where it is 399 lines over sixteen arms and imported by `lib/typing/diag.chiral`, which every compile reaches. `docs/elements/catalog.md:108` still reads `lib/typing/pretty.chiral` (51 L) with ZERO importers, and no source file in the tree names `E14` | `lib/surface/pretty.chiral:1`, gated by Phase 18 | IMPLEMENTED under another element |
| G3 the judgment | NbE, all of it in `lib/typing/kernel.chiral`: `eval-term` at `:672`, `conv` at `:702`, `conv-struct` at `:708`, `conv-neut` at `:745`, `quote-val` at `:762`. 1517 lines, six importers, inside the closure, reached by every compile | `lib/typing/kernel.chiral` | IMPLEMENTED |
| G3 | bidirectional inference with cumulativity: `infer` at `:819`, `subtype` at `:799`, and the refinement subtyping rule `subtype-into` at `:812` | `lib/typing/kernel.chiral` | IMPLEMENTED |
| G3 | the QTT semiring, 78 lines with six importers: `qfits` at `:40`, `uadd` at `:56`, the usage vectors in the kernel | `lib/typing/qtt.chiral` | IMPLEMENTED |
| G3 | the refinement decision procedure, 168 lines: interval with holes, symbolic bounds keyed by operand level, emptiness decided first | `lib/typing/refine.chiral:13-18` | IMPLEMENTED |
| G3 | ⚑ **a refinement whose bound is the I64 maximum is accepted.** `(def bad (refine I64 (> 9223372036854775807)) 0)` passes `bin/chirality check` at exit 0 and the same file at `...806` fails, reproduced 2026-09-18. `records/lenses/problems.md` PRB-17 is the row, `owner: E09` | `lib/typing/refine.chiral`, `lib/typing/kernel.chiral` | a false refusal |
| G3 | occurrence typing, the atom-selection half: `narrow` at `:163`, with the hooks `narrow-branch` (`lib/typing/kernel.chiral:483`) and `narrow-side` (`:484`). The element's own comment at `refine.chiral:139` scopes it and hands the deciding to `E9` | `lib/typing/refine.chiral:134-163` | IMPLEMENTED |
| G3 | termination, wired 2026-09-02: 387 lines of classifier plus a 161-line bridge from the sixteen-constructor `Term` to the six-constructor `TotTerm`, with the gate run between the load and the peel | `lib/typing/totality.chiral`, `lib/typing/totality-check.chiral`, `lib/lowering/compile-front.chiral` | IMPLEMENTED |
| G3 | ⚑ **the termination gate is demand-driven and nothing demands it.** `tot-gate` answers proven without classifying one def when no profile carries `(total)`, and zero roots under `prog/` declare a `(profile ...)` clause at all, so `E173`'s SPEC mutant M3 observes divergence and its gate row passes by looking at nothing. `records/lenses/problems.md` PRB-27 is the measurement and names `E11` as owner | `lib/typing/totality-check.chiral:153-156`, call site `lib/lowering/compile-front.chiral:371` | IMPLEMENTED and unexercised |
| G4 data | constructors, case coverage and constructor-parameter unification, 384 lines, inside the closure, imported by `lib/typing/{diag,kernel,ty-cmp}.chiral` | `lib/surface/data.chiral` | IMPLEMENTED |
| G4 | strict positivity: the walk at `:258` and `:283` with the per-parameter cache `compute-sp` at `:322`, called live from `lib/module/loader.chiral` at data install. The direct case refuses: `(data C () (mk-c (h (-> C I64))))` fails at `load: not strictly positive: h`, run 2026-09-18 | `lib/surface/data.chiral:256-294`, `:322` | ENFORCED for the direct case |
| G4 | ⚑ **the mutual case is accepted, and one probe carries its own control.** `(data A () (mk-a (f (-> B I64))))` beside `(data B () (mk-b (g A)))` passes `bin/chirality check` at exit 0, run 2026-09-18. The mechanism is in the code: `walk`'s `t-pi` arm asks whether the arrow's domain mentions the target, `B` is a nullary `t-tcon` that mentions nothing, and `walk-args` recurses only through a tcon's arguments, of which a nullary one has none. `records/lenses/problems.md` PRB-16 is the row, `owner: E07`, and calls it a false ENFORCED row rather than a stale one | `lib/surface/data.chiral:258`, `:267-269`, `:283-294` | a false refusal |
| G4 | the linear-kind decision for data: the type judges linearity through `is-linear`, and two refusals render it | `lib/surface/data.chiral`, `lib/typing/diag.chiral:455`, `:467` | IMPLEMENTED |
| G4 | the mutual data group, built as install-then-judge: `grp-add` installs every member at `:566`, `grp-check` re-runs the judgment at `:575`, `load-data-group` joins them at `:586`, and the refusal relays as `data-group: `. Called from `lib/module/load-batch.chiral:112` and `lib/surface/parse.chiral:1446`, both inside the closure | `lib/module/loader.chiral:566-593`, render at `lib/typing/diag.chiral:511` | IMPLEMENTED |
| G4 | ⚑ **the SCC scan half of `E79` is absent, and `grp-check` is where `E7` fails.** A case-insensitive grep for `scc`, `tarjan` and `strongly` over `lib/` and `prog/` returns one hit, a comment at `lib/typing/row-infer.chiral:12`. `grp-check` re-runs a per-declaration walk over the installed group, so a member's negativity through a sibling is never derived. `docs/elements/catalog.md:109` reads "No file in the tree is named for the group pass itself" | measured 2026-09-18 | absent |
| G4 | nothing for field dependence. `docs/elements/catalog.md:178` records that the limit `E48` cited was a line of the evicted `data.py` and that no telescope support was ported into the live file. Five SPECs defer a decision to it | `docs/elements/specs/E05-qtt-semiring-SPEC.md` decision 3, `E06-data-ctors-coverage-SPEC.md` decision 2, `E21-arena-SPEC.md` decision 2, `E22-regions-SPEC.md` decision 1, `E41-region-types-SPEC.md` decision 3 | absent |
| G5 the linearity floor | the one element of the eighteen at ENFORCED. Four places a linear value comes to rest are asserted with an admit control beside each: the extern arrow, the let binder, the pi binder and the case merge | `tools/test/linear-mint.sh:144`, `:174`, `:216`, `:264`, dispatched as Phase 6 at `tools/test/run-tests.sh:147` | ENFORCED |
| G5 | ⚑ **the data-field leg of the same rule is the one nothing runs.** `linear field declared non-1` appears in `tools/test/linear-mint.sh:8`, inside that file's header comment, and in no assertion anywhere | `lib/typing/diag.chiral:467` | absent |
| G5 | ⚑ **a closure that crosses a return drops its captured linear value to ω, and nothing refuses it.** `records/lenses/problems.md` PRB-101. A def that holds a handle at `1` and returns `(lam (x) (backend-close b))` checks OK, and its caller calls the closure twice. The same closure passed inside the body that holds `b` is refused. Re-run 2026-09-30, `records/checker-core.md` CK-05 | `lib/typing/kernel.chiral:945-951`, `:325-330` | absent |
| G6 the gate | the closure: 62 import targets resolve from `prog/compiler.prog` over `lib:prog` across the three extensions `MAP.md:20` names, carrying 17,654 lines against `lib/`'s 105 modules and 26,598. Every module of this arc's subject is inside it except one | measured 2026-09-18 | ENFORCED |
| G6 | the one exception, and it is `E13`'s: `lib/surface/terms.chiral`, 65 lines, zero importers. Five further modules under `lib/typing/` sit outside the closure and belong to elements this arc refuses: `row-infer` 137 L, `kernel-core` 60 L, `reflect-floor` 54 L, `effects` 46 L, `ty-cmp` 40 L | measured 2026-09-18 | SEEDED |
| G6 | what the gate tier does reach: Phase 3 asserts three refusals under the CLI's name, all in `tools/test/check-cli.sh`: `linear binder usage mismatch` at `:69` and `:73`, `type mismatch` at `:76`, `unknown name` at `:78`, each with a named mutant that is run | `tools/test/check-cli.sh`, dispatched at `tools/test/run-tests.sh:144` | ENFORCED |
| G6 | ⚑ **4 of the 36 judgment arms have their refusal read by an assertion.** `jg-lam-nonfn` at `tools/test/face.sh:662`, `jg-ctor-arity` at `tools/test/doc.sh:206`, `jg-nonexhaustive` at `tools/test/diag.sh:175`, `jg-refine-unproved` at `tools/test/recording.sh:278`. Two more appear in a gate script and only inside a comment, `jg-tcon-arity` at `tools/test/arity.sh:431` and `jg-linear-field` at `tools/test/linear-mint.sh:8`. The remaining 30 appear nowhere | census over `lib/typing/diag.chiral:429-468` against `tools/test/*.sh`, 2026-09-18 | absent |
| G6 | ⚑ **every one of the four belongs to another element's gate.** Phase 16 is `E175`'s, Phase 14 is `E158`'s, Phase 13 is `E157`'s, Phase 30 is `E197`'s. No phase script names any of the eighteen elements of this roster | measured 2026-09-18 | absent |
| G6 | ⚑ **four roots exist to re-found this arc's rules and no phase dispatches one.** `e170_conv_eta` for `E3`'s eta rule, `e170_infer_arms` for `E4`'s seventeen inference arms, `e170_qtt_semiring` for `E5`'s four tables, `e170_refine_top` for `E9`'s only-if-top conjunct. Each header cites `.planning/RUNG1-CHECKLIST.md:452-454`, which measured three checker rules as covered only inside a differential leg `E170` deletes. Phase 12 prints NOT PORTED with the fixtures landed | `tools/test/samples/`, `tools/test/run-tests.sh:22`, `:413` | absent |
| G6 | the wider root census, for the boundary rather than for a row: 103 roots carry `^(def compile-main` under `lib prog`, Phase 7's own selector, and **81 are named by no `tools/test/*.sh` at all** | measured 2026-09-18 | absent |

Four facts from that table govern the roster. **The rules are built and inside
the closure**, so no row here writes a judgment from nothing except `CK17`.
**Two built rules are wrong**, each convicted by one probe that runs in under a
second, and both probes existed as lens rows before this arc did. **The state
claims have drifted**, four of them measurably. **Nothing asserts 32 of the 36
arms**, which is condition 4(b) stated over this subject at the finest grain the
tree offers.

## What is missing, and its structure

| group | owns |
|---|---|
| G1 the reader | bytes to forms, with a position on every refusal. The reader half is built. What is stranded is a splitter, a guard and a native auditor that nothing calls, and what is absent is a position on the elaborator's own refusals |
| G2 the surface | forms to core terms over one term sum, and the written direction back. The elaborator is built with four slices its own record defers. What is wrong is the count of sums, which is two |
| G3 the judgment | NbE, bidirectional inference, quantities, refinement, narrowing, termination. Every one is on the path of every compile. Two of them refuse the wrong set of programs and a third refuses nothing because nothing asks it to |
| G4 data | constructors, coverage, positivity, linear kinds, the mutual group, field dependence. The per-declaration judgments are built. The cross-member closure is absent, and it is where positivity and the group pass fail together |
| G5 the linearity floor | every place a linear value comes to rest, refused at any quantity but 1. Four of six places are asserted. The fifth is the data field. ⚑ The sixth is a closure's capture once the closure leaves the body that holds the value, and it is refused nowhere. This group read five places until PRB-101 measured the sixth on 2026-09-30 |
| G6 the gate | a phase that runs a checking rule and judges the refusal it names. 32 arms wait for one, and four roots written for exactly this wait on a phase that belongs to another element |

### The edges that run against the order

| edge | direction | what crosses |
|---|---|---|
| G6 to everything | against, and the loudest | G6 reads as last and is first. `docs/definitions/bug-classes.md:171-173` names the class, and this arc's own premise is that two of its rules were measurably wrong while every authority read `built`. Both probes are two lines of source and neither needed a new instrument. Building further down the order adds arms to the unasserted 32 before it subtracts any |
| G4 to G3 | against | `E7`'s positivity walk and `E79`'s group pass fail as one defect. The walk is correct per declaration and the group pass re-runs it per declaration, so neither element can be repaired inside its own boundary. Reading G3 before G4 as a build order puts the judgment ahead of the pass that decides which judgments run together |
| G2 to G1 | against | `E13`'s module cannot be wired in: importing it beside the live sum refuses at load. Its work is a merge into `lib/surface/syntax.chiral`, which every G3 and G4 element cases over, so the cheapest-looking row in G2 is the one with the widest blast radius. Reading G1 then G2 as a schedule sends a session to import a file the loader refuses |
| G3 to G4 | out of this arc's reach | `E9`'s residue stops at the decision procedure. PRB-79 and PRB-82 settled 2026-09-10 that the linear arith-expression bound is `E41`'s and the saturated application admitted as an operand is `enforcement/N22`'s, so a session widening the operand from here is building another arc's row |
| G6 to G6 | out of this arc's reach | the four roots that re-found G3's rules sit behind Phase 12, whose port belongs to `E170`. `records/homing-triage.md:224` routes that element to [[arcs/enforcement-arc]] and reads `clear`. So `CK7` through `CK10` can each assert their rule directly and cannot get their existing root dispatched, and this arc names the port as owed |

## REQUIREMENTS

Six, each with the observation beside it, measured 2026-09-18.

1. **Every refusal a rule of this arc can produce is read by an assertion.**
   Observed as each of `Judg`'s 36 constructors (`lib/typing/diag.chiral:99-111`)
   having its rendered message (`:429-468`) read outside a comment by a
   `tools/test/*.sh` script a `run_phase` line dispatches. Today 4 of 36, and all
   four sit in the gate of another element.

2. **Every module an element of this arc names sits inside the compiler's import
   closure, or the element's row says why not.** Observed by resolving
   `(import "...")` transitively from `prog/compiler.prog` over `lib:prog` across
   the three extensions `MAP.md:20` names, which is goal condition 4(a)'s own
   observation. Today 62 targets and 17,654 lines, with one of this arc's modules
   outside: `lib/surface/terms.chiral`, 65 lines, zero importers.

3. **A rule the tree records as refusing refuses every case it claims to
   refuse.** Observed by running the case against `bin/chirality check`. Today two
   `built` elements fail one probe each: the mutual negative occurrence is
   accepted while the direct one is refused, and a refinement bound at the I64
   maximum is accepted while the same bound one lower is refused.

4. **No rule this arc's own code needs is undeclared, and no declared sum is
   declared twice.** Observed as one `(data Term` under `lib/` and no deferral
   pointer standing where a rule belongs. Today two term sums
   (`lib/surface/syntax.chiral:18` with sixteen arms, `lib/surface/terms.chiral:15`
   with five), five SPECs deferring a decision to `E48` against a live file with
   no field dependence, and `lib/typing/refine.chiral:7` routing its own second
   half to an element PRB-82 measured as the wrong owner.

5. **Every state claim over one of this arc's elements names code that says what
   the claim says.** Observed by opening each cited span and reading it. Today
   four fail: `docs/elements/catalog.md:108` cites `lib/typing/pretty.chiral`,
   which does not exist; `:434` reads "Not built" over two enhancements that are
   in the tree; `:109` says no file is named for the group pass while
   `load-data-group` is at `lib/module/loader.chiral:586`; and `E2`'s residue list
   names the import loader, which `sys-face/SF1` carries as `built`. This is the
   class [[records/findings]] FD-27 states and `E76` worked.

6. **Every rule this arc's elements ship has a root that exercises it and a phase
   that dispatches that root.** Observed as a root's basename appearing in a
   script some `run_phase` line names, which is goal condition 4(b)'s own
   observation. Today no root exists under any of the eighteen elements' names,
   four roots written to re-found this arc's rules sit behind Phase 12 at NOT
   PORTED, and 81 of the 103 roots Phase 7's own selector returns are named by no
   gate script.

## Roster

Nineteen rows. Eighteen carry an element minted long before this file and homed
by no roster until now, and one is unminted. Ids spell `CK`. **This arc mints
nothing and allocates no number.**

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `checker-core/CK1` | the reader, and every `lib/` module parses through it. 315 lines inside the closure, refusals carried as `r-err` values with a byte offset (`lib/surface/sexp.chiral:21`). Phase 3 reaches it on every row and asserts none of its refusals: `unclosed ( at` appears in `tools/test/diag.sh` under `E157`'s name and `unexpected ) at` appears in no gate script. **Wanted**: an assertion over the reader's own refusals, which need no import and no crossing. **Blocking condition**: none measured | G1 | primitive | bind | 1, 6 | built | `E1` |
| `checker-core/CK2` | the reader's positions, built, and the elaborator's still absent. The built half is `pos-line` (`lib/surface/sexp.chiral:137`), `pos-col` (`:151`), `fmt-pos` (`:164`) and the `depth` plus `last-form` context threaded at `:216` and `:236`, so `unexpected )` reads `unexpected ) at L:C depth=N`. The half this element's own title names is untouched: `p-err` carries a bare string with no position (`lib/surface/parse.chiral:132`, `:176`, `:200`) and `(lam (x ...) body)`, one of the two opaque messages the element was minted to retire, is live in four arms at `:243-247`. **Wanted**: a position on `p-err`, and one of them asserted. **Blocking condition**: none measured | G1 | primitive | bind | 1, 5, 6 | built | `E101` |
| `checker-core/CK3` | the reader follow-up, two enhancements of four in the tree and every one of them reached by nothing. The form-splitter is built: `read-all-forms` (`lib/surface/sexp.chiral:286`) returns each top-level form with its byte offset over `FormPos` (`:35`), and no consumer exists outside that file. The depth guard is a name and no check: `MAX-DEPTH` is `200` at `:44` and occurs once. The per-function paren delta is built as `prog/paren-audit.prog`, 244 lines, invoked from nothing under `tools/` or `bin/`. The token start position in atom-parse errors is absent: `r-err` at `:194` and `:205` passes the error site. `docs/elements/catalog.md:434` reads "Not built" over all four. **Wanted**: the three built halves reached, the guard given a check, the cell re-measured. **Blocking condition**: none measured | G1 | primitive | bind | 1, 5 | building | `E102` |
| `checker-core/CK4` | the elaborator, built with four slices its own record defers, and the deferrals have moved. `lib/surface/surface.chiral` (321 L) and `lib/surface/parse.chiral` (1466 L) are both inside the closure, and the `profile`/`target` slice landed 2026-08-22 with the manifest forms at `parse.chiral:712-764` and Phase 4 gating their parse. Measured 2026-09-18 against the four the ledger row still defers: **the import loader landed elsewhere**, `sys-face/SF1` carrying `E51` as `built`; **effect-row inference is written and unreached**, `lib/typing/row-infer.chiral` at 137 lines with one importer `lib/module/sig-driver.chiral`, which has zero importers and sits outside the closure; **the CLI is 220 lines of shell** at `bin/chirality`, which is [[goals/self-tooling]]'s ratio rather than this element's build; data-decl elaboration is the one that reads as this element's still. A fifth residue nothing records against this element: PRB-57 measured the profile's memory discipline stored and read by no consumer, `owner: none`. **Wanted**: the four cells re-derived against the tree, and the memory clause given a reader or a stated refusal. **Blocking condition**: effect-row inference turns on `E39`, `design`, whose home is the open call `records/homing-triage.md:117` records | G2 | law | bind | 1, 5 | building | `E2` |
| `checker-core/CK5` | the de Bruijn machinery, and it carries a second term sum. `lib/surface/terms.chiral` is 65 lines with zero importers, outside the closure, and `uses-below` (`:40`) and `shift-close` (`:64`) are the only definitions of either name in the tree. The file declares its own `(data Term ...)` at `:15` with five arms against the live sixteen-arm sum at `lib/surface/syntax.chiral:18`, whose `t-pi` carries a `Qty` and a `Seat` the five-arm version has no field for. **Blocking condition, measured 2026-09-18 and re-runnable**: a file importing `surface/syntax` and `surface/terms` together fails `bin/chirality check` at exit 1 with `load: data redeclared: Term`, so this module cannot be wired in beside the sum every G3 and G4 element cases over. The element's header states the deferral in its own words, the extension nodes being added to both walkers "when the full shared Term ADT is assembled", and that assembly happened on the other side. NbE needs neither walker: no `shift` or `subst` definition exists in `lib/typing/kernel.chiral`. **Wanted**: the merge into `surface/syntax`, or the element restated as retired into it | G2 | primitive | connect | 2, 4 | built | `E13` |
| `checker-core/CK6` | the printer, whose file left the tree under another element's number. `lib/typing/pretty.chiral` does not exist; `0c53875` moved it to `lib/surface/pretty.chiral` under `E181`, where it is 399 lines over sixteen arms, imported by `lib/typing/diag.chiral`, and gated by Phase 18. `docs/elements/catalog.md:108` still reads `lib/typing/pretty.chiral` (51 L) with ZERO importers, and no source file in the tree names `E14`. [[arcs/diagnostics-arc]] requirement 3 is the printer requirement and `E181` serves it. **This row homes the element and claims no build.** **Wanted**: the cell re-measured, and a ruling on whether the element retires into `E181` or is kept as its display facet. **Blocking condition**: that placement, carried verbatim under FLAGs | G2 | primitive | bind | 5 | built | `E14` |
| `checker-core/CK7` | NbE, on the path of every compile and asserted at the Reason level only. `eval-term` (`lib/typing/kernel.chiral:672`), `conv` (`:702`), `conv-struct` (`:708`), `conv-neut` (`:745`), `quote-val` (`:762`). `tools/test/check-cli.sh:76` asserts `type mismatch`, conv's refusal as a `Reason`, under the CLI's name and with a named mutant. The eta rule has no assertion and the tree already says so: `tools/test/samples/e170_conv_eta.prog` exists to re-found it, its header citing `.planning/RUNG1-CHECKLIST.md:452` for the measurement that three checker rules are covered only inside a differential leg `E170` deletes. **Wanted**: the eta assertion under this element's name. **Blocking condition**: none for a fresh assertion. The existing root needs Phase 12's port, which belongs to `E170` and is named as owed | G3 | law | bind | 1, 6 | built | `E3` |
| `checker-core/CK8` | bidirectional inference, eight judgment arms, one asserted. `infer` (`lib/typing/kernel.chiral:819`), `subtype` (`:799`), `subtype-into` (`:812`). `jg-lam-nonfn` is read at `tools/test/face.sh:662`, inside `E175`'s mutant table, so the one covered arm is covered by a face gate. `jg-var-range`, `jg-infer-lam`, `jg-pi-dom`, `jg-pi-cod`, `jg-apply-nonfn`, `jg-ann-nontype` and `jg-type-as-value` are read by nothing. `tools/test/samples/e170_infer_arms.prog` is the generator written for exactly this, seventeen tests keyed to `infer`'s arms, quantified over the closed sum. **Wanted**: the seven arms asserted. **Blocking condition**: none. Each of the seven is a two-line source fixture and needs no generator | G3 | law | bind | 1, 6 | built | `E4` |
| `checker-core/CK9` | the quantity semiring, whose refusals are asserted and whose tables are not. `lib/typing/qtt.chiral` is 78 lines with six importers; `qfits` at `:40`, `uadd` at `:56`, the usage vectors in the kernel, and [[banks/erasure]] shard A records the quantity half built. `linear binder usage mismatch` is asserted at `tools/test/check-cli.sh:69` and `:73` and `let binder usage mismatch` at `tools/test/linear-mint.sh`. `field binder usage mismatch` is read by no gate script, and `tools/test/samples/e170_qtt_semiring.prog` exists to re-found `qadd`, `qmul`, `qjoin` and `qfits`, citing `.planning/RUNG1-CHECKLIST.md:453` for the measurement that all four are covered only inside the differential leg. **Wanted**: the four tables asserted, and the field-binder arm. **Blocking condition**: none. The tables are pure functions over a three-element sum | G3 | primitive | bind | 1, 6 | built | `E5` |
| `checker-core/CK10` | the refinement decision procedure, and it accepts a bound it cannot satisfy. `lib/typing/refine.chiral` is 168 lines inside the closure with `Constraint` at `:13-18`. `jg-refine-unproved` is asserted at `tools/test/recording.sh:278` as a `REFUSE` constant under `E197`'s name; `jg-refine-i64`, `jg-refine-base`, `jg-refine-opnd-i64` and `jg-refine-opnd-form` are read by nothing. **Two open problems convict it, both reproduced 2026-09-18.** PRB-17: `(def bad (refine I64 (> 9223372036854775807)) 0)` passes at exit 0 while `...806` fails, so the one bound nothing can satisfy is the one accepted. PRB-48: a `let` over a `case` on a computed comparison cannot be proven, `owner: none`, with all four of FD-02's conditions still gating. **Wanted**: the wrap refused, the `let`-over-`case` case decided, the four arms asserted. **Blocking condition**: none measured for any of the three. **The operand widening is outside this row**, PRB-79 and PRB-82 having settled the linear sum to `E41` and the saturated application to `enforcement/N22` | G3 | primitive | bind | 1, 3, 4 | built | `E9` |
| `checker-core/CK11` | occurrence typing, built and observed by nothing. `narrow` at `lib/typing/refine.chiral:163` selects the atoms and the hooks are `narrow-branch` (`lib/typing/kernel.chiral:483`) and `narrow-side` (`:484`); the comment at `refine.chiral:139` scopes this element to selection and hands the deciding to `E9`. This element adds no judgment arm, because narrowing widens what is accepted, so requirement 1 does not reach it and requirement 6 is what would. No root exists that admits a call under a guard and has the unguarded form refused beside it. **Wanted**: that root, and a phase. **Blocking condition**: none measured | G3 | law | bind | 6 | built | `E10` |
| `checker-core/CK12` | termination, wired to a gate nothing asks for. `lib/typing/totality.chiral` is 387 lines and `lib/typing/totality-check.chiral` 161, both inside the closure, with the gate between the load and the peel at `lib/lowering/compile-front.chiral:371`. PRB-27 measured the shape: `tot-gate` (`totality-check.chiral:153-156`) answers proven without classifying one def when no profile carries `(total)`, and **zero roots under `prog/` declare a `(profile ...)` clause at all**, so `E173`'s SPEC mutant M3 observes divergence and that gate row passes by looking at nothing. PRB-27's `owner:` names this element and records that no new element is owed. `tools/test/profile-target.sh` gates the clause's parse and no phase gates its proof. **Wanted**: a root carrying `(total)` under a phase, so the classifier's refusal is asserted. **Blocking condition**: none for the assertion. The enforce-by-default flip turns on `E47`, `design`, which this arc refuses and which author call B holds | G3 | law | bind | 1, 6 | built | `E11` |
| `checker-core/CK13` | constructors and coverage, thirteen judgment arms, two asserted. `lib/surface/data.chiral` is 384 lines inside the closure, imported by `lib/typing/{diag,kernel,ty-cmp}.chiral`. `jg-nonexhaustive` is read at `tools/test/diag.sh:175` under `E157`'s name and `jg-ctor-arity` at `tools/test/doc.sh:206` under `E158`'s. `jg-dup-branch`, `jg-branch-nonctor`, `jg-branch-arity`, `jg-scrut-unknown`, `jg-scrut-nondata`, `jg-empty-case`, `jg-esc-binders`, `jg-not-a-ctor`, `jg-ctor-other-data`, `jg-ctor-nondata` and `jg-ctor-infer-params` are read by nothing. **Wanted**: the eleven asserted. **Blocking condition**: none. Each is a short source fixture over a two-constructor datatype | G4 | law | bind | 1 | built | `E6` |
| `checker-core/CK14` | strict positivity, and one probe convicts it with its own control. The walk is `lib/surface/data.chiral:258` and `:283` with the cache `compute-sp` at `:322`, called from `lib/module/loader.chiral` at data install, and the direct case refuses: `(data C () (mk-c (h (-> C I64))))` fails at `load: not strictly positive: h`. The mutual case passes: `(data A () (mk-a (f (-> B I64))))` beside `(data B () (mk-b (g A)))` exits 0, both run 2026-09-18. The mechanism is at `:267-269` and `:283-294`: the `t-pi` arm asks whether the domain mentions the target, a nullary `t-tcon` mentions nothing, and `walk-args` recurses only through a tcon's arguments. PRB-16 is the row, `owner: E07`, and calls it a false ENFORCED row. `docs/definitions/status-ledger.md:163` records the direct case verified and says nothing of the mutual one. **Wanted**: the cross-member closure, and the refusal asserted. **Blocking condition**: `E79`'s group judgment is where the closure lives, so `CK16` is the same work counted once | G4 | law | connect | 1, 3 | built | `E7` |
| `checker-core/CK15` | the linear-kind decision for data, whose two refusals are the ones nothing runs. The judgment is over the type, through `is-linear` (`lib/typing/kernel.chiral:325`) and the depth-bounded walk in `lib/surface/data.chiral`, and [[banks/capability]] shard B calls the q1 mechanism one of four where pulling any one leaks. `jg-linear-field` renders at `lib/typing/diag.chiral:455` and `jg-linear-field-decl` at `:467`, and neither is read by any gate script outside a comment: `tools/test/linear-mint.sh:8` names the second in its header and the file asserts the binder and arrow rules instead. **Wanted**: the field rule asserted, which is the fifth resting place `CK18`'s four leave out. **Blocking condition**: none measured | G4 | law | bind | 1 | built | `E8` |
| `checker-core/CK16` | the mutual data group, half built, and the half that is built is where `CK14` fails. `load-data-group` (`lib/module/loader.chiral:586`) is install-then-judge: `grp-add` at `:566` installs every member, `grp-check` at `:575` re-runs the judgment with the cache built over the whole group, and the refusal relays as `data-group: ` (`lib/typing/diag.chiral:511`), asserted at `tools/test/diag.sh`. Called from `lib/module/load-batch.chiral:112` and `lib/surface/parse.chiral:1446`, both inside the closure. **The SCC scan half is absent**: a case-insensitive grep for `scc`, `tarjan` and `strongly` over `lib/` and `prog/` returns one hit, a comment at `lib/typing/row-infer.chiral:12`. **And `grp-check` re-runs a per-declaration walk**, so a member's negativity through a sibling is never derived, which is `CK14`'s probe. `docs/elements/catalog.md:109` reads "No file in the tree is named for the group pass itself" and calls the element unverifiable; the pass is named, in `loader.chiral`. **Wanted**: the cross-member closure, the cell re-measured, and a mutual negative occurrence refused under an assertion. **Blocking condition**: none measured. This element carries no example and no SPEC, which `ledger-lint` check AH raises against this row | G4 | law | connect | 1, 3, 5 | built | `E79` |
| `checker-core/CK17` | field dependence, absent at every layer, and five SPECs wait on it. `docs/elements/catalog.md:178` records that the limit this element cited was a line of the evicted `data.py` and that no telescope support was ported into `lib/surface/data.chiral`. The five deferrals are `E05-qtt-semiring-SPEC.md` decision 3 (the typed length `(UVec n)`), `E06-data-ctors-coverage-SPEC.md` decision 2 (telescoped parameters), `E21-arena-SPEC.md` decision 2 (a refined cursor whose predicate names a sibling field), `E22-regions-SPEC.md` decision 1 and `E41-region-types-SPEC.md` decision 3 (nested-region field dependence). Verified 2026-09-18 that no arc rosters it: `grep` for `E48` over `docs/arcs/` returns nothing. `records/lenses/unspoken.md` UNS-13 admits it as unhomed. **Wanted when the row is taken up**: left-to-right field dependence in `data` constructors, which is what the five deferrals consume. **Blocking condition**: **author call B**, carried verbatim under FLAGs. No goal states this element | G4 | primitive | new | 4 | open | `E48` |
| `checker-core/CK18` | the linearity floor, the one element of the eighteen at ENFORCED. Two refusals live at `lib/typing/diag.chiral:455` and `:467` and Phase 6 asserts four places a linear value comes to rest, each with an admit control beside it: the extern arrow (`tools/test/linear-mint.sh:144`, `:149`), the let binder (`:174` onward), the pi binder (`:216` onward) and the case merge (`:264` onward), dispatched at `tools/test/run-tests.sh:147`. The element's own record carries the correction that makes it trustworthy: the arrow was measured and rejected as the discriminator and the binder quantity is it. **Wanted**: nothing measured as owed for the four asserted legs. **The fifth resting place is `CK15`'s**, the data field, whose message appears in this script's header comment and in no assertion. **The sixth is `CK20`'s**, a captured value on a returned closure, which this rule never sees because an arrow type is never linear. **Blocking condition**: none. This element carries no example and no SPEC, which check AH raises against this row | G5 | law | bind | 1 | built | `E159` |
| `checker-core/CK19` | the coverage instrument, so requirement 1's number cannot rot. Nothing in the tree re-derives which arms of the judgment sum reach an assertion, so `4 of 36` holds only until a gate script moves a string. `enforcement/N14` is the shape this copies: a committed, re-runnable instrument and a statement with the number behind it, `kind` `tool` because the deliverable is the instrument. **This is not `enforcement/N21`**: that row quantifies over the classes of `docs/definitions/bug-classes.md` and is satisfied by a gate tier whose contact with a class is accidental, while this row quantifies over the 36 constructors at `lib/typing/diag.chiral:99-111` and the message table at `:429-468` that renders them. **Wanted**: the census, committed, over both directions: an arm no assertion reads, and an assertion reading a message no arm renders. **Blocking condition**: none measured | G6 | tool | new | 1 | open | `unminted` |
| `checker-core/CK20` | the captured quantity of a closure, which is lost where the closure crosses a return. `records/lenses/problems.md` PRB-101, re-run 2026-09-30 in `records/checker-core.md` CK-05: `mk` of type `(=> (1 b Backend) (=> I64 Unit))` returns `(lam (x) (backend-close b))`, `twice` calls its argument twice, and `(twice (mk (backend-open "http://h:1")))` checks OK. A def of type `(=> I64 (=> I64 Unit))` that binds the handle in a `1` let and returns the same closure passes the kernel too. The two controls are refused: the closure passed to `twice` inside the body that holds `b`, and the caller holding the handle at `1` before passing it to `mk`. **The site that loses the grade** is `check-body`'s `t-lam` arm, `lib/typing/kernel.chiral:945-951`. It returns the body's usage of the captured variables once, through `strip-binder` (`:633-637`), at the closure's construction, and the arrow type it checks against records none of it. `is-linear` (`:325-330`) answers false for every `v-pi`, so `linear-binder-bad` (`:360-361`) never refuses an arrow bound at ω. Inside one body the charge is scaled again when the closure is passed, `(uscale q au)` in `infer-app2` at `:893`, because the captured variable sits in the caller's context. Across a return it sits in the callee's context and nothing the caller holds carries it. `docs/examples/E39-effect-row.md:157-159` states that capture accounting forces such a closure to be consumed once, and the probe contradicts it for a returned closure. **Wanted**: the captured quantity carried on the arrow, so a closure over a `1` value is itself linear, and the probe refused under an assertion beside `CK18`'s four. **Blocking condition**: none measured. every linear porttype handle waits on it. ⚑ Corrected 2026-09-30: `memory-discipline/M8` now carries an unrestricted region handle under `M9`'s seal, so neither waits on this row | G5 | law | new | 1, 3 | designed | `unminted` |

### Coverage

Run 2026-09-18 against the table above.

- **Every requirement is served.** 1 by `CK1`, `CK2`, `CK3`, `CK4`, `CK7`, `CK8`,
  `CK9`, `CK10`, `CK12`, `CK13`, `CK14`, `CK15`, `CK16`, `CK18`, `CK19` and `CK20`; 2 by
  `CK5`; 3 by `CK10`, `CK14`, `CK16` and `CK20`; 4 by `CK5`, `CK10` and `CK17`; 5 by
  `CK2`, `CK3`, `CK4`, `CK6` and `CK16`; 6 by `CK1`, `CK2`, `CK7`, `CK8`, `CK9`,
  `CK11` and `CK12`. No requirement is unscheduled.
- **Every row serves a requirement.** All twenty name at least one. No row is
  out of scope.
- **Fifteen rows are `built`, two are `building`, and the requirements they serve
  are unmet, which is this arc's premise.** The state column is the pipeline's authority for a row,
  the elements are built, and what the rows carry is the residue: a rule that
  refuses the wrong set, a record that drifted, a gate that never ran. Goal
  condition 4 is exactly the requirement that a built rule run on a path
  something asserts.
- **Every `origin` is defensible from the measurement.**
  - `CK5`, `CK14` and `CK16` are `connect` because both halves exist and the join
    between them does not: a five-arm term sum beside a sixteen-arm one that
    refuses to load together, and a per-declaration positivity walk beside a
    group pass that re-runs it per declaration.
  - `CK1`, `CK2`, `CK3`, `CK4`, `CK6`, `CK7`, `CK8`, `CK9`, `CK10`, `CK11`,
    `CK12`, `CK13`, `CK15` and `CK18` are `bind` because the code is built and
    what is absent is a surface onto it: a record that matches, or an assertion
    that runs it. Each names the span measured.
  - `CK17` is `new` because a grep returns nothing: no field dependence anywhere
    in `lib/surface/data.chiral` against five SPECs that defer to it.
  - `CK19` is `new` because no instrument in the tree re-derives any judgment-arm
    coverage figure, which is why this file carries the census in prose.
  - `CK20` is `new` because no quantity for a capture exists anywhere: the
    `v-pi` value (`lib/typing/kernel.chiral:26`) carries its binder's quantity and
    none for what the body closed
    over, and `is-linear` has no arm for it.

## What this arc does not take

- **Termination promotion and the enforce-by-default flip.** `E47` sized types
  and `E50` lexicographic and mutual termination measures.
  `records/homing-triage.md:124` and `:127` put both in class Q2 and `:252-254`
  carries author call B: no goal states them. **Verified 2026-09-18 that
  [[arcs/enforcement-arc]] rosters neither.** That arc's roster element cells are
  `E16`, `E17`, `E18`, `E70`, `E184`, `E185`, `E186`, `E187`, `E188` and `E198`,
  and a grep for `E47`, `E48`, `E50` and `E153` over the whole file returns
  nothing. `docs/goals/enforcement.md`'s five conditions reach a capability's
  rung, a claim carried as a value with evidence, the typed-assembly floor on the
  shipping path, a named mutant that is run, and the tooling ratio, and none of
  the five reaches termination promotion or field dependence. `CK12` homes `E11`,
  states the flip's dependency on `E47`, and takes neither `E47` nor `E50`.
- **The error vocabulary and the formatter.** [[arcs/diagnostics-arc]] owns
  `Reason`, `Doc`, `Rendering`, the face registry and the printer, through
  `E157`, `E158`, `E174`, `E175`, `E176`, `E179`, `E180`, `E181` and `E182`.
  **The boundary is the direction the two read `lib/typing/diag.chiral`.** That
  arc reads it as the vocabulary a diagnostic is written in and asks whether a
  message carries its evidence. This arc reads it as the register of judgments
  the checker can reach and asks whether each one runs on an asserted path.
  Requirement 1 quantifies over the 36 `Judg` constructors; that arc's five
  requirements reach `Reason`'s closure, `Doc`'s six constructors, the printer's
  sixteen arms, a `prog/` consumer and three error-quality rows, and none of them
  counts a `Judg` constructor. **`E11` is named in that arc's prose at
  `docs/arcs/diagnostics-arc.md:122` and rostered by nothing**: the sentence there
  is about `E158` being a first client for `E50`, and it names `E11`'s classifier
  as unable to see two mutually recursive pairs. `E11`, `E50` and `E159` appear in
  no element cell of that file, verified 2026-09-18. **No row of that arc is
  edited by this run.**
- **The printer itself.** `records/homing-triage.md:96` proposes
  [[arcs/diagnostics-arc]] for `E14`, verdict `clear`, citing that arc's printer
  requirement, and this run agrees with the reasoning. `CK6` homes the element
  where its subject sits and claims no build, because that arc's roster holds
  `E181` and not `E14` and this run's write surface is one arc file. If the author
  prefers the diagnostics seat, `CK6` retires and the element moves with its id
  intact.
- **The reader's error vocabulary.** `records/homing-triage.md:168-169` proposes
  the same arc for `E101` and `E102`, both `clear`, citing
  `docs/arcs/diagnostics-arc.md:52`, which is that arc's requirement 1 over
  `Reason`. **This run disagrees on both, for a measured reason.** `E101`'s built
  half is a byte-offset-to-line-column computation inside `lib/surface/sexp.chiral`
  and its residue is `p-err` inside `lib/surface/parse.chiral`, the two files `E1`
  also lives in, and neither touches a `Reason` arm. `E102`'s three built parts
  are a form splitter, a depth constant and a native paren auditor, none of which
  produces a diagnostic at all. Homing them there splits one file's element set
  across two arcs and puts the reader under a goal that is not
  [[goals/self-hosting]].
- **The typed-assembly floor.** `lib/lowering/tal/check.chiral`, 312 lines, is the
  largest checking module outside the compiler's closure, and it is outside by
  the author's ruling: `records/lenses/problems.md` PRB-70 settled 2026-09-08 that
  it stays out and that the wiring was the defect, and `enforcement/N8` carries
  the call site `ck-prog` has never had. `enforcement/N13` carries the
  preserve-check's T1 rung over `lib/evidence/interp.chiral` and
  `lib/lowering/tal/eval.chiral`, both at zero importers. This arc adds no row for
  any of the three and counts none of their lines in requirement 2.
- **The refinement operand and the linear sum.** PRB-79 and PRB-82 settled
  2026-09-10 that `E41` owns the linear arith-expression bound, a sum of atoms
  against an atom, and that `enforcement/N22` owns the saturated application
  admitted as a refinement operand plus the `=>` value binder visible to the
  seats after it. `CK10` takes this element's own two defects and neither of
  those.
- **Transfer functions over the refinement domain.** `records/lenses/gaps.md`
  GAP-23 measured the domain as built with nothing propagating through it,
  `owner: none`, and `docs/goals/emitted-speed.md` condition 3 already states the
  obligation over the nine enablers this seat belongs to, unopened and holding no
  arc file. `CK10` adds no row for it.
- **Real surface syntax.** [[arcs/surface-syntax-arc]] rosters `E49` and holds
  [[goals/readable-surface]] condition 4. This arc owns the s-expression reader
  the tree compiles through today; whether that surface graduates or a second
  notation lands is `surface-syntax/SY1`'s open call.
- **The effect membrane and the effect row.** `E12`, `E26`, `E38`, `E39`, `E70`
  and `E171` are category EF and `records/homing-triage.md` proposes
  [[arcs/enforcement-arc]] for four of them. `lib/typing/effects.chiral` (46 L,
  two importers) and `lib/typing/row-infer.chiral` (137 L, one importer) both sit
  outside the closure and this arc rosters neither. `CK4` names row inference as
  `E2`'s deferred slice and states the dependency on `E39` without taking it.
- **The certificate split and the reflective floor.**
  `lib/typing/kernel-core.chiral` (`E52`, 60 L, zero importers) and
  `lib/typing/reflect-floor.chiral` (`E45`, 54 L, zero importers) sit in the same
  directory as this arc's judgment and are `OT` track.
  `records/homing-triage.md:129` routes `E52` to [[arcs/module-split-arc]] or
  [[arcs/ownership-and-trust-arc]] as an open call and `:122` routes `E45` to the
  second as `clear`. Neither is this arc's, and the shared directory is why the
  refusal is written down.
- **Porting Phase 12.** Four roots written to re-found this arc's rules sit behind
  it and `tools/test/run-tests.sh:22` prints it NOT PORTED with the fixtures
  landed. `records/homing-triage.md:224` proposes [[arcs/enforcement-arc]] for
  `E170` and reads `clear`, citing `docs/arcs/enforcement-arc.md:315`. This arc
  names the port as owed and takes no row for it.
- **The wider root census.** 81 of the 103 roots Phase 7's own selector returns
  are named by no gate script. Of the 81, none is a root of any element on this
  roster, and the two largest families are `prog/prapanca/` and
  `tools/test/samples/_wip/`, which belong to [[arcs/orchestration-engine-arc]]
  and to the lowering lane. This arc measured the figure and schedules the
  subject's own share of it under requirement 6.
- **Repairing the catalog and the ledger.** Requirement 5 is what `CK2`, `CK3`,
  `CK4`, `CK6` and `CK16` buy, and this run edits neither file.

## FLAGs

⚑ **Author call B stands, and the register of author calls does not carry it.**
It lives in `records/homing-triage.md:252-254`, whose words are: *"**B. Is a goal
owed before these four can be scheduled?** E47 sized types, E48 dependent
records, E50 lexicographic termination measures, E153 the `F64` float tower. No
goal states any of them, and `docs/goals/coding-agent.md:85` holds a line against
`F64` reaching the surface at all."* A grep of `records/author-calls.md` for that
question returns nothing, so the call is registered only in the triage file. `CK17` is drawn while that call is out,
following [[arcs/sys-face-arc]]'s precedent for `SF20` and
[[arcs/syscall-custody-arc]]'s for `SC2` and `SC3`. The row is carried as blocked
on the call and not as its answer. One measurement bears on it and is offered
rather than decided: of the four, `E48` is the only one five SPECs already defer a
decision to, so an answer that opens no goal leaves five audited SPECs pointing
at an element nothing can schedule.

⚑ **This run was told that author call B was answered 2026-09-15 by widening
[[goals/enforcement]] to cover `E47`, `E48`, `E50` and `E153`. No tracked
document carries that widening.** Measured 2026-09-18: `grep` for `E47`, `E48`,
`E50` and `E153` over `docs/arcs/enforcement-arc.md` returns nothing; the same
grep over `docs/goals/enforcement.md` returns nothing; `docs/goals/enforcement.md`
is `updated: 2026-09-14` and its five conditions name no termination subject; and
`records/author-calls.md`'s four rulings dated 2026-09-15 are the `?` track sorts
for `E52`, `E71`, `E77` and `E78`, a different call. `records/homing-triage.md:125`
still reads `E48 | design | SH | ... | - | author-call | Q2`. So `CK17` is drawn
on the call as the tree records it, and if the widening happened in session the
record of it is owed.

⚑ **This run was also told that [[arcs/diagnostics-arc]] rosters `E11` and
`E50`.** It rosters neither. That arc's twelve element cells are `E157`, `E158`,
`E174`, `E175`, `E176`, `E177`, `E178`, `E179`, `E180`, `E181`, `E182` and
`E183`, and `E11` appears once in the file, in prose at `:122`, about `E158`
being a first client for `E50`. A prose mention is evidence against ownership,
which is the trap `records/homing-triage.md:17-20` records check AE as having
fallen into. `CK12` homes `E11` here and `E50` stays unhomed under author call B.

⚑ **Two built rules refuse the wrong set of programs, and this arc's own
authorities read `built` for both.** `E7`: the mutual negative occurrence is
accepted at exit 0 while the direct one is refused, run 2026-09-18, and PRB-16
has carried the measurement since 2026-09-01 at `owner: E07`. `E9`: a refinement
bound at the I64 maximum is accepted while the same bound one lower is refused,
and PRB-17 has carried it since 2026-09-06 at `owner: E09`. Neither lens row is
in this run's write surface, and **PRB-16's `owner:` cell is owed a repoint**:
the cross-member closure it asks for lives in `E79`'s group judgment, which is
`CK16`, so the row's owner is the `E7` and `E79` join rather than `E7` alone.

⚑ **Four state cells disagree with the code this arc measured**, listed under
requirement 5. `docs/elements/catalog.md:108` for `E14`'s file,
`:434` for `E102`'s four enhancements, `:109` for `E79`'s group pass, and `E2`'s
residue list for the import loader. `ledger-lint` check AB pairs the catalog's
build column against the ledger's state column and reports zero issues, so all
four drifted in the direction AB cannot see. Neither file is in this run's write
scope. [[arcs/sys-face-arc]] found four of the same class on the same day, which
makes eight in two arcs.

⚑ **DISCHARGED 2026-09-18 at `749ce10`. This arc was unanchored on
`arc -> goal done-condition` and is anchored now.** The FLAG read that
`docs/goals/self-hosting.md` conditions 4 and 5 each name `[[arcs/sys-face-arc]]`
and nothing else, so `lens.py chain` reported this file in that rung's uncovered
set at 34 of 35. That goal edit landed: condition 4 at
`docs/goals/self-hosting.md:62-64` names `[[arcs/checker-core-arc]]` and the
requirements carrying it, the table at `:102-107` carries this arc's row opened
with 18 elements, and the rung reads **37 of 37** under `python3
tools/lens/lens.py chain`, measured 2026-09-18. The spans this FLAG cited moved
with the goal, replaced by the two named here. `tools/lens/lens.py:255` reads a
condition's arc from the `[[arcs/...]]` links in its body. The `⚑` at
`docs/goals/self-hosting.md:124` stands undischarged:
`docs/goals/README.md:48` still reads *"none open, and see Rules"* for this
goal, which is true of conditions 1 to 3 and false of 4 and 5.

⚑ **`ledger-lint` check AH raises thirteen violations against this roster and
nine of them are a spelling artifact.** AH globs `f"{elem}-*-SPEC.md"` with the
element cell's literal text (`tools/ledger-lint/ledger-lint.py:2187-2189`), and
the nine single-digit elements' SPECs are zero-padded on disk:
`docs/elements/specs/E01-sexp-reader-SPEC.md` for a cell reading `E1`, and the
same for `E2` through `E9`. All nine SPECs exist. The element cells are written in
the bare form `docs/elements/ledger.md:9-12` fixes as the identity, and no arc
before this one carried a single-digit element cell, which is why the mismatch
surfaces here. **Four of the thirteen are real**: `E79` and `E159` each have no
example under `docs/examples/` and no SPEC under `docs/elements/specs/`, so each
raises both limbs. The tool is outside this run's write scope.

⚑ **`records/lenses/unspoken.md` UNS-13 and UNS-35 admit `E48` and `E102` as
unhomed and both stand at `unreviewed`.** `CK17` and `CK3` give each a home, so
both rows are owed a state change and a `checked:` date. That file is outside this
run's write scope and both edits are owed. The two rows are also why the element
homes owed count falls by sixteen and not by eighteen: check AE exempts an element
an unspoken row admits, so `E48` and `E102` were never inside the owed 67.

⚑ **Whether a design or a SPEC for an `OT` element is planning was ruled
2026-09-17, and both are.** `records/author-calls.md` carries the row at `ruled`,
landed in `7fc6eb0` during this run. No row above is `OT` either way: every one of
the eighteen reads `SH` in `docs/elements/ledger.md`, verified 2026-09-18. The
ruling is named here because `tools/lens/lens.py:466-468` still hard-codes that
call as one of two standing inside chain rung 2, so `lens.py chain` printed it
under this run's own before-and-after census, and that string's repair is recorded
as owed in the ruling's own row.

⚑ **2026-09-23: three measurements against this arc's G1 and G2 scope, and none
of them opens a row.** [[records/checker-core]] carries them as `CK-02`, `CK-03`
and `CK-04`. What each bears on:

- `CK-02` censuses the ten `case` expressions over `Term`'s sixteen formers.
  **Four carry every arm**, `eval-term` (`lib/typing/kernel.chiral:672-690`),
  `infer` (`:819-837`), `term->core`
  (`lib/lowering/upper/closconv-driver.chiral:42-59`) and `pp-term`
  (`lib/surface/pretty.chiral:272-332`), so a seventeenth former is refused by
  `jg-nonexhaustive` at `lib/typing/kernel.chiral:1319`. **Six end in a `_` that
  answers for it unseen.** Two of the six are already ruled, E184's decision 3
  taking the `(_ (none))` arms at `lib/lowering/compile-front.chiral:72` and
  `:134` out. The four with no owner are `tot-tr`
  (`lib/typing/totality-check.chiral:84`, defaulting at `:103`), `mentions?`
  (`lib/surface/data.chiral:203`, defaulting at `:217`), `walk` (`:258`,
  defaulting at `:282`) and `sp-rw`
  (`lib/lowering/upper/specialize-singleton.chiral:124`, defaulting at `:158`).
  Two of those four are
  the strict-positivity judgment `checker-core/CK14` and `checker-core/CK16`
  already convict on a different probe, and neither row is scoped to this shape.
  **The bearing on requirement 1** is that a per-file `_` count ranks these files
  backwards, so the unit the census has to quantify over is the walk. `CK19` is
  drawn over `Judg`'s 36 constructors and does not reach `Term`'s sixteen.
- `CK-03` measures the schema a derived printer would consult as built and read
  only by judgments: `sig-data` (`lib/typing/kernel.chiral:401`) and
  `ctor-fields` (declared `:460`, defined `:1013`) across seven call sites, five
  in the kernel's own checking and two in `lib/module/loader.chiral` at `:550`
  and `:571`. `pp-of` (`lib/surface/pretty.chiral:395`) is the one value-to-
  surface exit for a term, and `quote-val` (`lib/typing/kernel.chiral:762`,
  declared at `:430`) is over `Value` rather than over a declared type, so it is
  no inverse.
  **The bearing is on `checker-core/CK6`**, whose open question is whether `E14`
  retires into `E181` or is kept as its display facet: a printer derived from a
  declaration and a printer written for `Term` are different elements, and the
  row's question reads differently under each. `records/file-types.md` `FT-06` is
  the same absence measured from [[arcs/file-types-arc]]'s side.
- `CK-04` measures the asymmetry `checker-core/CK2` already names. The reader
  computes a position, `(r-err (msg Str) (pos I64))` at
  `lib/surface/sexp.chiral:21`; the elaborator's sum has no field for one,
  `(p-err (msg Str))` at `lib/surface/surface.chiral:25`. Over
  `lib/surface/parse.chiral`: 254 occurrences of `p-err`, 49 constructing from a
  string literal, and **52 of the shape `((p-err m) (p-err m))`**, an error
  destructured and rebuilt unchanged. **The bearing is on `CK2`'s Wanted half**,
  which reads *"a position on `p-err`, and one of them asserted"* with no
  blocking condition measured, and the 52-site shape belongs to
  [[arcs/errors-as-values-arc]] rather than to this arc.

## Resume state

Opened 2026-09-18 against [[goals/self-hosting]] condition 5, on the author's
approval of the four subject arcs when that goal was amended at `2d8dbac` and the
direction of 2026-09-17 to finish them. Nineteen rows, six requirements, nothing
designed. Rows spell `CK`. Every element on the roster was minted before this file
and this run mints nothing.

**The census.** `docs/elements/ledger.md` §CK holds 15 element rows. One, `E49`,
holds a roster row in [[arcs/surface-syntax-arc]]. Fourteen hold none: `E1`, `E2`,
`E3`, `E4`, `E5`, `E6`, `E7`, `E8`, `E13`, `E14`, `E48`, `E79`, `E101` and `E102`.
Four more the goal's own cell names for this arc hold none either, and they sit
outside §CK: `E9`, `E10` and `E11` in §RF, `E159` in §VAL. All eighteen are
rostered above. Eleven read `built`, two read a state the roster's closed
vocabulary has no word for (`E2` is `part` and `E102` is `flight`, both written
`building` here), `E48` reads `design` and is written `open`, and `E9`, `E10`,
`E11` and `E159` read `built`. No element of §CK is `superseded`.

**The row to take up first is `CK14`.** Its probe runs in under a second, needs no
tty, no network and no import, and the refusal it asks for is the one case a
`built` ENFORCED row in the tree gets wrong. `CK16` is the same work seen from the
group pass and closes with it. `CK13` is the third: eleven of its thirteen arms
are unasserted, each is a short source fixture, and requirement 1 is the back-edge
that runs against the whole order. `CK19` is the fourth and makes requirement 1's
number re-derivable, so the next reader of this file does not have to re-run the
census by hand.

**What was measured before any row's state was written.** The judgment census is
re-runnable: read the constructors of `Judg` at `lib/typing/diag.chiral:99-111`,
read their rendered messages from `dg-judg-msg` at `:429-468`, and look each
message up in `tools/test/*.sh` with comment lines dropped. It returns 4 of 36,
and 6 of 36 if a comment counts. The closure census resolves `(import "...")`
transitively from `prog/compiler.prog` over `lib:prog` across the three extensions
`MAP.md:20` names and returns 62 targets and 17,654 lines against `lib/`'s 105
modules and 26,598, with `lib/surface/terms.chiral` the one module of this
subject outside it. The root census greps `^(def compile-main` over `lib prog`,
which is Phase 7's own selector, and returns 103 roots of which 22 are named by
some gate script. The two refusal probes are three lines of source each and both
are recorded in full on `CK10` and `CK14`.
