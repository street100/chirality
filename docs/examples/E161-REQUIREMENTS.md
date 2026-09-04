# E161 — the module datasheet: requirements

**2026-08-23, rescoped.** Supersedes the first draft. Read this before the
worked example; the example's own framing predates several of these decisions and
is being revised against this file.

---

## 1 · What it is, in one paragraph

A **datasheet** is a small fixed-schema record attached to a module, holding what
a consumer would otherwise have to derive by traversal. Almost every field is
filled in by the compiler from the module's actual contents. Exactly one field is
written by a human, because exactly one is not derivable. Reading it costs one
lookup; it cannot go stale, because the parts that could go stale are not writable.

**Name.** `certificate` is already this repo's word for the general mechanism —
untrusted producer, small trusted checker, re-run the derivation
(`certificate-discipline.md`). A datasheet is **a certificate with a fixed
schema**: same discipline, one category of statement, mostly derived rather than
proved. Keeping it under `certificate` keeps the relationship visible instead of
minting a parallel hierarchy.

The analogy that fixes the shape: a hardware datasheet. You read it *instead of*
characterizing the part, and it is worth reading only because it is guaranteed to
match the part.

---

## 2 · The frame that makes it obvious: error handling

This is the same move as errors-as-values, twice over.

| the old way | the good way | here |
|---|---|---|
| a comment saying "this can fail" | `Result` in the return type — the compiler carries it, you cannot forget it | "this module crosses" as a comment rots; as a derived field it cannot |
| a `case` with a catch-all arm | exhaustive case — a new variant breaks every consumer | adding a crossing def must change the record, with no path where it silently does not |

`pretty.chiral` already states the second one for itself: *"no `<k>` catch-all — a
new former with no arm is a compile error."* The datasheet is that rule applied
to a module's own description of itself.

---

## 3 · Why this is not self-characterization eating its own tail

The knot: we are building a self-description mechanism to fix the failures of
self-description. The cut:

> **Self-description rots when it is a SOURCE. It does not rot when it is a
> PROJECTION.**

A comment claiming "this module is pure" is an independent assertion — a second
source of truth, free to drift, and it did: `ports.chiral`'s *"the category C
boundary, declared in source"* went false the moment E161's predecessor moved the
declarations out, and nobody noticed for a day. A **derived** `crossings` field is
not a second source; it is the code, viewed. There is nothing for it to drift from.

**And this is a mechanism, not a rule.** "Never write what you can derive" is a
bad rule — a rule has to be held in mind, and vigilance either decays or
overcorrects. It is a good *mechanism*: the compiler fills the field, so the slot
does not accept input, so the question "may I write this?" stops existing. The
design does not ask for discipline about self-description; it **removes the
occasion for it**, leaving one slot for the one irreducible judgment.

---

## 4 · The split, and why it lands where it does

Every question a consumer asks is derivable **except one**:

```
which crossings does this reach?     derivable  (expensive: walk every def's type)
is THIS def pure or crossing?        derivable  (its arrow — (-> ) empty row, (=> ) not)
what does it export, and as what?    derivable  (expensive: scan def/data/extern/porttype)
what altitude is it written at?      derivable  (infer from tal-ir / TIFn use)
does it define an entry?             derivable
which linear porttypes does it mint? derivable
what does its correctness rest on?   NOT DERIVABLE -- a judgment
```

`axis-typeability`'s test is *"what does its correctness rest on: proof / an
admitted hole / cross-checked evidence about a hole."* No traversal answers that.

**So: one authored field (`cat`), everything else inferred.** That asymmetry is
not a compromise between two designs — it is the whole design, read off the facts.

### The fork, and the call

- **Inferred** (like `Result` falling out of a body): nothing to write, nothing to
  drift — and it tells you nothing you did not already have.
- **Declared and checked** (like `throws IOException`): you state intent, the
  compiler refuses if the body disagrees. Catches **a wrong belief** — *"I thought
  this was pure"* — which inference can never catch, because inference agrees with
  whatever the body does.

**DECIDED: declared-and-checked for `cat` only; everything else inferred.** `cat`
must be declared because it is not derivable, and it is checkable because
derivable facts fence it. Every additional declared field buys the wrong-belief
catch at the price of a new drift surface, and that trade is not worth taking by
default. Adding one later is a deliberate act, per field, with a reason.

⚑ This **retires E160's `(pure)`/`(crosses)` claim** as an authored field. It
becomes derived.

---

## 5 · The mechanism

What the author writes, whole:

```
(module backend (cat C))
```

