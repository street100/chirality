# README rewrite: working state

**Opened 2026-08-31.** Discussion in progress, no edits made to `README.md` yet
beyond the earlier dead-reference pass (commit `8c76223`). This file holds the
settled decisions and the drafts verbatim so they survive a context reset.

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

## Section 3 drafts

**Q1. What bugs could a programming language inherently remove? Could debugging a
program be made purely about logical bug solving?**

> Everything can be expressed. That makes this a mechanical job. Every non-logic
> failure is a class, a class can be given a way to be said, and once it can be
> said the checker can refuse it. Work through the classes until what is left is
> you reasoning wrong.
>
> [six categories with state, table below]
>
> Full list and current state in `docs/definitions/bug-classes.md`.
>
> The residue is whether your specification says what you meant. Intent stays
> outside the checker. That is the logical bug.

⚑ Two earlier drafts were rejected. The first enumerated mechanisms with no
argument. The second used "mechanical rather than a research problem", which is
the banned antithesis template. Third draft above.

Q2 through Q7 below are the standing drafts.

**Q2. Why does one working stack need half a dozen languages that share nothing?**

> One language covers the compiler, the checker, the emitter, the runtime, the
> tooling and the data. The file extension carries the kind: `.chiral` is a
> module, `.prog` an entry point, `.port` a registry that mints capability types,
> `.profile` a frozen port set, `.manifest` data. Config stops being a second
> language.

**Q3. Could escape hatches like `unsafe`, `any` and raw casts be made into checked routes?**

> Declare the dangerous thing as a crossing with a type. A port registry mints
> the capability, the crossing is named, and a program that calls a crossing its
> profile froze out is refused at emit. Nothing gets an exemption from the type,
> so there is no hatch to reach for.

**Q4. Does a language with strong opinions have to fight you?**

> Make the well-behaved shape the low-ceremony one. Functions are total unless
> you annotate otherwise. An empty signature is the light base case, and every
> effect and every unit of fuel makes a type heavier. The risky shape is the one
> you opt into out loud.

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
