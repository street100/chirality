---
row: enforcement/N15
arc: enforcement
title: `tal-ty=?` stops standing in for type equality while failing to be an equivalence, or the collapse is discharged at a site the producer writes into the artifact
kind: law
origin: new
req: 3
status: blocked
needs-author: [N15-Q1 the discharge mechanism, N15-Q2 the type-argument wildcard reopens the 2026-09-03 repair-shape call]
updated: 2026-09-30
---

# enforcement/N15: the checker's type relation becomes transitive, and the erased word is left at a written cast

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** the relation `ck-fn` reads wherever it compares two tal types is
  transitive, and every place an erased one-word value meets a position of a
  more specific type carries an instruction the producer wrote, which the
  checker reads and which names the type the value moves to.
- **Serves:** requirement 3 of [[arcs/enforcement-arc]], "The check agrees with
  the compiler it checks." A relation that accepts `i64 ~ word` and
  `word ~ str` and refuses `i64 ~ str` gives a verdict that depends on which
  register an erased value passes through, so agreement is a property of the
  route the lowering happened to take.
- **Goal:** [[goals/enforcement]], condition 2: a claim the compiler makes about
  its own work is carried with evidence and refused when it does not hold.

## 2. What the tree holds

Measured 2026-09-30 at `9a9b047` with the working tree as the snapshot shows it.

- **Bank:** [[banks/erasure]] shard F, the uniform erased word at the lowering
  type level (`docs/banks/erasure.md:83`), and its cross-cut into
  [[banks/verification]]: `tal-ty=?` is the instrument that makes shard F
  checkable (`docs/banks/erasure.md:145-150`). The bank records the relation as
  built and restored by `ddfbc27`. It records nothing about transitivity, and its
  §5 items 1 and 2 still read E185 and E186 as open while both are built.

### The relation, and the two axes on which it fails

`tal-ty=?` (`lib/lowering/tal/check.chiral:68-77`) is reflexive and symmetric by
its arms: `tt-word` answers `true` against every type at `:70`, and each ground
arm and the data arm answer `true` against `tt-word` at `:71-73` and `:76`. The
comment at `:65-67` names it word-compatibility and says it is nominal equality
nowhere. The same relation is called at every type comparison the checker makes:
argument against parameter in `ck-args` (`:156`), callee return against the
destination's annotation in `ck-app` (`:164`), a returned register against the
declared return in `ck-term` (`:257`), and constructor fields through `ck-args`
from `ck-con` (`:184-197`).

It fails transitivity on two axes, and PRB-74 measured the first by reading.
Both are measured here by running the live relation: a probe importing
`lowering/tal/check`, built by the committed `bin/chirality-bin` and run at exit 0.

| pair | answer |
|---|---|
| `(tal-ty=? tt-i64 tt-word)` | `true` |
| `(tal-ty=? tt-word tt-str)` | `true` |
| `(tal-ty=? tt-i64 tt-str)` | `false` |
| `(List I64)` against `(tt-data "List" nil)` | `true` |
| `(tt-data "List" nil)` against `(List Str)` | `true` |
| `(List I64)` against `(List Str)` | `false` |

The second axis is `targs=?` (`:90-95`), which lets an empty type-argument list
on either side match any list. Its comment (`:78-89`) records it as the author
call "The `ck-prog` repair shape" of 2026-09-03 and calls it "the wildcard at the
argument-list level that tt-word is at the whole-type level". So the row's
defect has two instances, and the row as written names one.

### Why transitivity is the property, by the tree's own settled argument

`docs/decisions/decision-erased-word-level.md:44-49` refuses a `Word` in the
kernel's `conv` because conversion is an equivalence, and an equivalence in
which one word converts with two distinct ground types identifies those types.
The same argument holds at the lowering level. **Any equivalence relation over
`TalTy` in which `tt-word` relates to `tt-i64` and to `tt-str` relates
`tt-i64` to `tt-str`.** So the relation cannot become an equivalence and keep
its current accepts. An equivalence must either collapse the ground types or
relate `tt-word` to itself alone, and in the second case every value that crosses
between the word and a ground type needs a written site. The decision names the
two published ways out at `:46-48`: GHC's `Any` as a type with no equations, and
Java's `Object` as a supertype in a directional relation. The decision's reason 4
(`:64-68`) leans on `tal-ty=?` as the one statement of representation
compatibility; that wording describes the relation and fixes nothing about its
shape.

### Where the erased word is produced

