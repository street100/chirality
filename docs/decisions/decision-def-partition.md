---
node: decision-def-partition
layer: decision
related: [decision-preserve-check, decision-erased-word-level, decision-design-before-mint, arc-enforcement, records-findings, banks/erasure, status-ledger, index]
status: settled
updated: 2026-09-10
---

# Decision: what a definition's fate is, and who owns the partition

The compiler decides, for every definition it is given, whether that definition
reaches the artifact. Five mechanisms make that decision, three of them keep a
record, and no document states the classification they are jointly computing.
`lib/lowering/upper/lower.chiral:22-105` holds an abandoned attempt at one. This
settles what the partition is, what its classes are, where it lives, and which
element builds it.

## 0. The fork, and how it was ruled

`docs/arcs/parts/enforcement-N14.md` §5 opened the fork as decision 2:
**whether the 84-line unreached partition in `lower.chiral` is retired or
repaired.** Its Shape A repaired the dead code as `docs/elements/catalog.md:449`
instructs. Its Shape E deleted it. Two settled documents pointed one way and one
measurement pointed the other.

**Ruled 2026-09-09 by the author: NEITHER.** The row in
[[records/author-calls]] carries the words: *fix the partitioning the proper
way obviously. if its not the original partition and we're going to do it
differently outline it and doc*. Both shapes are refused. The deliverable is the
partition the tree should actually have, written down, and this document is it.

The ruling is answerable because the partition already has an owner. **E184's R1
is a total fate function over every def in the compiler's closure**
(`docs/elements/catalog.md:500`), minted 2026-09-01, ledger state `design`,
unbuilt. §3 below states the identity and §2 states what the measurement changes
about its classes.

## 1. The carrier: one classification, and a composition cannot be made total

The live tree decides a definition's fate in three places. The first question is
whether the partition is one classification or a named composition of those
three with a stated order.

**It is one classification.** A composition is unavailable, for two structural
reasons and one measured one.

| the three channels | acts on | records through |
|---|---|---|
| `peel-def` (`lib/lowering/compile-front.chiral:212-224`) | the front's global set, before `specialize-singletons` renames | **nothing.** four `(none)` arms, three causes, no record on any |
| `compile-fn` → `le-skip` (`lib/lowering/compile-back.chiral:270-271`) | the peeled `NDef` list, after closconv | `(mk-skrec name (sk-extern er))` |
| `filter-erasable` and `prune-pass` (`lib/lowering/compile-back.chiral:191`, `:211`) | the emitted `TFn` list | `(sk-extern op)` and `(sk-callee cn)` |

**The three range over three different sets, in sequence.** Each consumes the
survivors of the one before it. A composition of them classifies the last set,
and the members the first two removed are outside every class it can name.

**The first channel keeps no record, so a composition is missing its own first
stage by construction.** `peel-def` is `(-> ... (Maybe NDef))` and every one of
its four `(none)` arms discards the definition with no trace: the codomain
refusal, the kept-domain refusal, and two body refusals through `term->ncore`.
`prims->n` (`lib/lowering/compile-front.chiral:335-337`) does the same for
extern signatures. E184's R3 already names this as the only one of the five
mechanisms leaving nothing behind.

**The cascade is a chain, and a chain names a pointer.** `prune-fix`
(`lib/lowering/compile-back.chiral:214`) iterates `prune-pass` to a fixpoint, so
a `sk-callee` record can point at a definition that itself carries a `sk-callee`
record. The cause of a cascade drop is the non-cascade root at the end of the
chain, which E184's R5 requires and which no composition of three filters
computes.

**What forces one classification:** E184's R7, conservation checked inside the
compile, exactly one fate per definition, folding the fates reproduces the
emitted set. A definition with no fate, or with two, fails the compile. That is
the property a composition of three sequential filters cannot state.

**The set it ranges over:** the definitions of the compiler's closure as they
stand before `specialize-singletons` (`lib/lowering/compile-front.chiral:20`,
reached at `:373`), because that pass rewrites `x64` into `x64$0` and the fate
relation has to cross the renaming. E184's R6 is that requirement and names it
the design fork.

⚑ **THE ORDER IS BACKWARDS ON BOTH HALVES AND THE DOMAIN IS RULED. 2026-09-10.**
The channel table above reads that `peel-def` acts on the front's global set
*before `specialize-singletons` renames*, and the paragraph above fixes the domain
as the set standing before that pass *because that pass rewrites `x64` into
`x64$0`*. Both halves were measured at HEAD `838c311` for this run.

- **Peel runs after the pass.** `lib/lowering/compile-front.chiral:373` composes
  `(bridge-sig (closconv-sig (specialize-singletons sig)) name)`, and the peel it
  reaches at `:349` is `peel-globals` (`:226-233`).
