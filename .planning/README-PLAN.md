# README rewrite: working state

**Opened 2026-08-31. Absorbed `README-PLAN.md` on 2026-09-01.** This file holds
the settled decisions and the drafts verbatim so they survive a context reset.
It is the single working file for the README; `README-PLAN.md` is gone.

## Where this stands

The 2026-09-01 session did not know this file existed and edited `README.md`
twice. Both commits are in `master`.

| commit | what it did | keep? |
|---|---|---|
| `8912c09` | re-measured every number; five were wrong | **the measurements, yes.** They belong in section 4, not in a Status section |
| `871fd05` | restructured the README as a front door | **no.** Written blind to this file and it contradicts four settled decisions below |

`871fd05` against the Framing decisions:

- kept the `common-sense, the language` tagline, which is **cut**
- opened on zero trust, which is **rejected as the thesis**
- kept a Status section of numbers, which is **rejected**
- used its own section order rather than the author's four-part structure
- its "The idea" section mirrors PRINCIPLES, which the first framing decision
  forbids

**Recommendation: revert `871fd05`**, keep `8912c09`'s measurements, and build
from the structure below. The revert is not yet done and is the author's call.

⚑ The tagline was cut from `README.md` on 2026-09-01 as a standalone edit. A
revert of `871fd05` must not resurrect it: it was in the file before that commit
too.

## Structure, set by the author

```
TITLE
QUESTIONS PEOPLE MIGHT HAVE
CONCISE TACKLING OF EACH SOLVE WE WANT TO IMPLEMENT
EXPAND TO MORE DIVERSE CLAIMS WITH STATE TRUTHS AND LIMITS STATED WITH PROPOSALS
```

## Framing decisions

- **The README is the pitch.** "This is the problem, this is how we're actually
  solving it." PRINCIPLES is the argument and is deliberately vague. Do not
  mirror PRINCIPLES.
- **tal is core as a given, not as a focus.** Rejected a draft that made
  "everything lowers to typed tal" the headline.
- **Zero trust is not the thesis.** Rejected.
- **"common-sense, the language" tagline is cut.** Says nothing.
- **Questions come from the wanting side.** A question the reader asks because
  they want the answer. Not defensive, not "why another language".
- **Status section as it stands is rejected.** It reports numbers instead of
  saying what holds.
- **Tone.** Short and plain. No em-dashes. No "X, not Y" antithesis templates.
  See the `writing-style-terse` memory. Tables and short lists over paragraphs.

## The grounding chain, found 2026-09-01

**The README is a cited source of authority, and the rewrite has to preserve
that.** `docs/goals/README.md` states the rule: "Adding a goal means citing where
the project already claims it." Six of the seven goal files discharge it by
citing README line numbers.

    goals/self-hosting.md          README.md:44-46, :79-81
    goals/self-tooling.md          README.md:48-50, :79-81
    goals/ownership-and-trust.md   README.md:77-84
    goals/enforcement.md           README.md:60-75
    goals/independent-judgment.md  README.md:71-75
    goals/presentability.md        README.md:60, :63

All nine are broken today. `8912c09` shifted them and `871fd05` moved the
sections out from under them.

**Consequence for the rewrite: a section other documents cite needs a stable
heading anchor.** Line numbers cannot carry this. Every goal citation gets
repointed to `README.md#anchor`, and whatever a goal quotes has to actually be
stated in the README in the words the goal quotes.

Second break in the same chain, older and not from this session. Five goal files
quote `CLAUDE.md` verbatim:

- `goals/self-tooling.md`: "tools/ holds 9 Python tools carried as-is"
- `goals/independent-judgment.md`: "External judgment is cut ..."
- `goals/presentability.md`: "Report failures with their output ..."
- plus `goals/README.md` and `goals/self-hosting.md`

