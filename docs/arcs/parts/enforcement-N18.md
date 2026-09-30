---
row: enforcement/N18
arc: enforcement
title: the bounds relation has no carrier, and the vocabulary already refuses the half that has one
kind: primitive
origin: pair
req: 1
status: blocked
updated: 2026-09-18
---

# enforcement/N18: the bounds relation has no carrier, and the vocabulary already refuses the half that has one

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** a program that indexes a byte or string buffer outside that
  buffer is refused by a rule, or a ledger row states why it is not.
- **Serves:** requirement 1 of [[arcs/enforcement-arc]], *"A capability sits at
  ENFORCED, or its ledger row says why it does not"*
  (`docs/arcs/enforcement-arc.md:42`). The `req` cell reads `1` at `:509`;
  `records/bounds-residue.md` `BR-06`'s sibling row `BR-05` is `FIXED` and
  records the move off `1, 3`, because requirement 3 is the tal checker against
  the compiler's emitted TFns and this row writes nothing there.
- **Goal:** [[goals/enforcement]], condition 1. The goal's State section fixes
  the bar this row is measured against: *"A bug class comes off the list when it
  can be stated as a judgment and a gate fails when the judgment stops holding.
  Anything short of that is a bug the language happens to catch today"*
  (`docs/goals/enforcement.md:93-95`).
- **The pair**, per [[decisions/decision-primitive-with-consumer]] and
  `docs/arcs/README.md:74`. The primitive is a carrier that relates an index to
  the buffer it indexes, plus whatever judgment refuses the relation when it
  fails. The consumer is the call population through `nb-bslice` under both its
  surface names, plus `bget`'s. Both halves are measured in §2.

## 2. What the tree holds

Measured 2026-09-10 at HEAD. Nothing under `lib/`, `prog/` or `tools/` was
changed and no build was run.

### The banks, first

- **[[banks/text]] shard A** is the byte/string floor: `str-len`, `str-sub`,
  `str-find`, `str-find-from`, `str-cat`, `blen`, `bget`, `bslice`, `bcat`, in
  `lib/prelude/prelude.chiral` as externs, state **built**, with its own limit
  line reading *"`str-sub` is unclamped, E176 / BA-35"* (`docs/banks/text.md:47`).
  The bank's honest-residue section says the same thing a second time at
  `:138-139` and routes it to `E176` in both places. **Neither place names an
  indexed carrier**, so no phantom is available to borrow here.
- **[[banks/memory]] shard 3** is `mem-put-checked`, `CONFORMS as scoped`
  (`docs/banks/memory.md:118-131`). The bank's §5 residue 3 names the blocker
  this row runs into, before this row reaches it. Residue 3 is E9's
  variable-bound refinement at SEEDED, *"the enabling sub-capability"*, and
  *"`v<n` over inter-variable arithmetic is const/bare-var only today"*
  (`:362-366`).

### The census

| what exists | where | rung | reached by |
|---|---|---|---|
| E9's refinement decision procedure | `lib/typing/refine.chiral`, 168 lines | IMPLEMENTED, inside the compiler blob (`docs/elements/catalog.md:100`) | `lib/typing/kernel.chiral:18` |
| the bound already carried for another carrier | `lib/memory/mem-linear.chiral:26-28`, `(-> (0 n I64) (=> (1 p (Pool n)) (refine I64 (>= 0) (< n)) Bytes (Pool n)))` | CONFORMS as scoped | `(Pool n)` callers |
| an index on a data type, not just on a porttype | `lib/memory/mem-region.chiral:23`, `(data Region ((n I64))` | built | `mem-alloc`, `region-close` |
| the admissible operand of a refinement atom | `lib/typing/kernel.chiral:1390-1394`, `operand-ok?` | ENFORCED. Two value forms only: `(v-lit-i k)`, and `(v-ne h sp)` where the spine is `nil` and the head is `(n-var lvl)` | `check-ratoms`, `:1408-1420` |
| the refusal when the operand is any other form | `lib/typing/kernel.chiral:1419`, `(jg-refine-opnd-form)` | ENFORCED | the same |
| the refusal when the bound is not entailed | `lib/typing/kernel.chiral:1439-1440`, `(jg-refine-unproved)` | ENFORCED | `refine-entails?` |
| path-sensitive narrowing | `docs/definitions/status-ledger.md:188`, `narrow-branch` / `narrow-side` / `ctx-narrow` in `lib/typing/kernel.chiral` | built | a comparison-guarded branch |
| `Str` as a carrier | `lib/surface/syntax.chiral:29`, `(t-primty (n Str))` | built, and carries no index | every string in the tree |
| the refinement atom's own shape | `lib/surface/syntax.chiral:15`, `(data RfAtom () (r-atom (op SymOp) (operand Term)))`, and `:34` `t-refine` | built. The operand field is a `Term`, so the grammar admits what `operand-ok?` then refuses | `check-ratoms` |
| the judgment vocabulary | `lib/typing/diag.chiral:99-111`, `(data Judg ())` | built, closed, exhaustively rendered by `dg-judg-msg` at `:429` | `r-judged`, `:336` |
| one routine, two surface names | `lib/lowering/tal/erase.chiral:115`, `str-sub` and `bslice` both to `nb-bslice` | built | the whole call population |
| the routine | `lib/lowering/tal/bytes.chiral:147-160`, `nb-bslice-t`, a hand-written `TIFn` | built, emission, inside the blob | `compile-emit` |
| the second entry in the class | `lib/prelude/prelude.chiral:97`, `(extern bget (-> Bytes I64 I64))` | built, unchecked in both directions | `lib/prelude/prelude.chiral:117`, `:131`, and the rest |
| the corpse doctrine, already stated | `lib/lowering/tal/sys.chiral:1006-1009` | built and live | `nb-arena-fail-t` `:120-123`, called from `nb-arena-commit-t` `:133` at `:140` and `:152` |
| the routine's repair | `E176`, ledger state `design` (`docs/elements/ledger.md:312`), designed by `docs/arcs/parts/diagnostics-L5.md` | design | nothing yet |