- **The pass creates and deletes.** `lift-lifted`
  (`lib/lowering/upper/specialize-singleton.chiral:195`) lifts a field body into a
  NEW global `<gname>$<i>`, **13** on `prog/compiler.prog`. `process-mk` (`:202`)
  offers the singleton global and every projector for pruning, **44** on the same
  program, and `prune-live` (`:227`) hands `drop-pruned` only the names `gs-refs`
  finds no surviving reference for. `x64` stands beside `x64$0` wherever a
  reference survives.
- **The domain is the pre-pass def set plus what the pass created**, computed in
  two stages, with a fifth arm `ft-created (by Str)`, and a definition leaving the
  globals list leaves through `ft-specialized` naming its successors. The ruling is
  `docs/examples/E184-def-fate-sum.md` §6 decision 1, the row is `ruled` in
  [[records/author-calls]], the runs are [[records/enforcement-arc]] EN-29 and
  EN-30, and the live requirement text is `docs/arcs/enforcement-arc.md`
  `#### The seven requirements`.

**The section's conclusion stands and the measurement strengthens it.** Three
sequential filters over three different sets cannot name what a later pass
invents, and the back half invents too: `outline`
(`lib/lowering/upper/lower.chiral:311-319`) builds `<name>$<ncase>`, which
`lib/lowering/compile-back.chiral:272` adopts whole as `(cons main extra)`, 40
extras across 1,509 lowered defs. R6 keeps one clause, that the two stages are a
pass boundary neither R1 nor R7 names, and its object is a created-name-and-origin
relation where this section wrote a rename mapping.

## 2. The classes, enumerated from the live tree

### The dead vocabulary, and why none of it survives

`skip-reason` (`lib/lowering/upper/lower.chiral:83-93`) names four exclusions in
a fixed order. Measured against what the live tree does:

| the dead exclusion | the live tree's answer |
|---|---|
| dependent type | **lowers.** `t-pi` maps to `nt-word` at `lib/lowering/compile-front.chiral:71`, so an arrow domain is pointer-sized rather than refused |
| effectful (stays upper) | **no analogue in the lowering channels.** The effect gate is `eff-eligible?` at `lib/module/sig-driver.chiral:64`, a different pass on a different tier |
| quantified binder (0/1 stay upper) | **lowers.** `ty-kept-doms` (`:160-163`) drops a `q=0` binder outright and `t-var` maps to `nt-word` at `:70`, which is [[decisions/decision-erased-word-level]]'s B1 |
| type does not lower | **fires zero times on definitions.** `docs/arcs/parts/enforcement-N14.md` M2: `term->ntalty` answered `(none)` on 0 of 22,742 globals across 63 roots |

Three of the four describe refusals the live tree converts into lowerings, and
the fourth has an empty extension. The dead partition classifies a different
language from the one the compiler now compiles.

### The classes the tree actually needs

Producers are named beside each class. Counts are `docs/arcs/parts/enforcement-N14.md`
§2 M2 through M5, taken 2026-09-09 over 63 roots and 22,742 globals.

| class | producer today | measured |
|---|---|---|
| `emitted <label>` | `lower-defs`' `le-ok` arm into `opt-tfns` | 22,395 of 22,742 |
| `specialized-into <names>` | `specialize-singletons` (`compile-front.chiral:20`) | unmeasured. The pass rewrites rather than drops, so no channel counts it |
| `erased-by-design` | `filter-erasable`'s silent arm, `compile-back.chiral:189` | 0 on `prog/compiler.prog`. M5: `1549 - 1547 = 2`, both cascade, nothing dropped silently |
| `skipped: body-does-not-lower <site>` | `compile-fn` → `le-skip` → `compile-back.chiral:271` | **182**, in three sites: `lower.chiral:283` higher-order application 162, `:251` lambda stays upper 10, `:417` body is not a lambda chain 10 |
| `skipped: extern-with-no-wrapper <op>` | `filter-erasable` → `first-nonlowering-op` | **5**: `time-mono` 2, `notify` 2, `sock-connect` 1 |
| `skipped: callee-cascade <root>` | `prune-pass` → `(sk-callee cn)` | **160**, eight callees, largest `be-chat-stream` 40 |
| `skipped: defunctionalization-refused <why>` | `st-pois-defunc`, E187 | 0 in this tree. E187 measured 0 cause clauses in the self-compile |
| `skipped: type-does-not-peel <where>` | `peel-def`'s `(none)` arms | **0** on definitions, and no record is produced when it fires |

