# Placement

I have something to write. Which tier, which directory, which form.

`MAP.md` holds the contract this expands: extension is the file's kind,
directory is its role, and the doc tier sorts by role too. Where this document
and `MAP.md` disagree, `MAP.md` wins.

## Two questions, in order

**1. Who reads it?** A person, including a stranger who cloned the repo, sends
it to `docs/` or `records/`. A session working the tree sends it to `.planning/`
or `.claude/skills/`. `docs/decisions/decision-ai-tier.md` draws that line.

**2. What kind of thing is it?** The tables below.

## The human tier

| what you have | goes to | form |
|---|---|---|
| a named concept, one idea | `docs/definitions/<slug>.md` | frontmatter note, `[[slug]]` links |
| a fork that got settled, with its reason | `docs/decisions/decision-<slug>.md` | frontmatter note, `status: settled` |
| one concept refracted across many homes | `docs/banks/<name>.md` | six-section bank schema |
| one module, described | `docs/modules/` | frontmatter note |
| the source tree as it is | `docs/implementation/` | frontmatter note |
| a measurement, with its date | `docs/benchmarks/` | frontmatter note |
| what the project claims it is doing | `docs/goals/<name>.md` | goal, plus the arcs that serve it |
| the elements for one goal | `docs/arcs/<name>-arc.md` | goal link, reserved band, requirements, element list, resume state |
| one catalog element, worked | `docs/examples/E<NN>-<slug>.md` | six sections, plus its `INDEX.md` row |
| the plan that implements one element | `docs/elements/specs/E<NN>-<slug>-SPEC.md` | six sections |
| a new element row | `docs/elements/catalog.md` and `docs/elements/ledger.md`, both |
| what is built, on the four rungs | `docs/definitions/status-ledger.md` | ENFORCED, IMPLEMENTED, SEEDED, DESIGNED |
| a claim beside what was measured | `records/<arc>.md` | a `###` block, six fields |
| a fork only the author can settle | `records/author-calls.md` | one row, with why it blocks |

Two forms are produced by a tool rather than by hand. A bank is scaffolded by
`python3 tools/doc/doc.py new-bank <name> E# E#`, which pre-seeds the elements'
map rows as evidence and prints the `INDEX.md` row to add. Lint check D fails
until that row exists, which is the forcing function. An example and a SPEC are
scaffolded by `pack.py`, covered in `workflow.md`.

## The agent tier

| what you have | goes to |
|---|---|
| how work is done here | `.planning/protocol/` |
| how to show up, what the author steers | `.planning/PERSONA.md` |
| a live queue, a handoff, a capture | `.planning/`, top level for now |
| a run procedure a session executes | `.claude/skills/<name>/SKILL.md` |
| a pointer a session needs on arrival | `CLAUDE.md`, as a table row |

`.claude/skills/` is fixed by the harness, which loads skills from that path. A
skill holds the run: one command, one artifact, the stop condition. When its
prose outgrows that, the prose moves to `.planning/protocol/` and the skill
points at it.

## Form

| tier | frontmatter | links |
|---|---|---|
| `docs/`, `records/` | `node`, `layer`, `related`, `status`, `updated` | `[[slug]]` inline. A path in a link is rot |
| root spine | none, plain markdown | ordinary markdown links |
| `.planning/` | none | `[[slug]]` resolves here too |

`[[slug]]` is the filename without `.md`, or a path relative to `docs/` such as
`[[banks/module]]`. Add a link before its target exists. It marks work to do,
and lint check F reports it once the target should be there.

Keep `status` honest: `draft`, `settled`, `current`, `open`. Keep `updated`
current, because check B uses the date to decide whether a stale principle
citation is rot.

## Four rules that override the tables

- **Say it once.** A rule that appears in two places drifts. If a home already
  holds the rule, write a pointer. `CLAUDE.md` was emptied to a pointer table
  for this reason.
- **Read the bank before naming a gap.** `docs/banks/INDEX.md` holds eleven. A
  feature that is one thing elsewhere is here a sum of shards, each in its own
  home, usually mostly built. Naming a phantom feature is the cardinal working
  error in this repository. If a concept has no bank, build one.
- **Never defer to an unminted element.** If you name a follow-on `E#`, mint its
  catalog row and its ledger row in the same change, or write `UNASSIGNED` and
  stop. `docs/definitions/working-discipline.md` carries the rule and
  `docs/decisions/decision-lane-split.md` reserves the bands.
- **Element status has one authority.** It comes from
  `docs/definitions/status-ledger.md`. The old tree kept about 171 status lines
  by hand and grew lint checks to catch them drifting.

## Writing is mostly amending

Most writes in this tree change a document that already exists. Placing a new
one is the rarer case, and the tables above are for that case. This section is
for the common one.

**A thing you learn mid-task gets written where it belongs, in the same move.**
Reporting it in a message and carrying on loses it when the session ends. If the
learning changes a doc, change the doc. If it has no home yet, the working file
takes it.

**A discussion in progress is a file.** It holds the settled decisions, the
drafts verbatim, and what was rejected with the reason. It lives in `.planning/`
and it is the relay: the next session picks it up rather than restarting the
argument. `README-PLAN.md` is the live instance.

**Record what was rejected, and why.** An option that was considered and dropped
comes back otherwise. On 2026-09-01 a session proposed five question wordings
that the working file had already rejected by name, because it had not read the
file. The rejection list was doing its job and the session skipped it.

**Supersede in place; do not delete.** When a decision replaces an earlier one,
mark the earlier one superseded, date it, and leave it. The record of what was
tried is what stops it being tried again. Cutting it makes the file read cleaner
and makes the next session dumber.

**Amend with a date.** A doc that changed and does not say when reads as always
having said that. `updated:` in the frontmatter, and a dated line where the
change is a reversal.

**Read before you write.** Before adding to a doc, read what it already says on
the subject. Before opening a new working file, check whether one is open. This
is the cheapest rule here and the one most often skipped.

## Before you commit

```
python3 tools/ledger-lint/ledger-lint.py     # claims against the tree, checks A to S
tools/prose-lint/prose-lint.sh PATH...       # how it reads
```

`ledger-lint` carries 255 findings against the current tree. Compare the count
and the per-check distribution before and after, so a change that adds none is
visible. Commit with a pathspec, `git commit -- <path>`, because a bare commit
sweeps another agent's staged work and that has happened twice here.