### The vocabulary, counted

`Judg` holds **36** constructors, `lib/typing/diag.chiral:99-111`. The roster
row's `what` cell says 38 and `records/enforcement-arc.md` EN-31 cites the span
as `:97-110`; both predate the shrink that `records/author-calls.md:356-360`
tabulates, which took `Judg` arms and `dg-judg-msg` render arms from 38 to 36.
[[goals/enforcement]] `:97-100` already carries the corrected figure, *"36 named
judgments in `lib/typing/diag.chiral`, measured 2026-09-03"*.

**Five of the 36 are refinement arms**: `jg-refine-i64`, `jg-refine-base`,
`jg-refine-opnd-i64`, `jg-refine-opnd-form`, `jg-refine-unproved`.
`docs/definitions/bug-classes.md:117` counts the same five.

### What the class document says, in two rows that disagree in the useful way

- `docs/definitions/bug-classes.md:75`: *"out-of-range values | refinement
  types, **`I64` only** | refuses"*.
- `docs/definitions/bug-classes.md:46`: *"buffer overread and overwrite | bounds
  on indexing | none. `str-sub` reads past its buffer today"*, with a blank
  element cell.
- `docs/definitions/bug-classes.md:123-125`: *"No constructor exists for
  effects, termination, bounds, overflow, or ABI agreement. A rule cannot refuse
  what the vocabulary cannot say, so each of those needs a `Judg` arm before it
  needs a caller."*

The tree refuses an out-of-range **value** today and refuses nothing about an
out-of-range **index into a buffer**. The difference between those two rows is
the relation, and §3 is that difference.

### Why the floor cannot reach the refinement discipline, one level below the probe

`docs/arcs/parts/diagnostics-L5.md` §2 measured four probes against the
committed binary. Probe 1, `(=> (s Str) I64 (refine I64 (<= (str-len s))) Str)`,
is `load: unknown name s`. Probe 2, `(-> (0 n I64) (=> Str I64 (refine I64 (<= n)) Str))`,
loads. Probe 3, that signature applied as `(sub-safe 3 "abc" 0 99)`, is
`load: cannot prove refinement`. Probe 4, the same applied as
`(sub-safe 3 "abc" 0 2)`, passes.

**Measured here, and not by that run: the scope failure is not the binding
constraint.** `operand-ok?` (`lib/typing/kernel.chiral:1390-1394`) accepts an
`I64` literal and a neutral whose spine is empty and whose head is a variable.
`(str-len s)` evaluates to a neutral with a non-empty spine whatever `s` is
bound to, so it is refused by `jg-refine-opnd-form` at `:1419` on its form,
independently of scope. Two consequences follow and both are structural:

1. **Widening the `=>` binder's scope would not make probe 1 load.** It would
   move the refusal from the loader's name resolution to `check-ratoms`.
2. **Path-sensitive narrowing cannot carry the bound either.** A guard
   `(<=i end (str-len s))` narrows `end` against an atom whose operand is the
   same refused form, so the mechanism `status-ledger:188` records as built has
   nothing to record here.

`lib/typing/refine.chiral:7` names where this edge is owned: *"Non-goal: the
full-predicate REFACTOR (solver, inter-variable arith) -> E41."* `E41` is minted
(`docs/elements/catalog.md:168`) at ledger state `design`
(`docs/elements/ledger.md:167`).

⚑ **2026-09-11: that arrow lands short of this row on both halves, and the owner
is `enforcement/N22`.** Trigger: `records/lenses/problems.md` `PRB-82`, settled
2026-09-10 against `docs/elements/specs/E41-region-types-SPEC.md`,
`status: audited` since 2026-08-02. That SPEC's §1 (`:29-42`) scopes E41's
refinement half to a **linear** arith-expression bound, *"a sum of atoms"*
against an atom, `(<= (+ o s) cap)`, and its non-goals list *"the
**general/nonlinear** refinement solver"*. §3 decision 2 (`:75`) reads
*"RESOLVED: E41 owns it"* for that sum alone and names E22's refined cursor and
E25's byte-cell faces as the consumers it owns it for. `(str-len s)` is a
saturated application and not a sum of atoms, and the `=>` binder scope carries
no arithmetic at all, so **both halves of §4 Shape 3 fall outside `E41` on
`E41`'s own words.** `enforcement/N22` is the row that holds them, opened in
`docs/arcs/enforcement-arc.md` on 2026-09-10 at `origin` `pair`, `req` 1, state
`open`, and `PRB-79` and `PRB-82` both read `owner: enforcement/N22`. What
`lib/typing/refine.chiral:7` should read: the linear sum to `E41`, the
application operand and the `=>` binder scope to `enforcement/N22`. That comment
is compiler source inside the blob and is left standing under
[[working-discipline]]'s build rule. E41's SPEC additionally carries a
2026-09-04 NEEDS-REPLAN triage over its Step 1 home
(`records/spec-tier-triage.md`), which moves where the linear sum gets built and
moves no ownership.