⚑ **`specialized-into`'s cell says the pass rewrites, and the pass creates and
deletes. 2026-09-10.** §1's ⚑ carries the measurement and its citations. Two of the
numbers the cell calls unmeasured are read from the source at 13 created and 44
offered for pruning; how many survive `prune-live` is still unmeasured and F3
stands. This class list also predates R1's fifth arm, `ft-created (by Str)` for a
name with no pre-pass existence, and a new specialization enters `ft-specialized`'s
list as an instance, so the sum stays closed as passes are added.

Total refused: **347 of 22,742, 1.53%**.

### Three findings this enumeration produces

**F1. E184's R2 names the wrong three classes.** Its closed sum for `skipped` is
*extern-with-no-wrapper naming the op, type-does-not-peel naming which type and
where, callee-cascade naming the chain*. Measured: it names `type-does-not-peel`,
whose extension over definitions is empty; it omits `body-does-not-lower`, which
is 182 of the 347 and the largest class by a factor of eight over the next; and
E187 added a fourth constructor, `sk-defunc`, to `SkReason` after E184 minted.
R2's taxonomy is owed a correction before E184 is specced.

**F2. The live vocabulary files its largest class under `extern`.**
`lib/lowering/compile-back.chiral:271` records every `le-skip` as
`(mk-skrec name (sk-extern er))`. `sk-extern`'s field is `op` and
`lib/lowering/skip-diag.chiral:28` renders its tag as the string `"extern"`. So
182 term-level body-compile failures reach `format-blame` labelled as extern
refusals, sharing a constructor with `filter-erasable`'s 5 genuine ones. That is
the mechanical cause of the misreading `docs/arcs/parts/enforcement-N14.md` §3
D3 found in five documents: the compiler itself says `extern` where the cause is
a body that does not lower.

**F3. Nothing in the tree re-derives any def-level count.** A grep at
`d3ee8ad` for the peel counters `cod-none`, `dom-none`, `body-none`,
`total-skips` and `peel globals` over `lib/`, `prog/`, `tools/` and `bin/`
returns nothing. Every number in the table above rests on probes built for the
N14 design run and not committed. `tools/test/opt-census.sh` pins the
post-emission side and sees none of the peel.

## 3. Totality, and this partition IS E184's R1

**Stated plainly, because minting a second element for a job E184 already owns
is the failure the design stage exists to prevent.**

| what the partition needs | E184's requirement |
|---|---|
| a total classification, closed sum, no `_` arm | **R1** |
| classes carrying evidence rather than strings | **R2**, corrected by F1 |
| the front channel stops discarding its refusals | **R3** |
| the record survives the success arm | **R4** |
| a cascade resolves to a non-cascade root | **R5** |
| identity survives `specialize-singletons`' renaming | **R6** |
| conservation: one fate per def, folding to the emitted set, checked in the compile | **R7** |

⚑ **The R6 row names an object R6 no longer has, and the identity claim below
holds. 2026-09-10.** What R6 requires is the created-name-and-origin relation
across the two-stage domain, produced by the creating pass and carried the rest of
the way: §1's ⚑ and `docs/arcs/enforcement-arc.md` R6. R1's row absorbs the
relation, its carrier and the monomorphized-singletons failure mode, and R7's row
folds over the two-stage domain where it read the closure's def set. **The
identity itself was re-tested against the ruled domain and survives.** Every
clause of this document still lands on one of the seven requirements; what moved
is what three of them say. No second element is minted.

**The partition IS that requirement**, read against a measurement E184 did not
have when it minted on 2026-09-01. Every clause of it lands on one of the seven,
so the answer to "upstream, overlapping or identical" is identical.
**No element is minted for it.** What this document adds to E184
is the corrected class list, the identity of the set, and F1 through F3, all of
which the SPEC stage consumes.

**What totality means here, and where it stops.** The fate function is total over
the *definitions* of the compiler's closure. **Its domain stops there, and
extern *signatures* are outside it.** `prim->n` refuses 153 of 4,902, every one the leaf
`(t-primty "Pty")` (`docs/arcs/parts/enforcement-N14.md` M3), and an extern has
no body for `emitted` or `skipped` to range over. That region is E107's owed
native `pty-close` binding (`docs/elements/ledger.md:202`), deferred in the
source at `lib/ports/pty.port:30-35`. Widening E184's sum to cover declarations
would make one closed sum answer two questions. **The extern region stays E107's
and is stated here rather than absorbed.**

## 4. Where it lives

**The sum and its accessors go in `lib/lowering/skip-diag.chiral`.**

`MAP.md` fixes the rule: the directory is the identity, and a file belongs where
its own importers already are. Three facts decide it.

- The partial vocabulary is already there. `SkReason` and `SkRec` are
  `lib/lowering/skip-diag.chiral:15-16`, and the fate sum is that data
  declaration completed.
