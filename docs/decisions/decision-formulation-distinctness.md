---
node: decision-formulation-distinctness
layer: decision
related: [arcs/independent-judgment-arc, goals/independent-judgment, decision-self-verification, decision-split-checker, decision-work-ids, decision-scope, banks/verification, banks/evidence-and-split, banks/profile, banks/runtime, records/tooling-classification, records/author-calls, open-edges, testing-floors, certificate-discipline, split-role, status-ledger]
status: draft
updated: 2026-09-04
---

# Decision: two judges are distinct when their formulations differ

⚑ **This is a proposal awaiting the author, and `status: draft` is load-bearing.**
Nothing here is settled. The tree has no distinctness criterion at all, and
[[arcs/independent-judgment-arc]] rows `independent-judgment/J1` as requirement 1
because requirement 2 cannot be judged without one. This note is the draft that
row was waiting for. §7 lists what only the author can decide.

## Why it is owed now

[[records/tooling-classification]] measured the tooling surface at 506 call
sites: 15 irreducible, 288 convertible under a stated independence discipline,
145 with a built composition and 58 needing one. TC-12 records why the 288 are
stuck. Every independence axis those conversions would use is already in the
tree; what is missing is the criterion that says which of them count. Until this
note or something like it is ratified, all 288 stay owed work and none of them
can honestly convert.

## 1. What independence is for

Two threats want a second opinion, and they are different threats.

| threat | what it is | who answers it |
|---|---|---|
| **shared encoding error** | the rule set is believed right, one encoding of it is wrong, and a second encoding built from the same reading repeats the mistake | this criterion |
| **an adversary who controls the source** | Thompson's attack. A compromised producer that reproduces itself, surviving a fixpoint check by construction | not this criterion |

**This criterion addresses the first and does not address the second.** The
distinction is already settled doctrine: [[decision-self-verification]] §0 moved
diverse double-compiling off the self-verification route and onto the deferred
ownership-and-trust track that [[decision-scope]] holds, and §5 item 5 states the
reason in one line, that trusting-trust is an adversary and not a correctness
bug. More self-proof does not touch it. Only toolchain diversity or a
human-readable seed does, and the tree has neither today.

⚑ **Say it plainly wherever this criterion is cited.** A pair of judges that
satisfies every rule below is evidence about a shared mistake and is worth
nothing against an adversary who wrote the source both judges are built from.

`lib/evidence/ddc.chiral:30` holds the criterion the tree has now:

```
(data Prov ()
  (prov (language Str) (toolchain Str) (author Str) (epoch I64)))
```

and `leg2-disjoint?` at `lib/evidence/ddc.chiral:68` demands that both the
language and the toolchain differ. That predicate is correct for Wheeler's
threat and wrong for this one, and the file says so itself at
`lib/evidence/ddc.chiral:207-213`: judgment cores are all chirality-native so
every quorum returns `ddc-bad-quorum`, `Prov` carries no formulation axis, and
`ddc-fold` compares bytes where different formulations agree on a verdict.
[[open-edges]] edge 21 carries the same three points and mints no element for
them.

## 2. The axes

Six candidates. For each: what it rules out, how it is checked, and whether it is
attestable or assertable only. The honesty grade follows the one
`lib/evidence/ddc.chiral:28-29` already sets, where `language` and `toolchain`
are attestable-ish and `author` is assertable only.

| axis | rules out | how checked | grade |
|---|---|---|---|
| **formulation** | one reading of the rule set encoded twice. The E166 case | declared. No mechanical test exists | **assertable only** |
| **import-closure disjointness** | a mutation in `lib/` reaching the judge through its own dependencies | walk the transitive `import` graph from the judge's root key and intersect it with the subject's defining modules | **attestable**, fully mechanical |
| **building binary** | the artifact under test compiling the judge that grades it | record which binary built the judge, and require it to predate the artifact | **attestable** within the tree, and it inherits the trust-on-first-use residue of the promoted binary |
| **profile and frozen port set** | a judge reaching a crossing it has no business reaching | the profile check computes the composite's used crossings and flags every one outside the frozen set ([[banks/profile]] Shard B) | **attestable** |
| **runtime** | a verdict that depends on how evaluation is staged | the profile that staged it ([[banks/runtime]] Shard C) | **attestable**, and subordinate under the conditional below |
| **language and toolchain** | a backdoored compiler | unchanged from `leg2-disjoint?` | attestable-ish, and it answers the deferred threat |