⚑ **Shape 3's substance survives this and was re-tested at HEAD `bffa265`.**
`operand-ok?` (`lib/typing/kernel.chiral:1390-1394`) still admits `(v-lit-i k)`
and a spine-`nil` `(v-ne (n-var lvl) …)` and nothing else. `Constraint`'s `sym`
field is still `(List (Pair SymOp I64))` under the comment *"symbolic bounds
keyed by operand level"* (`lib/typing/refine.chiral:13-18`), so entailment over
an application still needs a term-keyed fact. Neither file is emission, so the
price stays `C1 == C2`. E41's sum-of-atoms bound ranges over those same level
keys and delivers no term key, so building it would not discharge Shape 3's cost
either. Only the ownership sentences are refuted.

### The consumer half, measured

`records/bounds-residue.md` `BR-06` measured **134** `str-sub` calls and **108**
`bslice` calls, **242** through `nb-bslice`, by a paren-balanced tokeniser over
303 files under `lib/` and `prog/`, counting only forms whose head token is one
of the two, with comments and string literals stripped. Re-verified here at
HEAD: the crude head-token grep returns **137** and **111** over **303** files,
and `BR-06` names the six comment lines that account for the difference exactly.
The stale `131` in three cells and the design-stage `250` are both recorded by
`BR-06` as not reproducing, and both are routed to `E176`'s SPEC stage.

`bget`'s population is not counted anywhere and is not counted here.
`enforcement/N20` is the row that buys the size of the class.

### What no artifact holds

`docs/arcs/parts/diagnostics-L5.md` §5 question 4 defers the length-indexed
`Str` to `text-tools/L6`. **That row does not exist.** `records/bounds-residue.md`
`BR-03` measured it: `docs/arcs/text-tools-arc.md:184-187` holds `P1` through
`P4` and no `L6`, and a revisit of that arc on 2026-09-10 returned HOLDS,
leaving `P5` free and putting the whole defect on the citing side. This design
cites no such row and coins no id.

## 3. The delta

§2 subtracted, what is missing:

1. **The relation, and nothing else in the chain.** The decision procedure is
   built and in the blob. The bound is already carried for one carrier. An index
   on a data type is already built. The judgment that fires when a bound is not
   entailed is already built and already fired in a probe. What is absent is any
   term that relates an index to the length of the buffer it indexes, in a
   position the checker reads.
2. **One function decides it.** `operand-ok?`
   (`lib/typing/kernel.chiral:1390-1394`) admits an `I64` literal and a bare
   variable. Every route to the relation, whether by indexed carrier, by erased
   index, or by a guard the narrower learns from, terminates at that function.
3. **No carrier can hold an index soundly over the producer set the tree uses.**
   `(Pool n)` works because `pool-create` is the only producer and it takes `n`.
   A `Str` is produced by every literal, by `str->bytes`, by `str-cat`, and by
   `nb-bslice` itself. §4 measures what that costs each shape.
4. **The vocabulary is not the gap, and the row's second disjunct is answered
   by measurement.** `jg-refine-unproved` refuses a bound that is written down
   and not entailed. A `Judg` arm naming a buffer relation has nothing to be
   issued by until item 1 lands, and `docs/definitions/bug-classes.md:46` stays
   at `none` either way.
5. **Requirement 1's second branch is unwritten for this class.** No ledger row
   states why bounds on indexing is not at ENFORCED. The requirement records
   that filling that half is mechanical and needs no author call
   (`docs/arcs/enforcement-arc.md:42-48`).

**Verdict: a real delta, and its mechanism is owned by elements and rows that
already exist.** The relation is `E41`'s declared subject by
`lib/typing/refine.chiral:7`. The floor's side is `enforcement/N19`. The
routine's repair is `E176`. What is left unowned is the statement in item 5 and
the question of whether anything else is owed at all, which §5 carries to the
author.

⚑ **2026-09-11: the relation is `enforcement/N22`'s subject and not `E41`'s.**
`docs/elements/specs/E41-region-types-SPEC.md` §1 and §3 decision 2 put the
application operand and the `=>` binder scope outside `E41`, and `PRB-82` opened
`enforcement/N22` on them. §2's ⚑ carries the measurement. The verdict's own
shape is unchanged and gets stronger: the mechanism is owned by a row that
exists, which is what this paragraph claimed and could not yet cite.

## 4. The shapes

The tree does not settle this. Six forms, and the carrier half and the
vocabulary half are listed together because every vocabulary shape depends on a
carrier shape landing first.

### Shape 1: a length-indexed `Str` as a new carrier

- **Form:** `(data SizedStr ((n I64)) (sized (s Str)))`, by exact analogy with
  `(data Region ((n I64))` at `lib/memory/mem-region.chiral:23`, then
  `(-> (0 n I64) (=> (SizedStr n) I64 (refine I64 (<= n)) Str))` by exact
  analogy with `mem-put-checked`.
- **Constructible:** the declaration is, today. The **sound** version is not.
  `sized` accepts any `n` for any `s`, so the index is an assertion the
  constructor site makes and nothing checks. Three things would close that and
  none is in the tree: an existential or dependent pair to package a
  runtime-computed length (measured: no `t-sigma`, no `exists` form in
  `lib/surface/syntax.chiral` or `lib/typing/kernel.chiral`); a
  constructor-private module boundary so a smart constructor is the only door;
  or a producer whose result type mentions its argument's length, which is
  §2's refused operand form.
