---
row: crypto-primitives/K1
arc: crypto-primitives
title: translate Keccak-f[b]: the family at `b = 25w`, `R = 12 + 2l`, its five steps, and what each carrier reaches. Everything below rests on it
kind: law
origin: new
req: 1, 2
status: draft
updated: 2026-09-23
---

# crypto-primitives/K1: translate Keccak-f[b]: the family at `b = 25w`, `R = 12 + 2l`, its five steps, and what each carrier reaches. Everything below rests on it

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** one artifact under `docs/translations/` renders the Keccak
  permutation family into this tree's nine sections, with every quote resolving
  into a pinned source, so that the module row `crypto-primitives/K2` builds
  against a written object instead of against a summary of one.
- **Serves:** requirement 1 of [[arcs/crypto-primitives-arc]], "**Every primitive
  here is a translation before it is a module.** Its artifact sits in
  `docs/translations/`, `tools/xlat/xlat.sh check` exits 0 on it, and
  `pipeline-audit` at TRANSLATE level passes." And requirement 2, "**The
  permutation is a family parameterized only where the mathematics is, and a
  target below its floor fails to construct.**" K1 supplies the second
  requirement's premise: which parameters the published family actually carries.
- **Goal:** [[goals/own-web]], condition 4.

The row is `kind: law` and `origin: new`. Both come from the roster cell at
`docs/arcs/crypto-primitives-arc.md:124`, which also fixes `req` at 1 and 2.

**This row was dispatched into `element-design` by an author ruling.** The arc's
own dispatch note at `docs/arcs/crypto-primitives-arc.md:184-190` routes the six
translation rows into the `translate` skill and states that dispatching one here
"would produce a design for an object nobody has read". That objection is
discharged for K1 and for no other translation row: [[records/findings]] FD-13
read the object against three pins on 2026-09-07, so the object is read and the
design that follows is the scoping decision the `translate` run would otherwise
take silently.

## 2. What the tree holds

Measured 2026-09-07 against the working tree at `f220328`.

**Bank: none names this concept, and none is owed for it.** [[banks/INDEX]]
carries thirteen banks and no crypto entry. A bank refracts one *chirality*
concept across the homes it is split into, and the Keccak permutation is a
published external object. `docs/translations/README.md:18` states the tier that
holds an external object and why it is separate: "A translation sits **upstream
of a roster row**." The bank obligation lands instead on the carriers this row
reports on, and four banks own those: [[banks/erasure]] for the erased index,
[[banks/memory]] for the `budget` and `access` dials, [[banks/verification]] for
the instrument tiering requirement 3 asks of the result, and [[banks/module]] for
the module key the built permutation will take. A bank for the permutation
machine itself is premature while the machine has no shard in the tree, since
[[banks/INDEX]] requires every build-state claim to be grounded in the
conformance map.

### The translation tier

| what exists | where | rung | reached by |
|---|---|---|---|
| the tier and its nine-section contract | `docs/translations/README.md:27-38` | IMPLEMENTED | check AL |
| one artifact, 141 lines, `status: draft` | `docs/translations/aead-chacha20-poly1305.md:5` | IMPLEMENTED and unaudited | check AL |
| its citations: **13**, all resolving, 0 moved, 0 unresolved | `tools/xlat/xlat.sh check`, run 2026-09-07 and re-run 2026-09-23 | measured | check AL |
| ⚑ **the 12 was a blind spot, not a count.** `xlat check` read one citation per line until 2026-09-23, and this file's thirteenth was a span hard-wrapped across two lines, which the old tool matched nothing on and skipped in silence. The re-wrap and the rebuilt checker are the same day's work | `tools/xlat/xlat.sh:224-354` | measured | check AL |
| the resolver: quote uniqueness, line agreement, nine stage headings | `tools/xlat/xlat.sh:229-274` | ENFORCED | `ledger-lint` check AL |
| the gate that makes running it mandatory | `tools/ledger-lint/ledger-lint.py:2303` | ENFORCED | the suite |
| the gate for a quotation outside the tier | `tools/ledger-lint/ledger-lint.py:2348` | ENFORCED | `xlat unpinned` |
| the gather manifest form: slot, source id, state, note | `.planning/sources/aead-chacha20-poly1305.gather` | IMPLEMENTED | `xlat gather`, `xlat bundle` |

