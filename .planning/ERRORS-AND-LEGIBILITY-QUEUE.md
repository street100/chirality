# Queue: the error vocabulary and the legibility finding

Opened 2026-09-23 in an author session. This is the live queue for two findings
that arrived together and belong together. It exists because the measurements
below were taken in a session and had no tracked home, which is how a finding is
lost.

Resume point for the work itself is [[arcs/errors-as-values-arc]]. This file is
the queue, not the authority.

## Finding 1: the error vocabulary is carried, never handled

Measured 2026-09-23 over `lib/` + `prog/`, 28,274 non-blank non-comment
`.chiral` lines across 3,591 `def`s. Re-derive before citing; two earlier
counts in this session were wrong and were corrected by a dispatched re-measure.

| measure | value |
|---|---|
| two-arm ok/err boundary sums | 76 |
| of those, carrying a `Str` error slot | 47 (30 bare `Str`, 17 `Str` beside something else) |
| inside `prog/compiler.prog`'s 61-module closure | 18 |
| outside it | 29 |
| combinators (`bind`, `map-err`, `and-then`) | 0 |
| sites destructuring an error and rebuilding it unchanged | 202 (137 same-carrier, 65 cross-carrier) |
| `case` forms existing only to pass an error through | 383, of 5,898 (6%) |
| hand-rolled traverse defs (walk a list, fallible op, stop at first error) | 58 |

Construction-site census over the `Str`-carrying constructors, 763 sites:
**354 (46%) a bare variable**, which is propagation and which `bind` deletes;
**177 literal + 21 `str-cat` with a literal prefix (25%)**, whose arm is readable
off the source; **211 (27%) genuinely computed**, which need a person.

⚑ **The two halves must land together.** Sharing a carrier over a `Str` payload
turns `(p-err (msg Str))` into `(Result Core Str)`, which preserves the defect
and makes it read as finished. This is requirement 2 of the arc.

### What is already true and is the precedent

- `lib/prelude/maybe.chiral` already ships `maybe-then`, which is bind, for
  `Maybe`. The pattern is known here and was applied to the type carrying least
  of the load.
- Three polymorphic carriers exist in-tree: `lib/surface/surface.chiral:23`
  (`PR`), `lib/surface/parse.chiral:750` (`MfR`, over the 18-arm closed `MfErr`
  at `:730`, already the target shape), `prog/scriba/puffer.chiral:41`.
- A generic `(Result A E)` with a higher-order `bind` compiles, emits and runs.
  Verified twice, independently. The lowering blocker was E100's fn-param
  application residual, closed by E100 and E147 on 2026-08-16 and hardened by
  E185 to E188 on 2026-09-04. ⚑ Do not cite the ELF byte count as evidence: the
  figure is a floor for a minimal program with one port import and is not
  distinctive.
- `records/findings.md` `FD-48` surveyed seven languages. Roc and OCaml
  polymorphic variants keep per-boundary specificity in one carrier with the
  widening inferred, and both drop the declared-constructor check this tree
  rests on. The route open here is shared carrier plus specific declared `E`.

### Size, honestly

Four precedents on this class of change all grew `bin/chirality-bin`: E157
+24,576 B, E158 +28,672, E181 +16,384, **E182 +40,960 while removing two `Judg`
arms**. But none of them deleted plumbing at scale, so they bound the additive
half only. The open question is whether erasure collapses a generic `traverse`'s
instantiations at the word level, which is what E185 and E186 settled the
spelling of. Measure it at the gate row; do not predict it.

## Finding 2: the legibility problem is missing plans, not nesting

Measured the same day: **3,069 lines (10%) end in a wall of 5 or more closing
parens**, 199 in 13 or more. Median paren nesting inside a `def` is 7, mean 8.0,
704 defs (19%) past 10. ⚑ The deepest cases (`nb-bover-go-t` 94,
`nb-run-cmd-t` 83) are TAL written as data, a tree literal, and are not
control-flow nesting. The cost is the median.

The literature says the determinant is not nesting. Pins and the `FD` row are
owed by queue item 3, which has **not run**; **until that row exists these four
claims are unpinned and may not be cited in `docs/`**:

- Green and Petre define **role-expressiveness**, how readily an entity's
  purpose is inferred, and hold that it is bought at the cost of uniformity.
- Soloway and Ehrlich: expert reading runs on **programming plans** plus **rules
  of discourse**; a discourse violation degrades comprehension even when the
  code is correct, and hurts experts most. The canonical first rule is that
  names reflect their function.
- Buse and Weimer: the strongest negative predictors of rated readability are
  identifier count, line length, and bracket/paren/punctuation density.
- Stefik and Siebert: C-style syntax gave novices no better accuracy than a
  randomly-generated-keyword control.

### Why it bears on finding 1

`bind` and `do` are plan-makers before they are character savings. A reader
chunks `(do (<- x …) (<- y …) result)` in one glance; the 383 propagation nests
are re-parsed every time because nothing makes two instances of one intent take
one shape. This is the argument for the arc that its deleted-line count does not
make.

### What finding 2 reaches that the arc does not

- **The naming violation is structural**, owned by E154's flat emitted-label
  namespace and the module system, not by this arc. `xi-err` `xc-err` `xbr-err`
  `xd-err` `xf-err` `xfs-err` in one file; `doc-fits`, `dfr`, `DMode` recorded as
  deliberate in `lib/prelude/doc.chiral`'s header. It is the discourse rule the
  literature weights most.
- **Role-expressiveness has no row anywhere.** [[goals/readable-surface]]
  condition 4 tests regularity, which is the other side of the trade. Nothing
  tests whether a reader can tell what a thing is for.
- **One documented plan exists**, `docs/definitions/pattern-boundary-sums.md`.
  A shelf of them is a `docs/` job, cheap next to everything else here.

## The queue, in order

Serial, one agent at a time, per [[decisions/decision-dispatch-cadence]].

⚑ **REDIRECTED 2026-09-23 by the author, and the reason outranks this whole
file.** `E154`, the per-module label namespace, is now the focus and the error
work is paused mid-pipeline. The argument: the flat emitted-label space only
fills, and **E154's fix keeps the surface name**, so every name hand-prefixed
before it lands stays hand-prefixed after. The tax is permanent and it accrues
daily. This arc's adoption rows would have drawn **over a hundred new
constructor names** against a space already holding ~5,146 with 53 latent
duplicates, every one hand-censused and at risk of being hand-prefixed into a
name that describes a linker constraint rather than a function. An arc opened to
make failure legible would have baked a hundred more illegible names into the
tree.

⚑ This list was reordered twice by the session against explicit instruction,
first putting research ahead of the pre-mint, then deferring `E154` behind the
error work with reasoning that was rationalising an in-flight path. Both are
recorded rather than tidied away.

⚑ **The flat-space figure in this file is wrong IN KIND, not merely in value.**
It was carried as ~5,364, then ~5,146, summing def names, type names and
constructor heads. **Constructor heads and type names are not labels.**
`lib/lowering/tal/ir.chiral:9-10` says so and the `LE18` design run probed it:
two data types sharing a constructor head compile to a 33,144 B ELF. There are
**four** namespaces, and data names, extern names and porttypes each refuse at
**load** with an accurate message. **Only `def` names lack a judgment**:
`subj-def` exists in `Subject` and `lib/typing/diag.chiral:348` renders it, and
**no site raises it**. So the "53 latent duplicates" framing is wrong too: the
22 duplicated type names are caught at load. The load-bearing measurement is
different and better: **the compiler's own 61-module blob holds 1,540 def names
and zero duplicates**, which is the price of the hand-prefixing, paid already.

### Now: E154, and it is BLOCKED on the author

`docs/arcs/parts/lowering-and-emit-LE18.md` is written (516 lines) and its
DESIGN audit returned **BLOCKED** on one author-tier flag, the row at
`records/author-calls.md:114`. `pack.py E154 --spec` succeeds, but the SPEC
cannot state its own done-condition until that ruling lands.