- **Where it is sound:** over a producer that already carries `n`, which is a
  `(Pool n)` read. That producer set reaches approximately none of the 242
  sites, because the tree's strings come from literals, `str-cat` and
  `str->bytes`.
- **Costs:** `lib/surface/syntax.chiral` is untouched, since indexed data
  declarations already parse. The 242 sites thread an index by hand. A second
  spelling of every string operation.
- **Forbids:** nothing, until the index is tied to the string. It converts a
  memory-safety hole into a constructor-site convention.
- **Status: unconstructible today as an enforcement.** Recorded as a shape
  rather than dropped, on the precedent of
  `docs/arcs/parts/diagnostics-L5.md` §2, which recorded the refined signature
  the same way.

### Shape 2: an erased index parameter on the operations, not on the type

- **Form:** `(-> (0 n I64) (=> Str I64 (refine I64 (<= n)) Str))`, the
  signature `docs/arcs/parts/diagnostics-L5.md` §2 probe 2 measured as loading,
  probe 3 measured as refusing a bad call, and probe 4 measured as passing a
  good one.
- **Costs:** the index is threaded by hand at every call site and nothing ties
  `n` to the string. A caller who passes a wrong `n` gets a refusal about the
  wrong number, or no refusal at all. `lib/prelude/prelude.chiral` is compiler
  source, so the signature change pays a generation cycle.
- **Forbids:** the bad call, when the caller tells the truth about `n`. It
  forbids nothing when the caller does not.
- **The objection is already written in this tree.**
  `docs/arcs/parts/diagnostics-L5.md` §4 Shape D refuses a checked wrapper
  because *"it converts a memory-safety hole into a convention, which is the
  form [[design-principles]] and this row's own premise reject: the defect is
  that a safety property was asserted in prose rather than enforced."* Shape 2
  is that shape with a type on it. The assertion moves from a comment to an
  argument position, and nothing checks it either way.

### Shape 3: widen the refinement atom's admissible operand

- **Form:** `operand-ok?` admits a saturated application of a total,
  `I64`-returning primitive over in-scope variables, and `=>` value binders are
  visible to the atoms of the seats that follow them. `(refine I64 (<= (str-len s)))`
  then means what it reads as, with no new carrier and no new judgment.
- **Costs:** `Constraint`'s symbolic facts are keyed by operand **level**
  (`lib/typing/refine.chiral:14-19`, `(sym (List (Pair SymOp I64)))`), so
  entailment over an application needs a term-keyed fact and a decision about
  when two applications are the same fact. `lib/typing/kernel.chiral` and
  `lib/typing/refine.chiral` are both inside the compiler blob, so the change is
  compiler source. It is not emission, so the first agreement is `C1 == C2`.
- **Forbids:** nothing on its own. It is the enabling change, and it is what
  every other shape terminates at.
- **Owner:** `lib/typing/refine.chiral:7` routes the full-predicate refactor to
  **`E41`**, which is minted at ledger state `design`. `docs/banks/memory.md`
  §5 residue 3 names the same lever as shared by two memory residues. The
  narrower question of whether an application, as distinct from
  inter-variable arithmetic, is inside `E41`'s scope is named by no artifact in
  the tree; a roster row is owed for it and this run does not open one, and does
  not coin an id for it, on `BR-03`'s evidence.

  ⚑ **2026-09-11: the Owner reads `enforcement/N22`, and the narrower question
  was named from `E41`'s side.** `docs/elements/specs/E41-region-types-SPEC.md`
  is the artifact this bullet said did not exist: its §1 (`:29-42`) scopes
  `E41`'s arithmetic to the linear sum `(<= (+ o s) cap)` and puts the
  general solver in its non-goals, which leaves a saturated application outside
  it, and the binder scope carries no arithmetic to be inside it either.
  `enforcement/N22` was opened on that measurement on 2026-09-10 and carries
  both halves of this shape's Form. §2's ⚑ carries the citation. This shape's
  Form, Costs and Forbids are unchanged.

### Shape 4: a `Judg` arm for bounds, with the check elsewhere

- **Form:** one constructor in `(data Judg ())` at `lib/typing/diag.chiral:99`
  and one arm in `dg-judg-msg` at `:431`. The rule that issues it lives
  wherever a bound can be decided.
- **Costs:** two lines in a module inside the blob, so one generation cycle at
  `C1 == C2`. `lib/typing/diag.chiral:97-98` says the sum is *"Closed and
  exhaustively cased below, so a new judgment breaks the renderer loudly"*, so
  the compiler finds the arms that need writing.
- **Forbids:** nothing. A vocabulary arm with no rule to issue it is SEEDED by
  `docs/definitions/status-ledger.md:134-135`, which is the state
  [[goals/enforcement]] exists to close. Under
  [[decisions/decision-primitive-with-consumer]] and
  `docs/arcs/README.md:100-104`, a primitive with no consumer is half a row, and
  this shape has no consumer until Shape 1 or Shape 3 lands.
- **The tree argues both ways on it.** `docs/definitions/bug-classes.md:123-125`
  says the arm comes before the caller. `records/author-calls.md:356-360`
  records the tree deliberately shrinking `Judg` from 38 arms to 36.