**Six pins now sit in `.planning/sources/`**, three of them Keccak's. `FIPS202`
is 1,871 lines and `origin: transcribed`. `KECCAKSUM` is 481 lines and
`origin: raw`. `ASCONSPEC` is 219 lines and `origin: raw`. The arc's blocker at
`docs/arcs/crypto-primitives-arc.md:192-195` says K1 holds neither a manifest nor
pins. Half of that is now stale: the pins landed with FD-13. The manifest is
still absent, and `xlat bundle` needs it before it can run.

### The object, already read

[[records/findings]] FD-13 (`records/findings.md:156`) is the measurement this
design rests on. What it established, against the three pins:

| the claim | the pin | verdict |
|---|---|---|
| a round has five step mappings | FIPS202:15 "consists of a sequence of five transformations, which are called the step mappings" | holds |
| ρ is intra-lane rotation by a per-position offset | FIPS202:22 "is to rotate the bits of each lane by a length, called the offset, which depends on the fixed x and y coordinates of the lane" | holds. ⚑ ρ had no slot in `.planning/CRYPTO-MODEL.md` §4 when this was written and it has one at `:138` |
| π is `A[(x+3y) mod 5, x, z]` | FIPS202:23 | holds, and carries no row-count term |
| `R = 12 + 2l` where `2^l = w` | KECCAKSUM:171 "is given by $n = 12+2l$, where $2^l = w$. This gives 24 rounds for" | holds. Keccak-f[800] is 22 rounds |
| the S-box slot and the round-constant slot | KECCAKSUM:188, KECCAKSUM:191 | hold on both sides |

FD-13 also measured the model against itself, and the six defects it found are
repaired. ⚑ **This design read `.planning/CRYPTO-MODEL.md` §4 as a machine with
four slots whose §5 agreed with the pins and whose §4 did not.** The `T1` ruling
of 2026-09-07 rewrote that section, and `.planning/CRYPTO-MODEL.md:109-115` now
opens it with the ruling and records "An earlier draft presented one machine with
four slots, and `records/findings.md` `FD-13` measured six defects in it against
three pins". ρ holds its own row at `:138`, and `R = 12 + 2l` is the boundary
between the two levels at `:122-127` rather than a cell in an instance table.

### The word layer the permutation would sit on

| what exists | where | rung | reached by |
|---|---|---|---|
| a named-lane state record with no array, sixteen lanes | `lib/crypto/chacha.chiral:42-46` | ENFORCED | `qround`, `dround`, `st-add` |
| a rotate built from shift, shift, or, fixed at 32 bits | `lib/crypto/chacha.chiral:24-25` | ENFORCED | every quarter round |
| the closed `Op` sum, fifteen constructors and no rotate | `lib/prelude/prelude.chiral:36-39` | ENFORCED | the tal emitter, exhaustively |
| the round count as a runtime `I64` argument | `lib/crypto/chacha.chiral:76-80` | ENFORCED | `chacha-block` |
| the erased index idiom: a type index at quantity 0 with a runtime witness beside it | `lib/memory/mem-region.chiral:23-24` | ENFORCED | `region-open`, `mem-alloc` |
| the crypto gate, 403 lines of shell | `tools/test/crypto.sh`, dispatched at `tools/test/run-tests.sh:367` | ENFORCED | phase 31 |

**Three of those are measurements this row's artifact has to carry.** The only
rotate in the tree is 32-bit and masks with `M32`, so a width-generic rotate is
unwritten. The only permutation-shaped module in the tree carries its round count
as a runtime value rather than as any kind of index. And the erased index that
`lib/memory/mem-region.chiral` demonstrates carries a *bound*. A shape is what
it cannot carry: a `Region n` has the same three fields at every `n`.

### What is absent

No module under `lib/` names a permutation, a sponge, Keccak, SHA-3 or Ascon.
Measured by a tree-wide grep over `lib/`, `prog/` and `tools/test/` on
2026-09-07: one hit, in a fixture comment about argument order at
`tools/test/samples/e188_apply_spine.prog:31`. `docs/definitions/status-ledger.md`
carries no rung for a digest, and its one crypto line at `:37` is about the
unregistered gate phase.

