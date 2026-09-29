---
row: enforcement/N23
arc: enforcement
title: the per-rewrite value check: every rewrite `opt-tfns` adopts runs under `lib/lowering/tal/eval.chiral` (`tal-eval`, `:98`) on its input and its output over a named corpus of TFns and arguments, and a disagreement refuses the rewrite and keeps the input. [[records/findings]] FD-55 §1 (`records/findings.md:1485`) measured this as nanopass's evaluable-language check and as `N13`'s T1 run per pass, cheaper than `N13` because both sides are the same IR. **Its standing falsifier exists**: `dead` alone grades `tools/test/row.sh` at `33 passed, 9 failed` and `ck-fn` accepts its residual (EN-24), so a check that stays green on `dead` measures nothing. **It quantifies over every pass `opt-tfns` adopts**, so the passes [[arcs/emitted-speed-arc]] schedules enter under it: an inlining step (`emitted-speed/X11`) owes its residual equal to the `let` it replaces under the evaluator (FD-55 §2, `:1493`), and a `specialize` call site (`emitted-speed/X10`) owes the Lambdamix shape, the residual equal to the original with its static inputs supplied (§3, `:1507`). Their effort and size counters are emitted-speed's and carry no correctness weight, because an aborted attempt keeps the call. **Two preconditions, read 2026-09-29 and not run.** `eval-prim` (`eval.chiral:86-95`) defines five of the eight operations `fold` rewrites and answers `(v-i64 0)` for `=i`, `<i` and `<=i`, which the lowering emits (`lib/lowering/tal/erase.chiral:97-99`), so the check would disagree with every comparison `fold` makes; that repair is E18's interpreter half, `N8`, and `N13` rests on the same evaluator. The evaluator omits the sysface (`eval.chiral:11`), so the corpus is pure TFns. **Where it runs is the author's**: on every self-compile inside the closure, or as a gate over the census the way `prog/optimizer-census.prog` runs `ck-fn` outside it. [[records/author-calls]] carries the call
kind: tool
origin: connect
req: 7
status: blocked
updated: 2026-09-29
---

# enforcement/N23: the per-rewrite value check

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** for every TFn `opt-tfns` rewrites, the input and the output are
  run under `tal-eval` (`lib/lowering/tal/eval.chiral:98`) over a named corpus,
  and a disagreement refuses the rewrite. The check reddens when `opt-tfns`
  adopts `dead` and stays green on `fold`.
- **Serves:** requirement 7 of [[arcs/enforcement-arc]]
  (`docs/arcs/enforcement-arc.md:471-507`), "**Every rewrite the optimizer
  adopts carries evidence that its output means what its input meant, and a
  rewrite without that evidence is refused.**" The requirement names this row
  as its first half at `:482-484`.
- **Goal:** [[goals/enforcement]], condition 2, "a claim the compiler makes
  about its own work is carried as a value with evidence, and refused when it
  does not hold". Condition 3 (`docs/goals/enforcement.md:34`) is touched only
  through the placement call in §5.

## 2. What the tree holds

Measured 2026-09-29 at `95e8043`, working tree as the author left it.

- **Bank:** [[banks/verification]]. Shard 2 (`docs/banks/verification.md:126-135`)
  calls `preserve-check` a translation validator "per compilation" and states
  its caveat: it checks types and leaves behaviour unchecked. Shard 9
  (`:468-477`) is the behavioural half, `E169`, at DESIGN, pairing
  `lib/evidence/interp.chiral` with `eval.chiral` across lowering. This row is
  the same evaluator on both sides of one tal-to-tal rewrite, which no shard
  holds. [[banks/evidence-and-split]] names `optimize.chiral` as an untrusted
  producer (`docs/banks/evidence-and-split.md:243`) and adds no shard here.
- **Settled texts.** `docs/decisions/decision-self-verification.md:170-178`
  names translation validation, "check each emitted artifact against its input,
  per compilation", as the move below L0. PRB-70
  (`records/lenses/problems.md:984-986`) ruled the checker outside the compiler
  closure. [[records/findings]] FD-55 §1 (`records/findings.md:1485`) and §4
  (`:1509-1521`) price the route.

