---
row: enforcement/N16
arc: enforcement
title: `shape-eq` (`lib/lowering/upper/closconv.chiral:343-350`) splits domains the way defunctionalization's published criterion does, or the coarsening is stated as a costed choice
kind: primitive
origin: new
req: 3
status: blocked
needs_author: [Q1]
updated: 2026-09-30
---

# enforcement/N16: the defunctionalization family key splits its domains by the published criterion

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** two arrow types share a `$apply` dispatcher only when the
  published route-one criterion says they share a data type, on the domain as
  already on the codomain, or the tree states the coarser key as a choice with
  its measured price.
- **Serves:** requirement 3 of [[arcs/enforcement-arc]]
  (`docs/arcs/enforcement-arc.md:123`), "The check agrees with the compiler it
  checks". A merged-domain dispatcher is the site where the lowering has no one
  domain to state, so the checker reads the erased word there.
- **Goal:** [[goals/enforcement]], condition 2 (`docs/goals/enforcement.md:29-32`),
  whose observing rows are `N2`, `N3` and `N5`. `N2` and `N3` are this
  criterion's symptoms.

## 2. What the tree holds

Measured 2026-09-30 at `487fd3a`. Every probe below ran in the scratchpad over a
copied `lib/`; nothing under `lib/`, `prog/` or `bin/` was edited.

- **Bank:** [[banks/erasure]] shard E, "representation-shape erasure: every
  non-arrow is one word, so a defunctionalization family merges"
  (`docs/banks/erasure.md:82`), justified at `:55-57` by *"no machine
  instruction distinguishes them"*. That justification covers the runtime and
  says nothing about the type the IR carries, which is this row's subject.
  Residue items 1 and 2 (`:216-240`) still describe E185 and E186 as open.
  Both are built (`docs/elements/ledger.md:329-330`).

