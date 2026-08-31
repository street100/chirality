# The user layer — the gap outline
### editor · document · knowledge base · agenda

**Minted 2026-08-30.** This is an **outline of coverage**, not a plan and not a
build. No row here is specced, nothing is minted into
`.planning/SELF-IMPLEMENT-CATALOG.md` or `.planning/LEDGER.md` yet, and no code is
touched. §11 is the mint queue that has to run *before* any row here may be cited by
a spec (the no-phantom-dep rule).

The question this answers: **what stands between scriba today and (a) a decently
full-fledged text editor, (b) an org-mode-grade document/outline substrate with real
scheduling, (c) a full knowledge-base management surface — and what file types of our
own that needs.**

The question it does **not** answer: how any of it is built, in what order beyond a
sketch, or whether it should be. Those are spec-tier and author-tier respectively.

**State lives in `.planning/USER-LAYER-TRACKER.md`** — what is done, what is
running, what is next. Neither this doc nor the plan tracks state.

**Companion:** `.planning/USER-LAYER-PIPELINE-PLAN.md` sorts every row below into
pipeline / spec-first / decision-first / mechanical, with a research brief per run and
a serial queue. Read this doc for *what the gap is*; read that one for *how each row
gets built*.

**Lane:** this doc opens `U#`, a fourth lane beside core `E#`, terminal `T#`, scriba
`S#`. It is deliberately not more `S#`: `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` owns
`S#` and is scoped to *the primitive floor* — it ends with the line *"the floor is
done here; the user layer can be built additively."* `U#` is what gets built
additively on top. Two docs minting into one number space would collide.

---

## §0 · How to read this

**The refraction rule governs the whole document.** chirality refracts conventional
monoliths: a thing that is ONE feature elsewhere is here a **sum of shards**, each in
its own principled home, usually mostly already built. Naming a phantom feature that
is already refracted is the cardinal working error in this repo. So §3 — *what is
already homed* — comes **before** any gap table, and every row below either cites its
home or says honestly that it has none.

**State vocabulary**, reused verbatim from `.planning/LANGUAGE-INVENTORY.md` so the
two axes read the same way:

| State | Means |
|---|---|
| `HAVE` | built and live |
| `MINTED E###` / `S##` | missing, but already a cataloged element with a named consumer |
| `GAP` | missing and **not** minted — no catalog row exists; §11 says which of these earn one |
| `DELIBERATE` | absent **by decision** — do not "fix"; the decision is cited |

Plus the checklist's row states: `design` (specced-able now) · `blocked` (named gate
first) · `decide` (an author decision must land first).

**The principles that actually decide things here** (not decoration — each one
settles a specific row below):

- **P1 · express everything.** The KB and agenda tooling that exists today is
  ~3,251 L of Python outside the language. Anything the framework cannot express is
  ungoverned. This is the whole motive for §6.
- **P2 · everything is a process; the type is the whole cost.** A note, an agenda
  query, a fontifier — each is a process whose type carries its ports and its cost.
- **P3 · govern the ports.** A KB *reader* and a KB *writer* are different port sets,
  therefore different types, therefore a real split (the E148/E149 pattern applied one
  level up).
- **P4 · the safe path is the cheap path.** The acceptance test of the `S#` floor —
  *adding a surface touches one registry row and one module* — is exactly what makes
  §5–§7 affordable. If a new mode still costs a `VimMode` variant, this outline is
  premature.
- **P5 · split what you cannot prove.** Told time is unprovable (§7). It enters as
  evidence, not as truth.

**The thesis that decides the shape** (`docs/live-environment.md`): *scriba isn't an
editor that can view things; it's the view-anything, and "editor" is what the
port-viewer looks like when the port happens to be a text buffer.* And: **Emacs puts
uniformity in the DATA (untyped text, every mode reparses meaning it already had);
chirality puts uniformity in the PORT.** Every row below is graded against that. An
org-mode feature that is a regexp scan over text in Emacs must come back here as a
*typed value plus a query*, or it has been ported rather than refracted.

---

## §1 · Measured baseline — 2026-08-30, working tree

