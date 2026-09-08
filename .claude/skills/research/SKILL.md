---
name: research
description: >-
  Research run for chirality. Answer ONE question from external sources, pin
  every source the answer leans on, and write ONE row to records/findings.md
  with citations that resolve into the pins. Use when a claim about the outside
  world is about to be made: what a standard says, what a scheme costs, what an
  attack reaches, what a library measures. Also the gather step of a translate
  run.
---

# research: one question, pinned

Produce exactly **one** `FD` row per run, then **stop**.

The output is a row plus the pins behind it. The pins are the point: a finding
whose sources are gone is a claim nobody can re-check, which is the shape of
every wrong statement this pipeline was built after.

## When to use

**Before any claim about the outside world enters the tree.** What an RFC
requires, what a scheme's key sizes are, what an attack costs, what a benchmark
measured, whether a construction has a property. `docs/definitions/working-discipline.md`
carries the reporting rule and this is its outward half.

`.planning/protocol/dispatch.md` puts research in the dispatched column. **A
session that runs its own searches spends the context that holds the queue**,
and the conclusion is all the orchestrator needed.

## Hard rule: one run = one question = one row

Touch nothing under `lib/`, `prog/` or `docs/`. The write surface is
`records/findings.md` and `.planning/sources/`.

## Step 1: state the question so it can be answered wrongly

A question that cannot come back `no` fails as a question. Write it down
before searching, in the form the row will carry.

## Step 2: search, then get the bytes

Searching returns summaries. **A summary stands in for a source and is one of
the things this pipeline exists to stop**: a summarizing fetch produced six
spans the RFC never carried.

```
curl -sS -o /tmp/<id>.txt <url>
tools/xlat/xlat.sh pin <ID> <url> raw /tmp/<id>.txt
```

`raw` means the bytes as served. Use `transcribed` only when the bytes cannot be
had, and then say so in the row, because a transcription carries the
transcriber's reading.

Egress works from this sandbox. It was assumed blocked for a whole session on
the strength of a note, and `curl` returns HTTP 200.

## Step 3: read the pin

Quote from the pinned file. Every quotation in the row carries `ID:LINE "span"`.

**A span must be unique in its source.** `xlat check` reports `AMBIGUOUS` when a
span occurs twice, because a citation that resolves to whichever came first
points somewhere by accident. Table-of-contents lines and repeated definitions
are where this bites.

## Step 4: write the row

`records/findings.md`, prefix `FD`, the row format in `records/README.md`:
`state`, `claim`, `measured`, `evidence`, `checked`, `element`.

| field | carries |
|---|---|
| `claim` | the question, and the answer in one sentence |
| `measured` | what the pins say, quoted, with `ID:LINE "span"` for each |
| `evidence` | the pin ids, their origins, and the date they were pinned |

**Name what you did not find.** A question the sources do not settle is an
answer, and recording it as one stops the next run repeating the search. Say
which sources were consulted and came back empty.

## Step 5: verify before stopping

```
tools/xlat/xlat.sh unpinned          # exit 0: nothing quoted lacks a pin
tools/xlat/xlat.sh sources           # the new pin, its origin and its hash
python3 tools/ledger-lint/ledger-lint.py   # check AM green
```

## Done

End by naming the `FD` id, the pins added with their origins, the answer in one
sentence, and anything the sources did not settle. Then **STOP**.