`CLAUDE.md` was emptied to a pointer table and contains none of those strings.
The rules moved to `docs/definitions/working-discipline.md` and
`docs/decisions/decision-dispatch-cadence.md`. Each citation needs repointing to
the tracked home that now carries the rule.

Third break: `docs/definitions/thesis.md` is dated 2026-06-16 and says "The
seven principles are this idea applied seven times", then walks P1 through P7.
`PRINCIPLES.md` was condensed to five on 2026-07-20. The one document stating
the single idea under the language describes a principle set that no longer
exists.

## Thesis and goals: new instruction, 2026-09-01

The author added scope this session, beyond what the four-part structure covers:
**"straighten up thesis and goals in the broadest sense of the language."**

The questions half of that instruction is already settled below, seven of them.
The thesis and goals half is new and unstarted. What exists to build on:

- `docs/definitions/thesis.md`, stale as above. One idea: *a gap is an ungoverned
  path.* Anything a program can do that the framework cannot name is ungoverned,
  so the only way to control everything is to be able to express everything.
- Seven goal files under `docs/goals/`, each with a state:

| goal | state |
|---|---|
| the language compiles and checks itself | held since 2026-08-05 |
| chirality writes its own tooling, no Python remains | in flight |
| the surface is convenient without escape hatches | in flight |
| what is built is gated | in flight |
| what this repo says about itself is true | in flight |
| judgment that does not rest on one formulation | stated, unbuilt, zero arcs |
| the ownership and trust model | deferred by decision |

Open: whether the goals appear in the README as their own section, or whether
section 4 (claims with state, limit, proposal) already is the goals section
under another name. The two lists overlap and have not been reconciled.

Open: whether the thesis is stated in the README in full or as one line plus a
link. The note needs the five-principle repoint either way.

## The seven questions, final wording

1. **What bugs could a programming language inherently remove? Could debugging a
   program be made purely about logical bug solving?**
2. **Why does one working stack need half a dozen languages that share nothing?**
3. **Could escape hatches like `unsafe`, `any` and raw casts be made into checked
   routes?**
4. **Does a language with strong opinions have to fight you?**
5. **Why is it so hard to see what a program can actually do?**
6. **What is the smallest thing you would have to trust to trust the whole
   language?**
7. **Does proof have to be costly? Does proof have to be slow?**

Q1 and Q7 are pairs. Seven items total.

### Rejected question wordings, so they are not re-proposed

- "Why another language when strong type systems already exist?" Defensive.
- "What failures does this remove that others do not?" Comparison bait.
- "Can a guarantee survive all the way down to machine code?" Vague about coding.
- "If your code type-checks, what makes the machine code do the same thing?" Too
  specific.
- "What does writing it look like?" Tutorial question, wrong perspective.
- "How much of it runs today?" Wrong perspective, and state belongs in section 4.
- "Why are so many kinds of data handled in mysteriously manipulatable ways?"
  Replaced. Nothing built backs it (`.manifest` is E163, unbuilt).
- "Can an entire universally functional language be manageably auditable top to
  bottom?" Overclaims. The tree is 50,163 LOC. Reframed to Q6.
- "Can you 'guarantee' a boundary without it being painful to write?" Replaced
  by Q4.
- "Why does every layer of the stack need a different language?" and "Can you
  change a language's core without forking it?" Both rejected for Q7.

Proposed again on 2026-09-01 by a session that had not read this file, and
rejected again on the same grounds recorded above: "Why another language?",
"What does zero trust buy me over a strong type system?", "Is everything
ceremony?", "How is this different from Rust, Idris, ATS, Austral?", "Is it
usable today?". Defensive, comparison bait, or state that belongs in section 4.

Three from that batch are **not** covered by the seven and stay open as
candidates: "What happens when I have to do something the type system cannot
prove?", "What is the runtime, and where does allocation happen?", "What is a
port, and why is that the unit?". The third overlaps Q5 heavily.

## Section 3 drafts

