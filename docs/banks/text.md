---
node: banks/text
layer: bank
tier: depth
related: [banks/INDEX, banks/verification, banks/module, arcs/text-tools-arc, design-principles, status-ledger]
updated: 2026-09-01
---

# Bank: text

> The monolith this refracts: **the regex engine / the string library / the Unix
> text tool set / the editor buffer** — four things elsewhere, one concept here.

Build state below is **measured against the tree on 2026-09-01**, not taken from
`.planning/audit/CONFORMANCE-MAP.md`. That map carries 73 elements against a
catalog of 177 and has a row for none of the shards here, so citing it would be a
gate that cannot fail. See [[records/baseline-alignment]].

## 1. The concept in chirality

**Text IS** a `Str` or `Bytes` payload, plus a way to *name a part of it*, plus
total functions between those. Every operation on it is pure `->`; reaching the
text is somebody else's crossing.

**Text IS NOT** a stream you scan with an engine. There is no regex engine here
and there cannot be one: a backtracking matcher's cost is not bounded in its
input, and `PRINCIPLES.md` §2 says a process's cost is its type, so the thing is
unwritable rather than merely discouraged. What replaces it is a total matcher
with a bounded arrow, which is also the fast one — see §5.

**Text IS NOT the document.** A document is a typed value that *renders* to text
(`Puffer A` → `Doc`). Confusing the two is the defect U13 exists to fix:
`RendererFn` takes `Str`, so every mode reparses text it already had.

The three monoliths this gets confused with, and what they actually are here:

| you reach for | it is here |
|---|---|
| a regex engine | one shard, D, and a *total* one |
| a string library | shards A and B, mostly built |
| the Unix text tools | compositions of D through I, not programs |

## 2. The refraction — the shards

| | shard | home | state |
|---|---|---|---|
| **A** | the byte/string floor: `str-len`, `str-sub`, `str-find`, `str-find-from`, `str-cat`; `blen`, `bget`, `bslice`, `bcat` | `lib/prelude/prelude.chiral`, extern | **built**. `str-sub` is unclamped, E176 / BA-35 |
| **B** | derived string ops: starts-with, strip-prefix, contains, split, cmp, lower, upper, trim, replace, pad, join | `lib/prelude/string.chiral` | **built**, chirality over A |
| **C** | sequence ops: take, drop, map, filter, fold, find, concat, sort, dedup-adjacent | `lib/prelude/list.chiral` | **built**. E152 sort, E156 dedup |
| **D** | **the matcher, returning spans** | owed, `lib/text/` | **E173**, `design`. Antimirov partial derivatives, drafted at `docs/examples/E173-total-matcher.md`. No spec, audit not run |
| **E** | **the match score** | owed | UNASSIGNED. The whole gap between prefix completion and ranked select, since C already takes a comparator |
| **F** | **the edit script over two sequences** | owed | UNASSIGNED. Yields diff, comm, join |
| **G** | **the stable address** | owed; render half built | UNASSIGNED. `Doc`'s `d-tag` carries a semantic role at zero width — that half exists |
| **H** | layout: `d-text`, `d-cat`, `d-line`, `d-nest`, `d-group`, `d-tag`; horizontal composition; the `Term` printer | `lib/prelude/doc.chiral`, `protocol/render`, `lib/surface/pretty.chiral` | **built**. E158, E174, E181 |
| **I** | encodings: UTF-8, JSON | `lib/protocol/utf8.chiral`, `json.chiral` | **built** |
| **J** | reaching a corpus: directory walk, argv | `lib/ports/`, owed | **E148** and **E150**, both `design` |
| **K** | the typed buffer a document lives in | `prog/scriba/puffer.chiral`, `(Puffer A)` | **built**. `puffer-value` hands the typed value out |
| **L** | text steps inside an orchestration | `prog/manas/core/flow.chiral`, `flow-pure` / `PureFn` | **built**, but `PureFn` is a **closed sum of six** concrete predicates |

## 3. Cross-cuts — where a text shard IS another concept's shard

This is the high-value section: four of these shards are load-bearing somewhere
that is not about text at all.

- **D (the matcher) is a shard of [[banks/verification]].** A check is a matcher
  plus an authority to compare against. `ledger-lint`'s 19 checks are 54 regexes
  over the tree; every one of them is D applied to a corpus. The matcher is not a
  convenience for tools, it is the instrument the verification tier runs on.