### formulation

The missing field. A formulation is **how the rule set is encoded**: the
decision procedure and the data it decides against. Two judges share a
formulation when one is derived from the other by anything short of a second
reading of the rules.

Nothing attests it. There is no check that distinguishes a genuine second reading
from one reading typed twice, and pretending otherwise would be the second
cardinal error this tree names, a gate that cannot fail. What the criterion can
do is bound the claim with two mechanical side conditions, which is the same
shape `leg2-disjoint?` already uses: `language` and `toolchain` are a proxy for
Wheeler's threat, checkable where the threat itself is not.

### import-closure disjointness

The axis that mechanically stops a mutation in `lib/` from reaching a judge.
It is already computed in bash: `tools/test/pretty.sh:552-573` walks a module's
transitive imports and gates G13 on the result, with M17 as the mutant that
falsifies it.

⚑ **Full disjointness is the wrong demand and it would admit nothing.** Every
judge in this tree imports `prelude/prelude`, so two closures always intersect.
The checkable property is **disjointness against the subject**: the judge's
closure contains no module that defines the behaviour under judgment.
[[records/tooling-classification]] establishes that this is a live distinction
and not a technicality, by enumerating every mutation target across the eighteen
gate scripts and finding that none of them is `lib/prelude/prelude.chiral`.

### building binary

The self-hosting form of the toolchain axis. `tools/test/mutant.sh:110-116`
already builds each mutant compiler with the promoted binary, so a judge
compiled ahead of the matrix is not built by the mutant it grades.

This axis inherits a residue it cannot discharge. The promoted binary is
trust-on-first-use ([[decision-self-verification]] §5 item 5), so pinning the
builder defends against a mutant reaching its own judge and defends against
nothing an adversary does.

### profile and frozen port set

A profile is a name, a manifest, a frozen port set and a target, and its validity
is a type-checking question ([[banks/profile]] §1). Staging a judge under a
minimal profile bounds what it can reach: a comparator that cannot write cannot
edit the file it compares.

⚑ **This is a containment axis and it is not a distinctness axis.**
[[split-role]] splits the role into containment, independence and verdict, and
states that the verdict rides on independence, because correlated agreement is
theater. Two judges under two profiles running one encoding agree by
construction. The profile makes a judge's reach checkable and says nothing about
whether its reasoning is a second opinion.

### runtime

There is no privileged runtime beneath everything, and two profiles over one
target stage two different runtimes ([[banks/runtime]] §1 and Shard C).
Core-minimal is one runtime among several.

**Subordinate, with one conditional.** A different runtime buys distinctness only
where the judgment's decision procedure actually runs on it, which is the case
for a conversion check re-run under a second evaluator. Where the verdict is
decided statically and the runtime only carries it, two runtimes are two
executions of one encoding. That is `lib/evidence/ddc.chiral:120-129` in its own
words: two runs of the same compiler agree with each other by construction.

## 3. The rule

**Formulation is the only axis that alone makes two judges distinct. Two
mechanical side conditions must hold beside it. The remaining axes are recorded
and never counted.**

A pair of judges over one subject is **distinct** when all three hold:

1. **Formulations differ.** Declared, with the two encodings named.
2. **Closure disjointness against the subject.** Neither judge's transitive
   import closure contains a module that defines the behaviour under judgment.
3. **Build independence.** Each judge was built by a binary promoted before the
   artifact under test existed.