### The shape of an answer, settled 2026-09-01

Each of the seven is a **loaded question**. It carries a premise the reader
already believes, earned from other languages: opinionated means painful, proof
is slow, you cannot see what a program does. The question is a belief being held
up, and an answer that opens on mechanism skips the belief.

So an answer opens by **taking a position on the premise**, and the position is
categorical. The interesting claim is rarely that chirality made a known pain
smaller. It is that the pain has a specific cause, chirality does not do that
thing, and the tradeoff the reader is bracing for is not the one they get.

    Q7  proof feels slow because you picture it running. It runs at compile
        time and is erased before emission, so there is no runtime proof object
        to pay for. A different category, not an optimisation.
    Q4  the fight comes from a denylist. There is no denylist here, so the
        argument that produces the fight never starts.

An earlier pass read the same defect as phrasing and proposed new opening
sentences for four of the drafts. The imperative was a symptom: the sentence
reached for an instruction because it had no position to open with and no table
to put the state in.

The hedge is load bearing. "Not usually" rather than "no" is what lets the state
table underneath read as part of the answer instead of a walk-back.

Three parts, in order:

1. **The position**, one or two sentences, naming what causes the pain elsewhere
   and why this is not that category.
2. **The reasoning**, the design goal and why this shape was chosen.
3. **The state table**: what is built, where it lives, and its honest limit.

Open: the categorical move may not be available for all seven. Q7 and Q4 have it
cleanly. Q6 (the smallest thing you would have to trust) carries no premise to
overturn; it is a real question with a number for an answer, and Q2 may be the
same. If the questions split into "dismantles an assumption" and "just answers",
the shape is not uniform and that is worth stating rather than forcing.

### The standing drafts, verbatim

**Q1. What bugs could a programming language inherently remove? Could debugging a
program be made purely about logical bug solving?**

> Some of them, and the set is open. A failure you can name as a class is a
> failure a checker can refuse, and because the language can express its own
> checker the list is worked rather than given.
>
> | category | what refuses today | how far it goes |
> |---|---|---|
> | memory and ownership | a linear binder used twice or dropped, a linear field | quantities carry it. There is no null in the language to dereference. Buffer bounds refuse nothing, and `str-sub` reads past its own buffer |
> | data at boundaries | non-exhaustive and duplicate branches, an empty case, a datatype with a negative recursive occurrence, an unproved refinement | nine judgments. Refinement is `I64` only. Integer overflow and division by zero have none |
> | effects and authority | a crossing outside the declared profile port set, refused at emit | `compile-emit.chiral:300`. A `->` body that calls an `=>` one has no judgment at all, which is E171 |
> | resources and termination | nothing | no termination judgment exists. The classifier is written and nothing imports it |
> | compilation fidelity | nothing on the shipping path | the typed-assembly floor checker exists and the compile never calls it |
> | concurrency | nothing | nothing in the tree points at it |
>
> Three of the six refuse something today and three refuse nothing. The
> vocabulary is 37 named judgments in `lib/typing/diag.chiral`, and what it does
> not contain is the more useful half of the answer.
>
> The residue is whether your specification says what you meant. Intent stays
> outside the checker. That is the logical bug.

⚑ Two earlier drafts were rejected. The first enumerated mechanisms with no
argument. The second used "mechanical rather than a research problem", which is
the banned antithesis template. Third draft above.

Q2 through Q7 below are the standing drafts.

**Q2. Why does one working stack need half a dozen languages that share nothing?**

