# Reconcile

The stage between design and mint that takes an author call a session can
settle. The author directed it on 2026-09-29: *"write a method for review against
principles and researched inspirations until a proper solution is found for the
author calls that are reasonable for you to handle? i dont think very many have
many options once you reflect principle requirements with relevant examples to
translate in line with them"*.

The premise is testable, and each run tests it. A fork looks open while its
options are listed bare. Held against `PRINCIPLES.md`, the settled decisions and
how published systems answered the same question, most forks keep one option.
This stage finds that option and writes the derivation, or shows the fork is
real and hands it to the author in plain words.

## Where it sits

```
design      docs/arcs/parts/<arc>-<id>.md       element-design
RECONCILE   the calls the design raised, and    this file
            the register rows its arc carries
audit       the design                          pipeline-audit
MINT
```

In the waves of `.planning/DISPATCH-QUEUE.md` it is wave 1b. Wave 1 ends when
designs stop finding unrostered needs. Wave 1b runs over every call those designs
raised and every `unreviewed` row in `records/author-calls.md` that names a row
of the arc in the wave. Wave 2, the mint, starts when each of those calls reads
`dissolved`, or `unreviewed` with a plain summary written for the author's batch.

One call per run. Serial, like every stage.

## Which calls a session may take

A call is eligible when its answer follows from things the tree already
commits to. It is out of reach when the answer is a value the author holds.

| out of reach | why |
|---|---|
| what a goal claims, or a new ambition | `docs/goals/README.md`: authoring an ambition is the author's |
| a number that sets a bar: a target ratio, a budget, a deadline | the tree's own rule is that a bar with nothing under it is invented |
| reopening anything under `docs/decisions/` with `status: settled` | `.planning/PERSONA.md`: a settled fork is closed unless the author reopens it |
| scope and track: what is deferred, what is in | `docs/decisions/decision-scope.md` is the author's |
| a call the author has already answered in words anywhere | follow the words and mark the row `ruled`, citing them |

Everything else is eligible, including naming, placement, which arc owns a
thing, and which of several technical shapes to take. The run states its
eligibility finding first. An ineligible call stops there and gets its plain
summary.

## The method, per call

1. **The fork, plainly.** One line saying what is being decided, and every
   option, including ones no document wrote down. A missing option is the most
   common way a fork looks harder than it is.
2. **The principle test.** Each option against each of the five principles in
   `PRINCIPLES.md`, and against the principle's own honest limit. Cite the line
   and test the principle's predicate against the option. A principle named
   beside an option without its predicate tested proves nothing, per
   `.planning/protocol/dispatch.md` §Verifying a return. An option that breaks a
   principle with no written reason is out.
3. **The standing constraints.** Settled decisions under `docs/decisions/`,
   standing author directives (`docs/definitions/pattern-boundary-sums.md` is
   one), and rulings in `records/author-calls.md`. An option that contradicts
   one is out.
4. **The inspiration test.** How published systems answered the same fork.
   Sources come from pinned `FD` rows in `records/findings.md`, read under the
   tiers of `docs/decisions/decision-inspiration-policy.md`: papers for the
   metatheory, and behaviour alone for tier O systems. For each,
   state what the conventional answer bakes in and whether chirality's forms
   refuse that assumption. `docs/translations/README.md` names that question.
   An answer that rests on an assumption chirality refuses does not transfer.
5. **The measurement.** Where an option's cost or behaviour is a fact about the
   tree, measure it and cite the command and the date.
6. **Owed research.** If step 4 needs a source no `FD` row pins, the run stops
   and names the question. The orchestrator dispatches one `research` run, and
   the call re-enters this stage with the new row. That loop runs until the
   sources a verdict leans on are pinned.
7. **The verdict.** One of three.

| verdict | when | what the run writes |
|---|---|---|
| `DISSOLVED` | exactly one option survives steps 2 to 5 | a `docs/decisions/decision-<slug>.md` note carrying the fork, the surviving option, the eliminations each with the principle line, constraint or measurement that removed it, and what it leaves open. The register row goes to `dissolved` and cites the note |
| `NARROWED` | two or more survive, fewer than started | the row stays `unreviewed`, its options cut to the survivors, each elimination cited, and a plain summary for the author's batch |
| `STANDS` | the principles and the sources do not tell the options apart | the row stays `unreviewed` with a plain summary. The fork is a value the author holds |

A plain summary follows `.planning/DISPATCH-QUEUE.md` §How the author calls
move: what the thing is, why it matters, the options in ordinary words, a
recommendation, and the references after.

## What keeps a dissolution honest

- **An adversarial check before it lands.** The next serial dispatch after a
  `DISSOLVED` verdict is a check run on it. It gets the note and the register row
  and tries to revive an eliminated option: a principle read too strongly, a
  constraint that does not say what the note claims, a source whose assumption
  chirality refuses, or an option nobody listed. One revived option turns the
  verdict to `NARROWED`.
- **The author keeps a veto.** Every dissolution appears in the next author
  batch as settled by derivation. A veto makes the row `ruled` for the author's
  answer and the decision note `superseded`.
- **No verdict on a value.** Where step 2 ends in a tie that only a preference
  could break, the verdict is `STANDS`. Breaking the tie is the author's.

## What it writes and never writes

It writes: one decision note on `DISSOLVED`, one register row edit, and the
check's findings. It never writes a goal, a roster row, a `ruled` token, or a
settled decision's text.
