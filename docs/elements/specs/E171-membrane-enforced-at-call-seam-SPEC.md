---
element: E171
slug: membrane-enforced-at-call-seam
title: The `->`/`=>` membrane, enforced at the call
design: arcs/parts/enforcement-N26.md
status: audited
updated: 2026-09-30
---

# E171 SPEC: The `->`/`=>` membrane, enforced at the call

> The build half, produced by the `design-to-spec` run. The design at
> `docs/arcs/parts/enforcement-N26.md` made the design decisions and an audit gated
> them before this element minted. An implementation run follows THIS file.

## 1. Deliverable

- **After this runs:** the kernel refuses an application whose Pi crosses at a
  seat that does not, with the diagnostic "effectful application at a pure seat
  (use => not ->)". A `(-> I64 I64)` def that calls a `(=> I64 I64)` def no longer
  compiles. The seat a body runs at is the seat of the Pi its lambda is checked
  against; a non-arrow def body, a quantity-0 argument or `let` value, and every
  type run pure.
- **Chosen shape:** Shape A, an ambient seat threaded through the judgment, with
  the rule written as one predicate `seat-sub`
  ([[arcs/parts/enforcement-N26]] §5).
- **Non-goals:**
  - The effect row. `enforcement/N25` widens `seat-sub` to row subsumption later;
    this build keeps the three sites it replaces single (§3 step 2).
  - Extern honesty. The refusal reads declared arrows and trusts an extern
    declared `->`; `enforcement/N27` owns the check.
  - Rule 3, on-binder. E159 built it (`lib/typing/kernel.chiral:360`).
  - A call-graph pass. Every body is checked against its written arrow
    (`lib/module/loader.chiral:388-400`), so transitivity follows by induction
    (design §3).
  - `lib/typing/effects.chiral`. Shape D was declined and the model stays
    uncalled; its header is residue (§5).

## 2. What the code forces