## 3. The delta

Four things are missing, and one of them is a decision rather than a document.

**1. The gather manifest.** `.planning/sources/` holds one `.gather` file and it
is the AEAD's. `xlat bundle` reads the manifest and refuses without it, so the
`translate` run for this object cannot start. The manifest is four tab-separated
slots and the honest ones are named in §6.

**2. The artifact.** `docs/translations/` holds one file and it renders the
AEAD. Nine sections, each with the tier's own obligation: §6 has to state what
stays byte-identical or the artifact is a redesign under a translation's name.

**3. The scoping decision, which is what makes this a design run.** The roster
row says "Keccak-f[b]: the family". FIPS 202 defines two families at two levels,
and which one is the object decides §2, §4, §5 and §6 of the artifact. It also
decides whether requirement 2 is satisfiable. Requirement 2 asks that the module
carry "no parameter the published family lacks". A free round count is a
parameter Keccak-f lacks and Keccak-p carries, so the requirement's verdict flips
on a choice nobody has made. §4 weighs it.

**4. ⚑ The delta FD-13 opened against the model is closed, and this row no
longer carries it.** The design said `.planning/CRYPTO-MODEL.md` §4 was wrong in
three measured places, that its §5 was right, and that the correction belonged to
the row that builds the machine, `crypto-primitives/K2`. The `T1` ruling rewrote
§4 the same day at `.planning/CRYPTO-MODEL.md:107-215`, so K2 inherits no defect.
The obligation on the artifact survives the repair: five steps in order with ρ
named leaves K2 no room to carry four.