`profile`, `port set`, `runtime`, `language`, `toolchain`, `author` and `epoch`
are recorded on every leg and contribute nothing to the verdict.

### Why the rule is one axis and not a count

`leg2-disjoint?` demands that two named axes both differ, and the obvious
generalization is a threshold: any k of n axes differ. **That shape admits E166
and is therefore worthless here.** The dropped C leg differed from the canonical
instance on language, on toolchain, on the building binary and on the runtime,
and it shared the two axes this rule turns on: it shared `compile-front` and
`compile-back` whole and differed only at emit. `docs/elements/catalog.md` E166 keeps the whole
record and the reason: one encoding emitted twice is a second target under one
formulation. Any threshold rule loose enough to admit a real second core would
have admitted the leg that was correctly dropped, so the axes are not peers and a
count over them is the wrong instrument.

### What the two side conditions add

A judge whose closure contains the module it judges can be moved by a mutation in
that module, whatever its encoding. A judge the artifact under test compiled can
be moved by the artifact under test. Both are mechanically checkable, both are
cheap, and both close a hole that a declared axis cannot see. Condition 1 is the
claim; conditions 2 and 3 are what stop the claim being the whole gate.

### The falsification obligation

[[testing-floors]] carries the run-the-mutant rule: a gate row must name a mutant
that falsifies it, and the mutant must be run. A distinctness check inherits it.
The mutant is a candidate pair that must be **refused**, and E166 is the standing
one: any implementation of this rule that admits a leg sharing a front end and
differing at emit has failed, and the pair is the fixture.

## 4. The candidates in the tree

Five cases, applied.

### `lib/lowering/tal/eval.chiral`, 187 lines, zero importers · **qualifies, over a narrower subject**

The reference tal interpreter, described at `lib/lowering/tal/eval.chiral:1-2` as
the Category-A oracle that defines what checked programs mean. Its register file
and byte store are explicit and threaded so evaluation is replayable by
construction, and a strictly decreasing fuel makes the meaning function total,
with out-of-fuel a constructor instead of a hang
(`lib/lowering/tal/eval.chiral:4-8`).

- **Formulation: differs.** It states the same claim operationally where the
  checker states it statically, and it names the cross-check itself at
  `lib/lowering/tal/eval.chiral:10-11`: no `ck-ok` program ever evaluates to
  `r-err`, which is progress and preservation stated as an execution.
- **Closure: disjoint against the subject.** Its imports are `prelude/prelude`
  and `lowering/tal/ssa` (`lib/lowering/tal/eval.chiral:19-20`), so its closure
  excludes `typing/`, `surface/`, `lowering/compile-*` and `lowering/tal/check`
  entirely.
- **Build independence: available and not yet exercised**, because nothing
  imports the module.

[[testing-floors]] already ranks it: an independent in-house reference is
rank 2, named there with `tal-eval` as the example. `records/tooling-classification`
TC-13 calls it the strongest formulation asset the tree owns and records that
the arc's own table omits it.

⚑ **It is a second formulation and it is not a second judgment core.** Its
subject is the tal floor and the pipeline's output, and requirement 2 asks for a
second core over the whole rule set. Both statements are true at once and
collapsing them would overclaim. What it qualifies as, today, is the judge for a
large share of the 288 sites in `records/tooling-classification` bucket 1b, which
is a smaller and real result.

⚑ **One shared object, named.** It shares `lowering/tal/ssa` with the tal
checker it would be compared against, deliberately, so that one value drives both
(`lib/lowering/tal/eval.chiral:15-18`). A shared data definition is the
comparable object rather than a shared formulation, and
[[decision-self-verification]] §6 makes the same move through E71's
spec-as-golden. A mistake **in that definition** is invisible to the pair, and §6
carries it as residue.

### `lib/typing/kernel-core.chiral`, 60 lines, zero importers · **does not qualify**