| what exists | where | rung | reached by |
|---|---|---|---|
| the rewrite on the shipping path: `opt-tfns` maps `fold` over every emitted TFn, with no verdict consulted | `lib/lowering/compile-back.chiral:246-250`, import at `:16` | ENFORCED as a rewrite, unjudged | `lower-defs`, every compile |
| `fold`: five arithmetic arms, three comparison arms; a folded comparison becomes `(i-con dst "Bool" cn nil ty)` | `lib/lowering/upper/optimize.chiral:60-67`, `:68-73`, `:92`, `:140` | IMPLEMENTED | `opt-tfns` |
| `dead`: a flow-insensitive liveness fixpoint that drops an unused `i-const`, `i-prim`, `i-blen`, `i-bget` or nullary `i-con` | `optimize.chiral:166-174`, `:192` | SEEDED | `optimize` (`:262-263`) and `specialize-raw` (`:249-256`, ending `(dead (fold ...))` at `:256`); neither has a caller in `lib/` or `prog/` outside the module |
| the standing falsifier: `dead` alone grades `tools/test/row.sh` at `33 passed, 9 failed`, the nine being E174 G4's `rnd-cols reported no width`, and `ck-fn` accepts the residual | `records/enforcement-arc.md:287` EN-24; `docs/elements/catalog.md:117` | measured 2026-09-05 | no gate re-derives it |
| the target evaluator: fuel-bounded, register file and byte store threaded, `(-> I64 Prog Store TFn (List Val) RunR)` | `lib/lowering/tal/eval.chiral:98`, `:111-187` | SEEDED | zero importers: `grep -rln 'lowering/tal/eval"' lib prog tools` returns nothing |
| `eval-prim`: `+ - * / %` over two `v-i64`, and `(v-i64 0)` for every other op or operand shape | `eval.chiral:86-95`, the two fallbacks at `:88` and `:95` | SEEDED | `eval-instr`'s `i-prim` arm, `:132-134` |
| the op names a lowered `i-prim` may carry: sixteen native ops parsed by `op-parse`, the three comparisons among them, and 24 byte-library rows | `lib/lowering/tal/erase.chiral:91-108`, comparisons `:97-99`, `prim2lib-table` `:112-142` | IMPLEMENTED | `lowerable-prim?`, `compile-back.chiral:280-289`, admits exactly these plus `bget`, `blen`, `str-len` |
| a string literal in typed SSA is `(i-const d (tt-str) ix)`, an index into the literal table; `eval-instr` reads every `i-const` as `(v-i64 v)` and `tal-eval` takes no literal table | `lib/lowering/upper/lower.chiral:241-244`; `eval.chiral:131`, `:98` | SEEDED | nothing |
| a sysface: absent, "Sysface (sys/bptr) omitted (pure floor)" | `eval.chiral:11` | absent | the gap is empty on this path: `lowerable-prim?` refuses a crossing op, so no effectful TFn reaches `opt-tfns` (`compile-back.chiral:280-289`, crossings listed at `lib/lowering/tal/crossing-wraps.chiral:13-20`) |
| the source-side evaluator | `lib/evidence/interp.chiral`, 109 L | SEEDED | zero importers; `enforcement/N13` holds its pairing with `eval.chiral` |
| the out-of-closure driver shape: a root that runs `compile-front` and `compile-back`, applies `fold` per TFn and judges each from outside the closure | `prog/optimizer-census.prog:49-53`, `:76-78` | ENFORCED as a gate | `tools/test/opt-census.sh`, `8 passed, 0 failed` at `38ecdba` (`docs/arcs/enforcement-arc.md:308-310`) |
| the self-compile this row's first placement would charge | `bin/chirality-bin` (tracked at `30b288b`) over the `prog/compiler.prog` blob | measured 2026-09-29 | the blob measured 851,722 bytes on 2026-09-29; 0.778 s and 0.790 s wall over two runs, 394,240 KB max RSS, output byte-identical to the tracked binary |

**Three readings the row's text depends on, re-derived.**

1. **The comparisons refuse on the input side, before any disagreement.** A
   comparison `i-prim` evaluates to `(v-i64 0)` (`eval.chiral:95`); the `tt-case`
   that scrutinizes it then answers
   `r-err "case: scrutinee is not a constructor"` (`eval.chiral:180`). The folded output carries a `v-con`
   (`optimize.chiral:92`) and runs. So every TFn where `fold` folds a comparison
   is unevaluable on the input side, and a check that counts input `r-err` as
   exclusion drops it silently from the corpus.