| target | the design assumed | the file admits | verdict |
|---|---|---|---|
| `lib/typing/kernel.chiral:945-951` | the `t-lam` arm binds the Pi's seat and can pass it as the body's ambient | the arm matches `(v-pi qp s dom cod)` and checks the body with `s` in scope | agrees |
| `lib/typing/kernel.chiral:886-894` | `infer-app2` binds the head's seat and never reads it | `(v-pi q s dom cod)` binds `s`; the arm reads `q`, `dom`, `cod` only | agrees; the refusal goes before `(check sig c a dom)` |
| `lib/typing/kernel.chiral:559-563` | `seat-sub` and `seat-none` sit beside `seat=` | `seat=` is there; no `seat-sub`, `seat-none` or `seat-at` is defined anywhere under `lib/` or `prog/` | agrees |
| `lib/typing/kernel.chiral:434-529`, the 38 heads that open `(lam (sig c` | all 38 take the ambient | 3 reach no judgment (`infer-global` `:841`, `infer-prim` `:846`, `finish-tcon` `:1056`). 7 judge only types: `infer-pi`, `infer-pi-lin`, `infer-pi2` (`:854-879`), `check-tcon`, `check-tparams` (`:1036-1055`), `check-refine`, `check-ratoms` (`:1395-1423`). The design's erased rule makes those 7 pure on every path | **constrains**: 28 heads take the ambient. The 10 others take none and call `infer`/`check` with `seat-none`, so a type is pure by construction |
| `lib/typing/kernel.chiral:920-935` | `infer-ann` checks its type pure | `infer-ann` infers `ty` then `infer-ann2` checks `tm` | agrees; the one head that holds both a pure and an ambient judgment |
| `lib/typing/kernel.chiral:1101-1113`, `:1127-1143` | the quantity-0 rule lives at `infer-app2` | `check-con-args` checks each constructor argument against a field `(pair q ftyv)`, and a field may be written `(0 name ty)` (`lib/surface/parse.chiral:496-505`). `solve-slots` infers the same arguments and swallows a `tc-err` | **constrains**: a quantity-0 field is an erased argument (`lib/typing/effects.chiral:39-40`, "a q0 (erased, runtime-absent) position must be pure"). One helper `seat-at` serves all four quantity sites. `solve-slots` passes the same ambient. A refusal it swallows leaves the slot unsolved, so the constructor is still refused: by `check-con-args` when another argument solves the slot, else as `jg-ctor-infer-params` (`:1088-1089`) |
| `lib/typing/kernel.chiral:900-918`, `:981-996` | a quantity-0 `let` value is checked pure | `infer-let` and `check-let` infer the value with `q` in scope | agrees; both call `seat-at` |
| `lib/module/loader.chiral:391`, `:398`, `:419`, `:437`, `:463`, `:508`, `:519`; `lib/surface/parse.chiral:807`; `lib/typing/kernel-core.chiral:58` | top-level callers pass the pure ambient | 9 sites, each a type or a def body checked at the top | agrees; each passes `seat-none` |
| `tools/test/samples/e170_infer_arms.prog:292-380` | not named | 24 calls to `infer`/`check` at the old arity, in a fixture of the unported Phase 12 (`tools/test/run-tests.sh:423`) | **constrains**: the calls take `seat-none` in the kernel commit, and the fixture keeps its compile outcome |
| `lib/typing/diag.chiral:99-111`, `:430-466` | one `Judg` arm and its text | the renderer cases `Judg` exhaustively. `tools/test/arity.sh:548` pins 36 arms, and its M7 (`:566-572`) anchors on the last line of `Judg` (`:111`) and wants 37 | **constrains**: the arm goes on its own line above `:111`; `arity.sh` re-pins 36 to 37 and M7's 37 to 38 in the same commit |
| `tools/test/diag.sh:305-330` | not named | E154: every name `diag.chiral` introduces is defined once across the tree | agrees; `jg-pure-crossing` is defined nowhere today |
| `tools/test/linear-mint.sh:486-497`, `tools/test/mutant.sh:278-286`, `tools/test/diag.sh:185`, `tools/test/arity.sh:426`, `:435` | not named | these anchor exact strings in `kernel.chiral`; none of them holds a `(sig c` call or a helper head | agrees; the implement run confirms each anchor still counts 1 |
| `lib/surface/surface.chiral:101-106` | the innermost binder carries the bit | `build-pis` puts `proc` on the last binder only | agrees; a curried `=>` def's outer lambdas run pure and return a closure |

- **Constraints carried into §3:** the 28/10 split of the helper heads; the
  helper `seat-at`; the `Judg` arm's line and the `arity.sh` re-pin; the
  fixture's 24 calls.
- **Refusals:** none.

**Emitted bytes.** `lib/typing/kernel.chiral` is in the compiler's closure, so
`bin/chirality-bin` changes. The kernel's verdict is pass or fail; the loader
builds the `Sig` from the terms it was handed (`lib/module/loader.chiral:396-399`),
and no lowering pass reads a kernel result. So every program that compiles
before and after emits the same bytes, and the change leaves emission alone:
the build converges at `C1 == C2`. The implement run measures both (step 2).

## 3. Change plan (ordered, commit-sized)

### Step 1: retype the four roots, repair the demo
- **Target:** `prog/samples/prapanca-divide-live.prog:32` (`show-chunks`),
  `prog/samples/prapanca-evidence-sift-refined-live.prog:91` (`dump-pure`),
  `prog/samples/prapanca-parse-robust-test.prog:18` (`dump`),
  `prog/prapanca/chatter/turn-test.prog:447` (`depth-ok`), `prog/demo/_eff.chiral:3`.
- **Change:** each declared `->` becomes `=>`. `_eff.chiral`'s body becomes
  `(put "x")` under the same `(-> I64 Unit)`, so the only thing wrong with it is
  the membrane. The live compiler accepts all five today: a `=>` body may call
  anything, and `_eff.chiral`'s `->` body is the defect this element closes.
