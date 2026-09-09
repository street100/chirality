---
node: altitude-errors
layer: foundation
related: [axis-altitude, bug-classes, status-ledger, records/baseline-alignment, records/findings]
status: draft
updated: 2026-09-04
---

# Altitude errors: the five axes the lowering axis does not cover

[[axis-altitude]] is about lowering: upper → tal → metal, with the rule *a
feature lives as high as it can and drops only as far as it must*. That axis is
healthy, and it has a `preserve-check`.

This note is the other five. Every one is the same shape — **a thing living
below the level of generality that owns it** — and every one was found by
measurement rather than by reading. None of them has a check, which is why they
rot silently.

The taxonomy was written 2026-08-21/22 in `.planning/BUILD-ORDER.md`, which is
tracked with the rest of the agent tier since 2026-09-01
([[decisions/decision-ai-tier]]). ⚑ *This read "which is untracked", the false
claim `records/baseline-alignment.md` BA-44 records as a class;
`git ls-files .planning` returns 145.* The classes are the durable part and are
hoisted here because a taxonomy is written for a person. **Every
instance below was re-measured 2026-09-01 against the migrated tree**, because
the original instances cite `scaffold/` and `TUI/` paths the migration evicted,
and about half of them are fixed.

## A1 · Definition altitude — a shared helper homed inside its consumer

A generic helper written wherever it was first needed, because there was no
shelf.

**Then (2026-08-21).** Five ad-hoc string comparators, three sharing the bare
name `str-cmp`; two of them already prefix-renamed (`ar-str-cmp`, `cb-str-cmp`)
to dodge the flat emitted-label namespace, which is A2 visible in the source.
`str-lower` lived in the chatter router and `str-trim` in the orchestrator's
flow module — text primitives homed inside an application. About twelve generic
prefixed clones. The only sort in 88 modules was an insertion sort private to
`row-infer`.

⚑ *Corrected 2026-08-22:* "4×" conflated definitions-of-the-exact-name with
ad-hoc comparators and was stale either way, and the `ledger-lint` check L
baseline was slack by one as a result: it recorded 4 where the exact-name count
was 3, so a new duplicate would have passed.

⚑ *Corrected 2026-08-23:* the private insertion sort was not the only one.
`closconv.chiral` defines `ins-uniq`, the same fused sorted-unique insertion,
and `compile-back.chiral` a third private de-duplicator. Two before E152, not
one.

**Now (measured 2026-09-01).** The shelf exists and most of the leak drained
into it. `str-cmp` has exactly one definition, `lib/prelude/string.chiral:91`.
`str-lower` is `lib/prelude/string.chiral:116` and `str-trim` is `:163`, out of
the application. `list-sort` is `lib/prelude/list.chiral:143`, `ms-sort-n` `:134`.

Still leaking, and this is the current instance list rather than the 2026-08 one:

| helper | copies | where |
|---|---|---|
| `list-nth` | 2 | `lib/evidence/interp.chiral:50`, `prog/scriba/list-utils.chiral:14` |
| `dedup-str` | 2 | `lib/lowering/compile-back.chiral:117`, `prog/prapanca/core/gate.chiral:105` |
| `se-length` | 1 | `prog/scriba/str-edit.chiral:30` |
| `se-reverse` | 1 | `prog/scriba/str-edit.chiral:26` |
| `ins-uniq` | 1, private | `lib/lowering/upper/closconv.chiral:40` |
| `rnd-append-list` | 1 | `lib/protocol/render.chiral:218` |
| `rules-append` | 1 | `prog/scriba/manas-mode.chiral:208` |

→ Fixed by E151 (string stdlib), E152 (sort) and the `VAL` ledger category — a
shelf that did not exist until 2026-08-21, which is *why* the leak happened.

## A2 · Mechanism altitude — a codegen defect forcing app-level duplication

A1 is not carelessness. Two co-blobbed modules **cannot** define the same
internal name, because emitted labels share one flat namespace. It was
hand-patched three times before it was named. If a shared name cannot be defined
twice safely, a module writes a prefixed clone instead of importing.

→ Fixed by E154: per-module label mangling at emit.

⚑ This is **not** the phantom `docs/banks/module.md` §4 refutes. That correction
is about the *design* tier and is right. This is the *emit* tier, and the bank
carries the caveat at §5 item 6 so it cannot be cited as evidence the collision
does not exist. Distinguishing the two is the whole content of this class.

## A3 · Source-tree altitude — the foundation reachable by several paths

`resolve.chiral` took **one** `CHIRALITY_LIBDIR`, so every independently-buildable
subtree needed the foundation visible under its own path.

⚑ **CORRECTED TWICE, and the sequence is kept because the pattern is the point.**
(1) "9 independent copies, nothing prevents drift", cited to differing inodes —
wrong, `stat` is unreliable here. (2) "hardlinks, proved by mutation" — right
conclusion, wrong mechanism. (3) Actual, settled by `ls -l` on 2026-08-22:
symlinks, running in both directions, 9 real files behind 12 shared paths, **no
duplication at all**. Each time the reasoning ran from indirect evidence when one
direct observation answered it outright. "Delete the 9 copies" was never a
deliverable.

