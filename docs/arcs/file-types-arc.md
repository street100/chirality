---
node: arc-file-types
layer: navigation
related: [arcs/README, goals/readable-surface, arcs/diagnostics-arc, status-ledger, index]
status: current
updated: 2026-09-02
---

# Arc: file types

- goals: [[goals/readable-surface]] (what it is built *for*), [[goals/self-tooling]] (what it is built *out of*)
- reserved element block: `E190-E195` (`docs/decisions/decision-lane-split.md`, Lane B)
- build-state authority: [[status-ledger]]
- lane: B. It runs in a separate session; `docs/decisions/decision-lane-split.md` holds the division and what
  enforces it.

TRACKED for the reason [[arcs/diagnostics-arc]] is.

## Why this arc exists

`MAP.md` states that the extension is the file's kind and the resolver checks it.
Two of the five kinds are declared and unbuilt. Meanwhile five codecs are
hand-written: `http` 780 lines, `vt-parser` 402, `json` 361, `apc` 252, `wire` 96,
totalling 1,891 lines, 177 defs and 122 byte-ops. Each hand-rolls its framing.
`apc`'s went stale twice in one session: its `enc` missed two `Rendering` arms
and shipped red, and its `dec` ends in an `else`, so new branches are invisible
to the compiler. E174 repaired both.

**One law, two carriers.** A declared form, a derived codec, a round-trip gate.
`.manifest` round-trips against chirality source, `parse(source(v)) == v`.
`.protocol` round-trips against bytes. That is why `Doc` serves one and not the
other: bytes have no layout freedom.

## REQUIREMENTS

Done when all five hold.

1. **`.manifest` exists as a checked kind.** A module whose every `def` body is a
   literal value: constructor applications and literals, no `lam` and no
   computation. Declared in the file and checked by the loader, because the
   property is one of term structure and the resolver cannot see it. E163.
2. **`.protocol` exists as a checked kind**, and `MAP.md` gains it. E183.
3. **Codecs are derived from the declared form** rather than hand-written.
4. **Each kind has a round-trip gate** with a named mutant that is actually run:
   source for `.manifest`, bytes for `.protocol`.
5. **The five emitters return `Doc`**, gated at widths 1, 40 and 10^6. E146.

## Element list

| element | title | state |
|---|---|---|
| E146 | value to source: the five emitters return `Doc` | not built. Imports `surface/pretty`, which E181 landed |
| E163 | `.manifest`: a declared form, a derived codec, a round-trip gate against source | not built |
| E183 | `.protocol`: the same law carried in bytes | not built. Minted 2026-08-31 by the diagnostics arc |

Full element prose for E183 is in [[arcs/diagnostics-arc]], which minted it.

## Resume state

**Design session 2026-09-02, author-led.** The arc's framing widened: a kind is a
**view** of the term language rather than a subset a predicate admits, and it is
legitimate when it round-trips, which is what requirement 4's gate already
demands without saying so. `.grammar` and a checker kind joined `.manifest` and
`.protocol`, and the author set two guidelines that let a kind fan out without
being mystical: mechanical is declared, judgement is written. The shared
structure is tracked in `.planning/FILE-KIND-STRUCTURES.md`, which points at
`.planning/README-PLAN.md` for the end-game requirements and
`.planning/MANIFEST-DESIGN-MAP.md` for `.manifest`'s own design. None of it is
minted, and E190-E195 is untouched.

Nothing built. E181 landed and moved the term printer to
`lib/surface/pretty.chiral`, so E146's dependency is in the tree. Two cross-lane
facts, neither gate-enforceable:

1. **The printer's module key is `surface/pretty`.** Root-relative keys make the
   directory the identity, so `typing/pretty` is a different module. E146 imports
   `surface/pretty`. Its API is `pp-of : (-> Str Term Doc)` and
   `pp-term-doc : (-> Term Doc)`.
2. **E181 promoted `bin/chirality-bin`**, 1,130,872 to 1,147,256 B, blob 755,238
   to 772,110 B. Any measurement taken before that landed was taken against a
   different compiler, and a byte comparison across the merge will differ for a
   reason unrelated to this arc.

The round-trip law `parse(source(t)) == t` is E146's row and cannot be E181's:
`parse`, `elab` and `core->term` live behind `module/loader`, which imports
`typing/diag`, which imports the printer. A `surface/pretty` to `module/loader`
edge would close a cycle. Phase 18's G13 runs that closure walk as a checked row.

Also true, since the round-trip depends on the printed form: a `case` prints
multi-line at every width and makes every enclosing form multi-line too, because
`doc-fits` refuses a hard break anywhere inside the group it measures
(`lib/prelude/doc.chiral:131`). A fixture assuming single-line output at a wide
width will be surprised.

## Constraints this arc works under

- **Lane B must not write its own term printer.** E158's G6 greps `lib prog
  tools` for every `prelude/doc.chiral` binding and fails on a duplicate
  definition, with M6 proving it can see one. This is the duplicate-owner defect
  this repo has already fixed four times: `str-cmp`, `list-sort`,
  `list-dedup-adj`, `Ord`.
- **`Doc`'s algebra is closed.** Six constructors and no seventh. A lane needing
  more converts into `Doc`. Adding an arm reddens two phases in mutants that are
  actually run.
- **The demanded statement this arc's kinds are checked against is prose, and
  unreached.** Measured 2026-09-02, `records/findings.md` FD-09. Under
  [[decisions/decision-split-checker]] each kind is an untrusted producer whose
  output `kernel-core` re-checks against a fixed statement, which is what lets a
  kind be added without growing the trusted base. In the tree that statement is
  `SpecRule.statement`, a `Str`, in `lib/typing/kernel-core.chiral`, which no
  module imports and no phase runs. So the argument that a new kind is cheap
  rests on a seam that is written and not wired. It does not block a kind from
  being built. It does mean a kind cannot claim its certificate is checked.
  `independent-judgment/J5` owns the fix and this arc does not.
- **Files Lane B may write**: `lib/manifest/**` (new),
  `lib/protocol/{json,http,wire,apc,vt-parser}.chiral`, `prog/` emitters, new
  Lane-B gates.