### Shape 5: the corpse route, the floor states the bound and dies

- **Form:** `nb-bslice` and the `bget` lowering take the shape
  `nb-arena-commit-t` already takes: on an out-of-range index, call
  `nb-arena-fail`, which is a live `(ti-sys 1 231 …)` that never returns
  (`lib/lowering/tal/sys.chiral:120-123`, called at `:140` and `:152`).
- **The doctrine is already written**, `lib/lowering/tal/sys.chiral:1006-1009`:
  *"A real bounds violation is a corpse: on size<=0 or off/len out of range the
  body takes the arena-fail shape (exit_group(-EINVAL), never returns) … so a
  fatal exit is control flow, not a value sentinel."*
- **Costs:** `lib/lowering/tal/bytes.chiral` is emission inside the blob, so the
  first agreement is `C2 == C3`, and `:134-144` makes gen3 mandatory evidence
  for any edit to that routine.
- **Forbids:** the over-read, at runtime. It forbids nothing at check time and
  issues no judgment, so `docs/definitions/bug-classes.md:46` moves from `none`
  to a runtime kill rather than to a rule.
- **Not this row's.** This is `docs/arcs/parts/diagnostics-L5.md` §4 Shape E,
  inside `E176`, and which of clamp or trap lands there is
  `records/author-calls.md:364` and that design's question 9.

### Shape 6: requirement 1's second branch, the stated reason

- **Form:** the ledger row for the bounds capability states why it is not at
  ENFORCED, naming `operand-ok?` as the mechanical blocker and `E41` as the
  element that owns it. `docs/arcs/enforcement-arc.md:42-48` fixes the shape:
  *"a `design` row states what an element would do rather than why the
  capability is not at ENFORCED … E70's row is the shape to copy."*
- **Costs:** nothing built, no generation cycle. The requirement records this
  half as mechanical and needing no author call.
- **Forbids:** nothing, and it claims nothing. It is the branch requirement 1
  holds open for exactly this case, a capability whose enabling element is
  minted and unbuilt.

  ⚑ **2026-09-11: the ledger row names `enforcement/N22` and not `E41`.**
  `docs/elements/specs/E41-region-types-SPEC.md` puts the operand widening
  outside `E41`, §2's ⚑ carries it, and `PRB-82` opened `enforcement/N22` to
  hold it. The Form is otherwise unchanged: the row still names `operand-ok?`
  as the mechanical blocker. The Forbids sentence's last clause now reads that
  the enabling work is a roster row rather than a minted element, which is what
  [[working-discipline]]'s deferral rule prescribes for unminted work and is a
  stronger statement than the one it replaces.

### How the shapes depend on the open calls

| shape | under author call 2 going to enforcement | under call 2 going elsewhere | under call 3, clamp discharges the class | under call 3, clamp does not discharge |
|---|---|---|---|---|
| 1 | unconstructible either way | unconstructible either way | unaffected | unaffected |
| 2 | refused on `design-principles` | refused on the same ground | refused | still refused; it is a convention under both answers |
| 3 | `E41`'s, plus one owed roster row | the owed row moves arc with the class | `E41` stays the owner | `E41` stays the owner, and the owed row becomes the critical path |
| 4 | half a row until 1 or 3 lands | half a row, in whichever arc | never needed here | needed, and still blocked behind 3 |
| 5 | `E176`'s, not this row's | `E176`'s | this is the discharge | this is not a discharge |
| 6 | this row writes it | the row moves whole and writes it there | the row closes after `E176` builds | the row stays open behind 3 |

⚑ **2026-09-11: row 3 reads `enforcement/N22` in all four columns, and the owed
row is opened.** `docs/elements/specs/E41-region-types-SPEC.md` puts both halves
of Shape 3 outside `E41`, §2's ⚑ carries it, and `enforcement/N22` was opened on
2026-09-10. So the cells read `enforcement/N22`'s, with no second row owed
beside it. Whether `N22` itself moves arc under author call 2 in this table,
`records/author-calls.md:85`, is that call's and this run does not take it. The
other five rows are untouched by this trigger.

⚑ **2026-09-18: author call 2 is ruled BOTH, so this table's second column is
history.** Column 1 is the live one, and no shape moves arc. The citation above
read `:363` until this pass. Call 3's two columns are untouched and still open.

## 5. The call

- **Chosen: Shape 6, with Shape 3 as the mechanism and its ownership deferred.**

  ⚑ **2026-09-11: the deferral has an owner and the call now reads "Shape 6,
  with Shape 3 as the mechanism, owned by `enforcement/N22`."** When this line
  was written the widening was routed to `E41` by a comment and no artifact
  named it from `E41`'s side. `docs/elements/specs/E41-region-types-SPEC.md`,
  `status: audited`, is that artifact, and it excludes both halves of Shape 3;
  `PRB-82` opened `enforcement/N22` on 2026-09-10 to hold them. §2's ⚑ carries
  the measurement. **The choice itself is unchanged.** Shape 6 is still what is
  buildable at this row today, for the reason stated below, and `N22` being
  `open` and `unminted` is exactly the state that keeps Shape 3 out of reach
  here.

  The reason is a measurement. Every route to the bounds relation terminates at
  `operand-ok?` (`lib/typing/kernel.chiral:1390-1394`), which admits two value
  forms. Shape 1 is sound only over a producer set the tree does not use for
  strings. Shape 2 is a convention with a type on it, refused on the ground
  `docs/arcs/parts/diagnostics-L5.md` §4 Shape D already states. Shape 4 is half
  a row under [[decisions/decision-primitive-with-consumer]] until a carrier
  exists. Shape 5 belongs to `E176`. What remains buildable today at this row is
  the statement, and requirement 1 holds a branch open for exactly that.