| what exists | where | rung | reached by |
|---|---|---|---|
| `shape-eq`: any two non-arrows are equal, a nested arrow recurses with its own codomain erased too | `lib/lowering/upper/closconv.chiral:343-350` | IMPLEMENTED | `arrow-key-eq` |
| the comment claiming `(-> I64 I64)` and `(-> Str Bool)` share a key, which `cod-key-eq` refutes (PRB-76's defect half) | `closconv.chiral:337-340` | n/a | n/a |
| `cod-key-eq`: arrow against arrow by `shape-eq`, variable against variable equal, variable against ground unequal, ground against ground by `core-eq` | `closconv.chiral:366-377`, its reason at `:359-365` | IMPLEMENTED | `arrow-key-eq` |
| `arrow-key-eq`: `shapes-eq` on the domains, `cod-key-eq` on the codomain, `ieq-list` on the effect flags | `closconv.chiral:382-386` | IMPLEMENTED | `key-in?`, `fam-has?`, `fam-add-site`, `ka-find` (`:651`, `:660`, `:670`, `:1250`) |
| slot keying: a function value passed to a callee is keyed by the callee's parameter type, so both sides of a family agree | `closconv.chiral:886-890` | IMPLEMENTED | `fv-site`, `fv-own` |
| E185's stated channel: `apply-ptys` states `nt-word` at every domain, because `shape-eq` leaves no one domain | `lib/lowering/upper/closconv-driver.chiral:117-133` | IMPLEMENTED, E185 built | `compile-front`'s `peel-def` (`lib/lowering/compile-front.chiral:192-209`) |
| `apply-ty` spells the domains from one arbitrary member's key | `closconv.chiral:1169-1185` | IMPLEMENTED | overridden by the stated channel |
| the lowering's own word rule: a type variable and an arrow type are `nt-word` | `compile-front.chiral:70-71` | IMPLEMENTED | `term->ntalty` |
| E185's gate, whose R2 asserts every `$apply0` domain is `nt-word` over a fixture built to merge `I64` with `(List Str)` | `tools/test/apply-word.sh:26-32`, `tools/test/samples/e185_apply_word.prog:1-9` | ENFORCED as a declared out-of-dispatch gate | by hand |

**The criterion's source.** [[records/findings]] FD-18: route one's criterion is
equality of the source arrow type, one data type per distinct arrow type
(`POLYDEFUNCX:172-173`), and it works only where arrow types are ground. The
tree keeps it on the codomain and drops it on the domain. FD-18 priced the repair
at zero new `TalTy` constructors, zero new `Instr` forms and zero change to
`tal-ty=?`. PRB-76 (`records/lenses/problems.md:1066`) carries the asymmetry and
records that *"Whether to split is the author's"*; no row in
[[records/author-calls]] carries it.

**Why the domain erases, from the code.** The comment at `:360-361` gives the
reason: *"a poly `(-> K K ..)` param must share a family with the concrete
closures passed to it"*. Slot keying (`:886-890`) already meets that for the
codomain, and it meets it for the domain on the same terms. A domain that is a
variable in the slot is keyed as a variable at both ends. So the variable half
of `cod-key-eq` is the rule a domain needs, and the ground half is the published
criterion.

**The probe.** A leaf `.prog` outside the tree runs `compile-front` and counts
the `$apply` NDefs, the `$clo` constructors, and how many dispatcher domains the
stated channel spells as `nt-word`. Five variants of `lib/`:

| variant | domain key | nested arrows | stated domains |
|---|---|---|---|
| HEAD | `shape-eq` | `shape-eq` | all `nt-word` |
| B | `cod-key-eq` per position | `shape-eq` | all `nt-word` |
| C | as B | `shape-eq` | ground concrete, variable and arrow `nt-word` |
| D1 | `core-eq` per position | `shape-eq` | all `nt-word` |
| D2 | as C | `arrow-key-eq` recursively | as C |

Over `prog/compiler.prog`:

| variant | `$apply` | `$clo` ctors | word domains / domains | self-compile | `optimizer-census` |
|---|---|---|---|---|---|
| HEAD | **8** | 33 | 17 / 17 | 1,261,944 bytes, equal to the committed binary | `tfns=1562 ok=1531 err=31` |
| B | 16 | 33 | 36 / 36 | 1,270,136, `C2 == C3` | `tfns=1571 ok=1540 err=31` |
| C | 16 | 33 | 3 / 36 | 1,270,136, `C2 == C3` | `tfns=1573 ok=1542 err=31` |
| D1 | 16 | 33 | 36 / 36 | 1,270,136, `C2 == C3` | not run |
| D2 | **16** | 33 | **3 / 36** | **1,270,136**, `C2 == C3` | `tfns=1574 ok=1543 err=31` |

The 31 refusals are one class under every variant, `call: unknown tal
function`, first instance `bput-u8`, which is requirement 2's `<name>$0` gap. The
split adds no refusal: every new dispatcher and every concretely stated domain
passes `ck-fn` as the relation stands.

Over every root `tools/test/run-tests.sh:175-176` discovers, less its known-fail
and `_reject_` entries, 96 roots:

- HEAD holds **199** dispatchers over 306 domains, all `nt-word`. D2 holds
  **247** over 420, 202 of them `nt-word`. The 48 added are eight in each of the
  six roots that carry the compiler; no other root moves.
- Emitted bytes under D2's promoted compiler: **89 roots byte-identical.** Seven
  differ, and each one embeds compiler source: `compiler` and `paren-audit`,
  `prose-lint` and `test-runner` +8,192 each, `shape-census` and `wield`
  +12,288 each, `e186-capture-fields` +4,096. That last root has zero families,
  so its 4,096 bytes are the added source alone, and the page granularity of the
  ELF layout bounds every figure here to 4 KiB. Total +61,440 bytes, +0.65% on
  the compiler.
- D1 splits four roots further than B (`prose-lint` 16 to 17, the three
  `prog/samples/prapanca-run*` roots 3 to 4). Its extra splits separate
  variable domains by de Bruijn position, which `compile-front.chiral:70` lowers
  to one `nt-word` whatever the position.
- D2 against C: equal dispatcher counts on all 96 roots.
- The E185 fixture: HEAD's one dispatcher with one word domain becomes two with
  none, and the fixture's ELF is 37,240 bytes under both and exits 0 under both.
  FD-18's `(-> I64 I64)` and `(-> Str I64)` pair goes from one dispatcher to two
  and exits 3 under both.

## 3. The delta

The criterion itself is missing. The domain key, `shapes-eq` at `:382-383`,
needs the per-position rule `cod-key-eq` already carries on the codomain. A nested
arrow needs the whole key, so the recursion is `arrow-key-eq` wherever
`shape-eq` stands now. The stated channel, `apply-ptys` at
`closconv-driver.chiral:132-133`, then has one domain per family to state and
states it: the ground type where the key is ground, `nt-word` where it is a
variable or an arrow. The false comment at `:337-340` and five comments that
describe the merge (`closconv-driver.chiral:117-127`,
`compile-front.chiral:192-199` and `:206-209`, `closconv.chiral:1169-1182`)
change with it. E185's gate asserts the behaviour this retires and is rewritten.

Nothing in `TalTy`, `Instr` or `tal-ty=?` is in the delta.

**Verdict:** a real delta, one criterion and the one channel that reads it.

## 4. The shapes

Route two (one indexed sum, a polymorphic dispatcher) and the existential route
are excluded without a shape: FD-18 measured both as needing `TalTy` and `Instr`
forms the target lacks.

### Shape A: state the coarsening as a costed choice
- **Form:** `shape-eq` unchanged; its comment repaired to describe the key it
  computes; PRB-76's price written at the code and into shard E.
- **Costs:** no bytes. Keeps 17 of 17 compiler dispatcher domains and 306 of 306
  tree-wide at `nt-word`, each one a position where `ck-fn` accepts through the
  word wildcard PRB-74 measured as intransitive.
- **Forbids:** nothing. It is the row's "not at all" branch, and it leaves
  E185's word domains as the stated answer for types the family could name.

### Shape B: exact source-type equality on every domain (D1)
- **Form:** `core-eq` per domain position.
- **Costs:** the same eight compiler dispatchers as Shape C, plus four more
  splits in four other roots.
- **Forbids:** a family merging two variable domains that differ only in de
  Bruijn position. Route one does not reach non-ground types (FD-18), so exact
  equality there follows no published criterion, and the lowering erases both
  sides to the same `nt-word`. The extra split buys a second dispatcher over
  identical target types. Rejected.

### Shape C: the published criterion at ground types, the tree's variable rule elsewhere, recursive at arrows (D2)
- **Form:** `arrow-key-eq` compares domains position by position with the rule
  `cod-key-eq` holds (ground exact, variable against variable, the two never
  equal) and recurses through `arrow-key-eq` at a nested arrow in either
  position. `shape-eq` and `shapes-eq` retire. `apply-ptys` states each domain
  from the key.
- **Costs:** eight more dispatchers in the compiler and +61,440 emitted bytes over
  seven compiler-carrying roots, zero elsewhere. About 20 lines of code in two
  files and a gate rewrite (§6).
- **Forbids:** a dispatcher whose ground domain is spelled as the word. It keeps
  every family slot keying aligns today, because the variable half is the rule
  the codomain already runs under slot keying.

## 5. The call

- **Chosen:** Shape C, recommended and carried to the author, because PRB-76
  hands the split to the author and no ruling exists. It is the proper answer by
  the tree's own terms: the codomain already runs this rule for the reason route
  one gives (`closconv.chiral:359-365`), the domain is the other half of the
  same arrow, and the measured price is eight dispatchers and 0.65% of the
  compiler for 33 of 36 compiler domains stated as their own type.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Split the domain key (Shape C) or state the coarsening as a costed choice (Shape A) | NEEDS-AUTHOR | PRB-76 records the split as the author's. Measured: dispatchers 8 to 16 in the compiler and 199 to 247 tree-wide; word domains 17/17 to 3/36 in the compiler, 306/306 to 202/420 tree-wide; 89 of 96 roots byte-identical, the compiler +8,192 bytes; fixpoint holds; `ck-fn` refusals unchanged at 31, one class. Recommended: Shape C |
| 2 | Does "zero change to `tal-ty=?`" still hold against `enforcement/N15`'s design (`487fd3a`) | RESOLVED | Yes. N16 edits neither `tal-ty=?` nor `Instr`, and the census above shows every new dispatcher accepted by the relation at HEAD. N15 turns the relation into an order with `word` on top plus a written `i-cast` (`docs/arcs/parts/enforcement-N15.md:213-227`); N16 needs nothing from either branch of that ruling and nothing it does conflicts with it. The two stay independent in order, as N15's Q6 (`:269`) states |
| 3 | Does N15's cast count shrink under N16 | RESOLVED, measured | Yes, at one of N15's seven word producers, `closconv-driver.chiral:129` (`enforcement-N15.md:93-96`). Under N15's order a ground value flows up into a word domain uncast and a downward cast falls in the dispatcher arm that hands the word to a member at its own type. Stated concretely, 33 of the compiler's 36 dispatcher domains need no such cast; the 3 left are variables or arrows and still do. Tree-wide 218 of 420 leave the word. N15's other six producers are untouched, so the need N15 answers remains, as its Q6 says |
| 4 | Is this under requirement 7 | RESOLVED: no, by the requirement's letter | Requirement 7 (`docs/arcs/enforcement-arc.md:471-472`) quantifies over rewrites the optimizer adopts, and `enforcement/N23` over every pass `opt-tfns` adopts. `closconv` is a translation that runs before `opt-tfns`, and a translation's value evidence is T1, `enforcement/N13`. The evidence this change carries at build is the fixpoint, the unchanged `ck-fn` refusal set and the 89 byte-identical roots above. Whether requirement 7 should widen to translations belongs to the author and is listed below |
| 5 | Nested arrows: keep `shape-eq`'s erasure or recurse with the whole key | RESOLVED | Recurse. `POLYDEFUNCX:172-173` keys on the whole source arrow type, and D2 against C moves no dispatcher count in 96 roots, so the proper form costs nothing measured |
| 6 | Does `decisions/decision-erased-word-level` still hold | RESOLVED | Yes. It settles the level the erased word is spelled at, and the 3 compiler domains that stay the word are still spelled there. Its wording around the merge is a doc edit inside the build |
| 7 | E185's gate, whose R2 asserts the merged behaviour | RESOLVED | Rewritten inside this element's build: the fixture now yields two dispatchers, so R2 inverts to each ground domain stated as its own type, and a row pins a variable domain at `nt-word`. An element that changes a gated behaviour ships the gate change in its own step, as E185 to E188 each did |

NEEDS-AUTHOR sets `status: blocked`. Q1 owes a row in [[records/author-calls]];
this run was scoped to write none.

**Needed and unrostered.**

| what | why it is needed | where it would go |
|---|---|---|
| the author-calls row for Q1 | an open fork with no row, and PRB-76 names the call | [[records/author-calls]], clerical |
| a `doc-audit` of [[banks/erasure]] | shard E cites `:335-356` for `shape-eq`, and residue items 1 and 2 describe E185 and E186 as open while both are built | a `doc-audit` run |
| whether requirement 7 covers translations as well as optimizer rewrites | a translation change that alters emitted code falls outside every value check the arc schedules except T1 | the author, against [[arcs/enforcement-arc]] requirement 7 |

## 6. The mint packet

- **Elements:** one. The key and the stated channel constrain each other: the
  channel has a domain to state only once the key splits, and a split key
  without the channel spells ground domains as the word, which is variant B.
- **Band:** `UNASSIGNED`. Lane A's `E184-E189` is spent
  (`docs/decisions/decision-lane-split.md:44-48`); the allocator takes the next
  number free tree-wide.
- **Catalog row:**
  `| E<NN> | **The defunctionalization family key splits its domains by the published criterion.** \`arrow-key-eq\` compares each domain as \`cod-key-eq\` compares the codomain, ground exact and variable against variable, and recurses at a nested arrow; \`apply-ptys\` states each dispatcher domain from the key | law | FD-18, route one's criterion (POLYDEFUNCX:172-173) | published | PRB-76: the key merged over its domains and split over its codomain, so 17 of 17 compiler dispatcher domains were the erased word; split, 3 of 36 are | SH |`
- **Ledger row:**
  `| E<NN> | lowering | design | The defunctionalization family key splits its domains by the published criterion. Modules: \`lowering/upper/closconv\`, \`lowering/upper/closconv-driver\`, \`lowering/compile-front\` (comments only) | SH |`
- **Size:** 3 `lib/` files and 1 gate. Code about 20 lines, from the probe: a
  7-line `doms-key-eq`, a two-line recursion in `cod-key-eq`, and a 12-line
  `dom-pty` replacing `word-ptys`, with `shape-eq` and `shapes-eq` (15 lines)
  retired. Comments about 40 lines across five sites. `tools/test/apply-word.sh`
  R2 inverted plus two rows, about 40 lines. One promotion of
  `bin/chirality-bin`, 1,261,944 to 1,270,136 bytes as measured. The build also
  runs `capture-fields.sh` and `apply-spine.sh`, whose fixtures this run did not
  measure under the split.
- **Related:** [[records/findings]] FD-18, PRB-76, `enforcement/N2` (E185),
  `enforcement/N3` (E186), `enforcement/N15`, `enforcement/N13`,
  [[banks/erasure]], [[decisions/decision-erased-word-level]].