- **G (the address) is a shard of [[banks/module]] and of evidence.** The module
  key is already a stable address for a *file* — root-relative path under `lib:`
  or `prog:`, which is exactly why renaming a file does not break an import. What
  is missing is the same idea *inside* a file. A citation is an address, and 294
  of them name a path that does not exist because the scheme stops at the file
  boundary (BA-20, BA-21).
- **H's `d-tag` is a shard of the face registry.** It carries a face-registry key,
  not a which-of-N, so the semantic-role set is open. That is what lets an address
  ride on rendered output at zero width.
- **L is a shard of the orchestration layer.** A text step and a model step are
  both `Flow` nodes with a typed arrow, checked by the same `flow-ty`. This is why
  doc tooling and AI orchestration are the same engine — see
  [[arcs/text-tools-arc]] and `prog/manas/core/flow.chiral`.

## 4. Native → chirality translation (the anti-misfire table)

Read this before saying chirality lacks a text feature.

| "chirality needs…" | what it actually is |
|---|---|
| a regex engine | shard D, and a **total** one. The backtracking kind is unwritable here, not missing |
| `grep` | D + `filter` |
| `cut`, capture groups | D returns spans; `str-sub` the span |
| `sed s///` | D + `str-replace` over the spans |
| `tr`, case folding | `map-list` over `Bytes`; B for the literal case. **No shard owed** |
| `sort`, `uniq`, `wc`, `head` | C, all built |
| a fuzzy finder | a subsequence *pattern* under D, plus shard E for the score. **No second matcher** |
| `diff`, `comm`, `join` | shard F |
| `column`, `fmt`, wrapping | H, built |
| a JSON parser | I, built |
| a markdown parser | usually nothing. Make the format cheap to read instead — [[records/README]]'s row format is one `###` block and six `- key: value` lines, chosen so no parser is needed |
| a string library | B, eleven operations already |
| a buffer | K, and it is already typed |

## 5. What is genuinely new or unbuilt (honest residue)

**New here, not a port of anything:**

- **The cost constraint picks the algorithm.** `PRINCIPLES.md` §2 makes an
  unbounded matcher untypeable, so the only writable shape is a one-pass automaton
  whose cost is linear in input and independent of pattern count. Measured
  motivation, from writing `prose-lint`: it does *"31 passes over 7 MB where one
  pass would do… the algorithm is the cost, not the compiled code"*, and runs 2.4x
  slower than awk as a result. The constraint and the performance win select the
  same design. That is not true of any language this borrows from.
- **A span-returning matcher is one primitive where a boolean one is four.** A
  span answers does-it-match, where, what-was-captured and how-many in one pass.

**Unbuilt, honestly:**

- **D, E, F, G.** One minted (E173), three not. [[arcs/text-tools-arc]] holds them
  and has no reserved element block, so they cannot be scheduled yet.
- **`PureFn` is closed at six constructors.** A new text step means editing
  `manas/core/flow.chiral` and recompiling. This is the ease-of-use wall, and
  opening it is D's second job.
- **`ty-text` is declared "the opaque escape hatch (any not-yet-modelled
  payload)"** in its own comment. Every unmodelled payload lands there and
  `flow-ty` degenerates to a tautology on those edges.
- **`Ty` compatibility is structural equality**; subtyping is deferred. `ty-span`
  cannot refine `ty-doc`.
- **`str-sub` is unclamped.** `(str-len (str-sub "abc" 0 99))` returns 99, and
  `string.chiral:14` claims in a comment that it clamps. E176, BA-35.
- **U13's seam is open.** `RendererFn` takes `Str` where the buffer already has
  the typed value, so a mode reparses what it had. U13 is drafted and names
  fourteen other `U#` elements, **none of which exist** in the catalog or ledger.

## 6. Relational anchors — thin notes that should link INTO this bank

- [[design-principles]] — regularity is a claim about text as read, and shard G is
  what makes a citation survive an edit.
- [[banks/verification]] — via shard D; a check is a matcher plus an authority.
- [[banks/module]] — via shard G; the module key is the file-level address.
- [[status-ledger]] — build state for E152, E156, E158, E174, E181.
- [[arcs/text-tools-arc]] — the elements, their order, and the packaging question.
- [[records/baseline-alignment]] — BA-13, BA-20, BA-21, BA-22 are all shard G;
  BA-35 is shard A.