2. **The fallback manufactures agreement.** An op outside `eval-prim`'s five
   yields `(v-i64 0)` on both sides of a rewrite. Where the rewrite drops or
   keeps such an instruction, both sides read the same fabricated value and
   agree. The check is unsound over any TFn using 35 of the 40 lowerable op
   names until an undefined op refuses.
3. **The falsifier's path runs through the ops the evaluator lacks.**
   `rnd-cols` reaches `str-cols` (`lib/protocol/render.chiral:448-449`), which is
   `decode-utf8` over `str->bytes`; `decode-utf8` is `decode-from` over `blen`
   (`lib/protocol/utf8.chiral:104-105`) and `utf8-decode1` over `bget`, `band`,
   `bor`, `shl`, `<i` and `<=i` (`utf8.chiral:42`, `:52-86`, `:60`). This is read
   from source and was never run. Which TFn `dead` miscompiles is unmeasured, and every
   candidate on the path EN-24's nine failures name is outside what
   `eval-prim` defines. A corpus scoped to today's evaluator cannot redden on
   `dead`.

## 3. The delta

What is missing once §2 is subtracted.

1. **An evaluator that can see the falsifier.** `eval-prim` must define every
   op on `dead`'s failing path and fold's eight, and must refuse an undefined
   op; `tal-eval` must carry the literal table. §2 readings 1 to 3 make this a
   precondition of any honest verdict. It is E18's module and it is unrostered:
   `enforcement/N8`'s text (`docs/arcs/enforcement-arc.md:539`) holds the call
   site and the pairing, and names no op coverage.
2. **A verdict over one rewrite.** A pure function from a corpus, a `Prog`, an
   input TFn and an output TFn to a closed sum: `agree` with the entry count,
   `disagree` with the first differing entry and both results, or `vacuous`
   when no corpus entry evaluates on the input side. Value equality over `Val`
   dereferences `v-cell` through each side's `Store`, since cell ids are
   allocation order (`eval.chiral:150`).
3. **A named corpus.** Programs, each with an entry TFn and argument tuples,
   compiled by the same `compile-front` and `compile-back` the census uses.
   The first member is the program behind E174's G4 rows, so the falsifier is
   in the corpus by construction.
4. **A gate with a run mutant.** `M-dead` makes `opt-tfns` adopt
   `(dead (fold t))`; the gate must redden. `M-vacuous` makes `eval-prim`
   answer `(v-i64 0)` again; the gate must redden on its vacuity row. A control
   row asserts `fold` agrees over the whole corpus.
5. **A consumer for the verdict**, which is the placement call.

`dead`'s repair is `enforcement/N7`'s (`docs/arcs/enforcement-arc.md:538`), and
this row delivers the instrument that re-admits it. Effectful TFns are outside
the delta, because none reaches `opt-tfns` (§2).

**Verdict:** a real delta. Items 2 to 4 are this row's; item 1 is a
precondition owned elsewhere; item 5 is the author's.

## 4. The shapes

Two axes differ in the tree and a third is the author's.

### Axis 1: how `N23` depends on the evaluator

**Shape P, precondition.** `N23` builds its verdict, corpus and gate, and the
gate's `M-dead` row is declared unrunnable until an evaluator row lands.
- **Costs:** nothing in `eval.chiral`. The gate ships with its falsifier row
  marked blocked, which requirement 6 forbids as a finished state.
- **Forbids:** `N23` reaching `built` before the evaluator row does.

**Shape S, first slice.** `N23`'s first build step extends `eval-prim` to the
ops the corpus needs, adds the literal table and makes an undefined op refuse.
- **Costs:** an edit to E18's module under `N23`'s number. `N13`, `LE20`
  (`docs/arcs/lowering-and-emit-arc.md:220`) and `E169` rest on the same
  evaluator and would inherit a coverage decision made for one consumer.
- **Forbids:** a separate audit of the evaluator's meaning. The op table would
  be graded only by the check that consumes it.

**Shape C, scoped corpus.** Ship now over TFns whose ops are `+ - * / %`,
`i-call`, `i-con` and `tt-case`.
- **Costs:** §2 reading 3. The falsifier sits outside the scope, so the gate
  cannot redden on `dead`, and reading 1 excludes every folded comparison.
- **Forbids:** the requirement's own observation, "a value check over a named
  corpus that reddens on `dead` today" (`docs/arcs/enforcement-arc.md:482-484`).