- **The row's second disjunct is answered by measurement, not by a decision.**
  The row asks whether *"the judgment vocabulary gains a way to say a bound at
  all."* It has one: `jg-refine-unproved` fired in
  `docs/arcs/parts/diagnostics-L5.md` §2 probe 3 against an erased index. What
  it lacks is a bound that names a buffer, and that is a carrier gap rather than
  a vocabulary gap. `docs/definitions/bug-classes.md` states both halves in two
  rows, `:75` reading `refuses` and `:46` reading `none`.

- **What the build rule costs, per shape, stated and not run.**
  `lib/prelude/prelude.chiral`, `lib/surface/syntax.chiral`, `lib/typing/kernel.chiral`,
  `lib/typing/refine.chiral` and `lib/typing/diag.chiral` are all compiler
  source. Shapes 2, 3 and 4 change no emission, so the first agreement is
  `C1 == C2` (`docs/definitions/working-discipline.md:36-41`). Shape 5 is
  emission: `nb-bslice-t` is a hand-written `TIFn` at
  `lib/lowering/tal/bytes.chiral:147-160`, reached from `prog/compiler.prog`, so
  the first agreement is `C2 == C3` and `:134-144` makes gen3 mandatory
  evidence. Shape 6 changes no source. **No build was run by this design.**

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Can a refinement atom name the length of a buffer | **RESOLVED, and the answer is no** | `operand-ok?` (`lib/typing/kernel.chiral:1390-1394`) admits `(v-lit-i k)` and a spine-empty variable neutral. `(str-len s)` is refused by `jg-refine-opnd-form` at `:1419` on its form, independently of the scope failure `docs/arcs/parts/diagnostics-L5.md` §2 probe 1 measured |
| 2 | Is the length-indexed `Str` constructible | **RESOLVED, as constructible and unsound** | Indexed data declarations parse (`lib/memory/mem-region.chiral:23`). No existential and no constructor privacy exist to tie the index to the string, so the index is a constructor-site assertion. Sound only over a `(Pool n)` producer, which reaches approximately none of the 242 sites |
| 3 | Does the judgment vocabulary need a new arm for this | **RESOLVED, and the answer is not yet** | Five refinement arms exist (`lib/typing/diag.chiral:99-111`, counted 36 total) and `jg-refine-unproved` already refuses an unentailed bound. An arm with no issuing rule is half a row under [[decisions/decision-primitive-with-consumer]] and `docs/arcs/README.md:100-104`, and SEEDED under `docs/definitions/status-ledger.md:134-135` |
| 4 | Who owns widening the refinement fragment | **DEFERRED to `E41`**, which is minted | `lib/typing/refine.chiral:7`: *"Non-goal: the full-predicate REFACTOR (solver, inter-variable arith) -> E41."* `docs/elements/catalog.md:168`, `docs/elements/ledger.md:167` at state `design`. [[banks/memory]] §5 residue 3 names the same lever |
| 5 | Whether a saturated application, as against inter-variable arithmetic, is inside `E41`'s scope | **ROSTER ROW OWED, and this run does not open one** | Named by no artifact in the tree. `docs/definitions/status-ledger.md:188` records the fragment's edge as *"only arithmetic-expression bounds (`v<n+1`) remain out"*, which does not reach an application. Per [[working-discipline]]'s deferral rule this names a row rather than an `E#`, and it does not coin an id: `records/bounds-residue.md` `BR-03` measured what coining `text-tools/L6` cost |
| 6 | The stale `38` in this row's `what` cell and in `records/enforcement-arc.md` EN-31 | **REPORTED, not edited** | `Judg` holds 36 (`lib/typing/diag.chiral:99-111`). `records/author-calls.md:356-360` tabulates the 38-to-36 shrink and [[goals/enforcement]] `:97-100` already reads 36. A design run may not write the arc file or an append-only record |
| 7 | The stale `250` in this row's `what` cell | **REPORTED, not edited**, and routed | `records/bounds-residue.md` `BR-06` measured 134 + 108 = **242** with the method stated, re-verified here, and routes the count to `E176`'s SPEC stage together with two other stale statements in the same cells |
| 8 | **Which arc owns the bounds class** | **RULED 2026-09-18 by the author: BOTH**, enforcement and diagnostics each own it | `records/author-calls.md:85`, `ruled`. The author's words: *"probably can give to enforcement and diagnostics its really part of both realistically"*. **This artifact does not move and keeps its id**, so the §4 table's first column is the one that applies. ⚑ The division underneath, diagnostics owning the ROUTINE and enforcement the JUDGMENT AND THE GATE, is the register row's derivation from the call's two candidate readings and not the author's words, so a later pass tests it rather than inherits it. ⚑ The region half is untouched: `E22` and `E41` stay unseated and `substrate-floor/SU15` and `SU16` stay `open`. This cell read `records/author-calls.md:363` until 2026-09-18, which is a different section and was wrong before the ruling too |
| 9 | **Is a clamp an enforcement outcome, or does it discharge the class by hiding it** | **NEEDS-AUTHOR** | `records/author-calls.md:364`, `unreviewed`, and the same fork as `docs/arcs/parts/diagnostics-L5.md` §5 question 9, clamp against trap. It governs `E176`'s repair shape, which is a different row. It governs this row only in one place: whether anything beyond Shape 6 is owed here after `E176` builds. §6 states the packet under both answers |