> Chirality wants to be one language covering the compiler, the checker, the emitter,
> the runtime, the tooling and the data.
>
> | layer | written in chirality as | state |
> |---|---|---|
> | the compiler | `prog/compiler.prog` over `lib/lowering/` | self-hosting since 2026-08-05, byte-identical fixpoint at generation one |
> | the checker | `lib/typing/`, 3,227 lines | on the path of every compile |
> | the emitter | `lib/lowering/x64/emit.chiral` | emits the shipped ELF |
> | the runtime | `lib/runtime/`, 3 modules, 379 lines | |
> | the tooling | `prose-lint`, `paren-audit`, `resolve`, `test-runner`, `wield` | 9 Python tools left, the target is zero |
> | config and data | `.manifest`, 2 files in the tree | resolves as an import target. The loader does not check the declared-data property that makes it data, which is E163 |
> | a frozen port set | declared inline, `(profile name (ports ...) (target t))` | refuses at emit, `compile-emit.chiral:300`, gated by `tools/test/profile-target.sh`. The `.profile` extension `MAP.md` names has zero files in the tree |
>
> File extension and types are kinda in the figuring stuff out process, but the
> goal is that we have file types that *are* parsed differently. The bit here is
> that they aren't different languages.

> End game requirements are like this:
> - A manifest can be written and turned into actual code + vice versa
> - A .manifest is view of the code that is very similar as a language,
>   but structured in a way friendlier to it's purpose as a view.
> - Applying this logic to .protocol, .grammar, and more.

**Q3. Could escape hatches like `unsafe`, `any` and raw casts be made into checked routes?**

> Declare the dangerous thing as a crossing with a type. A port registry mints
> the capability, the crossing is named, and a program that calls a crossing its
> profile froze out is refused at emit. Nothing gets an exemption from the type,
> so there is no hatch to reach for.

**Q4. Does a language with strong opinions have to fight you?**

> Not really. What makes an opinionated language hard is the amount you have to
> hold in your head. Strong typing already exists to mechanically exclude
> categories of failure, but they effectively leave all of typing to you every time.
> Chirality's bit is that if you can express anything, you can express the checker
> too. Error handling can be a fixed feature of the language and becomes something
> you extend, one bug class at a time, until the primitives cover it. (and this is the
> end goal)
>
> `paren-audit` is the small version, 244 lines of chirality. Break a paren and
> it names the form, the line it opens on, and the delta. Easy enough for the next
> step is a tool that repairs the file in place, and at that point unbalanced parens
> stop being something you consider at all. That is the method: name the class,
> build the primitive, stop paying attention to it.
>
> | what | state | where | limit |
> |---|---|---|---|
> | usage on binders | enforced, gated | `lib/typing/qtt.chiral`, Phase 6 | |
> | refinement types | enforced, gated | `lib/typing/refine.chiral` | `I64` only, `jg-refine-i64` |
> | totality as the default | written, unreached | `lib/typing/totality.chiral` | zero importers, no termination judgment in `diag.chiral` |
> | `->` against `=>` | carried, refused nowhere | `lib/typing/effects.chiral` | E171 |
> | `paren-audit` diagnosis | built, runs | `prog/paren-audit.prog` | reports a count, not a position |
> | `paren-audit` repair | not built | | needs P1 spans and P4 addresses, both unassigned in `docs/arcs/text-tools-arc.md` |
>
> Where the checker is wired the load is off you. Where it is not, the shape is
> light because nothing is weighing it.

**Q5. Why is it so hard to see what a program can actually do?**

> Enumerating what a program outputs is undecidable. Enumerating how it can reach
> outside itself is finite. Those crossings are closed and named, so a module's
> reach is the set of boundaries it declares. Time and memory are crossings too,
> which is how a regex that pins a core stops reading as harmless.

**Q6. What is the smallest thing you would have to trust to trust the whole language?**

> A judgement core small enough to read in a sitting. It is 1,823 lines.
> Everything above it is text that core checked, and the surface language is
> elaborated down into a small calculus before checking, so convenience syntax
> has nothing left to smuggle.

⚑ "Read in a sitting" for 1,823 lines of dependently typed code is optimistic.
Flagged, unresolved.

**Q7. Does proof have to be costly? Does proof have to be slow?**