What happens at load: the compiler walks the module's own defs — **it already
does exactly this**, in `kind-offender` / `kv-first-crossing` — fills the record,
and puts it in the `Sig` where anything can ask for it.

What a consumer gets back:

```
(module backend
  (cat C)                                          ; authored — the only one
  (declares backend-open)                          ; derived — see the sense note below
  (exports (be-url fn) (ok2xx fn) (be-chat proc)   ; derived — at def grain
           (Backend porttype) (ChatR data) ...))
```

**⚑ Corrected 2026-08-23 — the earlier draft of this block was wrong.** It listed
four crossings for `backend`. Measured: `backend` binds exactly **one** `=>`
extern, `backend-open` (`:36`); `be-base` (`:37`), `backend-close` (`:43`) and
`be-peek` (`:56`) are all `->`, and their own comments say so — *"Pure (`->`): no
syscall."* Also dropped `(alt upper)` from the sample: see the `alt` note in §6.

### Exactly two errors exist

Because the derived fields are **not writable**, no mismatch between record and
reality is representable. There is nothing to detect. That leaves:

1. **You wrote a derived field.** Not "wrong value" — the slot takes no input.
2. **Your letter contradicts the facts.** A module with crossings cannot be
   `(cat A)`. That is the fence.

One slot, one possible lie, one check.

### The failure that must be impossible

```
(def be-stream (=> Str Unit) (lam (s) (do (print s) unit)))   ; added; nothing else touched
```

The record must change on its own. No edit, no reminder, no review step — and no
path on which it silently does not.

---

## 6 · Requirements

### ⚑ R2a — "crossings" is THREE inequivalent senses. The schema must name which.

Found by the example revision, verified against the code, and it disagrees on the
very module used above:

| sense | on `backend` | who computes it today |
|---|---|---|
| (a) externs this module BINDS with `=>` | `{backend-open}` | trivial, module-local |
| (b) what a consumer transitively REACHES | — | **nothing computes this** |
| (c) crossings the OBJECT CODE calls | **{}** — none of `backend`'s externs is in `crossing-wraps` | `xw-code`, and this is what H8's profile gate uses |

(a) and (c) give different answers on the same module. Leaving the sense unnamed
is exactly the residual vacuity R7 forbids — a real derivation of a statement too
weak to use. **The schema must name its sense, or carry more than one under
distinct names.** My read, not a decision: a *datasheet describes a module*, so
(a) is the field that belongs; (c) describes an emitted program, not a module, and
already has its home in the profile gate. If a consumer needs "does importing this
put a crossing in my binary", that is (b), and nothing computes it yet.

```
R1  ONE record per module, fixed schema, small enough to read at a glance.
R2  It holds the authored judgment (cat) plus the derived record
    (alt, crossings, exports) at DEF GRAIN where that grain exists.
R3  Derived fields are FILLED BY THE COMPILER and are NOT WRITABLE. Writing one
    is an error in itself, not a value to be checked.
R4  The authored field is FENCED by derivable facts; a contradiction is a
    compile error. Not a lint, not a warning, not a review item.
R5  Reading the record costs ONE lookup. No traversal, no re-derivation.
R6  The record is REACHABLE BY CONSUMERS -- in the Sig, queryable. This is
    E160's actual defect: it computes these facts inside emit, truncates at the
    first crossing, and discards them. A check is not an API.
R7  TOTAL SCHEMA. No optional or "unspecified" field. One unknown field and a
    consumer must re-derive everything, which returns us to the status quo.
    (This is `certificate-discipline`'s residual-vacuity warning in this
    setting: a real derivation of a weak statement is worth nothing.)
R8  Adding, removing or retyping a def updates the record with no author action
    and no path to silent staleness.
R9  Optional adoption: a module with no record compiles exactly as today.
R10 Any filename / layout projection is a CONSUMER of the record — downstream,
    cosmetic, and never a gate on the record itself.
```

---

## 7 · Scored against what exists

| req | state |
|---|---|
| R1 one record, fixed position | **met** — E160's `(kind …)` |
| R2 authored judgment | **met** — the A/B/C letter |
| R2 derived record at def grain | **missing** — E160 holds one bit for a whole module |
| R3 derived fields not writable | **inverted** — today the author writes the claim |
| R4 authored field fenced | **partial** — the one bit is checked; `cat` is not fenced |
| R5 one lookup | **partial, not missing** (corrected) — `ModKind` is already a `Sig` field (`kernel.chiral:122-134`) with a public accessor `sig-kinds` (`:145`). What is absent is a lookup that RETURNS the record: the only one, `sig-kind-taken` (`loader.chiral:383`), returns `Bool` |
| R6 reachable by consumers | **partial, not missing** (corrected) — the *record* is reachable; the **crossings** are what get computed in emit, truncated at the first hit, and discarded. Also absent: `extern`/`porttype`/`data` are charged to nothing (`parse.chiral:1169-1171`) |
| R7 total schema | n/a — no schema yet |
| R8 no silent staleness | **partial** — holds for the one bit |
| R9 optional | **met** |
| R10 projection downstream | n/a — not built, correctly not blocking |

