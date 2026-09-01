# Doc audit queue

**Opened 2026-08-31.** Every document, audited one at a time, for accuracy,
goals, limits, and structure. This file is the queue and the state; it is the
only place that says what has been audited and what came out of it.

> **Relationship to the other two documents that look like this one.** Deliberate,
> and they are not merged.
>
> - `.planning/DOC-CLEANUP-PASS.md` is a **separate author directive** of the same
>   day. It cuts dead references, excess and prose complexity. It does not check
>   claims against authority. This queue does, and only this queue does.
> - `docs/arcs/presentability-arc.md` is **TRACKED** and is the arc both serve. It
>   holds the requirements and the resume state; this file holds the per-document
>   queue and its outcomes. The arc survives a fresh clone and this file does not,
>   so a finding that matters to a second reader goes to `records/` or to the arc,
>   never only here.

## Why a queue and not a sweep

⚑ **Re-measured 2026-09-01: 381 `.md` under `docs/` (the 126 element specs moved
in from `.planning/` that day), 11 at the root, 6 under `records/`, and 86 still
live in `.planning/` with 49 more under `.planning/archive/`.** The 226 / 245 this
line carried was measured before the element tier moved into git and before the
first consolidation pass. A sweep produces a pile of
edits nobody checked. The audit charter (`tools/doc/doc.py audit`) is per-doc
because its authority gradient is per-claim: code and tests outrank the
CONFORMANCE-MAP, which outranks decision docs, which outrank a bank, which
outranks a thin note. Resolving that gradient needs the whole bundle for one
doc in front of you.

**Cadence: serial. One document at a time, one agent at a time.** Standing user
directive. Not a batch, not a wave, not three.

## The tool works again

`tools/doc/doc.py audit <node>` was blocked and is not any more. Slice 7 hoisted
its inputs, and 2026-08-31 repointed it at the role-sorted tree:

- `resolve_doc` searches all nine `docs/` roles, not `docs/` and `docs/banks/`
- `EXINDEX` is `docs/examples/INDEX.md`
- `find_src` searches `lib/` and `prog/` before the old `scaffold/` bases

`ledger-lint` is still partly blocked: 7 of 14 inputs are path mismatches, 6 of
them mechanical. See `HANDOFF.md`.

## What an audit produces

Per the charter, in order: build-state truth, line-evidence truth,
settled-decision conformance, graph integrity, refraction honesty. Findings are
**FIX** (applied in place, to the audited doc only) or **FLAG** (author-tier,
surfaced verbatim, never self-resolved).

Three additions for this pass, because the author asked for goals and limits
explicitly:

- **Goal stated?** Does the doc say what it is for, in its own first screen?
- **Limits stated?** Does it name what it does not cover? A doc claiming a
  guarantee with no stated limit is the `SECURE-DATUM-MODEL` failure below.
- **Structure legible?** Headings that match content, no section that is a
  dumping ground.

## Order

Spine first, because everything else cites it. Then the notes that the most
documents link to. Then the depth tier. `.planning/` last, since it is a record
rather than a contract.

| # | doc | hits | state | outcome |
|---|---|---|---|---|
| 1 | `docs/definitions/secure-datum-model.md` | 5 | **AUDITED (by hand, 2026-08-31)** | 1 FLAG, filed |
| 2 | `PRINCIPLES.md` | 24 | queued | |
| 3 | `CONTENTS.md` | 15 | queued | |
| 4 | `MAP.md` | 5 | queued | |
| 5 | `README.md` | 0 | queued | |
| 6 | `docs/index.md` | — | queued | |
| 7 | `docs/definitions/thesis.md` | — | queued | |
| 8 | `docs/definitions/bootstrap.md` | 2 | queued | ⚑ overlaps `bootstrap-sequence.md`; resolve first |
| 9 | `docs/definitions/bootstrap-sequence.md` | — | queued | ⚑ same |
| 10 | `docs/banks/INDEX.md` + the 9 banks | — | queued | |
| … | the rest of `docs/definitions` (40) | — | queued | |
| … | `docs/decisions` (14) | — | queued | |
| … | `docs/modules` (14) | — | queued | |
| … | `.planning/` (86 live, 49 archived) | — | last | record, not contract |

## Findings so far

### 1. `secure-datum-model` — the threat split is drawn in the wrong place

`.planning/FINDING-datum-model-write-adversary-2026-08-31.md`.

Raised by the author. The document puts DMA **write** in scope and CPU code
execution out of scope. On the stated hardware (no IOMMU relied on) DMA write is
arbitrary physical memory write, which is a routine path to code execution;
PCILeech, which §2 names as the in-scope tool, ships kernel implants that do
exactly this. So the out-of-scope list is a consequence of a power the model
grants rather than a power the attacker lacks.

The document's own §1 supplies the verdict: every layer shares one dependency,
the register root, and *"N layers that share a weakness collapse to one."*

Survives intact: the whole model against a **read-only** DMA adversary, which is
the evil-maid and Thunderbolt-snapshot case. Register root, derive-not-store, the
interrupt-disabled window, and every §4 confidentiality multiplier are sound
there. Against a **write** adversary, confidentiality is not available from CPU +
RAM at any multiplier, and what is left is detection with an ordering assumption.

Owed: split §2's adversary, move tamper/rollback into an integrity section whose
verb is *detect*, and say plainly that A_write needs the IOMMU the document
currently lists as optional.

### 2. Two bootstrap documents

`docs/definitions/bootstrap.md` (106 lines, the re-bootstrap climb with its four
stages and gates) and `docs/definitions/bootstrap-sequence.md` (55 lines, an
org-roam foundation note). Both landed in `definitions/` from different places in
the old tree. Whether these are one concept or two is an author call, and the
audit of either is worthless until it is made.