> Proof runs at compile time. Quantity-0 binders are erased before runtime, and
> types are erased before emission, so the checking does not ride along. Measured
> against C on three micro-kernels: 2 to 6 times faster than `gcc -O0`, 1.37 to
> 8.4 times behind `gcc -O2`.

⚑ This answer leans on erasure as a virtue while section 4 has to admit the same
erasure is why the tal preserve check never runs. Unresolved.

## Section 4 draft: claims with state, limit, proposal

| claim | state today | limit | proposal |
|---|---|---|---|
| Everything lowers to typed assembly | eligible defs lower to typed SSA in every compile | types erased before emit, preserve check never called, effectful and dependent code stays upper, fraction unmeasured | measure the ratio, build E70, wire `ck-fn` |
| Every unit is a process with a type | pure/process bit carried through the front end | the three refusing rules have zero callers | E171 |
| Cost is in the type | QTT and refinement types run in the checker | `totality.chiral` has zero importers | wire E11, or drop termination from the claim |
| Crossings are named and closed | nine port registries, facade has 108 importers | timing, cache pressure and speculation have no port | name it open |
| Readable and self-hosting | self-hosts, fixpoint at gen3 | 14 Python files in tooling, kernel and runtime are design | E173, E148, E150 |
| Judgment frozen, rest re-checkable | `reflect-floor.chiral`, `kernel-core.chiral` written | zero importers | wire, or mark seeded |

## Measurements taken during this discussion

⚑ **Superseded in part.** The LOC figures below were taken with
`xargs wc -l | tail -1`, which reports only the last batch. The Wiring sweep at
the end of this file has the corrected numbers. The importer counts and the
file counts are unaffected and stand.


| thing | value | how |
|---|---|---|
| whole tree, `lib` + `prog` | 50,163 LOC | `find ... | xargs wc -l` |
| `lib/` only | 24,171 LOC | same |
| all of `lib/typing/` | 3,054 LOC | same |
| judgement core (`kernel` + `kernel-core` + `qtt` + `refine`) | 1,823 LOC | same |
| `ports/ports.chiral` importers | 108 | grep |
| `reflect-floor.chiral`, `kernel-core.chiral` importers | 0 | grep |
| `totality.chiral` importers | 0 | grep |
| capability modules | `lincoll`, `secret`, `session` | ls |
| port registries | 9 `.port` files | ls |
| `paren-audit` on a broken form | `def is-space 58 390 389 1`, then `FILE depth 1` | broke `is-space` in a copy of `prog/paren-audit.prog` and ran it |
| `paren-audit` write path | none, in either implementation | grep |

## The judgment vocabulary: ground truth for what refuses

`lib/typing/diag.chiral:97-110` defines 38 `Judg` constructors, and `:120-137`
defines 9 `Reason` evidence shapes. This is the real answer to "what does the
checker actually catch".

| group | count | examples |
|---|---|---|
| type and arity shape | 17 + `r-mismatch` | `jg-apply-nonfn`, `jg-tcon-arity`, `jg-type-as-value` |
| case coverage and constructor use | 10 | `jg-nonexhaustive`, `jg-empty-case`, `jg-dup-branch` |
| refinements, **I64 only** | 5 | `jg-refine-unproved`, `jg-refine-i64` |
| linearity and usage | 4 | `jg-linear-field`, `r-usage`, `r-linear`, `r-arrow` |
| strict positivity | 1 | `jg-not-positive` |
| scope and binding | 4 | `jg-var-range`, `jg-esc-binders`, `r-unbound`, `r-redeclared` |
| lowering skips | 1 | `r-skipped` |

**What has no judgment at all**, which is the important half:

- **Effects.** No effect judgment exists in the vocabulary. Independent
  confirmation of E171: the membrane is a type-level bit nothing can refuse on.