`recheck` re-runs the existing judgment. The module's own header says it at
`lib/typing/kernel-core.chiral:9-13`: the elaborated term is the derivation, so
the typing half is the existing infer and check on the certificate's term, and
there is no new judgment logic in the file. Its imports are `typing/kernel` and
`typing/diag` (`lib/typing/kernel-core.chiral:23-24`), so it fails condition 2
against the typing modules it would judge.

**That is a statement about the criterion and not a criticism of the module.**
`kernel-core` was built as the certificate seam (E52), and a small trusted
re-checker over an untrusted producer is a complementary control that
[[certificate-discipline]] and [[decision-split-checker]] both own.
`independent-judgment/J2` wiring it stays worth doing. It is not
`independent-judgment/J3`.

### `lib/typing/reflect-floor.chiral`, 54 lines, zero importers · **does not qualify**

Its closure is `prelude/prelude` alone (`lib/typing/reflect-floor.chiral:17`),
which is the best closure position in the tree. It has no judgment to hold. The
file is a type-level linearity argument: a write-capable builder, a read-only
frozen judgment, and one linear consume that makes reconfiguration untypeable.
The succession seam it forwards to is four `declare` lines with no bodies
(`lib/typing/reflect-floor.chiral:50-54`), and `recheck` there is E52's.

A module that decides nothing cannot be a leg. Condition 1 has no subject to
apply to.

### `ddc-legc` and `ddc-legcc` · **cannot be re-grounded as judgment legs**

`ddc-legc` at `lib/evidence/ddc.chiral:162` and `ddc-legcc` at
`lib/evidence/ddc.chiral:183` have zero callers and zero assertions since the C
backend was dropped, and `lib/evidence/ddc.chiral:172-181` records that the two
are refused as a pair by `leg2-disjoint?` because they share `language "c"`.

Under this criterion neither is a candidate at all, and the reason is upstream of
disjointness. gcc and CompCert judge C. Neither holds an opinion about whether a
chirality term type-checks, which is the judgment wanting a second opinion
([[decision-self-verification]] §0).

`independent-judgment/J4` offers **retired or re-grounded**, and this criterion
answers half of it: they cannot be re-grounded as judgment legs. What they still
record is toolchain provenance against the deferred threat, which the criterion
keeps in `Prov` and does not evict. The remaining half is a judgment call and §7
carries it.

### The E166 trap · **refused, as required**

A leg sharing a front end and differing only at emit fails condition 1, because
one formulation emitted twice is one formulation, and fails condition 2, because
its closure contains the whole shared front end. Any proposal that admits it is
wrong by the arc's own record, and this one refuses it on two independent
grounds.

## 5. What changes in `lib/evidence/ddc.chiral`

Described, with no code written here. Implementing it is a separate change and
[[open-edges]] edge 21 mints no element for it.

**`Prov` gains three fields and keeps its four.**

| field | why | grade |
|---|---|---|
| `formulation` | the axis the threat needs. A declared name for the rule encoding | assertable only, beside `author` |
| the judge's closure | so condition 2 is a function of the record instead of a separate walk | attestable |
| the building binary's identity | so condition 3 is a function of the record | attestable |

⚑ **The uncomfortable part, stated rather than smoothed.** The one axis the
threat actually needs is the one axis nothing can attest. `Prov` would then carry
a second assertable field beside `author`, and the two mechanical conditions are
what keep the criterion from being a label.

**`leg2-disjoint?` is replaced, and its type changes.** Today it is
`(-> Leg Leg Bool)`, a property of a pair alone. Conditions 2 and 3 are both
relative to the **subject**: a closure is disjoint *against something*, and a
builder predates *something*. Independence relative to a subject is not a
property of a pair, so the replacement predicate takes an argument the current
one has no way to receive. That is the sharpest structural consequence of this
criterion and it is the part most likely to be missed by reading the axes alone.