⚑ **2026-09-11: questions 4 and 5 are re-dispositioned, and the other seven are
untouched by this trigger.** **Question 4**, *who owns widening the refinement
fragment*, splits: `E41` owns the linear sum `(<= (+ o s) cap)` by its own SPEC's
§3 decision 2, and the widening this design needs, a saturated application
admitted as an operand plus the `=>` binder scope, is `enforcement/N22`'s.
**Question 5** now reads **RESOLVED, and the row is `enforcement/N22`**: it was
named by an artifact after all, `docs/elements/specs/E41-region-types-SPEC.md`
§1's non-goals read from `E41`'s side, and the row was opened on that
measurement on 2026-09-10. The reason this design declined to coin an id stands
and was the right call: `BR-03` measured what coining `text-tools/L6` cost, and
the id that landed came from the arc that owns it. §2's ⚑ carries the citations.

### The two calls, carried verbatim

⚑ **The first of the two was RULED on 2026-09-18. The second is still
NEEDS-AUTHOR.** Both are kept as they were put, because an answer is read
against the question it answered.

From `records/author-calls.md:85`, now `ruled`. Until 2026-09-18 this citation
read `:363`, which is a different section:

> **Which arc owns the bounds class** · Opened 2026-09-10 by the same revisit. |
> Enforcement: the missing artifacts are a judgment and a gate, requirements 1
> and 6's subjects. Diagnostics: `E176` and `diagnostics/L5` already own the
> routine, and splitting one defect across two arcs is the collision `arc-open`
> exists to catch. Text-tools: [[banks/text]] shard A owns the slice territory
> and `text-tools/L6`, the length-indexed `Str`, is already owed there.
> [[decisions/decision-primitive-with-consumer]] explicitly does not rule on a
> pair whose halves sit in different arcs. `enforcement/N18` is written on the
> judgment-and-gate reading; if the call goes the other way the row moves whole
> and keeps its id

⚑ **RULED 2026-09-18: BOTH.** *"probably can give to enforcement and diagnostics
its really part of both realistically"*. The call's own first two branches are
seated together, and the third, text-tools, was measured false before the call
reached the author: there is no `text-tools/L6` and no length-indexed `Str`, and
`docs/arcs/text-tools-arc.md` rosters `P1` through `P4`. `N18` does not move and
keeps its id. ⚑ **The ruling takes the bounds class only.** The region half,
`E22` and `E41`, is unseated, and `substrate-floor/SU15` and `SU16` stay `open`
on the narrowed condition.

**One fact bears on that row and is recorded without answering it.** Its
text-tools branch rests on `text-tools/L6`, and `records/bounds-residue.md`
`BR-03` measured that row as existing nowhere, with a revisit of
`docs/arcs/text-tools-arc.md` on 2026-09-10 returning HOLDS and leaving `P5`
free. The branch survives as a question about which arc should own the class.
It does not survive as a claim that the work is already rowed there.

From `records/author-calls.md:364`:

> **Is a clamp an enforcement outcome, or does it discharge the class by hiding
> it** · Opened 2026-09-10 by the same revisit, and it is the sharpest of the
> five. | `docs/arcs/parts/diagnostics-L5.md` §4 Shape A's own Forbids reads "an
> out-of-range call can no longer be detected. Silent truncation replaces silent
> over-read." For the clamp: it closes the memory-safety hole, and §2 measured
> the refinement route unconstructible over a `Str` with no index, so demanding a
> judgment blocks the repair behind a language element nobody has scheduled.
> Against: a clamp is a total runtime function that answers rather than a rule
> that refuses, so the capability lands at IMPLEMENTED and never at ENFORCED, and
> `bug-classes.md`'s row moves from `none` to something the language still cannot
> say. The goal's State section calls that "a bug the language happens to catch
> today." The call decides what state that row may read after `E176` builds, and
> `E176` is the next thing to build

`status: blocked` until both are said. This design answers neither.

## 6. The mint packet

- **Elements: none today.** This design mints nothing. `docs/decisions/decision-lane-split.md:327`
  records that the enforcement and diagnostics band `E184-E189` is spent and
  that two focuses cannot mint from it concurrently, and
  `records/enforcement-arc.md` EN-31 records that an `E#` here would be the
  phantom dependency [[working-discipline]] `:78` forbids.