- **Termination.** None. Matches `totality.chiral` having no importers.
- **Buffer bounds.** None. Which is why `str-sub` reads past its buffer.
- **Integer overflow, division by zero.** None.
- **Data races, deadlock, TOCTOU.** None.
- **FFI signature agreement.** `jg-extern-nontype` checks an extern's type is a
  type. Nothing checks it matches the real ABI.

## The bug-class list, drafted 2026-08-31

Destined for `docs/definitions/bug-classes.md`. Counts as of this draft:
**7 refuse, 3 partial, 4 written and unreached, 3 design only, 12 not started.**

### Memory and ownership

| class | how it gets said | state |
|---|---|---|
| use-after-free, double-free | quantities on binders | refuses |
| null deref | sums with no null in the language | by construction |
| aliasing and shared mutation | linear binders, memory profiles | partial |
| buffer overread and overwrite | bounds on indexing | nothing. `str-sub` reads past its buffer today |
| uninitialized read | nothing yet | not started |
| stack exhaustion | nothing yet | not started |

### Effects and authority

| class | how it gets said | state |
|---|---|---|
| syscall outside the declared set | port registry plus emit gate | refuses |
| IO from something that reads as pure | `->` against `=>` | carried everywhere, refused nowhere |
| a dependency exceeding its grant | capability types, datasheet fencing | partial |
| secret leaving by the wrong exit | linear `Secret`, one guarded exit | type-checks, nothing runs it |
| ambient authority through globals or env | nothing yet | not started |

### Resources and termination

| class | how it gets said | state |
|---|---|---|
| non-termination, unbounded recursion | structural and measure classifier | written, imported by nothing |
| unbounded allocation | cost carried in the type | design only |
| handle and fd leaks | linear resources | partial |
| time or fuel budget exceeded | cost gradient | design only |

### Data at boundaries

| class | how it gets said | state |
|---|---|---|
| non-exhaustive branches | case coverage | refuses |
| unsound recursive data | strict positivity | refuses |
| out-of-range values | refinement types, `I64` only | refuses |
| unchecked parse results | declared crossing plus refinements | partial |
| integer overflow, division by zero | nothing yet | not started |
| FFI signature disagreement | extern declarations | declared, never checked against the real ABI |
| config drift | data declared in the file | not built, E163 |

### Compilation fidelity

| class | how it gets said | state |
|---|---|---|
| miscompilation | typed assembly, checked at instruction level | checker written, never invoked |
| type information discarded at codegen | keep the check before erasure | this is the gap |
| effectful and dependent code never lowering | E70 | not built |
| link and ABI mismatch | nothing yet | not started |
| non-reproducible build | fixpoint | verified at gen3 |

### Concurrency

| class | state |
|---|---|
| data races, deadlock, TOCTOU, memory ordering | not started, nothing in the tree points at it |

## Next: the bug-class doc

Author call: capture the long-road list of bug classes as its own document, and
have Q1 pull a few major categories from it. **Adding classes with no ledger
entry is expected and fine.** The ledger was never going to cover everything.

Proposed home: `docs/definitions/bug-classes.md`. Columns: class, how it gets
said, state, element if one is minted. A row with no element says so plainly
rather than citing a number that does not exist (deferral rule).

Six majors proposed for Q1, honest split as of 2026-08-31:

| category | state |
|---|---|
| memory and ownership | partly |
| effects and authority | no |
| resources and termination | no |
| data at boundaries | partly |
| compilation fidelity | no |
| concurrency | not started |

## Open, unresolved

- Q6's "read in a sitting" claim over 1,823 lines.
- Q7's erasure answer against section 4's erasure limit.
- Whether section 4 lives in the README in full or links out for proposals.
- Whether the tal floor should get a question, since none of the seven reaches it
  now.

Added 2026-09-01:

- **Revert `871fd05`?** The rewrite contradicts four framing decisions. Author's
  call, and everything else here waits on it.