- **Check:** Phase 7 under `bin/chirality-bin`, the same counts as before.
  No compiler rebuild: none of these files is in `prog/compiler.prog`'s closure.
- **Size:** S, 5 lines.

### Step 2: the kernel refusal, one edit
- **Target:** `lib/typing/kernel.chiral`, `lib/typing/diag.chiral`,
  `lib/module/loader.chiral`, `lib/surface/parse.chiral`,
  `lib/typing/kernel-core.chiral`, `tools/test/arity.sh`,
  `tools/test/samples/e170_infer_arms.prog`, `bin/chirality-bin`.
- **Change:**
  1. Beside `seat=` (`kernel.chiral:559`), three defs:
     `(def seat-none Seat (s-pure))`;
     `(def seat-sub (-> Seat Seat Bool) (lam (callee amb) (case (seat-crosses callee) (false true) (true (seat-crosses amb)))))`;
     `(def seat-at (-> Qty Seat Seat) (lam (q amb) (case q ((q0) seat-none) (_ amb))))`.
     `seat-crosses` is defined at `:313`, above them.
  2. The 28 heads take `amb` after `c`: `infer`, `infer-app`, `infer-app2`,
     `infer-let`, `infer-let2`, `infer-let3`, `infer-ann`, `infer-ann2`, `check`,
     `check-body`, `subsume`, `check-let`, `check-let2`, `check-let3`,
     `check-con`, `con-with-targs`, `con-check`, `check-con-args`,
     `solve-con-params`, `solve-slots`, `check-case`, `case-branches`,
     `proc-branch`, `proc-branch2`, `branch-finish`, `finish-case`,
     `case-with-default`, `check-against`. Their `declare` lines at `:434-529`
     change with them. Every call among them passes `amb` through.
  3. The 10 others keep their heads. `infer-pi`, `infer-pi2`, `check-tparams`,
     `check-refine` and `check-ratoms` call `infer`/`check` with `seat-none`;
     `infer`'s `t-pi`, `t-tcon` and `t-refine` arms and `check-body`'s `t-tcon`
     arm call them without `amb`.
  4. `infer-ann` infers `ty` at `seat-none`; `infer-ann2` checks `tm` at `amb`.
  5. The `t-lam` arm of `check-body` checks the body at `s`, the seat of the Pi
     it matched. **This is the one place an ambient is introduced from a Pi.**
  6. `infer-app2`: inside the `v-pi` arm, first
     `(case (seat-sub s amb) (false (tc-err (r-judged (subj-none) (jg-pure-crossing)))) (true …))`,
     then the existing check of `a` against `dom` at `(seat-at q amb)`. **This is
     the one call of `seat-sub` in the tree, and `s` here is the one callee seat it
     reads.**
  7. `infer-let` and `check-let` infer `v` at `(seat-at q amb)`;
     `check-con-args` checks each argument at `(seat-at q amb)` with the field's
     `q`; `solve-slots` infers at `(seat-at q amb)` with the `field`'s `q`.
  8. The comments at `:14-15`, `:897-899` and `:1000-1002` state what is built:
     the seat is threaded, the refusal is in `infer-app2`, rule 3 is E159's, and
     the row is `enforcement/N25`'s.
  9. `diag.chiral`: `(jg-pure-crossing)` on a new line between `:110` and `:111`,
     and the renderer arm `((jg-pure-crossing) "effectful application at a pure seat (use => not ->)")`.
  10. The 9 top-level sites (§2) pass `seat-none`. `e170_infer_arms.prog`'s 24
      calls pass `seat-none`.
  11. `tools/test/arity.sh:548-549` want 37, and `:548` names E171 beside
      E182's count; `:571-572` want 38. The comments at `:533` and `:563` move
      with them.
- **The three sites `N25` replaces** stay single: `seat-sub`'s body (item 1),
  the ambient the `t-lam` arm passes (item 5), and the callee seat `infer-app2`
  hands `seat-sub` (item 6). The pure ambient is the one def `seat-none`, named by
  every top-level caller, by `seat-at` and by every type judgment.