### Axis 2: where the corpus arguments come from

**Shape W, whole-program swap.** Each corpus entry is an entry TFn and fixed
arguments. For a rewrite `t` to `t'`, evaluate the entry under `Prog` holding
`t` and under `Prog` holding `t'`, everything else unchanged.
- **Costs:** a full entry evaluation per changed TFn per reaching entry. A TFn
  `fold` leaves unchanged is skipped. No evaluator change beyond Axis 1.
- **Forbids:** checking a TFn no corpus entry reaches. The check says so as
  `vacuous`.

**Shape T, type-drawn arguments.** Evaluate `t` and `t'` alone, with arguments
drawn from each parameter's `TalTy`: a boundary table for `tt-i64`, nullary
constructors for `tt-data`.
- **Costs:** a generator over `TalTy` (`lib/lowering/tal/ssa.chiral:20-21`).
  `tt-str` and `tt-bytes` have no literal table to draw from, and a
  `tt-data` with fields needs a recursive builder.
- **Forbids:** nothing structural. It exercises values no program produces, so
  a disagreement may be on an unreachable input.

**Shape R, recorded arguments.** Run the corpus once on the input `Prog`,
record the argument tuples each TFn receives, then evaluate `t` and `t'` alone
on those.
- **Costs:** a recording hook in `eval-instr`'s `i-call` arm
  (`eval.chiral:135-144`), a second edit to E18's module.
- **Forbids:** nothing; it is W's coverage at T's price per rewrite.

### Axis 3: where the verdict is consumed, the author's

**Arm A, every self-compile.** `opt-tfns` consults the verdict and keeps `t`
on `disagree`.
- **Costs:** `eval.chiral` and the check module enter `prog/compiler.prog`'s
  closure, so every later edit to either owes the BUILD RULE. Three names in
  `eval.chiral` collide with the closure's blob today: constructors `r-ok` and
  `r-err` against `RR` at `lib/surface/sexp.chiral:20-21`, and `zeros` against
  `lib/lowering/mach/asm-reloc.chiral:46`, measured by grepping the blob.
  The corpus must travel into the compile, which forces Shape T or a compiled-in
  fixture, since a user compile has no named programs to evaluate. Time is
  unmeasured on this tree: the base is 0.78 s and 394 MB for a self-compile
  (§2), and FD-55 prices a validator at 1.1x to 4x of the checked pass's own
  time (`records/findings.md:1509-1521`), with no source measuring a per-pass
  evaluator check (`:1535`).
- **Forbids:** PRB-70's ruling as written, if it reaches `eval.chiral`, which
  the ruling leaves unsaid ([[records/author-calls]] `:116`).
- **Buys:** the row's literal text, "refuses the rewrite and keeps the input".

**Arm B, a gate outside the closure.** A root in the shape of
`prog/optimizer-census.prog` runs the check over the corpus; a disagreement
reddens the gate and the promote waits.
- **Costs:** a miscompiling rewrite still ships in any build that skips the
  gate. The compile keeps the rewrite, so "keeps the input" becomes "blocks the
  promote". Zero BUILD-RULE charge. Its wall cost falls on the gate tier, where
  `opt-census.sh` ran 7 s at `38ecdba` (`docs/arcs/enforcement-arc.md:308-310`).
- **Forbids:** goal condition 3's reading "running in the shipping compile"
  (`docs/goals/enforcement.md:34`).

## 5. The call

- **Chosen, Axis 1: Shape P, with the precondition scoped.** The evaluator's
  coverage is E18's, and three other consumers rest on it (§4 Shape S), so it
  belongs in its own row with its own audit. The precondition is stated as a
  set, so the owning row has a finish line: `eval-prim` defines fold's eight
  and the ops on the path in §2 reading 3 (`bget`, `blen`, `str->bytes`,
  `band`, `bor`, `shl`), an undefined op answers `r-err`, and `tal-eval`
  carries the literal table. Everything else in the 40 op names is `vacuous`
  until defined. Shape C is refused: it cannot meet requirement 7's own
  observation.
- **Chosen, Axis 2: Shape W for the first build, Shape R deferred to a
  measured cost.** W needs no evaluator change beyond the precondition, and a
  single-TFn swap localizes a disagreement to the rewrite that caused it. R is
  the repair if W's cost is measured too high, and T is refused as the default
  because it grades inputs no program produces.