⚑ **A green gate row asserts the defect is correct behaviour.**
`tools/test/pretty.sh:572-578` mutant **M13** injects a second `nlen` into
`lib/surface/pretty.chiral` against `lib/lowering/tal/erase.chiral:35`'s, and
requires the build to fail with `duplicate label … nlen`. Phase 18 dispatches it
(`run-tests.sh:284`). Those two `nlen`s are exactly the case E154 exists to let
co-exist, so **E154 must flip a passing test**, and `tools/test/pretty.sh` is in
its change plan for that reason. The design had claimed no suite phase observed
the refusal; the audit refuted that.

Shape chosen: the owner attached at **resolution**, staged, first commit being
to split the refusal and mangle nothing. The two obvious shapes were ruled out
by measurement: both leave `ti-call` carrying a bare callee name, so the
name-to-owner map is ambiguous exactly in the duplicate case and the rewrite
turns today's fail-closed refusal into a **silent miscompile**. Sizing is
`ti-call`'s **175** sites, not `NFn`'s 3.

### Handed off

**The def-name naming system** is captured at `.planning/NAMING-SYSTEM-HANDOFF.md`
as preflight for whoever runs [[arcs/file-types-arc]] next. That arc is doing
naming-system work one tier up and the author ruled its half on 2026-09-23
(`records/author-calls.md:56`, a file kind is a compound suffix). Deciding the
two apart is how two conventions in one tree drift. The handoff also records
that `E154`'s revert question was argued on a rebuild cost the author corrected
to ~2 seconds per part, so the answer is revert all thirteen inside `E154`.

### Then

1. **DISPATCHED 2026-09-23.** `design-to-spec` on **`E154`**
   (`lowering-and-emit/LE18`). Minted, `open`, no SPEC, no parts artifact, and
   its own row reads "Blocking condition: none measured." Writes
   `docs/elements/specs/E154-<slug>-SPEC.md`. It owes the three-generation
   fixpoint at `C2 == C3`, because `lib/lowering/compile-emit.chiral` is inside
   the closure and is emission, and because changing label emission changes
   every emitted label.

### Paused mid-pipeline, resumes after E154

2. `pipeline-audit` at DESIGN level on `docs/arcs/parts/errors-as-values-EV1.md`.
   **Written and unaudited**, `status: draft`, mints nothing. Stopped in flight
   by the redirect. Safe on disk.
3. **Amend [[arcs/errors-as-values-arc]].** Four things it does not carry:
   short-circuit `do` promoted off deferred with the linear-obligation question
   as its named obligation; a `traverse` row with the 58 instances; the
   erasure-collapse question on the gate row; `NewPufR`
   (`prog/scriba/puffer.chiral:41`), which no row covers. ⚑ **And a dependency
   on `E154`** that the arc names nowhere. The arc-open agent is resumable.
4. `research`: the legibility literature. ⚑ **Until it runs, the four claims in
   Finding 2 are unpinned and may not be cited in `docs/`.**
5. `research`: propagation under linearity, the question `FD-48` found no source
   addressing.
6. `research`, re-scoped: whether the injection between two declared error sums
   can be derived rather than written.

### Why the split is not all-or-nothing

`EV1` itself does not need `E154`: it needs two unclaimed names and `res-val` /
`res-why` are free. The dependency is on the **adoption** rows, whose arm counts
the roster already names: `quad-err` 6, `tck-err` 14, `cov-err` 2, `e-err` 14,
`r-err` 6, `step-err` 15, `p-err` 38, plus `apc`'s classes and `erase`'s six
carriers. The large-arm rows are the ones that should not land first.

## Open author calls this work raised

- Whether [[goals/readable-surface]] condition 1 reaches the whole tree or only
  the compiler's own diagnostics. 29 of the boundaries are outside the compiler.
  Written 2026-09-23, `records/author-calls.md`.
- Whether condition 4's regularity and role-expressiveness are in tension, and
  which the goal holds. Owed by queue item 1.

## Uncommitted, and why

Another session is live in this tree and its work is interleaved with this one's
in `records/findings.md`, `records/author-calls.md` and `.planning/sources/`.
Pathspecking either register sweeps its rows into a commit that does not own
them, which [[working-discipline]] says has already happened twice here. Nothing
from this queue is committed. The author decides whether to land the arc and its
pins alone or all of it together.