- **Build rule** ([[working-discipline]], `docs/definitions/working-discipline.md:15-45`):
  `C1` from `bin/chirality-bin`, `C2` from `C1`, a non-empty check before each
  `cmp`. Expected `C1 == C2`, since emission is untouched. `C1` compiling
  `prog/compiler.prog` is itself the measurement that `lib/` holds no refused
  site. Test with `C1`, then promote it to `bin/chirality-bin` in this commit.
- **Emitted-bytes measurement:** every root Phase 7 compiles, compiled by the old
  and the new binary; the outputs `cmp` equal, each checked non-empty first. A
  root that differs is reported with its name and stops the run.
- **Size:** L, about 150 lines over 7 files, most of them one token per call.

### Step 3: the gate, Phase 36
- **Target:** `tools/test/membrane.sh` (new), `tools/test/run-tests.sh` after
  `:378`.
- **Change:** a phase script on `tools/test/linear-mint.sh`'s shape: `refuse`,
  `admit` and `runs` rows over inline fixtures, a red log, and a mutant leg that
  sources `tools/test/mutant.sh` (`mutant_build` at `:127-151`) and pins each
  mutant's full red set (`linear-mint.sh:420-460` is the idiom). Registered as
  `run_phase 36 "the membrane refused at the call (E171)" membrane.sh`.
  `tools/test/registration.sh` needs no edit: 36 is outside the 21-23 band
  (`:118-121`) and dispatched once.
- **Size:** M, about 200 lines.

### Step 4: the records
- **Target:** `docs/elements/ledger.md:121`, `docs/elements/catalog.md:491`,
  `docs/definitions/status-ledger.md`, the conformance-map row, the arc's roster.
- **Change:** the design's amended rows (§6) with the measured state and
  `tools/test/membrane.sh` as the check; E171 moves to ENFORCED.
- **Size:** S.

## 4. Conformance gate

- **Baseline:** 2026-09-30. Phase 36 does not exist. The design's probe
  (`(def check (-> Str I64) (lam (s) (observe s)))` beside a `=>` `observe`)
  compiles, prints and exits 7 under `bin/chirality-bin` at 1,253,752 bytes
  ([[arcs/parts/enforcement-N26]] §2). Phase 7 compiles the four roots.
- **Expected:** Phase 36 green with every row below. Each fixture uses only the
  prelude and the stdio port, and is compiled by `$CHIRALITY_COMPILE`.

| row | fixture | want |
|---|---|---|
| R1 direct | `(def eff (=> I64 I64) (lam (n) (do (put "x") n)))` and `(def f (-> I64 I64) (lam (n) (eff n)))` | refused, the E171 text |
| R2 callback | `(def app (-> (=> I64 I64) I64 I64) (lam (g n) (g n)))` | refused, the E171 text |
| R3 data field | `(data Box () (box (run (=> I64 I64))))`, a `->` def applying the field it matched | refused, the E171 text |
| R4 partial application | `eff2 : (=> I64 I64 I64)`; a `->` body that binds `(eff2 n)` and saturates it | refused, the E171 text |
| R5 quantity-0 argument | `(def k (-> (0 x I64) I64 I64) …)` applied to `(eff n)` inside a `=>` body | refused, the E171 text |
| R6 quantity-0 `let` | `(let ((0 x (eff n))) n)` inside a `=>` body | refused, the E171 text |
| R7 quantity-0 field | `(data Tag () (tag (0 w I64) (v I64)))`, `(tag (eff n) n)` inside a `=>` body | refused, the E171 text |
| R8 type position | `(def pick (=> Unit (type 0)) …)`, `(the (pick unit) n)` inside a `=>` body | refused, the E171 text |
| R9 non-arrow def | `(def v I64 (eff 3))` | refused, the E171 text |
| R10 the demo | a root importing `demo/_eff` | refused, the E171 text |
| A1 `=>` body | R1's `eff` called from a `=>` `compile-main` | compiles, runs, exit pinned |
| A2 curried `=>` | R4's `eff2`, and `(def p (-> I64 (=> I64 I64)) (lam (n) (eff2 n)))` | compiles |
| A3 pure calls pure | a `->` def calling a `->` def and a `->` extern; its `compile-main` calls no crossing | compiles |
| A4 E42 | `prog/samples/e42_reject_pure_as_process.prog` | refused with "type mismatch", the `conv` refusal |
| A5 the four roots | the four files of step 1 | each compiles |