**The cut:** E160 built R1/R2-authored/R9 and a partial R4/R8 for a single
boolean. **E161 is R2-derived, R3, R5, R6, R7** — turning that boolean into a
compiler-filled, queryable, def-grain record, and retiring the authored claim.

---

## 8 · Killed by measurement — do not resurrect

- **"A module must be wholly pure or wholly crossing."** FALSE. `(crosses)` is
  existential in `kind-offender-go`; a mixed module compiles today (verified: two
  pure defs beside a crossing one, exit 42). This premise was mine, it reached the
  catalog row and the first pre-run brief, and the audit caught it.
- **A per-def `(pure)|(crosses)` declaration.** Phantom. A def's crossing is
  already carried by its arrow. Declaring it would be a second source of truth for
  a fact the type states — the exact disease.
- **The surface as an open question.** Settled: *"in-file identifiers to a fine
  grain with the file extension just being mostly cosmetic and an easy way to lay
  out file structure."* Not a design question. See R10.

## 9 · Still open — not mine to decide

Does the full record live in the **source file** (maximum legibility; the file
churns on every edit) or in the **Sig** (zero churn; the file shows a human less)?
R5 and R6 hold either way. The difference is whether the thing you read is the
file or the Sig.


---

## 10 · Corrections from the example revision (code beats this doc)

Surfaced by revising `E161-kind-identifier.md` against this file, each verified:

1. **`backend`'s crossings** — fixed in §5 above. One, not four.
2. **R5/R6 scoring** — fixed in §7 above. Partial, not missing.
3. **"Exactly two errors" overcounts by one, in the design's favour.** With a
   single authored slot, a derived field has no grammar production at all — so
   "you wrote a derived field" is the reader's EXISTING `(k-shape)` arm
   (`parse.chiral:1046,1057`), not new code. **Only the `cat` fence is new.**
4. **`alt` is silently retired and this doc did not notice.** §5's old sample
   marked `(alt upper)` derived while §4 says one authored field — but **nothing
   derives altitude today**, and the proposed "infer from tal-ir / TIFn use" reads
   the *import graph*, not the module. Either `alt` gets a real derivation or it
   leaves the schema. It must not sit in the sample unbacked. (Dropped from the
   sample; the decision is open.)
5. **R7 has a vacuity case already in the tree.** `ports.chiral` is a `C` module
   with **no def at all** — a 60-line façade whose own comment says a `(pure)`
   claim there would be *"true only vacuously, which is a worse lie than
   silence"*, and whose crossings *"live one import down."* A total schema forces
   it to carry empty fields. **Whether the record is transitive through imports
   decides whether `ports`'s datasheet says anything at all** — and that is R2a's
   sense (b), which nothing computes.
6. **Retiring the authored claim ORPHANS the emit gate.** `kind-offender`, all
   three `KvErr` arms, `kind-rows`, and `FR`'s `kinds` field exist only to check
   a claim E161 removes. This doc did not mention them. They must be **retired,
   not left dead** — leaving them is the built-but-unadopted pattern, which this
   repo has recorded six times.

---

## 11 · FLAG 1 and FLAG 5, DECIDED against the principles

Both were headed for the spec as NEEDS-AUTHOR. Both are decidable from
`PRINCIPLES.md`, so they are decided here rather than deferred.

### FLAG 1 — the sense is (a), DECLARED. Settled by P3.

> **P3:** *"You can enumerate the ways it can affect anything outside itself …
> the space of ports to the world is closed and named … you govern the membrane
> it must cross, not the interior."*

A module's membrane is **what it declares outward** — the `=>` externs it binds.
That is sense (a), and it is the only one of the three that is a property *of the
module*.

- **(c) object-code calls is a CATEGORY ERROR here.** It is a property of an
  emitted *program*, not of a module, and it already has its proper home: the H8
  profile gate, which governs a program's membrane. E160 only ever borrowed it.
  **This also answers FLAG 4:** sense (c) does not need re-homing when the emit
  gate retires — it goes back to where it belongs.
- **(b) transitive reach is a FOLD over (a) across the import graph.** A consumer
  composes datasheets; it needs no new analysis, no new field, and no new pass.
  Global principle 3 — compose, don't reinvent. Holding (b) as its own field would
  duplicate what composition already gives.