⚑ **A third error in the same section.** The claim that the resolver's *"first
occurrence wins"* dedup silently dropped a module cited a **comment**, not code.
The code keyed on the import string as written, so `(import "ports/proc")` and
`(import "proc")` were different keys and **both** were emitted — a
duplicate-definition hole, not a drop. Citing a comment as if it were code is
itself an A5 error.

→ Fixed by E155, built 2026-08-22. A basename collision between two different
modules is a named error naming both paths, with no blob emitted, in both
providers. Re-importing the same module still dedups, because the DFS relies on
it. Identity is canonical path-then-bytes in the shell provider and source text
in the chirality one, **not** the path string, because a path-keyed check would
have refused the build outright over the symlinks.

⚑ Measured 2026-09-01: `TUI/` no longer exists. The subtree this class was found
in was dissolved by the migration, so the instance is gone and the class is not.

## A4 · Catalog altitude — an element filed in the wrong lane

Two application elements carried core `E#` numbers and the ledger had flagged
them "pending migration" for months; one read `design` in the ledger and
`Not built` in the catalog while the code had shipped weeks earlier and was live
in the blob. Both corrected 2026-08-21 with citations.

This is the one axis with machinery: `tools/ledger-lint/ledger-lint.py` checks
J and K cover it, and they caught two mistakes made while the taxonomy was being
written.

## A5 · Claim altitude — a document asserting what the code contradicts

Three found and corrected 2026-08-21: an audit doc listing two shipped
primitives as open WANTs; a slice note saying "chirality needs" a capability
that had shipped five days earlier, leaving an obsolete workaround in the tree;
and the module bank's §4, which is A2 above.

This is the class [[records/README]] exists for. A row there is the durable form
of an A5 finding, and [[records/baseline-alignment]] and [[records/findings]]
are where they now land.

## A6 · Principle altitude — a build that contradicts a stated principle

Run 2026-08-22 against `PRINCIPLES.md`, after the author asked for one. Three
findings changed rows; the rest were written down so they would not be
re-derived.

- **P3 · an editor holding network authority.** The editor opened a backend port
  inline. P3 governs the ports, and [[live-environment]] decides this exact case:
  an AI-orchestrator earns its own node, a fontifier does not. The conventional
  fix, a buffer-local slot, would have entrenched the violation. Stated at the
  right level after a first draft over-collapsed it: conversation *content*
  leaves the editor, a re-attach *handle* stays, the network-authority removal is
  unqualified, and the split element is **not** strictly cheaper, because a port
  is linear and holding anything linear across a keystroke is what the chat
  buffer had to avoid.
- **P4 · a central record whose gradient points the wrong way.** One central
  record makes "add to global state" cheap and "make it a node" expensive. That
  is the slope that built Emacs's single image, which [[live-environment]]
  inverts.
- **P1 · E154 and E155 were correctly motivated and not cited as such.** The
  resolver's silent dedup is P1's seccomp example one level down: a module can
  vanish with no name for the event.
- **Principle 6 · this taxonomy is descriptive, not enforcing.** Until the
  one-command checks below are actual `ledger-lint` rows, it is policy rather
  than physics, which is what P4 rejects. **Owed, not done.**
- **Process · the pipeline was bypassed.** `CLAUDE.md` requires example → audit →
  spec → audit → implement before implementing a catalog `E#`, and one element
  went straight to implementation with neither. Precedent exists but the rule
  carries no carve-out, so it is a violation and not an exception. Either follow
  it or amend it on purpose; `PRINCIPLES.md` says a contradicted principle gets
  changed deliberately, not quietly.
- **P5 · not engaged, correctly.** Nothing here is in the unprovable region.

⚑ *Corrected 2026-08-22:* the supervisor element was reported `designed, unbuilt`
by propagating a lower-authority doc that the ledger had corrected ten days
earlier — an A5 error, and it read as unbuilt because **nothing imported it**.
Built-but-unadopted, which [[bug-classes]] now measures at ten modules and 1,680
LOC.

## The through-line

Every one of these is a thing sitting lower than the level that owns it: a
helper below its generality, a duplicate below its source, an element below its
lane, a claim below its authority, a build below its principle. The lowering
axis has a `preserve-check`. These five have nothing.

⚑ The taxonomy still does not constrain anything. Two of its checks are one
command each and were named as `ledger-lint` candidates in 2026-08 and are still
not rows:

- `grep -c '(def [a-z]*-str-cmp'` returns 1. Measured 2026-09-01: it returns 0,
  and the single canonical `str-cmp` is at `lib/prelude/string.chiral:91`. The
  check as written no longer matches what it was aimed at and needs restating
  before it becomes a row.
- No new helper is written inside a consumer when a shelf exists for it. The A1
  table above is what a check would have to produce, and nothing produces it.

An abstraction that does not constrain is overhead. This one is still overhead.