- **Axis 3: carried, NEEDS-AUTHOR.** The row exists at
  `records/author-calls.md:116`. The verdict function, corpus and gate are the
  same under both arms; only the consumer differs, so the SPEC stage can plan
  items 2 to 4 of §3 before the ruling and must plan item 5 after it.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Where the verdict is consumed: every self-compile, or a gate outside the closure | **NEEDS-AUTHOR** | `records/author-calls.md:116`, `unreviewed`. PRB-70 (`records/lenses/problems.md:986`) points out, `docs/decisions/decision-self-verification.md:175` and `docs/goals/enforcement.md:34` point in. §4 Axis 3 prices both arms. No new row is opened |
| 2 | Who extends `eval-prim` and adds the literal table | **NEEDS A ROW** | E18 owns `eval.chiral` (`docs/elements/ledger.md:135`); `enforcement/N8`'s text holds no op coverage. Listed in the residue table below. A roster edit is outside this run's write surface |
| 3 | Whether `N23` checks `specialize` and inlining | **DEFERRED → `emitted-speed/X10`, `X11`** | The row quantifies over whatever `opt-tfns` adopts. Adopting either is those rows' act (`docs/arcs/emitted-speed-arc.md:335-336`); the check needs no change, since a residual is a TFn |
| 4 | Whether `dead` is repaired here | **DEFERRED → `enforcement/N7`** | `docs/arcs/enforcement-arc.md:538` re-admits `dead` only under this row. `N23` supplies the instrument and repairs nothing |
| 5 | Whether a disagreement on a comparison is a defect in `fold` | **RESOLVED → no** | §2 reading 1: the input side refuses before comparison, so the verdict is `vacuous` for those entries today. `enforcement/N24` checks fold's arms against the emitted instruction |
| 6 | Whether the gate takes a suite phase number | **RESOLVED → `not-a-phase:` with a reason** | The route `opt-census.sh` and eight siblings take, kept green by `tools/test/registration.sh` G2 and G4 (`docs/arcs/enforcement-arc.md:383-390`) |
| 7 | Whether the eval name collisions block Arm A | **DEFERRED → `lowering-and-emit/LE18`** | Label mangling is `E154`'s, and until it lands a rename of `r-ok`, `r-err` and `zeros` is the cost Arm A carries (§4) |

Decision 1 sets `status: blocked`. It blocks the mint's consumer half and
leaves items 2 to 4 of §3 designable.

## 6. The mint packet

- **Elements: one.** The verdict, the corpus and the gate constrain each other:
  the corpus is chosen so the gate's `M-dead` row can redden, and a verdict with
  no gate re-derives nothing, which is EN-25's conviction of requirement 4. The
  evaluator coverage is a separate row (§5 decision 2) because its consumers
  outnumber this one.
- **Band:** `E184-E189` is spent (`docs/decisions/decision-lane-split.md:31-35`,
  `:44-45`), and an arc with no band takes the next free number tree-wide
  (`:60-62`). Measured 2026-09-29 over `docs/elements/catalog.md` and
  `docs/elements/ledger.md`, the highest minted is 202, so the free number is
  203. `E<NN>` below is what `pack.py --mint` recomputes.
- **Catalog row:**
  `| E<NN> | **The per-rewrite value check: every rewrite opt-tfns adopts agrees with its input under tal-eval over a named corpus, or is refused.** A pure verdict over one rewrite (agree, disagree with the first differing entry, or vacuous), a corpus of named programs whose entries reach the rewritten TFn, and a gate whose M-dead mutant makes opt-tfns adopt dead and must redden. The consumer is the author's call at records/author-calls.md:116 | Not built. Rests on eval-prim covering fold's eight ops, the ops on dead's failing path and refusal of an undefined op, which no row holds | OURS (prog/optimizer-census.prog, one stage later); nanopass's per-pass evaluation (PAPER, FD-55 §1) | SH |`
- **Ledger row:**
  `| E<NN> | rewrite-check | design | Per-rewrite value check under tal-eval, verdict + corpus + gate; consumer awaits records/author-calls.md:116 | enforcement/N23 | SH |`