- Every producer already imports it, with no cycle:
  `lib/lowering/compile-back.chiral:21`, `lib/lowering/upper/closconv.chiral:26`
  and `lib/typing/diag.chiral:57`. `lib/lowering/compile-front.chiral` gains the
  fourth import, which is the one new edge.
- E184's R5 already places the cascade rooting there, beside E97's blame chain,
  and the catalog row states that as its reason.

⚑ **The home holds under the ruled two-stage domain and the new-edge count rises
from one to three. 2026-09-10.** `lib/lowering/skip-diag.chiral` imports
`prelude/prelude` alone, so any producer imports it with no cycle. Stage two seats
a creator in each half of the compiler, so the edges owed are
`lib/lowering/compile-front.chiral`,
`lib/lowering/upper/specialize-singleton.chiral` for `lift-lifted`, and
`lib/lowering/upper/lower.chiral` for `outline`.
`docs/examples/E184-def-fate-sum.md` §6 places every sum and accessor here and
reads this section as needing no reopening.

**The conservation check needs a seat that sees the whole closure**, which is
`lib/lowering/compile-all.chiral`. That module is where the record dies today:
its `elf-ok` arm (`:35`) discards `skips` and only the `elf-err` arm (`:42-44`) renders
them. E184's R4 is that repair.

**Nothing goes in `lib/lowering/upper/lower.chiral`.** Its header (`:1-16`)
scopes the module to the E16 partition slice differentiable against
`lower.py.lower_all`, and that oracle is CUT ([[status-ledger]]). What survives
in the module is `compile-fn` and its helpers, which is emission.

## 5. What it costs, split three ways

| part | is | cycle owed |
|---|---|---|
| this document, the N14 design's `⚑` amendment, the arc roster row, the `records/` row | **documentation** | none |
| the census that re-derives the counts, and the gate that pins them | **gate**, `prog/` and `tools/test/`, outside the compiler closure | none. This is `enforcement/N14`'s Shape D and it is what makes §2 falsifiable before E184 builds |
| the fate sum, the four producers, the conservation check, the report exit | **code**, five modules inside the compiler's blob | **full BUILD RULE**, `build-new → test → promote` with the fixpoint verified and the Step-0 precondition checked first |

E184's catalog row prices the code half at roughly 150 to 250 LOC across five
modules with three signature changes. `bin/chirality` dispatches compile / run /
check / test and has no exit for the report, so one is owed, and R7 puts the
gate on E168's test floor as a chirality program.

**The 84 dead lines are retired by E184's build, in the same change.** They are
the abandoned draft of the sum that build constructs, they have zero consumers
tree-wide (re-verified by grep at `d3ee8ad` over all fifteen names: `UT`,
`LowBind`, `Lowdef`, `LowRes`, `ttype`, `ttype-list`, `any-dep?`, `any-eff?`,
`any-quant?`, `doms-lower?`, `types-lower?`, `skip-reason`, `eligible?`,
`lower-def`, `lower-all`), and both the standing instructions to keep them are
spent: `docs/elements/catalog.md:449`'s mirror instruction points at a function
E184 replaces, and [[decisions/decision-preserve-check]] was amended 2026-09-09
so its tier line no longer runs through `ttype`'s `Maybe`. Retiring them on
their own would spend a BUILD RULE cycle to change no emitted byte. Retiring
them inside E184's cycle costs nothing extra and leaves one partition in the
tree instead of two.

## 6. What this does not settle

- **Which discharge T0 takes.** [[records/findings]] FD-17's five mechanisms are
  `enforcement/N15`'s and the author's, unchanged.
- **The count of `specialized-into`.** No channel measures the renaming pass
  today, and E184's R6 is the fork that decides how it is carried.

  ⚑ **The pass creates and deletes, and the fork R6 named is ruled. 2026-09-10.**
  §1's ⚑ carries both. The created and offered counts are read at 13 and 44; the
  surviving count is what no channel measures, which is F3. What stays unsettled
  is the two arm-count sub-questions in `docs/examples/E184-def-fate-sum.md`
  §6 decision 1, and they are the author's.
- **The three stale citations naming `ttype` as live.** `docs/definitions/status-ledger.md`'s
  "Lowering: pure fragment → tal" row, `lib/lowering/lowspec.chiral:27` and
  `lib/lowering/compile-front.chiral:324` all name `ttype` where the live
  function is `term->ntalty`. The first is a `doc-audit` subject; the two
  comments are inside the blob and move with E184's cycle.
- **Whether `sk-extern` splits.** F2 measures the mislabelling. Whether the
  repair is a new constructor or a corrected construction site is E184's SPEC
  stage, since both land in the same closed sum.