- **Do the goal citations repoint to README anchors, or does the README come out
  of the grounding chain** and the goals cite `PRINCIPLES.md` and the docs tier
  instead? The second is less coupling and makes the README free to change.
- **The five dead `CLAUDE.md` quotes**: restore that text somewhere tracked, or
  repoint each goal to the home that now carries the rule?
- **Does the goals table live in the README**, or does section 4 already cover it?
- **Thesis in the README in full, or one line plus a link?**
- **Does an answer's state table cover one thing or two?** Q4's has four typing
  rows answering what the checker demands of you, and two paren-audit rows
  answering how far the extension claim reaches.
- **`docs/definitions/bug-classes.md` does not exist.** Q1's table cites the
  judgment vocabulary directly instead, so it does not depend on the doc. The
  doc is still owed: the six-category split and the class rows in this file are
  its content, and the deferral rule says a README pointing at it before it
  lands is naming something that is not there.

## Wiring sweep, 2026-09-01

Corrected measurements. Earlier numbers in this file used `xargs wc -l | tail -1`,
which reports only the last batch when xargs splits. **Whole tree is 57,169 LOC,
not 50,163.** `lib/` is 25,222 across 103 files.

### lib/ by subsystem

| subsystem | files | LOC |
|---|---|---|
| `lowering/` tal, x86-64, ELF | 34 | 10,619 |
| `protocol/` json, http | 11 | 3,729 |
| `typing/` | 12 | 3,289 |
| `surface/` reader, elaborator | 6 | 2,586 |
| `module/` loader, resolver | 5 | 1,350 |
| `evidence/` test harness | 4 | 1,348 |
| `prelude/` | 9 | 1,112 |
| `runtime/` | 3 | 379 |
| `ports/` 9 registries plus facade | 10 | 365 |
| `memory/` | 6 | 229 |
| `capability/` | 3 | 216 |

Judgement core (`kernel`, `kernel-core`, `qtt`, `refine`): **1,823 LOC**, 7% of
`lib/`, 3% of the tree. `ports/` is 365 LOC with 108 importers.

### Zero-importer modules: 19 files, 2,137 LOC, 8.5% of lib/

Verified two ways. No `(import "<key>")` anywhere in `lib` or `prog`, and no
mention of the full module key anywhere in `lib`, `prog` or `tools`.

| subsystem | unreached | of | modules |
|---|---|---|---|
| `memory/` | 151 | 229 | `mem-linear` 32, `mem-region` 75, `arena` 44 |
| `typing/` | 592 | 3,289 | `totality` 387, `kernel-core` 60, `reflect-floor` 54, `pretty` 51, `ty-cmp` 40 |
| `lowering/` | 703 | 10,619 | `upper/optimize` 254, `tal/eval` 187, `listing/mach` 136, `tal/spec` 126 |
| `module/` | 185 | 1,350 | `sig-derive` 108, `sig-driver` 77 |
| `evidence/` | 137 | 1,348 | `interp` 109, `harness` 28 |
| `protocol/` | 258 | 3,729 | `render-doc` 258 |
| `surface/` | 65 | 2,586 | `terms` 65 |
| `prelude/` | 46 | 1,112 | `set` 46 |

### What this sharpens

- **The tal verification apparatus is unreached as a whole.** `check.chiral` is
  imported, but `eff-lower` takes only its types and `optimize` is the only
  caller of `ck-fn`. `optimize` has zero importers. `tal/eval` (the reference
  interpreter) and `tal/spec` also have zero importers.
- **Memory discipline has no reached implementation.** `mem-linear`,
  `mem-region` and `arena` are all unreached. The `(memory linear)` profile
  clause parses and is gated on its parse.
- **`sig-driver` is the only importer of `eff-lower`, and `sig-driver` itself has
  zero importers.** Correction to an earlier claim in this session that effect-row
  checking was wired through `sig-driver`. It reaches nothing. E12 and E171 are
  further from wired than stated earlier.