**`ddc-fold` moves from bytes to verdicts.** Recommended, and the change is
large. The fold at `lib/evidence/ddc.chiral:97` compares `Bytes` through `bytes=?` at
`lib/evidence/ddc.chiral:54`. Different formulations of one judgment agree on a
verdict and their byte-level outputs have no reason to match, so the fold's
element becomes a verdict value and the equality becomes verdict equality.

Two constraints on that move:

- **`bytes=?` must survive.** `lib/evidence/test-floor.chiral:31` imports the
  file for it and is the only live consumer of anything in it.
- **Agreement on a verdict is one bit per run**, which is the canonicality
  problem [[decision-split-checker]] names. [[decision-self-verification]] §4
  item 3 sharpens it: where formulations are extensionally equivalent by
  construction, agreement is worth close to nothing, and the value of a second
  formulation shows up as a failed adequacy proof instead of as a differing
  verdict.

What transfers unchanged: verdicts as values, a divergence naming which two legs
disagreed, and the quorum gate firing before any byte is read.

## 6. The residue

Category C in [[banks/evidence-and-split]] is cross-checked truth where proof
runs out, and that bank's own preamble states the hazard this section exists to
avoid: if the density reads as shipped machinery it has failed. The ladder there
puts copies-compared at T1 and records that the differential-testing net is the
T1 that is real today. A formulation quorum is a T1 instrument with a declared
axis. Calling it more is the failure.

What the criterion cannot distinguish:

- **Two formulations from one reading.** Nothing attests that two encodings are
  genuinely different readings of the rules. Conditions 2 and 3 bound the claim
  and do not establish it.
- **A shared author.** [[testing-floors]] rank 2 already concedes correlated
  blind spots for an in-house reference. [[decision-self-verification]] §4 cites
  Knight and Leveson (1986), who built 27 independently written versions from one
  specification and measured coincident failures far above what the independence
  assumption predicts. Independent authorship is unavailable in this tree at all,
  so the position here is strictly weaker than the experiment that found the
  assumption false.
- **A wrong specification.** If the rule set is wrong, every leg agrees and every
  leg is wrong. The shared IR definition is the concrete instance: a mistake in
  `lowering/tal/ssa` is invisible to the interpreter-against-checker pair that
  shares it.
- **The demanded statement.** `SpecRule` at `lib/typing/kernel-core.chiral:28`
  holds its statement as a `Str`, so the thing every leg would be judged against
  is prose. [[certificate-discipline]] names that as the one vacuity a
  certificate cannot absorb, and the arc rows it separately as requirement 5.
  A quorum over a prose statement is a quorum about an unread object.
- **The adversary.** By construction, per §1.

What stays assertable: `formulation` and `author`.

What this note does not decide: **N**. [[decision-self-verification]] §0 leaves
the number of cores unchosen and this note does not choose it. The criterion says
what makes a **pair** distinct.

## 7. What the author is asked to settle

1. **Ratify or reject the rule in §3**, which is the whole of
   `independent-judgment/J1`.
2. **`independent-judgment/J4`'s remaining half.** The criterion says the two C
   legs cannot be re-grounded as judgment legs. Whether the constants are retired
   or kept as the dated record of a leg that ran, the way E166's catalog row is
   kept, is a call this note does not make.
3. **Whether `ddc-fold` is generalized or forked.** Generalizing it over a
   comparable type honours the one-owner-per-rule rule the file states at
   `lib/evidence/ddc.chiral:110-112`. Forking it keeps the byte fold intact for
   the trusting-trust use it was written for. Both keep `bytes=?`.
4. **Whether the closure and the builder live in `Prov`** or stay a gate row
   outside the pure core, where `tools/test/pretty.sh:552-573` already runs the
   closure walk.
5. **A reserved element block for this arc.** Ratifying §3 does not by itself let
   the repoint be scheduled: [[arcs/independent-judgment-arc]] has no block, so
   nothing there can be minted, and [[records/author-calls]] already carries that
   as a standing call across nine arcs.