Two further holes are named here so the artifact records them as open. `.planning/CRYPTO-MODEL.md:522-525` records that a shift of 64 has
never been exercised in this tree, and KECCAKSUM:369 "The rotation offsets
<code>r[x,y]</code> are given in the table below." heads a table whose `x = 0,
y = 0` entry is 0, so ρ at `w = 64` computes a shift by the full width on its
first lane. FIPS202:23 "the offsets may be reduced modulo the lane size" settles the
narrower question of how the table travels down to `w = 32` and leaves the
full-width shift standing. And `.planning/CRYPTO-TRANSLATION.md:588` leaves open
whether Keccak-f[25] exists as a real module, which decides whether the
artifact's law section can promise an exhaustive check at the smallest member.

**Verdict:** a real delta. Nothing in the tree renders this object, and the
scoping decision in item 3 is unmade.

## 4. The shapes

The axis is what the translated object is. It is a real fork because FIPS 202
publishes two families and the roster row's own words name both halves.

### Shape A: the object is KECCAK-f[b], seven fixed permutations
- **Form:** §2 states `b = 25w` over the seven widths, the five steps, and
  `R = 12 + 2l` as a definition rather than as a parameter. There is no round
  count to carry. §6's invariant core is the published KAT for each `b`.
- **Costs:** the smallest §2 and the cleanest §6. Every reduced-round or
  round-count-varying mode falls outside the object and owes its own translation.
  `crypto-primitives/K19` is exactly such a mode: its roster line says "at the
  keyed round count", and `.planning/CRYPTO-TRANSLATION.md:604-606` records that
  Ascon's AEAD runs a different round count at initialization than between data
  blocks, so a machine carrying one round count cannot express it.
- **Forbids:** a `rounds` index on the module at all. Under requirement 2 the
  module could carry `w` and derive everything else, which is the strictest
  reading of the requirement and the one that makes FD-13's Keccak-f[800] finding
  structural rather than a table typo.

### Shape B: the object is KECCAK-p[b, nr], with KECCAK-f[b] as its instantiation
- **Form:** §2 states the generalization first, FIPS202:14 "The generalization of
  the KECCAK-f [b] permutations that is defined in this Standard by converting
  the number of rounds nr to an input parameter", with its domain at FIPS202:15
  "the permutation is defined for any b in {25, 50, 100, 200, 400, 800, 1600} and
  any positive integer nr", then the specialization at FIPS202:26 "KECCAK-f [b] =
  KECCAK-p[b, 12 + 2l]". Two levels, and the derivation is the boundary between
  them.
- **Costs:** one more layer in §2, and a §6 that has to say which level the
  published vectors pin. They pin `f`, so `p` at an arbitrary `nr` has no vector
  and the artifact must say so. §7 gains one law: that the module's derivation of
  the round count from `w` agrees with `12 + 2l` at all seven widths.
- **Forbids:** reading a free round index as a defect on its own. It also forbids
  a module that offers both levels as one type with no derivation between them,
  because §6 could then not name what the vectors cover.

### Shape C: the object is the permutation machine, Keccak and Ascon together
- **Form:** one artifact covering both instances, which is the shape
  `.planning/CRYPTO-MODEL.md:106-135` describes and the shape its own sentence
  "Two instances is the point" argues for.
- **Costs:** it breaks the tier's first rule, `docs/translations/README.md:11`
  "One file per published external object, rendered into this tree's forms." The
  gather manifest is per object and `xlat bundle` takes one object name. FD-13
  also measured that Ascon's standard could not be read in this sandbox, so half
  the artifact would rest on a designers' page while claiming to translate a
  standard.
- **Forbids:** an honest §6. Two objects have two vector sets, and one invariant
  core cannot say what stays byte-identical for both.

## 5. The call

- **Chosen:** **Shape B**, the object is KECCAK-p[b, nr] with KECCAK-f[b] named
  as its instantiation.

Three reasons, in order of weight. The roster row already asks for both halves,
naming "the family at `b = 25w`, `R = 12 + 2l`", and only Shape B makes both
sentences true at once. FIPS 202 publishes `p` as the family and derives `f` from
it, so Shape B translates the standard's own layering and Shape A translates a
slice of it. And requirement 2's phrase "no parameter the published family lacks"
is undecidable until the family is named: under Shape B the round count is
licensed at the `p` level and constrained at the `f` level by a derivation the
artifact states, which is a checkable claim, while under Shape A the same index
is a defect. FD-13's Keccak-f[800] finding survives Shape B unchanged: 22 rounds
is what `12 + 2l` gives. ⚑ The machine's instance table carried 24 at every
width when this was written, and `.planning/CRYPTO-MODEL.md:167` now carries 22
at Keccak-p[800, nr].

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Which family is the translated object | RESOLVED | Shape B, on the three reasons above and FIPS202:14 |
| 2 | Does a translation row mint an element | RESOLVED | No. `docs/elements/catalog.md:16` scopes the catalog to "Every element chirality needs its own implementation of", and `docs/translations/README.md:18` puts a translation upstream of the row that builds. §6 mints nothing and the artifact is the row's product |
| 3 | Does the concept owe a bank | RESOLVED | No. [[banks/INDEX]] refracts chirality concepts and this object is external. §2 names the four banks that own the carriers |
| 4 | Whether Ascon-p is a second instance, and so owes a second translation row | DEFERRED | `crypto-primitives/K2`. The question is `C2` at `.planning/CRYPTO-MODEL.md:508` and it does not change what Keccak is. K2 is the row that must show the module carries no parameter its families lack, and it is the row that discovers how many families there are |
| 5 | Repairing `.planning/CRYPTO-MODEL.md` §4's four slots, its `rows`-derived π, its θ-and-Σ pairing and its 24-round table | ⚑ **RESOLVED**, having been DEFERRED to `crypto-primitives/K2` | The `T1` ruling rewrote §4 on 2026-09-07 and `.planning/CRYPTO-MODEL.md:109-115` records the six FD-13 defects as the earlier draft's. ρ has a row at `:138`, π is `A[(x + 3y) mod 5, x, z]` at `:139` with no row-count term, Ascon's linear step sits at ρ's position at `:145-151`, and the instance table carries 22 at Keccak-p[800, nr] at `:167`. §3 item 4 carries the same correction |
| 6 | The fidelity target: faithful to the specification's algorithm, or to the mathematics the algorithm computes | ⚑ **RESOLVED**, having been NEEDS-AUTHOR and the blocker on this row | `T1` was ruled on 2026-09-07, twenty minutes after this design was written. `.planning/CRYPTO-TRANSLATION.md:582` reads "**RULED 2026-09-07: the mathematics, realized as separated primitives.** The five step mappings are each their own primitive with its own signature. The family is the layer above them, and any fusion is a composition there that owes a proof of equality". So §2 of the artifact carries the five steps in their published order, each as its own mapping with its own signature, and any fused step is a composition at the family layer owing a proof of equality. The ruling reads the fork as a factoring: "separated steps reproduce the published order for free, and they are what gives requirement 3's differential gate two representations to compare", which is why the two §4 carrier tables the question weighed collapse to one |
| 7 | Whether Keccak-f[25] is a real module or a test-only instance | DEFERRED | `crypto-primitives/K16`, the law gate row, which owns "run exhaustively at the smallest member of each family". The open decision is `T7` at `.planning/CRYPTO-TRANSLATION.md:588` |
| 8 | Whether a shift by the full width is defined, which ρ's zero offset reaches at `w = 64` | DEFERRED | `crypto-primitives/K2`. `.planning/CRYPTO-MODEL.md:522-525` already carries it as owed. The artifact's limits section names it as a hole rather than answering it |

⚑ **Question 6 set `status: blocked` and its ruling discharged it.** No question
here is NEEDS-AUTHOR, the frontmatter reads `draft`, and no row is owed in
[[records/author-calls]]. Questions 4, 7 and 8 stay deferred to the rows named
beside them.

## 6. The mint packet

- **Elements: none.** This row mints nothing, per question 2 above. Its product
  is `docs/translations/keccak-p.md` and its completion test is
  `tools/xlat/xlat.sh check` exiting 0 plus a TRANSLATE-level `pipeline-audit`
  PASS, which is requirement 1's observable verbatim. The element that builds the
  permutation belongs to `crypto-primitives/K2`, which is `unminted`, so it is
  named as a roster row here and not as an `E#`.