- **Band: `UNASSIGNED`.** A band is advisory since author call B, ruled
  2026-09-06 (`records/author-calls.md:60`, and
  `docs/decisions/decision-lane-split.md:38`, *"Bands may overlap, and they are
  advisory"*), so an arc without a free number mints the next free number
  tree-wide at mint time. The number is assigned then, per
  [[decisions/decision-work-ids]].

### What this row delivers now, and it is not an element

Shape 6 is a ledger row. `docs/arcs/enforcement-arc.md:42-48` records that
filling requirement 1's second branch is mechanical, row by row, and needs no
author call, and names `E70`'s row as the shape to copy. The row to write is
`E176`'s, `docs/elements/ledger.md:312`, and it states why bounds on indexing is
not at ENFORCED: the relation between an index and its buffer is not expressible,
`operand-ok?` at `lib/typing/kernel.chiral:1390-1394` is the one function that
decides it, and `E41` owns widening it. A design run may not write
`docs/elements/ledger.md`, so this is the packet's instruction to the stage that
can.

⚑ **2026-09-11: the row to write names `enforcement/N22` as the owner of the
widening.** `docs/elements/specs/E41-region-types-SPEC.md` puts the application
operand and the `=>` binder scope outside `E41`, §2's ⚑ carries it, and `PRB-82`
opened `enforcement/N22` on 2026-09-10. The rest of the instruction stands
verbatim: the relation between an index and its buffer is not expressible, and
`operand-ok?` at `lib/typing/kernel.chiral:1390-1394` is the one function that
decides it. The stage that writes the ledger row writes `enforcement/N22`, which
is `open` and `unminted`. [[working-discipline]]'s deferral rule bars an `E#`
here.

### The element owed, and the answer it waits on

**If author call 9 rules that a clamp discharges the class**, this row closes
once `E176` builds. Nothing further is owed here, `docs/definitions/bug-classes.md:46`
moves off `none` by `E176`'s repair, and the row's state goes to `closed` with
Shape 6's ledger row as its residue.

**If author call 9 rules that a clamp does not discharge the class**, one
element is owed, and it is owed **behind `E41`** rather than at this row. Its
shape, written so the mint step can execute it once `E41` is built and once
call 8 says which arc holds it:

⚑ **2026-09-11: it is owed behind `enforcement/N22`, and `N22` is unminted.**
`docs/elements/specs/E41-region-types-SPEC.md` puts Shape 3's two halves outside
`E41`, §2's ⚑ carries it, and building `E41` would leave this element as blocked
as it is today. So the mint step executes the packet below once `enforcement/N22`
is designed, minted and built, and once call 8 says which arc holds this row. The
packet's own content is unchanged by this trigger: its catalog row, ledger row,
size estimate and gate all describe the carrier and the judgment, and none of
them names `E41`.

- **Elements:** one. The carrier and the judgment constrain each other: a
  `Judg` arm with no issuing rule is half a row, and a bound that names a buffer
  with no arm to refuse it cannot be reported. One element covers both.
- **Band:** `UNASSIGNED`.
- **Catalog row:**
  `| E<NN> | The bounds relation: a refinement atom names a buffer's length, and `str-sub`, `bslice` and `bget` carry a bound that refuses an out-of-range index at check time | primitive | Dependent ML index refinement (Xi/Pfenning), Liquid Types (Rondon/Jhala) (`PAPER`) | `OURS` over `lib/typing/refine.chiral` | The decision procedure is built and in the blob, the bound is already carried for `(Pool n)`, and the only missing term is the one relating an index to its buffer. 242 calls through `nb-bslice` under two surface names, plus `bget`'s | SH |`
- **Ledger row:**
  `| E<NN> | typing | lib/typing/kernel.chiral, lib/typing/refine.chiral, lib/typing/diag.chiral, lib/prelude/prelude.chiral | design | SH |`
- **Size:** four files under `lib/`, plus one gate under `tools/test/`.
  `operand-ok?` is 5 lines (`lib/typing/kernel.chiral:1390-1394`) and its
  widening pulls `Constraint`'s `sym` field
  (`lib/typing/refine.chiral:14-19`) from a level key to a term key, which
  touches `entails` and `is-empty` inside 168 lines. One `Judg` constructor and
  one `dg-judg-msg` arm, 2 lines in `lib/typing/diag.chiral`. Three extern
  signatures in `lib/prelude/prelude.chiral` at `:83`, `:97` and `:98`. Estimate
  **150 to 250 lines changed**, on the basis that `refine.chiral` is 168 lines
  whole and the change re-keys one of its four `Constraint` fields. No emission
  is touched, so the first agreement is `C1 == C2`. The call-site cost is not
  in this estimate and is not known: whether any of the 242 sites can discharge
  the obligation depends on what the widened fragment proves, and nothing in the
  tree measures that today.
- **Gate:** a phase that reddens when the arm stops being issued, per
  [[goals/enforcement]]'s State section, *"a gate fails when the judgment stops
  holding."* `enforcement/N21` is the row for the mechanical half of that over
  every class at `none`.

### Owed elsewhere, named and not opened

- **A roster row for whether a saturated application is inside `E41`'s scope**,
  §5 question 5. No arc holds it. This run does not open it and does not name it
  with an id.

  ⚑ **2026-09-11: opened, and the enforcement arc holds it.**
  `enforcement/N22`, `docs/arcs/enforcement-arc.md`, 2026-09-10, `origin` `pair`,
  `req` 1, state `open`, `unminted`. Its next stage is `element-design`. This
  bullet stops being work owed elsewhere.
- **The `38`, the `250`, and `records/enforcement-arc.md` EN-31's `:97-110`
  span**, §5 questions 6 and 7. Reported here, written by the stages that own
  those files.

- **Related:** [[arcs/enforcement-arc]] `enforcement/N19`, `N20`, `N21`;
  [[arcs/diagnostics-arc]] `E176` and `docs/arcs/parts/diagnostics-L5.md`;
  [[banks/text]] shard A; [[banks/memory]] shard 3 and §5 residue 3;
  [[records/bounds-residue]] `BR-03`, `BR-05`, `BR-06`;
  `records/enforcement-arc.md` EN-31; [[decisions/decision-primitive-with-consumer]];
  [[decisions/decision-work-ids]]; [[decisions/decision-lane-split]].
