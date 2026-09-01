# The user layer — research & spec pipeline plan

**Minted 2026-08-30.** Companion to `.planning/USER-LAYER-GAP.md` (the `U#` outline,
53 rows). That doc says *what the gap is*; this one says **which rows earn a worked
example, which go straight to a spec, which need an author decision first, and what
research each run owes before it starts.**

Nothing here is a run. No example is drafted, no spec written, no row implemented.
**Live state — what is done, running and next — is `.planning/USER-LAYER-TRACKER.md`.**

---

## §0 · The criterion, applied rather than assumed

`CLAUDE.md`, amended 2026-08-22:

> An element goes through the pipeline **iff implementing it requires CHOOSING between
> shapes the codebase does not already settle.** Design content, not size, is the test.
> A bug-class fix whose shape is forced by the defect does not need a blueprint — the
> defect is the blueprint.

Every row in §2 carries a **skip test**: the one sentence saying what would be chosen
wrongly if the run were skipped. A row with no such sentence is Track S or Track M by
construction. This is the check the E145/E147-vs-E150/E151b split turned on, and it is
cheap to state and expensive to omit.

**Five tracks:**

| Track | Meaning | Artifact chain |
|---|---|---|
| **P** | full pipeline — an open shape choice | example → audit → spec → audit → implement |
| **D** | an author decision lands first, then P or S | `docs/decision-*.md` → … |
| **S** | shape settled; scriba's historic spec-first path (`.planning/specs/S1,S2,S13–S17`) | spec → audit → implement |
| **M** | mechanical; the defect or the precedent is the blueprint | implement + gate |
| **X** | blocked — its design content belongs to another lane's row | inherits |

---

## §1 · ⚑ The tooling blocker — the pipeline cannot address `U#`

`tools/pack/pack.py:508`:

```
die("element id must look like E13 (or the CAT·E# form, e.g. MEM·E120)")
```

**The pack is `E#`-only.** It resolves the row out of
`.planning/SELF-IMPLEMENT-CATALOG.md`, the CONFORMANCE-MAP, `examples/INDEX.md` and
the KB link graph — all keyed on `E#`. So *none* of the 53 `U#` rows can run
`--spec`, `--audit`, `--kb` or `--mark` as things stand. This is not a detail to work
around at run time; it decides the shape of every run below.

Three ways out, and they are not equivalent:

| | What | Cost | Verdict |
|---|---|---|---|
| **(a)** | mint each pipelined `U#` as an `E#` | numbering churn; and it contradicts the S31/S32 precedent, where `E88`/`E92` were **rehomed off** `E#` precisely because they were scriba-app elements | wrong for app rows, right for core ones |
| **(b)** | teach the pack a second catalog + id prefix (`U#`, and `S#` while we're there) | one bounded change to a 636 L deterministic tool, no LLM in the path | **recommended** |
| **(c)** | run `U#` by hand off the SKILL files | works — the `S#` specs were made this way — but the KB slices, the `--mark` status flips and `ledger-lint`'s coverage are all lost, and *that* is how a lane drifts out of the discipline | fallback only |

**U0 · Teach `chirality-pack` the `U#` lane. — ✅ BUILT 2026-08-30**, `tools/pack/pack.py`
only, E-lane bundles byte-identical, `ledger-lint` clean, three mutants run. ⚑ Two
facts it established that this section had wrong: the KB rows' baseline is **declared
by the adapter, not discovered from the row** (no `U#` row names a `.py` — the
`bin/*.py` names live in §6's prose, and §5's prose names `ledger-lint.py` as something
it *retires*), so that list is a maintained fact that can rot; and the `U#` legend
costs ~14 KB per bundle (U runs 22–28 KB vs E's 10–13 KB), tracked as `U0b`. Accept `U<n>` (and `S<n>`), resolve the row
from `.planning/USER-LAYER-GAP.md` / `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md`, keep
every other stage identical. **This is the first thing built in this whole plan** —
before any example — because it is the difference between a lane inside the discipline
and a lane beside it. `CLAUDE.md`'s own amendment note applies exactly: *silent
divergence is worse than either rule.*

⚑ **Second, smaller tooling fact.** The pack's example bundle slices *"the OURS Python
baseline around the named symbols."* For the **KB rows that baseline is perfect and
already in-tree** — `ledger-lint.py` (1033 L), `chirality-doc.py`, `chirality-capture.py`,
`chirality-frontier.py` are literally the conventional implementation of §6. For the
**document-family rows there is no in-tree baseline at all**; the conventional
comparator is org-mode's own element parser, which is external and must be
*researched*, not sliced. U0 should let a row declare its baseline as `EXTERNAL` so
the bundle says so instead of emitting an empty slice.

**⚑ Cadence:** these runs go **serially, one at a time** — standing user directive,
which overrides `CLAUDE.md`'s "parallel waves" guidance for pre-runs. `--no-index` and
the orchestrator-appends-rows protocol therefore do **not** apply; each run updates its
own INDEX row.

---

## §2 · The sort — all 53 rows

### §2.0 · The scope table

Every row, its track, what it needs minted, and the gate that decides it. **Track**:
**P**`n` = pipeline run *n* · **S** = spec-first · **M** = mechanical · **X** = blocked,
design owned elsewhere · **X→S** = blocked now, light spec after.

**Mint** reads: `app` = app-tier row, stays `U#`/`S#` (S31/S32 precedent, no `E#`) ·
**MINT** = needs a new catalog + ledger row before it can be cited · a bare `E###` =
already minted, cite freely.

#### §4 · Text editor floor — 12 rows

| U# | Element | Track | Mint | Deciding gate |
|---|---|---|---|---|
| U1 | codepoint-correct editing | **P9** | **MINT** `VAL` | rank 1 — UAX #29 vectors; mutant: byte-index swap on a 2/3/4-byte fixture |
| U2 | display width (`wcwidth`) | S | T17-tier | frame diff; **gates aligned tables + diagrams** |
| U3 | soft wrap + h-scroll | S | app | frame diff |
| U4 | multi-file search + result surface | S | E148 | native sample; shares U51's result shape |
| U5 | fontification from the real parse | **P10** | app · **D-U1** | mutant: syntactically broken buffer |
| U6 | structural editing + indentation | X→S | app | after P10's seam |
| U7 | completion-at-point | S | app | the *seam* is the deliverable, not a source |
| U8 | diagnostics in the buffer as values | S | **E157** | native sample |
| U9 | file safety (atomic save, mtime, revert) | S | **E148 + E149** | ⚑ uid-0 trap |
| U10 | jumplist + `.` repeat | S | app | native sample |
| U11 | encoding + line-ending policy | S | app | closed sum, not a guess |
| U12 | the honest scale bound | M | — | **measure and record; no code** |

#### §5 · Document type family — 19 rows

| U# | Element | Track | Mint | Deciding gate |
|---|---|---|---|---|
| U13 | renderer takes the **value**, not `Str` | **P1** | app · **D-U7** | **the additivity gate**; mutant: re-point one mode at `Str` |
| U14 | `Mode` grows — keymap + ops + views | **P1** | app | ″ |
| U15 | extension → document type, checked | **P1** | app | ″ |
| U16 | the block algebra | X | **E158** | inherits E158's open design — do not draft a second blueprint |
| U17 | N views per type | **P1** | app | ″ |
| U18 | per-type surface reader | **P2** | app · **D-U2** | round-trip **+ rank-3 hand-written corpus** |
| U19 | `parse`/`print` round-trip, per type | **P2** | app | ⚑ common-mode limit — rank 4 if print derives from parse |
| U20 | type 1 — outline / notes | **P3** | **MINT** `VAL` | mutant: drop a field from `print` only |
| U21 | type 2 — sectioned doc + schemas | **P4** | **MINT** `VAL` · **D-U6** | rank 2 vs `ledger-lint`; mutant: section out of order |
| U22 | type 3 — table + column schema | **P5** | **MINT** `VAL` | mutant: row past the declared schema |
| U23 | type 4 — graph + typed edges | **P6** | **MINT** `VAL` | mutant: collapse two edge types to one string |
| U24 | type 5 — journal / datetree | S | `VAL` | gated on U40 |
| U25 | diagram rendering, tiered | **P7** | app / TUI | mutant: rank swap; ⚑ `r-graph` = **recompile trigger** |
| U26 | generalize the outline engine | S | app | the **ratio rule** — 1,034 L generalized |
| U27 | charts | S | **E153** (partial) | integer tier declared, not deferred silently |
| U28 | cross-type links + transclusion | S | app | gated on S26 + S27 |
| U51 | the derived lane | **P8** | app | mutant: strip provenance → jump-to-source must fail |
| U52 | the stream lane | X | **S20b** | linear-handle-across-keystrokes |
| U53 | the remote lane | X | **S20b** | ″ |

#### §6 · Knowledge base — 10 rows

| U# | Element | Track | Mint | Deciding gate |
|---|---|---|---|---|
| U29 | KB as a port, read/write split | **P11** | E148 + E149 | ⚑ **the uid-0 trap's sharpest case** — "the reader cannot write" is a permission claim |
| U30 | note graph as a typed value | **P11** | app | rank 2 vs `ledger-lint` |
| U31 | link integrity as a property | S | E157 | rank 2 vs lint's link-graph checks |
| U32 | query + view surface | S | app | one query language, shared with U46 |
| U33 | citation checking against live files | S | **S26** | rank 2 vs lint; the row that proves S26 earns its keep |
| U34 | authority gradient as a value | **P12** | app | mutant: invert two adjacent tiers |
| U35 | capture + routing | S | E149 | rank 2 vs `chirality-capture` |
| U36 | staleness digests | S | **E116** | weaker checksum = a **named** downgrade |
| U37 | refile / archive / rename + link rewrite | S | E149 | ⚑ uid-0 |
| U38 | transclusion / block references | X→S | S26 + S27 | deliberately unscheduled |

#### §7 · Scheduling and agenda — 12 rows

| U# | Element | Track | Mint | Deciding gate |
|---|---|---|---|---|
| U39 | a program can acquire a `Clock` | M | **D-U4** | **blocks all of §7**; costs a paragraph |
| U40 | civil date/time | **P13** | **MINT** `VAL` | rank 1 vectors; mutant: make 1900 a leap year |
| U41 | told time as evidence | **P14** | **MINT** `SYS` | mutant: rolled-back told time must alarm |
| U42 | timezones, tiered | M | **D-U5** | UTC+offset floor; tzdata a **named not-had** |
| U43 | timestamps in the document value | S | U40 | native sample |
| U44 | repeaters (`+1w`, `.+1d`) | S | U40 | pure arithmetic on U40 |
| U45 | TODO state machines | **P16** | **E163** | mutant: swap two states in the manifest |
| U46 | the agenda as a query | **P15** | app | mutant: drop the deadline filter |
| U47 | priorities / tags / properties / effort | M | app | falls out of U46 |
| U48 | clocking | S | U41 + `time-mono` | the two senses must not fuse |
| U49 | the agenda daemon | X | **E39** + S28/S29 | last; gates nothing above it |
| U50 | capture with a timestamp | M | U35 + U40 | falls out |

**Totals — 53 rows:** P **21** (in 16 runs) · S **21** · M **5** · X/X→S **6**.

### §2.0b · The file types — what each extension is scoped as

⚑ *Added 2026-08-30: the first scope table listed the document **types** (U20–U24) and
lost the **extensions**, which is the half that does the semantic sorting. They live in
`USER-LAYER-GAP.md` §5's roster; this is that roster with scope attached.*

**12 extensions over 6 value shapes** — extensions outnumber types on purpose. Where two
families differ only in their section list they share a type and differ by a declared
**schema**; where the value shape differs they are separate types.

| Ext | Type | Value shape | Renders as | Tier | Run | Consumer today |
|---|---|---|---|---|---|---|
| `.fol` | **U20** | `Item` tree — heading, state, tags, props, timestamps, body | foldable tree (`r-tree`+`r-section`) | 1 | **P3** | the org-analogue |
| `.bank` | U21 · schema | 6 fixed sections | section stack | 1 | **P4** | **10 banks** |
| `.spec` | U21 · schema | deliverable / delta / dispositions / plan / gate | ″ | 1 | **P4** | **122 specs** |
| `.wex` | U21 · schema | 6 worked-example sections | ″ | 1 | **P4** | **118 examples** |
| `.dec` | U21 · schema | decision + provenance + do-not-reopen | ″ | 1 | **P4** | **14 decisions** |
| `.deck` | U21 · schema | slides | slide view | **2** | P4 (schema only) | none — named, not built |
| `.tab` | **U22** | rows over a declared column schema | aligned `r-table` | 1 | **P5** | the `INDEX.md` family |
| `.led` | U22 · schema | catalog / ledger rows | ″ | 1 | **P5** | `SELF-IMPLEMENT-CATALOG.md`, `LEDGER.md` |
| `.graph` | **U23** | nodes + **typed** edges | diagram · tree · adjacency — *same value* | 1 | **P6** | the 71-node link graph, module imports, lane deps |
| `.log` | **U24** | time-keyed entries | timeline lanes | 1 | S, after U40 | capture targets (§7) |
| *(none)* | **E163** manifest | pure data as type-checked chirality | value view | **built** | — | `target-linux.chiral` |
| `.chiral` | source | the language | fontified from the real parse | **built** | P10 | everything |

**Tier 2 — named, deliberately not scoped:** `.ref` (bibliography — the repo's own
`PAPER`/`IMPL`/`OURS` reference-class convention is one already) · `.chart` (U27) ·
`.diff` · `.kbd` (keymap documents). Each is one schema or one small type when a
consumer appears; none has one.

**⚑ Extension naming is an author call; the shapes above are not.** `D-U2` settles the
roster's extent and the surface syntax; the letters are cosmetic and can change without
touching a single row.

#### What deliberately gets NO file type

Listed so a later pass does not "discover" these as missing formats.

| Candidate | Why not | Where it actually lives |
|---|---|---|
| the **agenda** | it is a **query**, derived on demand | U46 — org has no agenda file either, but here the *type* enforces it rather than convention |
| the note-graph **index** | derived from the notes | U30; a cache, if one is ever needed, is an **E163 manifest** |
| **config / init** | already homed | `S11` init-file (chirality, per D-S1) + **E163** |
| saved **manas setups** | already shipping as data | `persist.chiral` JSON codec (P1–P4, 2026-08-16) |
| **attachments** | not a format | a path plus `stat` — **E148** |

#### The lane × operation matrix — a scoped deliverable, not a table yet

`D-U7`'s output is not just the packing choice; it is **the vocabulary every lane must
implement**. That matrix is scoped to **P1**, and it is what decides whether the family
is convenient or grows escape hatches:

| Lane | Row | render | key | save/print | undo | refresh | jump-to-source | close (linear) |
|---|---|---|---|---|---|---|---|---|
| text | — (all 152 today) | ✓ | ✓ | ✓ | ✓ | — | — | — |
| value | U20–U24 | ✓ | ✓ | ✓ | ✓ | — | — | — |
| derived | **U51** | ✓ | ✓ | — | — | ✓ | **✓** | — |
| stream | **U52** | ✓ | ✓ | — | — | ✓ | — | **✓** |
| remote | **U53** | ✓ | ✓ | — | — | ✓ | — | **✓** |

The two ✓ in the last column are `S20b`'s question, which is why U52/U53 are Track X
and the other three lanes are not.

### §2.0c · Upstream — scoped, but not by this lane

This lane waits on these and owns none of them. Each already has a home.

| Upstream | Owner | What it gates here |
|---|---|---|
| `S19` `S20` `S21` | scriba floor | **everything** — §2 of the gap doc |
| `S20b` | scriba floor | U52, U53 (the linear-handle question) |
| `S26` `S27` | scriba floor | U8, U28, U33, U38 — anything anchoring into text |
| `S28` `S29` | scriba floor, async | U49 only |
| **`E148` `E149`** | core `SYS` | **the widest gate** — U4, U9, U29, U35, U37 |
| `E157` `E158` | core | U8, U16, U31, and every row that reports anything |
| `E163` | core | U45; and the manifest answer for schemas |
| `E153` | core `NUM` | U27's non-integer tier only |
| `E116` | core `CRY` | U36 |
| `E39` | core `EF` | U49's `notify` crossing |
| `E132` | core | babel / literate blocks; `S11` |
| `T17` | terminal lane | U2 |
| profile-hands-caps / `E32` | core | U39 → all of §7 |

**New mints owed by this lane — 7 rows, all `MINT` in the tables above:**

| | Rows | Category | Why it earns a real catalog row |
|---|---|---|---|
| core-lane | `U1` codepoint view · `U40` civil date/time | **`VAL`** | pure value modules, empty port set; consumers named |
| core-lane | `U41` told time + freshness reconciliation | **`SYS`** | a crossing. ⚑ verified 2026-08-30: `freshness-verify` has **no** catalog or ledger row — this is a mint, not an adoption |
| doc family | `U20` `U21` `U22` `U23` | **`VAL`** | each is a pure value + a total `parse`/`print`; `U24` joins them once `U40` exists |

Everything else stays **app-tier** (`U#`/`S#`, no `E#`) per the S31/S32 rehoming
precedent — including P1's seam and the `r-graph`/`r-chart` render nodes. Plus **U0**,
which is tooling, not a catalog row.

### Track P — full pipeline (16 runs, some merging several rows)

Merges are deliberate: the hard convention is **one element per run**, so where four
rows are one decision they must become **one element**, not four runs sharing a
blueprint.

| Run | Rows merged | Element | Skip test — what gets chosen wrongly without it |
|---|---|---|---|
| **P1** | U13 U14 U15 U17 | **the typed document seam** | the packing point (D-U7). Pick the closed `DocValue` sum by default and additivity dies quietly — every new document type edits a sum and forces a scriba recompile, and nobody notices until the fifth type |
| **P2** | U18 U19 | **the family's surface syntax** | whether types share one reader skeleton or each hand-rolls one. Get it wrong once and it is re-litigated per type, five times |
| **P3** | U20 | **the outline/notes value** | whether properties are typed fields or an alist, and whether TODO states are in the type or in a schema. Both are one-way doors for every note ever written |
| **P4** | U21 | **sectioned document + declared schemas** | the type/schema line (D-U6). Four separate types vs one type + four schemas is the difference between 4× machinery and 1× |
| **P5** | U22 | **table + declared column schema** | where the column schema lives — in the file, in a manifest, or in the type. Decides whether `SELF-IMPLEMENT-CATALOG.md` can ever *be* one of these |
| **P6** | U23 | **graph + typed edges** | edge typing. Collapse `[[link]]`, import, lane-dep and "cites" into one string edge and §6's whole query surface degrades to grep |
| **P7** | U25 | **diagram rendering, tiered** | the layout tier and where it stops. An untiered "render a graph" row grows into a layout engine |
| **P8** | U51 | **the derived lane** | what provenance a derived row carries. Today it carries none (`Str` puffers); pick that again and jump-to-source is unbuildable for agenda, occur and backlinks alike |
| **P9** | U1 | **codepoint string view** (core, `VAL`) | codepoints vs grapheme clusters as the editing unit, and view-type vs decode-at-use. Wrong choice touches all 62 byte-indexed sites twice |
| **P10** | U5 | **the fontification seam** (D-U1) | parse-driven vs lexer-driven faces, and what happens on a broken buffer — the case that makes the wrong answer look right |
| **P11** | U29 U30 | **the KB port + note graph** | whether the KB earns a `porttype` or is directory caps + pure folds (P3 applied); and read/write split shape |
| **P12** | U34 | **the authority gradient as a value** | the gradient is prose today (code > map > decision > bank > note). As a type it must decide what "disagree above the doc" *returns* |
| **P13** | U40 | **civil date/time** (core, `VAL`) | epoch, resolution, `Date`/`DateTime`/`Instant` split, and the no-float constraint. Everything in §7 is built on it |
| **P14** | U41 | **told time as evidence** (core) | the reconciliation shape and what divergence *does*. P5's honesty lives or dies here, and a wrong shape reads as "we added a clock" |
| **P15** | U46 | **the agenda as a query** | the query language's shape — shared with §6's U32 or not. Two query surfaces is the failure |
| **P16** | U45 | **TODO workflow as a manifest** | whether the workflow is a value (E163) or a hardcoded sum. Decides per-file workflows forever |

### Track D — an author decision first

| Decision | Blocks | Then |
|---|---|---|
| **D-U7** packing point | P1 | P1 is the run that *produces* the decision — the example is the argument, the decision doc is its output |
| **D-U2** surface syntax + roster extent | P2 | same shape: the run produces it |
| **D-U1** fontification seam | P10 | same |
| **D-U6** typed docs vs `ledger-lint` schema checks | P4, and D-U3 | decide beside D-U3 |
| **D-U3** KB mode replaces or accompanies `bin/*.py` | P11, U35–U37 | **pure author call** — no run produces it; it is a scope decision about 3,251 L of working tooling |
| **D-U4** how a `Clock` is acquired | U39, all of §7 | **pure author call** — wait for profile-hands-caps, or an interim crossing on the `env-open` precedent. One paragraph, and §7 is blocked until it exists |
| **D-U5** told-time tier + what divergence does | P14, U42 | partly produced by P14; the *tier* is the author's |

### Track S — spec-first, no example (design settled)

`U2` `U3` `U4` `U7` `U8` `U9` `U10` `U11` `U24` `U26` `U27` `U28` `U31` `U32` `U33`
`U35` `U36` `U43` `U44` `U48` — **21 rows** (`U37` too).

*(⚑ Corrected 2026-08-30 while building §2.0: `U6`, `U38`, `U47` and `U50` were listed
in two tracks each in the first draft. `U6`/`U38` are **X→S** — blocked now, light spec
after their gate; `U47`/`U50` are **M**, since both fall out of a row that precedes
them. `U19`/`U30` are **P**, folded into P2/P11, not S. Building the scope table is what
surfaced this — a row in two tracks is a row nobody owns.)*

Each still gets a SPEC before code — that is the scriba precedent and it is what
`SCRIBA-PRIMITIVE-CHECKLIST` §6 already prescribes for mechanical rows.

### Track M — mechanical; implement + gate, no artifact

`U12` (measure and write down the scale bound) · `U39` once D-U4 lands ·
`U42` once D-U5 lands · `U47` (falls out of U46) · `U50` (falls out of U35 + U40).
**5 rows.**

### Track X — blocked, design content belongs elsewhere

| Row | Owner of its design |
|---|---|
| `U16` block algebra | **E158** (`Doc`) — its own catalog row already says *"Open design: the algebra's shape, unification with `Rendering`"*. Do not draft a second blueprint |
| `U52` stream lane · `U53` remote lane | **S20b** — the linear-handle-across-keystrokes question. Both inherit it; neither can be specced before it |
| `U49` agenda daemon | **E39** (`notify` as a real row-tag crossing) + `S28`/`S29` |
| `U38` transclusion | `S26` + `S27`; revisit after them |
| `U6` structural editing | `U5`/P10's seam; light spec after |

---

## §3 · Research briefs — what each P run owes *before* it opens the pack

Standing rule: **blackbox/ABI and external-format facts are web-verified against
primary sources (man7 / kernel / the spec itself), never recalled from memory.**
In-tree facts are measured with a command, not remembered.

**P1 · the typed document seam.**
*Measure:* the 152 `(Puffer Str)` vs 7 `(Puffer A)` split; the 3 coexisting
`RendererFn` instances (`init-loader.chiral:614-616`); `Mach`'s 12-field
record-of-functions; `specialize-singleton.chiral`'s singleton guard (`:78-84`) and
`proj-idx` (`:99-118`) — **does a fn-bearing record with N>1 live instances lower, and
under what conditions?** The shipping 3-instance `RendererFn` says yes; confirm *why*,
because the whole recommendation rests on it. *External:* none. *Feeds:* D-U7.

**P2 · the family's surface syntax.**
*Measure:* `sexp.chiral`'s reader surface — what it costs to reuse. *External,
web-verified:* org-mode's element grammar, djot, and Markdown's ambiguity cases — for
the *conventional* column only. *Carry two types* (an outline and a graph): a syntax
that only looks right for one type is the failure mode. *Feeds:* D-U2.

**P3 · outline/notes value.** *Measure:* `manas-mode.chiral`'s `Focus`/`Outline`/
`OutlineNode` — the shape being generalized. *External:* org's headline/property/drawer
model. *Feeds:* U26, U43, U45.

**P4 · sectioned doc + schemas.** *Measure:* the actual section schemas of the 10
banks, 122 specs, 118 examples, 14 decisions, **plus which of `ledger-lint`'s 19
checks (A–S) are schema conformance and which are semantic** — that split is the
deliverable's own justification. *Feeds:* D-U6.

**P5 · table + column schema.** *Measure:* the column shapes of
`SELF-IMPLEMENT-CATALOG.md`, `LEDGER.md`, the `INDEX.md` family, and which lint checks
police them.

**P6 · graph + typed edges.** *Measure:* the 1,349 `[[links]]` / 71 targets; the module
import graph; `BUILD-ORDER`'s lane graph. *External:* property-graph vs typed-edge
models — light.

**P7 · diagram rendering.** *External, web-verified:* layered (Sugiyama) DAG layout —
the ranking/ordering/positioning phases, and what each tier costs. *Measure:* whether
`Rendering` can take an `r-graph` node without disturbing the APC codec
(`apc.chiral:99,222` case over the sum) and `flow-view`'s exhaustive case.

**P8 · derived lane.** *Measure:* every read-only surface today (`help.chiral`,
`flow-view.chiral`, run-view) and exactly what each throws away.

**P9 · codepoint string view.** *External, web-verified:* **UAX #29** grapheme cluster
boundaries — because "codepoint" is very likely the wrong unit and that must be
decided from the spec, not assumed. *Measure:* all 62 `str-sub`/`str-len` sites in
`str-edit.chiral`; `utf8.chiral`'s 11-case gate; **and the in-flight
`e106-linear-caps-utf8` branch — reconcile before drafting.**

**P10 · fontification seam.** *Measure:* the 3 hand-written renderers; what
`parse.chiral`/`sexp.chiral` return on malformed input (does it produce a partial tree or
an error?) — that answer *is* the decision.

**P11 · KB port + note graph.** *Measure:* `chirality-frontier route`'s ranking, the
frontmatter schema across 71 notes. *Read:* `docs/banks/port.md` + `capability.md`
before claiming the KB needs a porttype — the refraction rule applies to this run too.

**P12 · authority gradient.** *Measure:* `chirality-doc.py audit`'s gradient
implementation; the `doc-audit` SKILL's FIX/FLAG rule. *Read:* `evidence-and-split`
bank — a gradient of trust is that bank's subject, and this row may already be
refracted there.

**P13 · civil date/time.** *External, web-verified against primary sources:* the
days↔civil algorithm (Howard Hinnant's `civil_from_days`/`days_from_civil`, including
its proleptic-Gregorian domain), leap-year rules, **ISO 8601 / RFC 3339 grammar**, ISO
week-numbering. *Constraint to hold:* integer-only — no `E153` dependency. *Read:*
`docs/decision-numeric-width-pluggable.md`, so nothing re-hardcodes 64-bit.

**P14 · told time as evidence.** *Read first:* `docs/time-and-clocks.md` (the three
senses), `docs/error-and-alarm.md`, `banks/evidence-and-split`, and
`ports/clock.chiral`'s own comment — the design is substantially *already written* and
this run's job is to instantiate it, not invent it. *Measure:* whether
`freshness-verify` exists anywhere (it has **no catalog or ledger row** — verified) so
the run knows whether it is minting or adopting.

**P15 · agenda as a query.** *Measure:* U32's query surface if it exists by then —
**one query language or two is the decision**, so P15 must not run before P11.

**P16 · TODO workflow as manifest.** *Read:* E163's row and `target-linux.chiral` as
the worked instance of a manifest.

---

## §4 · The serial queue

One run at a time. Each run: draft → `--audit` → `--mark` → next.

```
  0.  U0        teach chirality-pack the U# lane                    ← before any run
 ──── the seam ────────────────────────────────────────────────────────────
  1.  D-U4      author call: how a Clock is acquired            (one paragraph,
                                                                 unblocks §7 early)
  2.  P1        the typed document seam            → D-U7
  3.  P2        the family's surface syntax        → D-U2   (carries 2 types)
 ──── the first two members ───────────────────────────────────────────────
  4.  P3        outline/notes value
  5.  P5        table + column schema
  6.  P9        codepoint string view              (core VAL; unblocks U2/U3)
 ──── the rest of the roster ──────────────────────────────────────────────
  7.  P4        sectioned doc + schemas            → D-U6  (with D-U3)
  8.  P6        graph + typed edges
  9.  P7        diagram rendering, tiered
 10.  P8        the derived lane
 11.  P10       fontification seam                 → D-U1
 ──── the knowledge base ──────────────────────────────────────────────────
 12.  P11       KB port + note graph
 13.  P12       authority gradient as a value
 ──── time ────────────────────────────────────────────────────────────────
 14.  P13       civil date/time                    (heaviest external research)
 15.  P14       told time as evidence              → D-U5
 16.  P15       agenda as a query
 17.  P16       TODO workflow as manifest
```

Track S specs interleave behind their gates; they are not in this queue because they
do not compete for the same scarce thing (a design decision).

**Why this order, in three claims worth arguing with:**
- **D-U4 is first among decisions and costs a paragraph.** It is the only gate on all
  of §7 and it needs no run — leaving it late strands twelve rows for no reason.
- **P2 carries two types on purpose.** Everything after it inherits the syntax; a
  single-type example would validate a syntax that does not generalise.
- **P9 sits early despite being core-lane**, because U2/U3 (display width, soft wrap)
  gate aligned tables and diagrams, and those are the roster's first visible payoff.

---

## §5 · Per-run protocol

Unchanged from the repo's discipline; restated so a run does not have to re-derive it.

| Stage | Command | May write |
|---|---|---|
| pre-run | `python3 tools/pack/pack.py <id> <slug>` | `examples/<id>-<slug>.md` + its INDEX row. **Never** `scaffold/`, `lib/`, `TUI/` |
| audit | `python3 tools/pack/pack.py <id> --audit example` | FIX in place on the audited artifact only; FLAG surfaced verbatim, never self-resolved |
| promote | `python3 tools/pack/pack.py <id> --mark reviewed` | the status flip; audits never flip state |
| spec | `python3 tools/pack/pack.py <id> --spec` | `.planning/specs/<id>-<slug>-SPEC.md`. **Never** the example, `scaffold/`, `lib/` |
| audit | `python3 tools/pack/pack.py <id> --audit spec` | as above |
| promote | `python3 tools/pack/pack.py <id> --mark audited` | |
| implement | follow the SPEC | build with **B1 only** — Python compiles nothing, ever |

Reading discipline for a pre-run: **the pack bundle + the scaffolded file, plus one
single-fact `grep`.** Not the glossary, not `PRINCIPLES.md`, not sibling examples —
the bundle's `_CHEATSHEET.md` replaces them. That is the cost win and it is measured.

⚑ **Rows touching a `Flow`/`PureFn`/`Rendering` constructor force a scriba recompile**
(`flow-view.chiral` and `apc.chiral` both case exhaustively). P7 adds `r-graph`; P1 may
change `RendererFn`. Budget the rebuild in those specs.

---

## §6 · Gates

### §6.0 · This instantiates a contract; it does not invent one

`docs/testing-floors.md` is the contract and `docs/banks/verification.md` is its
refraction. Neither is restated here — this section says **what they mean for a lane
that has no Rocq spec, no reference interpreter, and no differential C leg.** Three
lines from them govern everything below:

> Verification is **a layered set of independent instruments, each of which can only
> see what is below its branch point, ranked by the provenance of the expectation it
> checks against** — not a suite, not a number, and not the fixpoint.

> **Rule 1** — a differential only covers what is BELOW its branch point. Above it,
> both legs run the same code, so both are wrong the same way and the comparison
> reports `ok`.

> **The run-the-mutant rule** — a gate row must **name a mutant that falsifies it, and
> the mutant must be RUN**, reverted afterwards, with its measured failure recorded.
> Naming a mutant is a claim about the gate; running it is the evidence.

⚑ **The lane's structural handicap, stated once.** The compiler lane has four
independent instruments (native behavioural, Rocq, the DDC C leg, the Python oracle).
The user layer has **none of them by default**. So every gate below is explicit about
which of the four expectation ranks it can actually reach, because the honest default
here is rank 4 — a golden capture — and *rank 4 unlabelled is a finding*.

### §6.1 · Which floor a U-row's test lands in

| Floor | Role for this lane | U-lane usage |
|---|---|---|
| **native-behavioral** (`chirality test-native`) | **the primary gate** — a `.chiral` program whose *meaning* fixes an exit code, run natively, zero Python | **every U row's unit test goes here**, as a sample walked by the native test-runner — not as a side script. A test outside the gating floor is not a gate |
| **rocq** | unreachable for this lane today | — |
| **python oracle** | ADVISORY for the compiler | ⚑ **but see §6.2 — for the KB rows the Python tier is a genuine rank-2 instrument**, and it is the only place in this lane where one exists |

A U-row test that lives only in a shell script or only in a PTY driver is **advisory by
construction**. Say so in the SPEC rather than letting it read as gating.

### §6.2 · Expectation provenance — what rank each run can actually reach

Ranks (contract §*Expectation provenance*): **1** external · **2** independent in-house
reference or a fixed committed artifact · **3** the meaning of the form, hand-derived
before running anything · **4** implementation-derived golden capture, *permissible only
when labelled a regression net*.

| Run | Best reachable rank | The source, named |
|---|---|---|
| **P9** codepoint view | **1** | **UAX #29** supplies grapheme-break conformance vectors. Use them; this is one of only two runs in the lane that can make a correctness claim rather than a regression claim |
| **P13** civil date/time | **1** | ISO 8601 / RFC 3339 grammar + published civil↔days test vectors, plus known-hard dates (1900, 2000, the proleptic domain edges) |
| **P11 · P12 · U31 · U33 · U35 · U36** KB rows | **2** | ⚑ **`bin/*.py` is a real independent in-house reference** — `ledger-lint`'s 19 checks, `chirality-doc`'s gradient, `chirality-frontier route` are a genuine second computation over the same 264 files. Run both, diff the verdicts. **This is the only rank-2 instrument the user layer has, it already exists, and it costs nothing to keep** |
| **P3–P6** document types | **3** | a hand-written corpus: files whose parsed value is written down by hand *before* the parser runs |
| **P1** the seam · **P8** derived lane · **U26** | **3**, with a **4** floor | behaviour derived from what the seam is supposed to mean; the PTY frame capture is the regression net beneath it |
| **P7** diagram · **P10** fontification · **U2/U3** display | **4**, labelled | frame captures. There is no independent renderer to differ against; say "regression net" in the SPEC and do not dress it up |

⚑ **The D-U3 consequence.** Rank 2 exists in this lane *only while the Python tier
runs*. That reframes D-U3: beside "replace" and "sit beside" there is a third option
the compiler lane already proved — **keep Python as the differential oracle and retire
it the same way** (`testing-floors.md` §*Why Python is advisory*: advisory, reported,
retired when the native instrument covers the area). Deleting `bin/*.py` early does not
just cost tooling; it deletes the lane's only independent expectation.

### §6.3 · The falsifier table — one named mutant per run, to be RUN

Per the run-the-mutant rule. Each SPEC §5 must carry its row, run it, revert it, and
record the **measured** failure. A mutant the gate *misses* is also a measurement and
must be recorded — that is the only thing that says where the gate stops.

| Run | Mutant to introduce | The gate must |
|---|---|---|
| **P1** seam | re-point one document mode's renderer at the buffer's `Str` instead of its value | fail — otherwise the gate is textual, not behavioural (Rule 3) |
| **P1** additivity | add a second document type and touch a shared sum or an exhaustive case | fail the additivity gate (§6.5) |
| **P2** syntax | emit a `print` that drops one field the reader accepts | fail the round-trip gate on the **hand-written** corpus |
| **P3** outline | drop a property from `print` while `parse` still reads it | fail — this is the exact shape a print-derived-from-parse round-trip **misses**, so it doubles as the check on §6.5's honest limit |
| **P4** schemas | feed a bank file with a section out of order / one missing | fail the schema gate; **and** the corresponding `ledger-lint` check must agree (rank 2) |
| **P5** table | widen a row past the declared column schema | fail |
| **P6** graph | collapse two distinct edge types into one string edge | a backlink/query gate must fail — if it stays green, the edge typing bought nothing |
| **P7** diagram | perturb layout ranking so two nodes swap rank | frame capture must diff; if it does not, the fixture renders nothing structural |
| **P8** derived lane | strip provenance from a derived row | jump-to-source must fail |
| **P9** codepoints | swap one codepoint index back to a byte index | a cursor motion over a multi-byte fixture must fail. **Fixture must contain a 2-, 3- and 4-byte sequence** — an ASCII-only fixture passes both implementations |
| **P10** fontification | feed a syntactically broken buffer | must produce the *decided* behaviour, not a crash and not silently-no-faces |
| **P11** KB port | give the reader cap a write path | the write must be refused. ⚑ **See §6.6 — uid 0 masks exactly this** |
| **P12** gradient | invert two adjacent authority tiers | a case that should FLAG must stop FLAGging — if the verdict is unchanged the gradient is decorative |
| **P13** dates | make 1900 a leap year | the external vectors must catch it |
| **P14** told time | feed a rolled-back told time | must raise the divergence alarm, not silently accept |
| **P15** agenda | drop the deadline filter from the query | a fixture with a past deadline must stop appearing |
| **P16** TODO | swap two states in the workflow manifest | the transition gate must refuse |

### §6.4 · The four standing gates, and their instruments

Every row passes all four that apply to it.

**A · Artifact gates** — the two audit charters, run by `chirality-pack --audit`, verbatim:

| Level | The 5 checks |
|---|---|
| **example** | 1 phantom-feature (vs the bank slices) · 2 settled-decision conformance · 3 build-state accuracy (nothing rounded to done *or* to undone) · 4 syntax legality · 5 internal consistency (§5 exhibits exactly what §4 claims) |
| **spec** | 1 citation truth · 2 baseline honesty (no respeccing a built shard) · 3 right homes (vs the banks' cross-cuts) · 4 **gate soundness** — green-line arithmetic right, tests named, differential floors stated · 5 disposition discipline (nothing decidable parked as NEEDS-AUTHOR; nothing author-tier silently RESOLVED) |

Protocol both levels: **FIX** mechanical defects in place on the audited artifact only ·
**FLAG** author-tier issues verbatim, never self-resolved · promote with `--mark` only
if no FLAG blocks. Audits never flip state themselves.

**B · Build gates.**
- `bin/scriba` compiles clean — **B1 only**, Python compiles nothing, ever.
- Paren balance before building (`bin/paren-audit.py`) — hand-nested parens bite.
- ⚑ **Recompile triggers:** any row touching a `Flow` / `PureFn` / `Rendering`
  constructor forces a scriba recompile — `flow-view.chiral` and `apc.chiral`
  (`:99,:222`) both case exhaustively. **P7 adds `r-graph`; P1 may change
  `RendererFn`; U27 adds `r-chart`.** Budget it in those SPECs.
- **The self-host fixpoint is NOT a gate for this lane** — no U row changes compiler
  sources. If one ever does: regenerate the blob first (`scaffold/build/blob.chiral`
  goes stale), and remember the fixpoint proves **stability, not correctness**.

**C · Behavioural gates.**
- A **mesh-free unit test with real assertions**, landed as a native-suite sample.
- A **PTY run** proving the behaviour end to end (`bin/scriba-run-smoke.py` shape).
- A **differential PTY smoke** where the change is meant to be invisible —
  `bin/scriba-edit-smoke.py`: run the pre-change binary, run the post-change binary,
  diff the frame files; **an empty diff is the gate, a diff is a finding.** This is
  the S18 instrument and it is rank 4: label it a regression net.

**D · Systemic gates** — §6.5.

### §6.5 · The systemic gates, and one honest limit

**The additivity gate — fires once, and it is the plan's stop condition.**
After P1 + P2 + the first type, adding the **second** type must touch exactly *one
registry row and one module*: zero new `command-loop-inner` arms, zero new `VimMode`
variants, zero new threaded parameters, zero edits to the `:`-command dispatch, and
zero edits to a shared sum. If it touches any of those, **D-U7 was answered wrongly and
the plan stops** rather than adding a third type onto a bad seam. This is
`SCRIBA-PRIMITIVE-CHECKLIST` §5's acceptance test, fired as a gate instead of quoted as
an aspiration.

**The round-trip gate — per document type, with its limit stated.**
`parse(print(v)) ≡ v` structurally, as a real assertion, for every roster member.
⚑ **Its honest limit, which must be written into each SPEC:** if `print` is authored as
the inverse of `parse`, the two share a branch point and the round-trip is
**common-mode** — Rule 1, met in this lane. It then catches *structural loss* and not
semantic error, which makes it **rank 2 at best and rank 4 when print is derived from
parse**. The pairing that fixes it is the rank-3 hand-written corpus (§6.2), and P3's
mutant is the check that the pairing is real.

**The no-second-truth gate.** No document type may keep both a `Str` and a typed value
as live state. `Str` is the *serialization*; the value is the truth. A memoised parse
alongside a mutable text buffer is option (d) of D-U7 arriving through the back door.

**The no-new-phantom gate.** No U row may ship naming a chirality gap that a bank already
refracts. This is audit check 1 at example level; restated as a systemic gate because
the U lane touches four surfaces and the failure mode compounds.

**Doc-tier green.** `tools/ledger-lint/ledger-lint.py` clean after every row that touches a ledger,
an INDEX, or a bank; `tools/doc/doc.py audit <node>` for the semantic residue. A row
that adds a catalog entry and leaves lint red has not landed.

**CONFORMANCE-MAP row.** Build-state is authoritative from
`.planning/audit/CONFORMANCE-MAP.md`, not from the checklist and not from this plan. A
row is `built` when the map says so.

### §6.6 · How a gate in this lane will lie to you

The five measured environment traps (`SCRIBA-PRIMITIVE-CHECKLIST` §2b), mapped to the
runs where each actually bites — plus two specific to this lane.

| Trap | Where it bites here |
|---|---|
| **uid 0 masks permission errors** — this sandbox runs as root, and a probe with `CAP_DAC_OVERRIDE` succeeds where a real user's fails | ⚑ **P11's mutant is exactly this shape.** "The reader cap cannot write" is a permission claim, and under uid 0 it may pass while being false. **Re-run under a dropped uid, or reason from the mode bits.** Also U9 (atomic save), U29, U37 |
| **ELF size is not a signal — the image is zero-padded** | adding a document type may leave the binary byte-identical in size while 300 kB of content differs. **Compare content or behaviour, never size** |
| **`grep -r` does not follow symlinks; `-R` does** | `TUI/scriba` ↔ `scaffold/lib/scriba` is a symlink; a `-r` sweep over the editor silently finds nothing. Use `-R` or a file-walk |
| **`stat`/inode reasoning about file identity** | same symlink web. `ls -l` answers it outright |
| **a stale `scaffold/build/blob.chiral`** | only if a U row ever touches compiler sources; regenerate before any fixpoint claim |
| **an empty PTY frame diff** | may mean the path was never walked, not that nothing changed. S18's own smoke *"walks ~12 of 79 defs, touching none of the ~40 manas/catalog/runview/chat defs"* — **state the walked fraction in the SPEC** or the empty diff is decoration |
| **a green round-trip** | may mean `print` is `parse`'s inverse by construction (§6.5). Pair it with the hand-written corpus or label it rank 4 |

### §6.7 · When each gate fires

```
  pre-run drafted        →  A: audit charter (example, 5 checks)  →  --mark reviewed
  SPEC written           →  A: audit charter (spec, 5 checks)     →  --mark audited
       ⇧ check 4 is gate soundness: the falsifier row (§6.3) must be
         named IN the SPEC, with its rank (§6.2), before code exists
  implementing           →  B: paren balance · B1 build clean
                         →  C: native-suite sample, real assertions
                         →  C: PTY run end-to-end
                         →  C: differential frame smoke, where invisibility is claimed
                         →  §6.3: RUN the mutant, revert, record the measured failure
  after the 2nd type     →  D: the additivity gate — plan stops here if it fails
  per type               →  D: round-trip, with its rank labelled
  row touches a ledger   →  D: ledger-lint clean · CONFORMANCE-MAP row updated
```

## §7 · What must be minted before any of this runs

From `USER-LAYER-GAP.md` §11, in the order this plan needs them:

1. **U0** — the pack change (tooling, not a catalog row).
2. **`VAL` rows** for P9 (codepoint string view) and P13 (civil date/time) — core
   elements with named consumers, so they earn `E#` numbers, not `U#`.
3. **A `SYS` row** for P14's told-time acquisition + freshness reconciliation —
   ⚑ **verify first** whether `freshness-verify` already has a row; measured
   2026-08-30 it has **none**, so this is a mint, not an adoption.
4. **`APP` rows** for P1's seam and the render nodes (`r-graph`, `r-chart`) — app-tier,
   so `U#`/`S#`, **not** `E#`, per the S31/S32 rehoming precedent.
5. Each document type (P3–P6) as a `VAL` row — pure value + total `parse`/`print`,
   empty port set.

No row in §2 may be cited by a spec before its dependency is a real row. That is the
no-phantom-dep rule and it is the reason this section exists rather than a note saying
"mint as needed".

---

## §8 · Anchors

`.planning/USER-LAYER-GAP.md` (the 53 `U#` rows this plans) ·
`.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` (the `S#` floor; §6 pipeline discipline) ·
`.planning/BUILD-ORDER.md` (cross-lane sequencing owner) ·
`.planning/LEDGER.md` (`VAL` / `SYS` / `APP` / `CRY` categories) ·
**`docs/testing-floors.md`** (the floors contract §6 instantiates — provenance ranks,
the run-the-mutant rule, the coverage map's Rules 1 and 3) ·
**`docs/banks/verification.md`** (its refraction — instruments, plural and independent,
each blind above its own branch point) ·
`.planning/audit/CONFORMANCE-MAP.md` (build-state authority) ·
`examples/INDEX.md` + `.planning/specs/` (the artifact tiers) ·
`.claude/skills/worked-example/SKILL.md` · `.claude/skills/example-to-spec/SKILL.md` ·
`.claude/skills/pipeline-audit/SKILL.md` · `tools/pack/pack.py` (`:508`, the blocker).