R5 to R8 sit in `=>` bodies on purpose: there the call refusal admits them, so
only the erased rule refuses them. Every R row pins the E171 text, since a row
that wants only a refusal passes on any refusal. R8 needs it: the kernel leaves
a global stuck (`lib/typing/kernel.chiral:682`), so under M4 `n` fails against
`(pick unit)` as a type mismatch and the row stays refused.

- **Mutants, each run, each pinning its full red set:**
  - **M1 refusal-off:** `seat-sub`'s body becomes `true`. Reddens R1 to R10.
    A1 to A5 stay green.
  - **M2 erased-arg-off:** `seat-at` returns `amb` for every quantity. Reddens
    R5, R6, R7 only.
  - **M3 lambda-ambient-pure:** the `t-lam` arm passes `seat-none` in place of
    `s`. Every `=>` body that applies a crossing is then refused. Reddens A1
    (`eff`), A2 (`eff2`), A4 (`poll-fds` applies `nb-poll`,
    `lib/runtime/poll.chiral:82-86`, in the sample's import closure) and A5. A3
    stays green: its root and the prelude hold no such body. No R row is in it:
    each stays refused with the E171 text.
  - **M4 annotation-type-ambient:** `infer-ann` infers `ty` at `amb`. Reddens R8
    only.
  - A mutant that does not build scores BUILD:fail; one byte-identical to the
    base scores INERT; the base red set is asserted empty first.
- **Structural rows:** `(seat-sub ` occurs at one call site under `lib/`, and
  `infer-pi`, `infer-pi2`, `check-tparams`, `check-refine` and `check-ratoms`
  take no seat. A scratch copy with a second call added reddens the first row.
- **Neighbouring phases:** Phase 7 compiles every root it compiled before;
  Phase 24 (`arity.sh`) reads 37 arms; Phase 6 (`linear-mint.sh`) and Phase 13
  (`diag.sh`) keep their tallies.
- **Named phase:** 36, `tools/test/membrane.sh`.
- **Done when:** `tools/test/run-tests.sh` shows Phase 36 green with R1 to R10,
  A1 to A5, the structural rows and M1 to M4 each convicting its pinned set, and
  every other phase reports what it reported before step 2.

## 5. Residue and links

- **Deliberately unbuilt:**
  - Extern honesty: 43 externs declared `->` are trusted as declared.
    `enforcement/N27`.
  - The row: `seat-sub` over rows, the lambda's ambient as the row evaluated at
    its variable, the callee's row evaluated at the argument. `enforcement/N25`,
    then E39.
  - `memory-discipline/M9`'s seal: a `->` def that applies its `=>` block is
    refused here, so the seal is a kernel rule or a trusted extern. Carried into
    that row's design.
  - `prog/scriba/flook.chiral:132`: a pure-seat call in a file that names the
    unbound `flook-list` and has no importer. A revisit of the scriba subtree.
  - `lib/typing/effects.chiral:1-6` still calls a deleted file the oracle, and its
    three rules are superseded once E171 and E39 land. A `doc-audit` of that file,
    or `N25`'s SPEC.
  - The kernel comment `tools/test/arity.sh:16` cites kernel line numbers that
    step 2 moves. A `doc-audit` of that script.
- **Follow-on:** `enforcement/N25`, `enforcement/N27`, `memory-discipline/M9`.
- **Related:** [[arcs/parts/enforcement-N26]], [[arcs/enforcement-arc]],
  [[banks/effect-and-alarm]], E12, E159, E39, [[working-discipline]].