- **Band:** `UNASSIGNED`. The arc reserves none, per
  `docs/arcs/crypto-primitives-arc.md:14` and [[decisions/decision-lane-split]].
- **Catalog row:** none. A translation is a document under `docs/translations/`
  and the catalog holds implementations.
- **Ledger row:** none, for the same reason.
- **The gather manifest**, which is the first thing the `translate` run needs and
  the artifact `.planning/sources/keccak-p.gather` must hold. Four slots, tab
  separated, in the form `.planning/sources/aead-chacha20-poly1305.gather` uses:

  | slot | source | state | note |
  |---|---|---|---|
  | `construction` | `FIPS202` | run | FIPS 202, transcribed. One line per PDF page and every Greek letter absent, so §1 of the artifact carries the transcription caveat |
  | `steps` | `KECCAKSUM` | run | keccak.team specifications summary, raw. The pseudocode, the rotation offset table, and the round-count law |
  | `margin` | `-` | UNRUN | the round-count margin and the reduced-round cryptanalysis, which is what licenses `crypto-primitives/K19`'s keyed round count |
  | `vectors` | `-` | UNRUN | the published known-answer tests for Keccak-f[b], which §7 of the artifact must pin before any gate cites them |

  Two slots run and two UNRUN. `xlat gather` prints an UNRUN slot as a known hole
  and the audit fails an artifact that does not name it.

- **Size:** one manifest of 4 lines and one artifact of nine sections. The basis
  is the one comparable artifact in the tree: `docs/translations/aead-chacha20-poly1305.md`
  is 141 lines carrying 12 resolving citations over three pins. This object has
  three pins, one more open decision, and a step-by-step §2, so the estimate is
  the same order and no figure is claimed beyond it. No `lib/` or `prog/` file is
  touched by this row.
- **Related:** [[arcs/crypto-primitives-arc]], [[goals/own-web]],
  [[translations/README]], [[records/findings]], [[banks/erasure]],
  [[banks/memory]], [[banks/verification]], [[decisions/decision-design-before-mint]],
  [[definitions/working-discipline]].

Every `E#` named here is already minted. Where one is owed, this names a roster
row instead.