| Measure | Value | How |
|---|---|---|
| scriba source | **10,481 L** across 28 modules | `wc -l TUI/scriba/*.chiral` |
| `command-loop.chiral` | 2,545 L | unchanged across S18 (S18's win was bytes, not lines) |
| `str-edit.chiral` — the whole text engine | **1,225 L** | flat-text motions, objects, find/till, brackets |
| Modes registered in the `Mode` registry | **3** (`Str`, `chirality`, `manas`) | `init-loader.chiral:614-616` |
| Written-but-inert modules | `window` 400 · `flook` 268 · `help` 248 | imported by nobody |
| Editor state | `editor-state.chiral`, 125 L | **S18 BUILT** 2026-08-23 |
| Pure externs (the floor) | **32** | `prelude.chiral` |
| Crossings | **50** | `ports.chiral` |
| KB corpus this must manage | **73** `docs/*.md`, 71 with `node:` frontmatter, **10 banks**, **1,349** `[[link]]` occurrences over **71** distinct targets | `grep` |
| Python tooling that manages it today | **3,251 L** — `ledger-lint` 1033 · `chirality-frontier` 650 · `chirality-pack` 636 · `chirality-capture` 619 · `chirality-doc` 313 | `wc -l bin/*.py` |
| Schema'd documents already in the tree | **~264** — 10 banks (6-part schema) · 122 specs · 118 examples · 14 decisions | `ls` |
| Lint checks holding those schemas up | **19** (A–S), in Python | `tools/ledger-lint/ledger-lint.py` |
| `Rendering` node kinds already built | **8** — `r-text` `r-table` `r-section` `r-tree` `r-lines` `r-face` `r-hole` `r-stream` | `render.chiral:6` |
| Org / agenda / roam prior art in the tree | **zero** | `grep -ril 'org-mode\|org-roam\|agenda' .planning docs` |

Two measured facts that shape everything below, both verified by reading source:

1. **`str-edit.chiral` is byte-indexed.** 62 uses of `str-sub`/`str-len`, **zero**
   occurrences of `utf8` or `codepoint`. A UTF-8 decoder exists (`utf8.chiral`, 105 L,
   RFC 3629, 11-case gate) and `str-edit` does not import it. Cursor motion, `x`,
   text objects and column arithmetic all count bytes.
   *(⚑ The current branch is `e106-linear-caps-utf8` — reconcile with in-flight work
   before quoting this.)*
2. **A mode's renderer is handed a `Str`, not the buffer's value.** `render.chiral:16`
   — `(rf (fn (-> Str (Pair I64 I64) I64 Rendering)))`. `Puffer` is polymorphic and the
   `Mode` registry is keyed by `type-name`, but the renderer signature discards the
   type, so **every mode must reparse text exactly like Emacs, because the type says
   so.** §5 is built on this.
3. **There is no wall clock, and that is a decision, not an omission.**
   `scaffold/lib/ports/clock.chiral:7` — *"there is no wall clock (CLOCK_REALTIME is
   B-untrusted time, freshness-verify's)"*, decision #4, 2026-07-27. `Clock` and
   `Timer` are split porttypes on purpose. See §7, which is built on this.

---

## §2 · What "the floor" already promises — do not re-catalog it

`.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` owns `S18–S32`: the editor-state record
(built), the `:`-command registry, buffer list, buffer-local slots, the
orchestrator-node split, help/apropos, window tree, dired, markers, overlays, hooks,
init file, macros, and the async pair. **Every one of those is assumed done by this
document and is not restated as a gap.**

The one line to carry forward is that checklist's §5 acceptance test, because it is
the precondition for this entire outline:

> The floor is finished when adding a new user-layer surface touches exactly two
> things: **one registry row and one new module** — zero new `command-loop-inner`
> arms, zero new `VimMode` variants, zero new threaded parameters, zero edits to the
> `:`-command dispatch.

§4–§7 add **four** surfaces. If the floor is not done, this outline costs four
`VimMode` variants and four nested-`case` arms, which is how the current mess was
made. **`S19`/`S20`/`S21` are the hard gate on everything here**, and `S26`
(edit-stable markers) + `S27` (overlays) are the gate on anything that anchors into
text — which is most of §6.

---

## §3 · The refraction check — what is ALREADY homed

Read this before naming anything below a gap. Each row is a thing one would naively
list as missing, and where it actually lives.

| The thing you'd name as missing | Where it already is | State |
|---|---|---|
| "we need an outline / tree widget" | **`manas-mode.chiral` (1,034 L)** already has `Focus` (a closed sum of navigable identities), `Outline` (doc + cursor + expanded), `OutlineNode` (depth/focus/text/expandable), flatten-and-render, and `j/k/l` navigation — the whole cursor-outline model, built 2026-08-16 (`.planning/SCRIBA-OUTLINE-PLAN.md`). An org outline **is that shape over a different document type.** | `HAVE` — **generalize, never rebuild** |
| "we need a config/notes file format" | **E163 — a manifest module kind**, chirality's replacement for JSON/TOML: pure B-referent data, empty port set, no lambdas, ordinary type-checked chirality in the blob. *"No parser, no escaping story, no schema language."* `target-linux.chiral` already is one. | `MINTED E163` (open choice inside it) |
| "we need to write structured values back to disk" | **E146** — value→source serializer, `config->source : (-> Config Str)`, with the round-trip gate `parse(source(v))` ≡ `v`. | `MINTED E146` |
| "we need a formatter / template engine / printf" | **E158 — `Doc`**, a closed formatting sum with `doc->str` / `doc->rendering` / `doc->json` as chosen exits. Consumes E157. | `MINTED E158` |
| "we need error messages with locations" | **E157 — diagnostics as typed values**, a closed `Reason` sum with evidence. Its own row says it *"unlocks navigable errors in scriba (both sites of a redeclare, foldable chains) because the compiler is itself chirality."* | `MINTED E157` |
| "we need a timer / scheduler for the agenda" | **`supervisor.chiral` (E42, BUILT v1)** — an `AlarmSet`, `(alarm due-ms rid)`, `k-resume dt` re-arming forward from now, over a linear `SockVec` + `Clock`. That *is* the alarm scheduler. Its `notify` is a **stub extern** standing for the handler port, gated on **E39** (effect algebra / typed rows). | `HAVE` (v1) + `MINTED E39` for the crossing |
| "we need monotonic time" | `time-mono : (=> (1 c Clock) TimeR)`, `sleep-ms` — `ports/clock.chiral`. Clock and Timer split on purpose. | `HAVE` |
| "we need a wall clock for dates" | **`DELIBERATE` absence.** `clock.chiral:7` and `docs/time-and-clocks.md`: told time is a **B referent** — untrusted substrate reached through a port, turned into evidence by `freshness-verify` against the register-anchored monotonic counter. See §7; this is the most important row in the table. | `DELIBERATE` + an unbuilt evidence leg |
| "we need sort / string ordering" | **E152 BUILT** (comparator-passed stable merge sort, `collections.chiral`). **E151a** landed `string-utils.chiral` as the string owner (213 L, canonical `str-cmp` at `:80`); E151's *duplicate retirement* is still open. | `HAVE` / `MINTED E151` |
| "we need Map/Set for a note graph" | AVL `Map` + `Set`, comparator passed explicitly — `collections.chiral`. | `HAVE` |
| "we need a directory listing / file mtime" | **E148** (`getdents64` + `stat`), **E149** (`unlink`/`rename`/`mkdir`, split because write authority is its own grant). | `MINTED E148/E149` |
| "we need `scriba <file>`" | **E150** — own `argv`. | `MINTED E150` |
| "we need UTF-8" | `utf8.chiral`, RFC 3629, 11-case gate — **exists and `str-edit` does not import it.** The gap is adoption, not the decoder. | `HAVE` (unadopted) |
| "we need a rich render vocabulary — tables, folds, trees, faces" | **`Rendering` already has all of it** — `r-table` (headers + nested rows), `r-section` (title/collapsed/body), `r-tree` (children + selected), `r-lines`, `r-face`, `r-hole`, `r-stream` (`render.chiral:6`). The "render fancily" half of §5 is **built and shipping**; only a diagram node and a chart node are missing. | `HAVE` |
| "we need a schema language for our note/bank/spec formats" | **`tools/ledger-lint/ledger-lint.py`'s 19 checks are that schema**, enforced in Python over ~264 files. The schema exists; it is just not a type. | `HAVE` (in the wrong language) |
| "we need a subprocess / shell mode" | `proc-spawn` (E33) + pty acquisition (E104) + `term.chiral` + `vt-parser.chiral`. | `HAVE` |
| "we need encryption for private notes" | `secret.chiral` (E40, custody) + the `CRY` ladder **E114–E119** already reserved (entropy, rotations, SHA, HMAC/HKDF, AEAD, curve25519). | `MINTED E114–E119` |
| "we need a content hash for staleness digests" | **E116** (SHA), already slotted in `CRY`. `ledger-lint` check I does this in Python today. | `MINTED E116` |
| "we need a regex engine for note queries" | `DELIBERATE-ish` — the boundary-sums discipline prefers **parsers over patterns**. Reconsider only with a real consumer; a typed note graph is not one. | `DELIBERATE` |
| "we need a *live* extension mechanism for user modes" | **RESOLVED D-S1**, `docs/decision-user-layer-extensibility.md`: the user layer extends **in chirality, live** (code, not data); `S11` stays an init-file loader gated on `E132`; hooks are the observation half of the one model, not a rival mechanism. **Do not re-open.** | `RESOLVED` |

**What has no home at all** — the genuinely new territory, and therefore the real
content of §4–§7:

1. Codepoint-correct text editing and display width.
2. A document value richer than "a list of lines" — headings, tags, properties,
   timestamps, blocks.
3. A file type of our own to carry it.
4. A note **graph** (links, backlinks, integrity) as a typed value.
5. Calendar/civil time as a type, and the evidence leg that makes told time usable.
6. Multi-file search, and anything that anchors a result back into text.

---

## §4 · Surface E — a decently full-fledged text editor

Rows the `S#` floor does **not** cover. Everything here is gated on `S18` (built) and
most of it on `S19`/`S21`.

| U# | Element | State | Gate | Note |
|----|---------|-------|------|------|
| **U1** | **Codepoint-correct editing.** `str-edit.chiral` (1,225 L, 62 byte-indexed `str-sub`/`str-len` sites) counts bytes; `utf8.chiral` exists and is not imported. Motions, `x`, text objects, `f`/`t`, column math and `$` are all affected. The chirality-shaped answer is not "sprinkle decode calls" — it is a **codepoint-indexed string view** the zipper is written against, so the invariant is structural (P4: the correct path becomes the only path). | `design` | S18 · reconcile with branch `e106-linear-caps-utf8` | the single largest correctness gap in the editor |
| **U2** | **Display width.** `wcwidth` is stubbed to 1 (`TUI/PRIMITIVE-AUDIT.md` calls this grid-correctness, not polish, at T17-tier). CJK and emoji misalign every frame. Separate shard from U1: editing is codepoints, display is columns. | `blocked` | **T17-tier** · U1 | a terminal-lane row scriba consumes |
| **U3** | **Soft wrap + horizontal scroll.** `SCRIBA-STATE.md` records long rows truncating at terminal width as *"cosmetic, not cataloged."* **That verdict does not survive §5–§7:** a KB/notes surface is prose-first, and wrapping is its primary reading mode. Promote it. | `design` | S18 | the `chat-view.chiral` word-wrapper is the working precedent |
| **U4** | **Multi-file search + a result surface.** isearch and query-replace are buffer-local; there is no cross-file search, no result list, no jump-to-hit. Also the primary KB primitive (§6). | `blocked` | **E148** · S19 · S26 | one implementation serves §4 and §6 |
| **U5** | **Fontification from the real parse, not a re-lexer.** Three renderers are hand-written face-taggers. **The compiler is chirality**: `sexp.chiral` / `parse.chiral` already produce the true syntax tree, so a chirality-mode highlighter that re-lexes is Emacs's mistake (uniformity in the data) reproduced. Design content: the seam between a parse and a face run, and what happens on a syntactically broken buffer. | `decide` | **D-U1** · S27 | strong worked-example candidate |
| **U6** | **Structural editing + indentation** over that same parse (paredit-shaped, not regexp-shaped). | `blocked` | U5 | |
| **U7** | **In-buffer completion-at-point.** `completion.chiral` (64 L) is minibuffer prefix completion only — no in-buffer surface, no source seam. §6 needs `[[link]]` completion over the note graph; §7 needs tag completion. | `design` | S21 · U4 | the *seam* is the deliverable, not any one source |
| **U8** | **Compiler diagnostics in the buffer as values.** E157's `Reason` sum, anchored by S26 markers, rendered by S27 overlays. Emacs parses compiler *text*; chirality has the compiler in-process. | `blocked` | **E157** · S26 · S27 | |
| **U9** | **File safety: atomic save, external-change detection, revert, autosave.** No `mtime` check (E148 `stat`), no write-temp-then-rename (E149), no backup. The floor checklist parks autosave as *"belongs with a persistence policy, not the floor"* — §6 **is** that policy, so it graduates here. | `blocked` | E148 · E149 | |
| **U10** | **Jumplist + `.` repeat.** `C-o`/`C-i` and last-change repeat are absent; both are ordinary once ops and keys are data. | `design` | S21 · S30 | cheap |
| **U11** | **Encoding + line-ending policy.** `save-puffer` appends a final newline; there is no CRLF handling and no declared encoding. Should be a closed sum on the buffer, not a guess. | `design` | U1 | boundary-sums |
| **U12** | **The honest scale bound.** The buffer is `LineCtx` = `(above (List Str)) left right (below (List Str))`, whole file in memory, and `List` is the only sequence type (no O(1) array — `LANGUAGE-INVENTORY` §3 `GAP`). This is fine for notes and wrong for a 100k-line log. Deliverable: **measure it and state the bound in the docs**, not a rope. | `design` | — | name the limit; do not silently pretend |

---

## §5 · Surface D — the document type FAMILY, and our own file types

### The correction this section exists to make

An earlier draft of this section proposed **one** document type with many views over
it, on a "minimality" argument. That was wrong, and wrong in a specific, diagnosable
way: **one substrate with N views over it is the Emacs shape wearing chirality clothes.**
Emacs has one data type (text) and N modes that reparse meaning the text already had.
"One `Note` value and N views" is the same move one level up — a union type that every
consumer must case over, with the real distinctions pushed into variants instead of
into types.

`docs/live-environment.md` says what to do instead: *uniformity lives in a common port
vocabulary, and **each session's payload type differs per instance**.* The
[[splitting-law]] agrees — a graph and a bullet outline have different value shapes,
therefore different types, therefore a **real** split. Collapsing them is the spurious
*join*.

So: **the extension IS the type.** `.graph` is not a naming convention that a mode
sniffs; it names the document type, which selects the value, the reader, the renderer,
the keymap, the ops, and the operations that are even expressible. That is what makes
an extension semantic enough to sort by, and it is strictly stronger than what Emacs
gets from `auto-mode-alist`.

### ⚑ The measured blocker — the renderer takes a `Str`

`render.chiral:16` — `(data RendererFn (rf (fn (-> Str (Pair I64 I64) I64 Rendering))))`.

**A mode's renderer is handed the raw string.** `Puffer` is already polymorphic
(`(Puffer A)`, a typed lens on a port) and `Mode` is already keyed by the buffer's
`type-name` — but the renderer signature throws the type away and hands over text. So
every mode today *must* reparse, exactly like Emacs, **because the type says so**.
This is not a missing feature; it is the Emacs mistake baked into a five-line
declaration, and it is the one thing that has to change before any typed document type
is expressible. **U13 is that change, and it gates the whole family.**

### ⚑ The other half — the fancy rendering vocabulary already exists

`render.chiral:6` — `Rendering` is already a closed sum with **`r-table` (headers +
rows), `r-section` (title, collapsed, body), `r-tree` (children + selected),
`r-lines`, `r-face`, `r-hole`, `r-stream`.** Nested tables, foldable sections, trees
with a selection, faces — the "render fancily" half is **built and shipping**. What it
lacks is a diagram node and a chart node (U25/U27).

So the family is cheaper than it looks: a rich render vocabulary exists, a typed
buffer exists, a mode registry exists. The missing pieces are one signature (U13), a
per-type reader, and one small module per type.

### The three legs every document type has

Each type is **type-easily / render-fancily**, which is three things, not one:

```
    surface syntax   →   typed value   →   Rendering
    (fast to type,       (the truth,       (fancy, and N of
     line-oriented)       checkable)        them per type)
```

The surface is minimal *per type* — that is where "very minimal" belongs. The value is
narrow. The renderings are as rich as the terminal allows, and **there can be several
per type**, which is the port-viewer payoff Emacs cannot have: one typed graph value
renders as a diagram, an indented tree, or an adjacency table with **no reparse**,
because nothing was ever parsed twice.

### Two different `Str` lanes — keep one, delete the other

"Should the renderer keep a `Str` lane?" splits into two questions that look alike
and have opposite answers:

- **`Str` as the renderer's INPUT** — *delete it.* That is the Emacs mistake in a
  signature: it forces every mode to reparse meaning the buffer already had. U13.
- **`Str` as any document's SERIALIZATION** — *keep it, mandatory.* U19's `print` is
  what makes save, diff, `grep`, version control and "just open the file in anything"
  work uniformly across the whole family without a second truth. Every typed document
  has a text form; nothing renders *from* it.

And **plain text stays a first-class member of the roster** (type 7), because the
editor must open an unknown file. That is not a fallback interface — it is one type
among N, and it is the one whose value happens to be `Str`.

### ⚑ The measured constraint — `Puffer`'s polymorphism has never been cashed

`(Puffer Str)` appears **152×**; `(Puffer A)` appears **7×** — only in the generic
helpers. Same for the zipper: `(Zipper Str)` 10, `(Zipper A)` 6. So
`SCRIBA-PRIMITIVE-CHECKLIST.md` §1's *"richer than emacs's: the buffer is a typed lens
on a port"* is true **in the type and false in every instance**: every buffer in scriba
today is a text buffer. The parameter is a promise nothing has cashed, which is
exactly why the renderer could take a `Str` without anyone noticing.

*(FLAG, not fixed here: that §1 line overstates the built state. It is another
ledger's claim and belongs to a `doc-audit` run, not to this outline.)*

### The lanes — what a buffer can be over

`Puffer` is a lens on a **port**, and ports are not all static values. Five lanes,
three of which already exist in the tree in some form:

| Lane | What the buffer is over | Already? | Save | Undo | Refresh | `close` | Holds a linear port |
|---|---|---|---|---|---|---|---|
| **text** | a `Str` — unknown/plain files | **yes** (all 152) | ✓ | ✓ | — | ✓ | no |
| **value** | a typed document (§5's roster) | no — U13 gates it | ✓ via `print` | ✓ | — | ✓ | no |
| **stream** | a live source, tailed | **partly** — `r-stream (source-id Str)` ships, handled in the diff and the APC codec; run-view streams tokens | — | — | ✓ | **✓ linear** | **yes** |
| **derived** | a fold over *other* buffers — the agenda, backlinks, occur, `:help` | **by convention only** — `help.chiral:4`: *"the command loop renders results into read-only `Str` puffers"*, with no type-level read-only-ness | — | — | ✓ + jump-to-source | ✓ | no |
| **remote** | another node's port — a peer scriba, a running process | no | — | — | ✓ | **✓ linear** | **yes** |

⚑ **`close` was missing from this table until 2026-08-30 (P1).** It is the field that
makes the "holds a linear port" column typeable at all, so it is required of *every*
lane, not optional — its *quantity* is what differs.

Two things fall out that are not obvious:

1. **The derived lane already exists and is unmodeled.** Read-only result buffers are
   made today by rendering into a `Str` puffer — losing the structure that would let
   you jump back to the source. §6 and §7 produce mostly derived buffers, so this lane
   carries more of the user layer than the value lane does.
2. **The stream and remote lanes inherit `S20b`'s unresolved hard edge.** They hold a
   linear port across keystrokes, which is precisely what `command-loop.chiral:1735`
   records the loop as having been designed to avoid (*"nothing linear is held across a
   keystroke, which is what let CHAT become a normal mode instead of a blocking
   loop"*). **They are gated on S20b's answer, not on U13.** The text, value and
   derived lanes are not — they can land first, and should.

### The roster

**Distinct value shapes get distinct types.** Where two families differ only in their
*section list*, they share a type and differ by a declared **schema** — a named,
testable profile of one frozen base, which is this project's modularity rule
(conformance, not configuration), not a collapse. Extensions may outnumber types, and
should: the extension is the semantic handle, the schema is what it binds to.

| # | Type | Ext (author's call) | Value shape | Renders as | In-repo consumer TODAY |
|---|---|---|---|---|---|
| 1 | **outline / notes** | `.fol` | tree of `Item` (heading, state, tags, props, timestamps, body) | foldable tree, `r-tree` + `r-section` | the org-analogue; `docs/*.md` prose |
| 2 | **sectioned document** + declared schema | `.bank` `.spec` `.wex` `.dec` `.deck` | ordered named sections, schema-checked | `r-section` stack, per-schema faces | **~264 documents**: 10 banks (6-part schema), 122 specs, 118 examples, 14 decisions |
| 3 | **table / ledger** | `.tab` `.led` | rows over a **declared column schema** | `r-table`, aligned, sortable | `SELF-IMPLEMENT-CATALOG.md`, `LEDGER.md`, every `INDEX.md` |
| 4 | **graph** | `.graph` | nodes + **typed** edges | diagram (U25) · indented tree · adjacency `r-table` — same value | the 71-node `[[link]]` graph; the module import graph; `BUILD-ORDER`'s lane graph |
| 5 | **journal / datetree** | `.log` | time-keyed entries | timeline lanes, day sections | capture targets (§7); session logs |
| 6 | **manifest** | — | **already E163** — pure data as type-checked chirality | value view | `target-linux.chiral` |
| 7 | **source** | `.chiral` | **already the language** | U5 fontification from the real parse | everything |

**Tier 2 — clear shape, waiting on a consumer** (named so they are not "discovered"
later as gaps): `.ref` bibliography/reference entries (the repo's own
`PAPER`/`IMPL`/`OURS` reference-class convention is one already) · `.chart` data plots
(U27) · `.diff` · `.kbd` keymap documents.

**Still no file for:** the agenda (a *query*, §7), the note graph index (derived; a
cache is an E163 manifest), config (E163 + `S11`), saved manas setups (`persist.chiral`
JSON, shipping).

### The finding this roster produces

**The repo's own doc tier is already six document types pretending to be markdown, and
`tools/ledger-lint/ledger-lint.py` is the type-checker they don't have.** 19 checks (A–S) over ~264
schema'd files: bank shard claims against the CONFORMANCE-MAP, the link graph, line
citations against live files, the cheatsheet's ops against `refine.py`. Every check
that is *schema conformance* is a type error waiting for a type — and the checks that
survive typing (citations still pointing at true lines) are the genuinely semantic
ones, which is exactly the sorting `doc-audit` already makes by hand.

That is P1 stated concretely: the knowledge base is governed by a tool outside the
language because the language cannot yet express what a bank *is*.

| U# | Element | State | Gate | Note |
|----|---------|-------|------|------|
| **U13** | **The renderer takes the typed value, not `Str`.** So a mode renders a *value*. **Gates the entire family**; without it every type reparses and the whole exercise is Emacs with extra steps. Measured blocker: `render.chiral:16`. ⚑ The real content is *where the heterogeneity is packed* — see D-U7 and the four options below; the signature change is the easy half. | `decide` | **D-U7** · S18 · S19 | small signature, wide blast radius |
| **U14** | **`Mode` grows to a real mode.** Today `(mode renderer faces)`. A document type needs **renderer + faces + keymap + ops + views + (schema)** — Emacs modes bind keys; scriba's do not. This is the record that makes "one registry row and one module" (the floor's acceptance test) actually true for a rich type. | `design` | U13 · S21 | `render.chiral:24` |
| **U15** | **Extension → document type, as a checked binding.** Not a sniffer: a registry row binding extension to type, so opening a file *selects* value, reader, mode and permitted ops. `E160` (module coordinate as a **checked declaration**, BUILT) is the in-tree precedent for "promote a convention into something the compiler refuses when it contradicts fact." | `design` | U14 | the semantic-sorting mechanism |
| **U16** | **The block algebra — the shared leaves.** Types are distinct at the top; *blocks* compose across them (prose · list · code · table · link · timestamp · transclusion), so a bullet can hold a table and a graph node can link to a note. **This is E158's `Doc`**, and it is where the shared piece belongs — at the leaves, not at the document. | `blocked` | **E158** | the non-collapsing shared layer |
| **U17** | **N views per type.** A `View` beside the renderer, so one value has several renderings (graph → diagram / tree / adjacency table) chosen at runtime with **no reparse**. The port-viewer thesis, made operational; Emacs structurally cannot do this. | `design` | U13 · U14 | the payoff row |
| **U18** | **Per-type surface reader** — one small, line-oriented, fast-to-type syntax per type. "Minimal" is a property of *each* surface, not of the roster's size. | `decide` | **D-U2** | pipeline: worked example settles the shape |
| **U19** | **`parse`/`print` round-trip gate, per type** — `parse(print(v)) ≡ v` structurally, E146's gate applied to each. Non-negotiable for every member of the family. | `blocked` | U18 | |
| **U20** | **Type 1 — outline / notes.** The org-analogue: `Item` tree with state, tags, properties, timestamps, body blocks. | `blocked` | U13–U19 | |
| **U21** | **Type 2 — sectioned document + declared schemas.** One type, N schemas (bank 6-part · spec · worked example · decision · deck), N extensions. **Retires the schema-conformance half of `ledger-lint`** across ~264 files. | `blocked` | U13–U19 | the largest measured consumer |
| **U22** | **Type 3 — table / ledger** over a declared column schema. Retires the row/column checks over `SELF-IMPLEMENT-CATALOG.md`, `LEDGER.md`, the `INDEX.md` family. Aligned rendering needs **U2** (display width). | `blocked` | U13–U19 · U2 | |
| **U23** | **Type 4 — graph**, nodes + **typed** edges. The edge *type* is the point: a `[[link]]`, an import, a lane dependency and a "cites" are different edges and should not be one string. | `blocked` | U13–U19 | feeds §6's note graph directly |
| **U24** | **Type 5 — journal / datetree**, time-keyed entries. | `blocked` | U13–U19 · U40 (date type) | capture target for §7 |
| **U25** | **Diagram rendering, tiered honestly.** `Rendering` has no diagram node. Tier 0: indented adjacency (free today). Tier 1: box-drawing layered DAG layout. Tier 2: crossing minimization + orthogonal routing (large). `split-role`'s *do what you can, and name it* — declare the tier, do not fake it. | `design` | U23 · U2 | new `r-graph` node |
| **U26** | **Generalize the outline engine.** `Focus`/`Outline`/`OutlineNode` in `manas-mode.chiral` (1,034 L, PTY-proven) become polymorphic over the document, so types 1–5 inherit navigation, folding and cursor identity. **Highest leverage row in the document** — converts built code into the family's substrate. | `design` | S20 · U13 | generalize; never rebuild |
| **U27** | **Charts.** Integer-count bars and sparklines are expressible today; anything with a rate, ratio or axis scale wants **E153** floats. New `r-chart` node. Tier it, do not defer it silently. | `design` | E153 (partial) · U22 | |
| **U51** | **The derived lane, modeled.** A read-only buffer whose content is a fold over other buffers, carrying its provenance so a row can jump back to its source. Today this is faked with `Str` puffers (`help.chiral:4`) and the structure is thrown away. §6's queries and §7's agenda are both this lane. *(Appended after §7's rows; `U#` are stable identifiers, not an ordering — the same convention the `E#` catalog uses.)* | `design` | U13 · S26 | carries more of the user layer than the value lane |
| **U52** | **The stream lane, modeled.** `r-stream` ships as a *handle* (`source-id Str`) and run-view streams through it; what is missing is a buffer that IS a stream — tail-follow, no undo, no save, explicit close. **Holds a linear port across keystrokes → gated on `S20b`.** | `blocked` | **S20b** · U13 | |
| **U53** | **The remote lane** — a buffer over another node's port (a peer scriba, a live process). `docs/live-environment.md` names this as a first-class case. Tier 2; same linear gate as U52. | `blocked` | **S20b** · U52 | named, deliberately unscheduled |
| **U28** | **Cross-type links + transclusion.** `[[target]]` as a typed `Link` resolved against the graph; a region of one document included in another *by identity*. Wants S26 markers + S27 overlays. | `blocked` | U16 · U23 · S26 · S27 | |

## §6 · Surface K — knowledge-base management mode

**The requirements here are measured, not invented.** This repo already runs a
working KB — 73 notes, 71 with `node:` frontmatter, 10 banks, 1,349 `[[links]]` over
71 targets, plus `.planning/` ledgers, `examples/`, `.planning/specs/` — and it is
managed by **3,251 L of Python** whose feature set is the specification:

| Python tool | What it does | The `U#` that inherits it |
|---|---|---|
| `ledger-lint.py` (1033) | checks A–S: bank shard claims vs CONFORMANCE-MAP, the link graph, line citations against live files, cheatsheet ops vs `refine.py` | U31, U33, U34 |
| `chirality-frontier.py` (650) | `condense` (a rot-proof digest with a source hash), `route` (rank a claim's home in the node graph), `bundle` | U32, U35 |
| `chirality-pack.py` (636) | element pipeline bundles + INDEX status flips | U36 |
| `chirality-capture.py` (619) | route a claim to its home(s), scaffold the target with the source claim + the authority it must be checked against | U35 |
| `chirality-doc.py` (313) | claim-beside-authority audit bundles; `new-bank` scaffolding | U34 |

P1 is the motive: *you can only mediate what the framework can express*. A knowledge
base governed by a tool outside the language is exactly the ungoverned path P1
describes — and the tooling is the one part of this project still outside chirality.

⚑ **This does not make retiring `bin/*.py` a goal by default.** Those tools are not in
the build path (the BUILD RULE is about *compilation*, and they compile nothing), they
work, and rewriting 3,251 L is a real cost. Whether the KB mode *replaces* them or
sits beside them is **D-U3** — an author call, not a foregone conclusion.

| U# | Element | State | Gate | Note |
|----|---------|-------|------|------|
| **U29** | **The KB as a port, split read from write.** A KB reader and a KB writer have different port sets, therefore different types (P3 + the splitting law) — the same cut E148/E149 already make one level down. A note *browser* must not hold delete authority. | `design` | E148 · E149 | decides the shape of everything below |
| **U30** | **The note graph as a typed value.** Nodes + typed links + tags, built by folding the parsed notes. `Map`/`Set` are `HAVE`; ordering is `E151a`. Backlinks are a fold, not an index to maintain. | `blocked` | U20 · U28 · E148 | |
| **U31** | **Link integrity as a checkable property** — dangling `[[targets]]`, orphans, cycles. Today: `ledger-lint` checks in Python. Here: a fold over U30 returning a closed `Reason` sum (E157), not printed text. | `blocked` | U30 · E157 | |
| **U32** | **Query + view surface.** Backlinks, tag queries, orphan lists, "what links here", graph slices. One query language over the typed graph; the views are Modes. Sorting is `E152` (built). | `blocked` | U30 · U26 | |
| **U33** | **Citation checking against live files.** The KB cites `file.chiral:123`; lint verifies those lines still say what the claim says. In chirality this is a real reference into a real buffer — **S26 edit-stable markers are the gate**, and this is the row that proves S26 earns its keep. | `blocked` | **S26** · E148 | |
| **U34** | **Claim-beside-authority audit bundles.** The authority gradient (code > map/INDEX > decisions > bank > thin note) becomes a closed **ordered sum**, and "disagree above the doc = FLAG, never pick" becomes a typed outcome rather than a prose instruction to the reader. | `blocked` | U30 · U33 | the deepest refraction in §6 |
| **U35** | **Capture + routing.** `chirality-capture`'s route-a-claim-to-its-home, live: capture from any buffer, route against U30, scaffold the target pre-seeded with source + authority. Org-capture and `chirality-capture` are the same feature; this is where they merge. | `blocked` | U30 · U34 · E149 | |
| **U36** | **Staleness digests.** `chirality-frontier condense` embeds a hash of its sources so lint can flag a stale digest. Needs a content hash — **E116**, already slotted in `CRY`. Until then a weaker checksum is a named, honest downgrade. | `blocked` | **E116** | do not invent a hash |
| **U37** | **Refile / archive / rename-with-link-rewrite.** Moving a note must rewrite inbound links — trivial on U30's typed graph, a sed-and-pray on text. | `blocked` | U30 · E149 | |
| **U38** | **Transclusion / block references.** Include a region of one note in another by identity. Wants S26 markers and S27 overlays; **defer until a consumer asks.** | `design` | S26 · S27 | flagged, deliberately unscheduled |

---

## §7 · Surface A — scheduling and the agenda

**Read `docs/time-and-clocks.md` before adding anything here.** It is the refraction,
and it already splits time into three things that land in different categories. The
mapping to org-mode is unusually exact, and it is the best conventional-vs-chirality
contrast in this document:

| Org-mode | chirality, per `time-and-clocks.md` | Category |
|---|---|---|
| `CLOCK:` / effort estimates / `org-clock` | **time you spend** — a graded quantity in the type, an over-approximate bound | A: internal, provable |
| the agenda's "today", `org-today`, timestamp comparison | **time you are told** — an untrusted reading from the world, a **B referent** reached through a port, turned into evidence by `freshness-verify` against the register-anchored monotonic counter. *You never trust the told time.* | B → C: substrate made into evidence |
| `SCHEDULED:` / `DEADLINE:` | **time you must act by** — a bound; **reaching one fires a counter-effect**, and its expiry is an **alarm** | a bound + `error-and-alarm` |

So: **a chirality deadline is not a string in a heading. It is a bound in a type whose
expiry is an alarm answered by a counter-effect** — and `supervisor.chiral` (E42,
BUILT v1) is already the alarm set that carries it (`(alarm due-ms rid)`, `k-resume
dt` re-arming forward from now). The agenda *view* needs none of that; the agenda
*daemon* needs all of it. **Split those two, or the view will be blocked on async for
no reason.**

⚑ **Two hard facts measured 2026-08-30, both load-bearing:**

- **There is no wall clock, by decision.** `clock.chiral:7`. Calendar time is not a
  missing feature to add — it is the **B-untrusted leg**, and building it means
  building the evidence path (told-time cap → reconcile against `time-mono` →
  divergence is an alarm), not adding a syscall.
- **`Clock` has no acquisition crossing.** `Env` has `env-open`; `Clock` and `Timer`
  do not. `scaffold/tests/samples/e170_port_zeros.chiral:73` states it outright: *"no
  constructor, so no term anywhere can produce a `Clock` — `time-mono` and `sleep-ms`
  are crossings no program can reach."* Caps are meant to arrive from the profile
  (the `profile-hands-caps` move `clock.chiral` anticipates). **Until that lands, an
  agenda cannot read the time at all** — this, not the calendar type, is the real
  first gate.

| U# | Element | State | Gate | Note |
|----|---------|-------|------|------|
| **U39** | **A program can acquire a `Clock`.** Either profile-hands-caps, or an interim acquisition crossing on the `env-open` precedent. **Gates every other row in §7.** | `blocked` | profile-hands-caps · E32 | the measured first gate |
| **U40** | **Civil date/time as a type.** `Date` / `DateTime` / `Duration` as closed records, days↔civil conversion, comparison, arithmetic. **Pure integer math — no `E153` floats needed**, which keeps it off the numeric-width decision. `LANGUAGE-INVENTORY` §8 lists this `GAP`, unminted; §6 now supplies the consumer that earns the mint. | `GAP` → mint | U39 | §11 |
| **U41** | **Told time as evidence, not as truth.** A told-time reading + reconciliation against the monotonic anchor; divergence (rollback, staleness) is an **alarm**, not a silent wrong answer. This is `freshness-verify`'s shape, and it is what `clock.chiral` means by "B-untrusted". | `design` | U39 · U40 · `error-and-alarm` | the row that keeps P5 honest |
| **U42** | **Timezones — tiered, honestly.** No tzdata exists and reading `/etc/localtime` is a port. The cheap correct floor is **UTC plus a fixed offset**, with full zone rules a **named not-had** (the `split-role` "do what you can, and name it" discipline). Do not fake it. | `design` | U40 | state the tier |
| **U43** | **Timestamps in the document value.** `SCHEDULED` / `DEADLINE` / active / inactive / ranges as `Item` fields of type `DateTime` — typed at parse, never re-scanned. | `blocked` | U20 · U40 | |
| **U44** | **Repeaters** (`+1w`, `.+1d`, `++1m`) as a closed sum + pure arithmetic on U40. | `blocked` | U40 · U43 | cheap once U40 exists |
| **U45** | **TODO state machines.** A `TodoState` sum, and the *workflow itself* is a value — org's in-file `#+TODO:` config becomes an **E163 manifest module**. Per-file workflows for free, type-checked. | `blocked` | U20 · E163 | a clean refraction |
| **U46** | **The agenda as a query.** Fold the note set → filter by state/tag/window → sort (E152, built) → render as a Mode. **Needs nothing async.** Org rebuilds its agenda by regexp-scanning files; here it is a fold over typed values. | `blocked` | U30 · U43 · U40 | the deliverable most people mean by "org-mode" |
| **U47** | **Priorities, tags, properties, effort** — `Item` fields; queries fall out of U46. | `blocked` | U20 · U46 | cheap |
| **U48** | **Clocking.** Clock-in/out and time tracking: the *elapsed* half is `time-mono` (HAVE, trustworthy); the *wall stamp* half is U41 (told time). Two senses, do not fuse them — `clock.chiral` split `Clock` from `Timer` for exactly this reason. | `blocked` | U39 · U41 | |
| **U49** | **The agenda daemon — deadlines that actually fire.** `supervisor.chiral`'s `AlarmSet` + `notify`. `notify` is a **stub extern** gated on **E39**; delivery into the editor loop is **S28/S29**. **Strictly separate from U46**: the view must not wait for this. | `blocked` | **E39** · S28 · S29 · E42 adoption | the async half, last |
| **U50** | **Capture with a timestamp** — org-capture's datetree. Falls out of U35 + U40. | `blocked` | U35 · U40 | |

---

## §8 · The rest of the sensible sphere — verdicts

Named so a later pass does not "discover" them, each with a verdict rather than a
silence.

| Candidate | Verdict |
|---|---|
| **Babel / literate source blocks** | **IN, and it is the best refraction available.** Org runs a code block by shelling out to a foreign interpreter. Here a chirality source block **is a module**, compiled by the real compiler in-process, with its ports in its type — the block's authority is visible before it runs. Wants `E132` (runtime dynamic loading). Deserves its own worked example. |
| **Export (HTML / PDF / man)** | **IN, cheap** — `E158`'s `Doc` with `doc->str`/`doc->rendering` already names the exits. One new exit per target. |
| **Shell / terminal mode** | **HAVE** — `proc-spawn` (E33) + pty (E104) + `term.chiral` + `vt-parser.chiral`. Wiring, not building. |
| **VCS integration (magit-shaped)** | **OUT for now.** No git plumbing in chirality; it would be `proc-spawn` over the `git` binary, which is a foreign-authority crossing worth deciding on purpose, not by drift. |
| **Mail / news / IRC** | **OUT.** `http.chiral` is plaintext-only by design and there is no TLS (`E129`: "zero TLS"). Do not start. |
| **Calendar interop (iCal), contacts** | **OUT** until U40/U42 land; then reconsider. An iCal parser before a date type is backwards. |
| **Bibliography / citations** | **OUT** as a feature; U28's typed links plus U33's citation checking already cover the in-repo case, which is the only live consumer. |
| **Spreadsheet formulas in tables** | **OUT.** Wants `E153` floats and has no consumer. U22 keeps tables as declared-schema structure; U27 covers integer charts over them. |
| **Note encryption** | **Slotted** — `secret.chiral` (E40) for custody, `E114–E119` for the crypto. Not a new gap; do not name one. |
| **Sync across machines** | **Slotted, and structurally interesting** — `docs/time-and-clocks.md` edge 19 already decides cross-node ordering: causality rides the ports, the causal edge is the port-move, the vector clock is crossing metadata. A note-sync design that invents its own ordering would be ignoring a settled answer. |
| **Presentations / slide decks** | **IN, tier 2, nearly free** — a deck is a *sectioned document with a slide schema* (§5 type 2), so it costs one schema and one view, not a feature. Drawing and image display stay **OUT**: display is per-face (`axis-altitude`) and the terminal lane owns it. |
| **Abbrev / snippets, narrowing, recursive minibuffer** | **Already dispositioned OUT** by `SCRIBA-PRIMITIVE-CHECKLIST.md` §"Not cataloged — and not phantoms". Unchanged. |

---

## §9 · Cross-cutting — what all four surfaces need

1. **The `S#` floor, genuinely finished** (§2). Non-negotiable; four surfaces is
   exactly the load the floor was specified to carry.
2. **`E148` + `E149`.** Every surface reads a directory or writes a file. These two
   are the widest gate in the document, and their read/write split is also the model
   for U29.
3. **`S26` markers + `S27` overlays.** Anything that anchors into text — diagnostics,
   citations, search hits, transclusion — is blocked on them. They stop looking
   optional the moment §6 exists.
4. **`E157` + `E158`.** Every surface reports something. Without them each one grows
   its own `str-cat` message chain, which is the A1 altitude leak repeating.
5. **`E152` (built) + `E151` completion.** Every surface sorts and compares strings.
   E151's duplicate retirement being open is a live risk: four new modules will each
   write their own comparator if it stays that way — *the exact failure `BUILD-ORDER`
   §A1 documents.*
6. **One place to decide the document *machinery* — U13–U19.** Not one document
   *type*: §5's whole correction is that types stay distinct. What must be shared is
   the typed-renderer signature, the mode record, the extension binding, the block
   algebra (E158's `Doc`) and the round-trip gate. If §6 and §7 each grow their own
   renderer seam or their own block sum, the family has been lost even though the
   types are separate.

---

## §10 · Decisions owed

Blocking their rows and nothing else. Named `D-U#` to sit beside the checklist's
`D-S#`.

- **D-U1 — the fontification seam (U5).** Does a mode's face run come from the real
  parse (`sexp.chiral`/`parse.chiral`), from an independent lexer, or from a mode-chosen
  either? What happens to faces while a buffer is syntactically broken — the case that
  makes an independent lexer tempting and is the whole reason to decide on purpose.
- **D-U2 — the surface syntax of the family (U18), and how far the roster runs.**
  Three questions, one decision: (a) does each type get a hand-written line-oriented
  reader, or does the family share one skeleton (an s-expression frame read by the
  existing `sexp.chiral`, with raw prose blocks) specialised per type? (b) which roster
  members are tier 1 now (§5 proposes types 1–5) versus tier 2? (c) where the
  type/schema line falls — a sectioned document with N declared schemas versus N
  separate types. **Pipeline required**, and the worked example should carry at least
  **two** members (an outline and a graph), because a syntax that only looks right for
  one type is the failure mode. The round-trip gate is settled and is not part of this
  decision.
- **D-U7 — where the heterogeneity is packed (U13).** A buffer list and a mode
  registry are single lists holding buffers of *different* document types. Four
  shapes, and this is the decision U13 actually turns on:
  **(a) a closed `DocValue` sum** — one variant per type; registry and buffer list stay
  homogeneous, exhaustiveness is checked, no new machinery. Cost: every new type edits
  the sum and forces a scriba recompile — the known `Flow`/`PureFn` cost
  (`SCRIBA-STATE.md`) — and it breaks the floor's *one registry row + one module*
  additivity.
  **(b) buffer-as-object** — the buffer list holds a record of closures (render,
  key, save, name, dirty) that have already captured the typed value; the type
  variable is erased by closure conversion, so no existentials are needed. Additivity
  holds: a new type is a new module, zero edits elsewhere. Cost: the value is only
  reachable through the vocabulary, which is the point rather than a defect.
  **(c) one registry per type** — type-safe, no packing, but the buffer *list* still
  cannot be one list, so it does not actually solve S19.
  **(d) `Str` plus a memoised parse** — everything degrades gracefully; cost is two
  truths, exactly what U19's round-trip gate exists to prevent.
  ⚑⚑ **STATUS 2026-08-30 — RESOLVED IN FAVOUR OF (b). It is expressible today.**
  An earlier revision of this cell said (b) "does not lower". **That was wrong and is
  withdrawn.** Full measurements: `.planning/FINDING-captured-closures-2026-08-30.md`
  (392 L, 39 fixtures in `scaffold/tests/samples/_wip/`).

  **The defect is syntactic, not about capture.** A bare `(lam …)` written directly in
  a **data-constructor argument position** is never registered as a closure-conversion
  site — `closconv.chiral:791`, the `c-con` arm of `cwalk-struct`, passes `none` for
  expected types where `cwalk-app` (`:805-812`) threads `callee-doms`. So `lam-lit`
  (`:743-752`) rejects a bare `c-lam` while accepting `(c-ann (c-lam) arrow)`. Falsified
  in **both** directions, and I re-ran both myself:
  · **zero captures**, bare lam in ctor position → **REFUSED** (`higher-order application`)
  · **captures `k`**, same position, wrapped in `(the (-> I64 I64) …)` → **lowered, ran, exit 0**
  Capture is irrelevant. The fix at the call site is an annotation; the fix in the
  compiler is to thread the ctor field-type map — which **already exists**
  (`closconv-driver.chiral:84-91`, `sv-ctor-fields` `:902`) and is consumed only on the
  case-*arm* side, never on construction.

  **(b) demonstrated end to end:** buffer-as-object with three closures over one
  captured `Doc` applied across function boundaries; the additivity shape — two
  different payload types in one homogeneous `(List Buf)` driven by one loop; and the
  effectful `=>` field matching live `ScribaOp`. All lower, run, and fail their mutants.

  ⚑ **Two corrections this run forced, both against things I wrote above:**
  1. **The `Flow` corroboration is WITHDRAWN — refuted at source.** `flow.chiral:71-73`
     gives its own reason for `PureFn` being a closed sum: *"so the SG1 codec stays
     total; boundary-as-closed-sum … NOT an opaque closure"* — **serialisability and
     `flow-ty` totality, not lowering.** No closure/lowering rationale exists anywhere
     in `scaffold/lib/manas/`. ⚑ But the withdrawal is not free: **that reason bites
     `Buf` too, the moment a buffer list needs a codec or a structural checker.** That
     is the one genuine new constraint on (b), and the lane can now take it on purpose
     rather than discover it.
  2. **"The dictionary shape works" is a measurement trap.** A one-lam projector passes
     only because `specialize-singletons` fires at exactly one instance
     (`specialize-singleton.chiral:65-95`, the hard `count-inline == 1` cap); add a second
     instance and it fails. The k=0 control cited below had **three** instances, so that
     pass was inert and the result is genuine closconv — sound, but for a different
     reason than stated.

  **`E147` is BUILT and does not cover this.** It fixed the *consumption* side
  (`arm-body` running `rw` with an empty ctx). `:791` is the *registration* side — with
  no site there is no `$clo` for `arm-rw-ctx` to be a context of. Same root pattern, a
  walk that lost its type context; different site.

  **Recommendation: (b).** ⚑ **The evidence in this cell was wrong until 2026-08-30
  and is corrected here by the P1 run** — `Mach` was cited as the witness and is the
  **counter-example**. There are *two* shapes of fn-bearing record in this tree and the
  compiler treats them oppositely:
  · **dictionary shape** (`Mach`, `Alloc`) — fields reached through **projector
  globals** (`mach.chiral:64`, a `case` binding 37 field names), handled by
  `specialize-singletons`, and **structurally capped at ONE instance per blob**:
  `specialize-singleton.chiral:78-84` says so loudly — *"a fn-bearing type built >1 time
  returns `none` here … the lowering path er-skips it -> a visible compile failure,"*
  and records the `16d6d1a` count>=1 relaxation being **reverted as an order-dependent
  silent miscompile.**
  · **vocabulary shape** (`RendererFn`, `ScribaOp`) — consumed by an **inline `case` in
  the body** (`command-loop.chiral:98`), routed by `closconv-sig`, and **N instances are
  fine**: measured 2026-08-30, `ScribaOp` = `(op (name Str) (fn (=> (Puffer Str)
  (Puffer Str))) (doc Str))` runs **31 live instances in one registry** with an
  *effectful* field.
  So (b) holds **provided `Buf` is consumed by inline `case`** — but ⚑ **the stated
  mechanism for the no-accessor-globals rule was wrong** (audit FLAG 2, confirmed at
  source): `find-singleton`'s second gate is `find-con-global`
  (`specialize-singleton.chiral:65-76`), which matches only a global whose *whole body*
  is a bare `(t-con …)`. A `Buf` built inside a `lam` never qualifies, so
  `specialize-singletons` is **inert for `Buf` with or without accessor globals**. The
  rule may still be worth keeping as a convention, but it is not justified by that pass
  — and the measured refusals above happen either way.
  Also: `LANGUAGE-INVENTORY` §4's indexed-record GAP does **not** bite, because the
  vocabulary record is ground — the type parameter is erased by capture.
  **The E7 argument, found by P1 and SCOPED by the audit (both halves measured
  2026-08-30).** Strict positivity (`data.chiral:267-269` — *not* `:262-266`, which is
  the head-occurrence branch) refuses a recursive occurrence in a field arrow's
  **domain** and walks into the **codomain**. Measured with B1:
  · `(data Buf () (buf (op (-> Buf I64)) …))` → **REFUSED**, `load: not strictly
  positive: op`.
  · one **parameterless hop** — `(data Prov () (prov (f (-> Buf I64))))` +
  `(data Buf () (buf (q Prov) …))` → **ACCEPTED**, compiled and ran.
  `walk` recurses through a `(t-tcon n as)` only into the type *arguments* `as`
  (`data.chiral:270` → `walk-args`); it never resolves `n` to its own declaration, so a
  parameterless intermediate is invisible in both directions. **So the guarantee is
  real for DIRECT fields and is a CONVENTION across an indirection** — and §5's own
  shape has that indirection (`Buf` holds `(prov Provenance)`, `Provenance` mentions
  `Buf`). The proposed shape does not *violate* it — `Provenance`'s fields mention `Buf`
  only in the codomain — but the checker would not catch it if a later edit did. State
  it in the module header; do not call it by-construction.
  It is also `docs/live-environment.md`'s own answer in its own words — *"uniformity
  lives in a common port vocabulary (list, inspect, send-op), and each session's payload
  type differs per instance."*
  ⚑ **Honest cost, against the floor's acceptance test:** (b) is *source*-additive — one
  `cons` plus one module, no shared sum, no shared exhaustive `case`. It is **not
  recompile-free**: `closconv-driver.chiral:107-112` mints one `$clo` constructor per
  closure site and one `$apply` per arity family, so the generated case grows and the
  blob rebuilds — the same whole-program cost `SCRIBA-STATE.md` records for
  `Flow`/`PureFn`. The win over (a) is real but it is precisely *who edits the case*:
  the pass, not a human.
  ⚑ The deliverable of this decision is **the vocabulary itself** — which operations
  every lane must implement and which are optional per lane (the lane table in §5).
  ⚑ **Corrected by P1:** "optional per lane" understated it. Read the lane table by
  *column*, `save`+`undo` are present in exactly `{text, value}` and `refresh` in
  exactly `{derived, stream, remote}` — a **total, disjoint partition**, so the optional
  half is ONE closed two-variant sum (`owned` / `derived`), not four independent
  `Maybe`s. A save-and-refresh buffer then becomes *untypeable*, and no consumer needs a
  defensive arm for a state the lane table says cannot exist.
- **D-U6 — does the typed doc family retire `ledger-lint`'s schema checks?** If a bank
  is a type, most of A–S becomes a type error. Same shape as D-U3 and should be decided
  with it, but it is a *different* question: D-U3 is about the KB *tooling*, D-U6 about
  the *schema checker* — and typing the documents settles D-U6 whether or not the
  tooling moves.
- **D-U3 — does the KB mode replace `bin/*.py` or sit beside it?** (§6.) P1 argues
  replace; 3,251 L of working tooling argues beside. A third reading — the chirality mode
  is the *live* surface and the Python stays the *batch/CI* surface — is coherent and
  should be considered rather than defaulted into. ⚑ **A fourth reading has since
  gained evidence** (`USER-LAYER-PIPELINE-PLAN.md` §6.2): under
  `docs/testing-floors.md`'s provenance ranks, `bin/*.py` is the **only rank-2
  instrument the entire user layer has** — a genuine independent in-house computation
  over the same 264 files. So the compiler lane's own pattern applies: keep it as the
  **differential oracle**, advisory and reported, retired when the native instrument
  covers the area. Deleting it early does not just cost tooling — it deletes the lane's
  only independent expectation, leaving every KB gate at rank 4.
- **D-U4 — how a `Clock` is acquired (U39).** Wait for profile-hands-caps, or add an
  interim acquisition crossing on the `env-open` precedent? `clock.chiral` already
  marks `env-open` as INTERIM and says it is deleted when profiles hand caps — so
  this is a question about *timing*, and the answer determines whether §7 is
  buildable now or later.
- **D-U5 — the told-time tier (U41/U42).** UTC-plus-offset with tzdata as a named
  not-had, or full zone rules? And what a freshness divergence *does* in an editor:
  refuse, warn, or annotate. `split-role`'s "do what you can, and name it" governs the
  form of the answer, not its content.

---

## §11 · The mint queue — run this before any row here is cited

The no-phantom-dep rule: *never defer to a follow-on `E#`/`T#` that is not already
minted.* Nothing in §4–§8 may be cited by a spec until its dependency is a real row.

**Already minted — cite freely:** `E39` `E42` `E114–E119` `E132` `E146` `E148` `E149`
`E150` `E151` `E152` `E153` `E157` `E158` `E163` · `S11` `S19`–`S30` · `T17`.

**Owed — must be minted (catalog row + ledger row) before use.** Each now has the
named consumer that `LANGUAGE-INVENTORY` requires for a mint:

| To mint | Category | Consumer that earns it |
|---|---|---|
| **Civil date/time type** (U40) | `VAL` | U43/U44/U46 — the whole agenda |
| **Told-time acquisition + freshness reconciliation** (U41) | `SYS` / evidence | U46's "today"; U48 clocking. ⚑ Check first whether `freshness-verify` already has a row — if it does, this is an adoption row, not a new element |
| **Codepoint-indexed string view** (U1) | `VAL` | `str-edit`; every prose surface |
| **`Clock` acquisition** (U39) | `SYS` | all of §7. May be subsumed by profile-hands-caps — **verify before minting** |
| **The typed-renderer seam + mode record** (U13/U14/U15) | `APP` (scriba) | gates the entire family |
| **The block algebra** (U16) | **already E158** — cite, do not mint | every document type |
| **Each document type** (U20–U24) | **`VAL`** — pure value + total `parse`/`print`, empty port set | §5's roster; §6 and §7 are views over them |
| **`r-graph` + `r-chart` render nodes** (U25/U27) | `APP` / `TUI` | diagram and chart rendering |
| ~~**The `U#` lane itself**~~ | — | **DONE 2026-08-30** — lane row in `.planning/BUILD-ORDER.md` §Lane docs + anchor in `SCRIBA-PRIMITIVE-CHECKLIST.md` §8, so this doc is not reachable only from itself (`BUILD-ORDER` §A4: a live doc findable only through a dead one) |

⚑ **Do not mint a new "document"/"format" category for U20.** `FMT` is *External
formats & ABIs* (ELF, Wayland, PNG, APC) and ours is not external; `VAL` is *Pure
value modules — category A, empty port set, pure `->`*, which is exactly what a
document value plus a total `parse`/`print` pair is. And `LEDGER.md §VAL` carries the
2026-08-22 naming correction in full: *"'standard library' is not a legible category
in chirality — it is a conventional monolith, a topic bucket."* A `DOC` category would be
that same error, freshly made. The **file type** (U18) is the one part that touches a
port, and it rides `SYS` with E148/E149.

**Deliberately not minted:** regex, spreadsheet formulas, iCal, TLS/mail, VCS, rope
buffers, a hash function of our own (E116 owns it). Minting an element with no
consumer creates the opposite phantom — a catalog row nobody will ever pull.

---

## §12 · Sequencing sketch — not a build order

`.planning/BUILD-ORDER.md` owns sequencing; this is the shape it should be given.

```
  (prerequisite)  S19 · S20 · S21          the floor's remaining Tier A
  (prerequisite)  E148 · E149              directory read + fs mutation
  ──────────────────────────────────────────────────────────────────────
  0.  U13                                  renderer takes the VALUE, not Str
                                           ⇧ five lines; gates literally everything below
  1.  U14 · U15 · U17                      mode record · extension→type · N views per type
  2.  D-U2  →  U18 · U19                   per-type surface syntax + round-trip gate
                                           ⇧ pipeline: example → audit → spec → audit,
                                             carrying TWO types (an outline and a graph)
  3.  U16 (E158) · U26                     block algebra; generalize the outline engine
  4.  U20 · U22                            type 1 outline · type 3 table
                                           ⇧ first two members; the family is now real
  5.  U1 · U2 · U3                         codepoint editing · display width · soft wrap
                                           ⇧ U2 is a hard gate on aligned tables + diagrams
  6.  U21                                  type 2 sectioned doc + schemas  → D-U6
  7.  U23 · U25                            type 4 graph + diagram rendering, tier 0→1
  8.  U30 · U28 · U32                      the note graph; typed links; queries
  9.  D-U4  →  U39 · U40                   a reachable Clock; the civil date type
 10.  U24 · U43 · U45 · U46                journal type; timestamps; TODO workflows;
                                           the agenda VIEW
 11.  S26 · S27  →  U33 · U8 · U4          markers/overlays; citations, diagnostics, search
 12.  D-U3  →  U34 · U35 · U37             authority bundles, capture, refile
 13.  U27 · U36 · U38                      charts; priorities/tags/properties
 14.  D-U5  →  U41 · U42 · U48             told time as evidence; tiers; clocking
 15.  E39 · S28 · S29  →  U49              the agenda DAEMON — last, gating nothing above
```

Four things this ordering asserts, all worth arguing with:

- **U13 is step zero and it is five lines.** The renderer signature is the cheapest
  row in the document and the widest gate: until a renderer sees a typed value,
  every "document type" is a naming convention over text.
- **Two members before three.** Steps 4 and 6–7 land the roster incrementally, and the
  worked example at step 2 carries an outline *and* a graph deliberately — one type is
  not enough to tell whether a surface syntax generalises.
- **`U2` (display width) has been promoted twice.** It was "cosmetic" in
  `SCRIBA-STATE.md`; aligned tables and box-drawn diagrams make it structural.
- **The agenda view (U46) lands long before the agenda daemon (U49)**, because the
  view is a pure fold and only the daemon needs async. Fusing them would put the most
  wanted feature behind the last-built lane.

---

## §13 · Anchors

`.planning/USER-LAYER-PIPELINE-PLAN.md` (**how these rows get built** — tracks,
research briefs, serial queue) ·
`.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` (the `S#` floor this stands on) ·
`.planning/SCRIBA-STATE.md` (what is built) ·
`.planning/SCRIBA-OUTLINE-PLAN.md` (the outline engine U26 generalizes) ·
`.planning/LANGUAGE-INVENTORY.md` (the language axis; state vocabulary) ·
`.planning/BUILD-ORDER.md` (sequencing owner; §A1 altitude leak) ·
`.planning/LEDGER.md` (`E#` categories — `VAL`, `SYS`, `CRY`) ·
`.planning/SELF-IMPLEMENT-CATALOG.md` (E39/E42/E116/E132/E146/E148–E153/E157/E158/E163) ·
`docs/live-environment.md` (the port-viewer thesis; uniformity in the port) ·
`docs/time-and-clocks.md` (**the refraction §7 is built on**) ·
`docs/error-and-alarm.md` + `docs/banks/effect-and-alarm.md` (deadline expiry as alarm) ·
`docs/decision-user-layer-extensibility.md` (D-S1, resolved) ·
`docs/pattern-boundary-sums.md` · `docs/splitting-law.md` · `docs/split-role.md` ·
`docs/insp-emacs.md` (what chirality takes and what it rejects) ·
`scaffold/lib/ports/clock.chiral` (the no-wall-clock decision, in source) ·
`TUI/PRIMITIVE-AUDIT.md` (T17 display width).