**And this dissolves the `ports.chiral` vacuity worry (R7's live case).** A
façade's *declared* crossings are empty, and that is **correct, not vacuous** — a
façade declares nothing and re-exports everything. Its transitive crossings are
non-empty and are obtained by folding its nine imports' datasheets. The vacuity
was an artefact of the unnamed sense, and naming it removes the case.

### FLAG 5 — the extent must be DECLARED, not inferred. Settled by P1 + global 5.

The measured fact: **the blob carries no module boundary at all.** Modules are
concatenated with comments; `(kind ports C upper)` is followed directly by another
module's text. The provider (`chirality_blob` / `resolve.chiral`) *knows* every
boundary and destroys it at concatenation. `kinds-close-bodied` then tries to
recover it from a heuristic — "has this coordinate charged a def yet" — and that
heuristic is what swallows 345 foreign defs.

> **P1:** *"the fix is never a longer denylist; it is a model that covers the
> whole surface, so 'deny by default' actually means everything."*

A rule that is right for modules-with-defs and silently wrong for façades **is**
the seccomp hole one level down. And **global principle 5** — *push invariants
into the substrate, not across a runtime seam* — names the error exactly:
the boundary exists in the provider and is being re-derived across a seam.

**Decided:** the module's extent is **declared, not positionally inferred.** The
compiler stays `Str -> ELF`, so the marker lives in the text the provider emits.
The exact token is spec-grain; the shape is not.

**And the interim, which is decidable now:** until a declared extent lands, a
`kind` form that charges no def must be **REFUSED**, not silently extended. That
is fail-closed, and it is the same rule E155 already enforces one level up — *a
silent drop must have a name.* A façade then either gains a body-charging rule or
carries no `kind` line; both are honest, and both are a compile error the author
sees rather than a wrong answer nobody sees.

### What stays open, and is genuinely author-tier

- **FLAG 2** — is `alt` derived, a second authored field, or does it leave? Nothing
  derives *or reads* it today.
- **FLAG 3** — source file vs `Sig` for the record.
- **FLAG 6** — does the per-def typeability letter survive? Its falsifier is unrun.

None of these blocks the spec: the schema's central field now has a fixed meaning
(FLAG 1) and the extent rule has a shape (FLAG 5).


---

## 12 · D11 DECIDED — the gate observes the record IN PROCESS (channel ii)

The spec audit blocked on: the gate harness sees only compile status, refusal
text, and program exit code, so five of twelve rows cannot observe a `Sheet`.
Two channels were offered. **Channel (ii), the in-process reader, and it is not
close.**

**R6 is the element.** *"The record is REACHABLE BY CONSUMERS — in the Sig,
queryable. This is E160's actual defect: it computes these facts inside emit,
truncates, and discards them. **A check is not an API.**"*

Channel (i) observes the record only where it changes a verdict — i.e. **only
through a check**. Gating that way would ship the API untested *as an API*, and
the gate would pass. That is E160's exact defect reproduced **inside the gate of
the element built to fix it**, and it is the built-but-unadopted pattern for the
eighth time in this repo. Global principle 6 — *an abstraction must constrain
behaviour or it is overhead* — rules it out: a queryable record that nothing
queries is overhead, and a gate that cannot query it cannot tell.

**"No precedent in the tree" is not an argument against — it is the finding.**
Nothing drives `load-source` in process because nothing has ever needed to query
a `Sig`. That is precisely what E161 changes. The first consumer is the proof
that a consumer is possible, so **the gate's reader IS the conformance evidence
for R5 and R6**: a test program that `(import "parse")`, calls `load-source` on
an inline module text, and exits 42 iff `sig-sheet` matches the expected record.

**Both channels, not one.** Where a claim IS fence-observable, use the fence too —
it is cheaper and it exercises the real refusal path. The audit's own restatement
of **G8** is strictly better than either original: *append a `=>` def to a
`(cat A)` module ⇒ recompile is REFUSED with no edit to the `(module …)` form.*
Keep that as a fence row **and** an in-process row; they falsify different mutants.

### Also decided — the audit's riskiest-step finding is a real gate hole

Step 1's only immediate check (`test_resolve_chirality.py`) compares the two providers
**against each other**, never against a fixed expectation. A marker emitted
identically-wrongly by both passes that differential silently, and the failure
mode is the same class as the defect being fixed. **The gate must pin
`(end-module …)` against a FIXED expected blob**, not only provider-vs-provider.
Same lesson as this session's stashed lint check, which reported `ok` forever.