- **Size and closure.** Basis: `prog/optimizer-census.prog` is 225 lines for the
  census root, and `eval.chiral` is 187 lines for a full evaluator.

  | file | change | lines | inside `prog/compiler.prog`'s closure |
  |---|---|---|---|
  | `lib/lowering/tal/rewrite-check.chiral` (new) | the verdict and `Val` equality over two stores | 100 to 150 | no under Arm B; yes under Arm A |
  | `prog/rewrite-check.prog` (new) | the corpus runner, W shape | 150 to 220 | no |
  | `tools/test/rewrite-check.sh` (new) | control row, `M-dead`, `M-vacuous` | 150 to 250 | no |
  | `tools/test/samples/` | corpus fixtures | 2 to 4 files | no |
  | `lib/lowering/compile-back.chiral:246-250` | `opt-tfns` consults the verdict | 10 to 20 | **yes**: Arm A only, owes the BUILD RULE |
  | `lib/lowering/tal/eval.chiral` | none from this element; the precondition row edits it | 0 | no today; yes under Arm A, owes the BUILD RULE on every later edit |
  | `lib/lowering/upper/optimize.chiral` | none | 0 | yes, untouched |

  Under Arm B no `lib/` file inside the closure changes and no BUILD RULE cycle
  is owed. Under Arm A the cycle is owed once for the wiring and again for each
  later edit of `eval.chiral` or the check module.
- **Related:** [[banks/verification]] shards 2 and 9 · [[records/findings]]
  FD-55 · [[records/enforcement-arc]] EN-24, EN-25, EN-36 ·
  `records/lenses/problems.md` PRB-70 · `enforcement/N7`, `N8`, `N13`, `N24` ·
  `emitted-speed/X10`, `X11` · E17, E18, E169

Every `E#` named here is already minted. 203 is the number free today.

## Residue

### Needed and unrostered

Grepped 2026-09-29 over `docs/arcs/*-arc.md` for `eval-prim`, `eval.chiral`,
`tal-eval`, `literal table` and compile-time budget. The only rows naming
`eval-prim` are `N23` and `N24` in the enforcement arc, and neither owns its
repair.

| needed | evidence | arc it belongs to |
|---|---|---|
| `eval-prim` defines fold's eight ops and the ops on `dead`'s failing path, and answers `r-err` for an undefined op in place of `(v-i64 0)` | `lib/lowering/tal/eval.chiral:86-95`, fallbacks at `:88` and `:95`; the 40 lowerable op names at `lib/lowering/tal/erase.chiral:91-108` and `:112-142`; `enforcement/N8` at `docs/arcs/enforcement-arc.md:539` names no op coverage | enforcement, as E18's interpreter half |
| `tal-eval` carries the literal table, so a `(i-const d (tt-str) ix)` evaluates to its string | `lib/lowering/upper/lower.chiral:241-244`; `eval.chiral:131` reads every `i-const` as `v-i64`; `eval.chiral:98` takes no table | enforcement, the same row as above |
| a condition that holds the compiler's own time and memory, so Arm A has a budget to be priced against | FD-55's `element:` field, `records/findings.md:1544`: "no goal condition holds the compiler's own time"; `records/author-calls.md:116` records the author's "2 seconds and 1gb" without its referent; measured here, 0.78 s and 394 MB per self-compile | emitted-speed, after a `goal-open` amendment names the condition |

### Drift against the brief and the row

- The row and the brief cite FD-55 at `records/findings.md:1485`, `:1493`,
  `:1507` and `:1521`. These resolve in the working tree only. At `HEAD` the
  author's uncommitted 239-line insertion ahead of FD-55 is absent and FD-55
  starts at `:1236`, with §1's "What it owes" at `:1246`.
- The row reads "that repair is E18's interpreter half, `N8`". E18 owns the
  module; `N8`'s text holds no op coverage. The first residue row is the gap.
- The row reads "the check would disagree with every comparison `fold` makes".
  Traced through `eval.chiral:180`, the input side refuses first, so the
  comparison entries fall out as `vacuous` and show no disagreement (§2
  reading 1).
- `specialize-raw` spans `optimize.chiral:249-257`; the brief's `:249-256`
  holds `(dead (fold ...))` at `:256` as stated.
- The row's "the corpus is pure TFns" holds and costs nothing today: no
  effectful TFn reaches `opt-tfns`, because `lowerable-prim?` refuses a crossing
  op (`lib/lowering/compile-back.chiral:280-289`).

### Unmeasured

- Which TFn `dead` miscompiles. §2 reading 3 bounds the path from source.
- How many TFns `fold` changes per self-compile, which sets Shape W's cost.
- The wall and memory cost of either arm.