Seven sites originate a word type, across five files:
`lib/lowering/compile-front.chiral:70` (an erased type variable in a kept
position) and `:71` (an arrow type), `lib/lowering/compile-back.chiral:29`
(`nt-word` to `tt-word`), `lib/lowering/upper/closconv-driver.chiral:129`
(E185's dispatcher domains, `word-ptys`), and `lib/lowering/upper/lower.chiral:49`
(`ttype` of an erased type), `:304` (a case with no expected type) and `:404-405`
(the erased-binder placeholder). The empty argument list is produced at one site,
`expr-con` (`lib/lowering/upper/lower.chiral:291`), which annotates every
constructed value `(tt-data dn nil)` at `:299`.

The lowering emits a typed instruction at five points: `mk-call` for `i-prim`
and `i-call` (`lower.chiral:220`), the nullary call (`:248`), `i-con` (`:299`),
the outlined-case call (`:319`) and the return (`:345`). These are the points a
written cast would be emitted beside.

### The instruction set has no cast

`Instr` (`lib/lowering/tal/ssa.chiral:26-34`) holds eight forms: four carry a
`ty` and four do not (`:31-34`). None moves a value from one tal type to another.
`ssa.chiral:16-20` defines `tt-word` as representation-compatible with any
one-word type and names `tal-ty=?` as its check. `Instr` is matched in four
consumers besides its declaration: `lowering/tal/check`, `lowering/tal/erase`,
`lowering/tal/eval` and `lowering/upper/optimize`.

### What the relation carries, measured over the compiler's own blob

`prog/optimizer-census.prog` runs `ck-fn` over every TFn the compiler emits for
`prog/compiler.prog`. Re-run here the way `tools/test/opt-census.sh` runs it
(the probe built from a scratch `lib/`, run over the tracked blob), with
`tal-ty=?` and `targs=?` mutated in the scratch copy only. `ck-fn` stops at a
TFn's first error, so each count is TFns refused and a floor on sites.

| relation in the scratch copy | ok | refused | classes of refusal |
|---|---|---|---|
| live (base) | 1,531 | 31 | 31 `call: unknown tal function` |
| `tt-word` equal to itself alone | 651 | 911 | 511 argument, 353 con field, 27 return, 20 unknown call |
| `targs=?` strict | 819 | 743 | 92 argument, 439 return, 195 con field, 17 unknown call |
| both, the nominal equivalence | 576 | 986 | 307 argument, 348 return, 317 con field, 14 unknown call |
| `tt-word` a top, `got` below `expected` | 900 | 662 | 557 argument, 57 con field, 26 return, 22 unknown call |
| that preorder with an empty list as a top | 594 | 968 | 305 argument, 435 return, 214 con field, 14 unknown call |

So the erased word's collapse is load-bearing in 955 of the 1,531 TFns the live
relation accepts. Of the word axis's 911, about 249 are the upward direction, a
specific value flowing into a word position (911 against 662; each count is a
TFn's first error, so the split is approximate).

### The gate that pins the current relation

Phase 22, `tools/test/tal-check.sh`, pins the wildcard as ACCEPT rows: `G1`, `G5`
and `G6` go red under mutant `M2`, which restores the strict argument-list
check (`tools/test/tal-check.sh:92-93`). It pins three refusals the relation
makes: `G10` ground against data (`:61-62`), `G12` the data name (`:65`) and
`G15` two present argument lists that disagree (`:71`).

### The ledger rung

`E18`'s checker is built and reached by no shipping path; `ck-prog` has zero call
sites and PRB-70 keeps `lowering/tal/check` outside the compiler closure
(`records/lenses/problems.md` PRB-70). The census program above is the one
runner of `ck-fn` in the tree.

### What was built today, and whether it touches this row

| row | element | touches `TalTy`, `Instr` or `tal-ty=?` | interaction |
|---|---|---|---|
| `enforcement/N26` | `E171`, built | no. Kernel seat on the Pi, `lib/typing/kernel.chiral` | none |
| `enforcement/N27` | `E204`, built | no. `load-extern` and `emit-elf-m`; its SPEC names none of the three | none |
| `enforcement/N25` | `E39`, designed | not yet | when `N9` lowers the effect row to tal, any new `TalTy` component enters this relation, so the preorder below is stated over the whole of `TalTy` |
| `checker-core/CK20` | unminted, designed | no. Quantity on a kernel arrow | none |

## 3. The delta

1. A transitive relation in place of `tal-ty=?` and `targs=?`. The live relation
   is transitive on neither axis (§2 table one).
2. An instruction that moves a value between a word type and a more specific
   one, with a checker rule for it. `Instr` has none (`ssa.chiral:26-34`).
3. The producer writing that instruction at the five emission points in
   `lower.chiral`, enough that the census returns to 1,531 accepted with the
   same single class of 31. Measured today, 986 TFns (nominal) or 968 (the
   preorder) refuse without it.
4. Phase 22 rewritten: `G1`, `G5` and `G6` become a pair each, the uncast shape
   refused and the cast shape accepted, plus a transitivity row that reddens on
   today's relation.
5. The four `Instr` consumers learning the new form: `erase` lowers it to
   nothing or a register move, `eval` to the identity, `optimize`'s passes
   through it.

**Verdict:** a real delta. Every part of it is missing from the tree.

## 4. The shapes

The tree does not settle among them. [[records/findings]] FD-17 surveyed five
published discharges and its `element:` field leaves the choice to the author;
§2's structural argument narrows the field to shapes that write a site or
collapse the types.

### Shape A: one representation class (Cmm's `weak_eq`)

- **Form:** every `TalTy` is one machine word, so the equivalence has one class
  and `tal-ty=?` answers `true` for every pair. FD-16 measured GHC's `weak_eq` as
  an equivalence over three classes; this tree's types all fall in one.
- **Costs:** nothing to write.
- **Forbids:** every type distinction the checker makes. `G10`, `G12` and `G15`
  stop refusing and the checker's claim drops to "every value is a word".
  Refused under "proper or not at all": it meets the letter of the row by
  narrowing the claim.

### Shape B: nominal equivalence, with a written cast in both directions

- **Form:** `tal-ty=?` becomes structural equality, `tt-word` equal to itself
  alone and argument lists compared strictly. A new `(i-cast (dst I64) (src I64)
  (ty TalTy))` is accepted when its source and target are both one-word types
  and one side is `tt-word` (or the two differ only in an erased argument list).
  It costs nothing at runtime. This is FD-17's fifth mechanism, System FC's
  cast, with the unproved coercion GHC names `UnivCo` scoped to the erased word.
- **Costs:** 986 TFns to repair by producer casts, both directions written. One
  `Instr` constructor through four consumers.
- **Forbids:** any implicit move into or out of the word. The upward direction,
  which is sound without a check, is written 249 extra times.

### Shape C: a directional preorder, with a written cast downward only

- **Form:** the relation becomes `tal-ty<=?`, reflexive and transitive, with
  `tt-word` a top: any one-word type sits below it, and the word sits below
  nothing else. Every call reads it in one direction: argument below parameter
  (`check.chiral:156`), callee return below destination annotation (`:164`),
  returned register below declared return (`:257`). The downward move is the
  same `i-cast` as Shape B, written by the producer. This is the JVM verifier's
  `oneWord` and Java's `Object`, the directional relation
  `decision-erased-word-level.md:47-48` names as the published way to escape the
  collapse.
- **Costs:** 662 TFns repaired by downward casts on the word axis, 968 with the
  argument-list axis folded in. One `Instr` constructor through four consumers.
- **Forbids:** an implicit downward move. The relation stops being called
  equality, which the row's first branch asks for.

### Shape D: a checked downcast (the JVM's `checkcast`, WebAssembly's `ref.cast`)

- **Form:** Shape C with a runtime test in the cast.
- **Costs:** a runtime type descriptor on every value that can be cast. An
  `I64` and a `Str` are both a raw word here, so the test is unconstructible
  without boxing every value that passes through an erased position. FD-17
  measured WebAssembly's cast at three machine operations plus a descriptor.
- **Forbids:** an unsound cast at runtime, which the tree has no other means to
  observe until `N13`'s T1 rung runs.

### Shape E: specialization, so no word survives to the check

- **Form:** duplicate each polymorphic def and each `$apply` family per
  instantiation until `tt-word` has no producer.
- **Costs:** code size, and it undoes E185's family merge, which is
  `enforcement/N16`'s criterion. FD-17 item 2 records Harper and Morrisett
  classing it an optimization, since it stops at a compilation-unit boundary.
- **Forbids:** nothing the row needs; it removes the subject instead.

Type passing and term-level type representations (FD-17 items 3 and 4) are
excluded without a shape: both make an erased quantity-0 type available at
runtime, which is the quantity erasure of [[banks/erasure]] shard A.

## 5. The call

- **Recommended:** Shape C, because it is the shape the settled decision itself
  names as the published escape (`decision-erased-word-level.md:47-48`), it is
  transitive, it writes the fewest sites of the shapes that keep the checker's
  distinctions, and its written site is the instruction FD-17 found four of five
  mechanisms needing. Its cast is unchecked at runtime; the value it moves is
  what `enforcement/N13`'s T1 rung checks, so C leaves no claim unowned.
  The recommendation stands until the author rules on Q1.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Which discharge: B, C or D (A and E refused above) | NEEDS-AUTHOR | FD-17's `element:` field leaves the choice among its five to the author. Recommended C. Measured cost: B 986 TFns, C 968, D unconstructible without boxing |
| 2 | Whether the argument-list wildcard at `check.chiral:90-95` goes too | NEEDS-AUTHOR | It is the 2026-09-03 author call "The `ck-prog` repair shape" ([[records/author-calls]]), and the row is unmet while it stays: `(List I64)`, `(List)`, `(List Str)` measure `true`, `true`, `false`. Recommended: the same preorder with an empty list as a top, and `expr-con` writing the real arguments where the expected type carries them (`lower.chiral:299`), so fewer casts are written |
| 3 | Whether the check runs on the shipping path | DEFERRED(`E18`, `enforcement/N8`) | PRB-70 ruled the checker outside the closure; this row changes the relation and the producer, and the census is its runner meanwhile |
| 4 | Whether a cast's value is checked | DEFERRED(`enforcement/N13`) | T1 compares values; an unchecked cast is exactly the claim T1 convicts |
| 5 | The level the word lives at | RESOLVED | `docs/decisions/decision-erased-word-level.md:39-40`: strictly the lowering type level. Every shape here keeps it there |
| 6 | Order against `N16` and `N17` | RESOLVED | Independent. `N16` would shrink the number of dispatcher casts and removes none of the need. `N17` adds `ty` to three other `Instr` forms; both edit `Instr` and neither waits on the other |

## 6. The mint packet

- **Elements:** one. The relation, the cast instruction, its emission and the
  gate constrain each other: the relation refuses 968 TFns until the producer
  casts, and the cast has no meaning without the rule that reads it.
- **Band:** `UNASSIGNED`. Lane A's `E184-E189` is spent and
  `docs/decisions/decision-lane-split.md:40-49` lets `--mint` take the lowest
  number free tree-wide.
- **Catalog row:**
  `| E<NN> | **The checker's type relation is transitive, and the erased word leaves at a written cast.** \`tal-ty=?\` becomes a preorder with \`tt-word\` a top (or equality, per the ruling); \`Instr\` gains \`i-cast\`, written by the lowering wherever a word meets a more specific position | law | FD-17 item 5 (System FC cast), JVM \`oneWord\` | published | PRB-74 and this row's census: the live relation accepts i64~word and word~str and refuses i64~str, and 955 of 1,531 accepted TFns rest on it | SH |`
- **Ledger row:**
  `| E<NN> | lowering/tal/check | design | The checker's type relation is transitive; the erased word leaves at a written cast. Modules: \`lowering/tal/ssa\`, \`lowering/tal/check\`, \`lowering/upper/lower\`, \`lowering/tal/erase\`, \`lowering/tal/eval\`, \`lowering/upper/optimize\` | SH |`
- **Size:** six files under `lib/` and one gate, roughly 150 to 200 lines.
  `ssa.chiral` one constructor; `check.chiral` the relation (about 20 lines) and
  one `ck-instr` arm; `lower.chiral` a cast helper and five emission points
  (about 50); `erase`, `eval` and `optimize` one arm each; `tal-check.sh` three
  rows turned into pairs plus a transitivity row with its mutant (about 80).
  `lower` and `erase` are inside the compiler closure, so the build owes a
  fixpoint and a promoted binary. Basis: the census classes in §2, the five
  emission points and the four `Instr` consumers counted there.
- **Related:** PRB-74, FD-16, FD-17, [[decisions/decision-erased-word-level]],
  [[banks/erasure]], `enforcement/N8`, `enforcement/N13`, `enforcement/N16`,
  `enforcement/N17`, `E185`.

### Needed and unrostered

| what | why it is owed | where it would go |
|---|---|---|
| the two author-call rows for Q1 and Q2 | a NEEDS-AUTHOR earns a row; this run writes one artifact | [[records/author-calls]], by the orchestrator |
| `decision-erased-word-level.md:29-35` and `:64-68`, and `ssa.chiral:16-20` | both describe `tal-ty=?` as the compatibility check; under B or C the compatibility moves into the cast rule | a `revisit` on the decision once Q1 is ruled; the code comment inside the element's build |
| [[banks/erasure]] shard F row and §5 items 1 and 2 | the row says nothing of transitivity; §5 reads E185 and E186 open, both built | a `doc-audit` of the bank |
| a pinned source for the gradual-typing consistency relation | the published relation of this exact shape (reflexive and symmetric, intransitive, with a dynamic type), whose published discharge is cast insertion; unpinned here and not relied on above | a `research` run |
| `tools/test/opt-census.sh:143-147` pins | they read 1,519 defs and 1,549/1,518/31; the census measures 1,532 and 1,562/1,531/31 today, so rows R1 and R2 would read red | a rebaseline with a stated cause, outside this row |
