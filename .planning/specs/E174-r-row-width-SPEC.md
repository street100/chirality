---
element: E174
slug: r-row-width
title: **`Rendering` gains horizontal composition (`r-row`) and the per-node width function it needs**
kind: BUILD-PROPER
example: docs/examples/E174-r-row-width.md
status: audited
updated: 2026-08-31
audited: 2026-08-31
---

# E174 SPEC — **`Rendering` gains horizontal composition (`r-row`) and the per-node width function it needs**

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

> **⚑ The pack did not run, and was not repointed.** `tools/pack/pack.py` probes
> `examples/`; this tree's corpus is `docs/examples/`, and
> `tools/pack/MIGRATION-NOTES.md` records the tool as **not repointed on
> purpose**. Per the brief this SPEC was written **by hand** against the tree and
> nothing was repointed at a guess — the same disposition E158's SPEC took. Every
> citation, count and byte string below was **read or executed live on
> 2026-08-31** in `/workspace/chirality-verify` @ `e158-doc`. Where a measurement
> corrected the example it is called out in §6.
>
> **⚑ Amended by the SPEC audit gate (2026-08-31, same tree, same branch).** That
> claim did not hold everywhere. The spec run mis-tallied the sample sweep (SIX
> check `OK`, not seven); reported the compiler blob's *non-blank* line count as
> its line count (**16 161** lines, 14 157 non-blank); asserted an import list
> and a home for `Unit` that `t5_utf8.prog` does not have (it has **no imports
> at all**); mis-cited Phase 7's `fail` increment (`:176`, not `:177`);
> mis-attributed `doc.sh`'s assembled-pattern device to its registration rows;
> counted the hoisted constants as seven while listing eight; and left
> `t5_vt_parser` "not determined" when one command determines it. **All are
> corrected in place below**, and §6 carries the audit's own RUN log — including
> the two mutants (M5, M7) executed against scratch copies of `lib/`.

## 1. Deliverable

- **After this runs:** `lib/protocol/render.chiral` owns a **nine**-constructor
  closed `Rendering` — the ninth being `(r-row (children (List Rendering)))`,
  bare left-to-right juxtaposition with **no implicit separator** — and the
  measure that constructor cannot exist without:
  **`rnd-cols : (-> Rendering I64)`**, a pure per-node *advance* width with one
  arm per constructor and **no `_`**. The **eight** layout constants the emitter
  carries as bare literals become **named `def`s with two readers**
  (`rnd-cols` and `render-to-ansi`) so the width function and the emitter cannot
  drift apart by editing one of them. `render-to-ansi` gains `render-row`;
  `diff-node` gains its structural arm; **`render-section` gains the
  `ansi-goto` it has never had** (FLAG A, §3 row 1). `lib/protocol/apc.chiral`'s
  codec learns the three arms it is missing — `r-lines`, `r-face`, `r-row` — on
  **both** sides, which takes the module from **red to green**. A new
  **Phase 15** gate, `tools/test/row.sh` + `tools/test/samples/e174_row.prog`,
  grades the element **behaviourally against the emitter's own byte stream**,
  never against a shape assertion.

- **The element is the width function, not the constructor.** `r-row` is one arm
  and six lines of emitter. `rnd-cols` is nine arms, four folds, eight hoisted
  constants and a stated precondition, and it is *a contract with*
  `render-to-ansi` rather than a property of the value — which is why §5 grades
  it by rendering and reading the cursor, not by comparing numbers to numbers.

- **Non-goals** (each with where it actually lives):
  - **E175 — nested `r-face` restores the outer face.** Minted
    (`SELF-IMPLEMENT-CATALOG.md:439`, `LEDGER.md:294`). **Not absorbed, and the
    independence is provable, not decorative:** SGR bytes are non-printing, so
    `rnd-cols`'s `r-face` arm is `(rnd-cols body)` whether the renderer resets
    (today) or restores (E175), and **no E175 fix changes one number in
    `rnd-cols`**. §5's screen model makes that a *checked* row (G4/`r-face`,
    mutant M3) rather than a claim. E174 is missing **layout**; E175 is
    non-nesting **SGR state**.
  - **E176 — `str-sub` is unclamped and segfaults.** Minted (`:440`,
    `LEDGER.md:295`). E174 adds **zero** `str-sub` call sites: `str-cols` goes
    through `str->bytes` + `decode-utf8`, not through substring extraction.
    Named so the implement run does not import the hazard by reflex.
  - **E177 — a wcwidth-class codepoint→cell table.** Minted
    (`SELF-IMPLEMENT-CATALOG.md:441`, `LEDGER.md:296`), with **E174 as its first
    consumer**. `str-cols` ships counting **codepoints** — strictly better than
    the incumbent byte count, localised in one named function whose name states
    the unit — and it is **still wrong** for CJK/full-width (2 cells), combining
    marks and ZWJ (0 cells). E177 changes the **body**; the seam and the
    signature do not move. Its row records that the hard part is the **ambiguous
    class** (U+2014), not the table. Decision 15 (§3).
  - **E178 — `r-table`'s header/body layout disagreement.** Minted
    (`SELF-IMPLEMENT-CATALOG.md:442`, `LEDGER.md:297`). Headers advance by
    content (`render.chiral:360`), body cells on a fixed 16-column grid (`:368`)
    — one value, two layouts, measured. E174 **surfaces** it and defines
    `r-table`'s width against the grid; it does not fix it, and its table gate is
    **deliberately narrowed** to the agreeing region. E178 exists so that
    narrowing is a **tracked debt**. Decision 16 (§3).
  - **`doc->rendering` / E158 commit 4.** That is E158's commit
    (`E158-doc-formatter-SPEC.md` §4), which *consumes* `r-row`. E174 owns the
    target type; it does not write the producer.
  - **Wrapping, reflow, or 2-D box layout inside a row.** `rnd-cols` returns one
    `I64`, and §3 row 6 states the precondition that makes one number honest.
  - **The E161 `(module protocol/render …)` datasheet line.** Measured:
    `lib/prelude` carries one in **9 of 9** files, `lib/protocol` in **0 of 8**.
    Adding one here is E161 adoption against the directory's own convention.
  - **`r-hole`'s dead `(put "")`** (`render.chiral:468`). Real, inert, and
    deleting it is not this element.
  - **APC wire-format versioning.** Three new tag letters extend a grammar that
    has no version field. Recorded in §6; giving the envelope a version is not
    E174 and has no minted row.

## 2. Baseline (what already exists — do NOT respec these)

- **Conformance-map verdict: none.** `.planning/audit/CONFORMANCE-MAP.md` has no
  row for E174, E175, E176, E157 or E158 — all postdate the map snapshot
  (`grep -n 'E174\|E158\|E157'` → 0 hits). Treat as **BUILD**, with the live
  measurements below standing in as the build-state authority. Same disposition
  E157's and E158's SPECs took.

- **Ledger / catalog state:** `LEDGER.md:293` — `E174 | render | design | … |
  ←E158, →E158c4`. `SELF-IMPLEMENT-CATALOG.md:438` — `Not built, and it is the
  measured blocker under E158's doc->rendering.` The example's INDEX row
  (`docs/examples/INDEX.md:135`) reads `specced` and links this file — flipped by
  hand with the SPEC commit (§6); it was `reviewed` when the spec run began. Its
  FLAG A block is author-decided (`ea218aa`).

- **⚑ The suite is GREEN today, and the number is the baseline this element must
  not move.** Measured, one run, this session:

  ```
  $ ./bin/chirality test
  …
  downstream roots: 35 compiled, 0 failed, 3 known/negative, 0 newly passing
  typed diagnostics (E157): 30 passed, 0 failed
  layout algebra (E158): 26 passed, 0 failed
  assertions: 168 passed, 0 failed
  chirality test: gate PASSED          (exit 0)
  ```

- **⚑ And the tree is ALREADY RED at the module level, which is the gate E174 is
  handed for free.** Measured, two commands:

  ```
  $ ./bin/chirality check lib/protocol/apc.chiral
  chirality check: lib/protocol/apc.chiral FAILED (exit 1)
  load: non-exhaustive case
  $ ./bin/chirality check lib/protocol/render.chiral
  chirality check: lib/protocol/render.chiral OK
  ```

  `enc : (-> Rendering Str)` is declared at `apc.chiral:41` and defined at
  `:89-104`; it matches **six of eight** — `r-text`/`r-table`/`r-section`/
  `r-stream`/`r-tree`/`r-hole` — with **no default arm**. `r-lines` and `r-face`
  were added to the sum and the codec was never updated. `render.chiral` itself
  is **green**: the sum's own two exhaustive cases are current. The **module** is
  the clean gate; the samples are downstream casualties.

  Casualties, measured over all nine of `prog/scriba/samples/`: **six** check
  `OK` (`t1`, `t2`, `t4_codec`, `t4_grid`, `t4_minimal`, `t7_pty_cap`);
  **`t6_apc_roundtrip.prog`** and **`t5_vt_parser.prog`** fail
  `load: non-exhaustive case` (the latter via `vt-parser.chiral:4`'s
  `(import "protocol/apc")`); **`t5_utf8.prog`** fails
  `load: unknown name Unit` — **unrelated, and for a reason worth stating
  correctly: it has ZERO `(import …)` lines at all.** It is an unported old-tree
  root (its header still reads *"Build: prelude + TUI/vt-core/utf8.chiral + this
  file"*), so nothing resolves into its blob and `Unit` — defined at
  `lib/prelude/prelude.chiral:17`, **not** in `ports/ports` — is simply absent.
  Nothing in E174 touches it, and no `enc` fix can move it.

  **⚑ Determined at the SPEC audit, and it changes commit 3's obligation.**
  `vt-parser.chiral` carries **40** `case`s and one `_`, so whether it *also*
  held a non-exhaustive case of its own was left open by the spec run. It was
  then **measured**: in a scratch copy of `lib/` with `enc`'s two missing arms
  (`r-lines`, `r-face`) added and nothing else changed,
  `prog/scriba/samples/t5_vt_parser.prog` **compiles and runs to exit 42**
  (its own all-passed sentinel). So `t5_vt_parser` goes green on the `enc` fix
  alone; it holds no non-exhaustive case of its own. **Commit 3 therefore removes
  BOTH `t6_apc_roundtrip.prog` and `t5_vt_parser.prog` from `KNOWN_FAIL`**, and
  Phase 7 lands at `37 compiled, 0 failed, 1 known/negative, 0 newly passing`
  (`t5_utf8` alone). Re-measure at implement time — but this is no longer an
  open question, and leaving it "not promised" would have parked a decidable
  one.

- **⚑ Phase 7 will go RED on success unless its `KNOWN_FAIL` list moves in the
  same commit.** `tools/test/run-tests.sh:153` reads
  `KNOWN_FAIL=" t5_utf8.prog t5_vt_parser.prog t6_apc_roundtrip.prog "`;
  `:164-168` is the known-fail branch, which at `:166-167` prints **`NEWPASS`**
  and increments `r_newpass` when a known-failing root starts compiling; and
  **`:176`** turns any non-zero `r_newpass` into a suite failure
  (`[ "$r_newpass" -eq 0 ] || fail=$((fail+1))`), which `:219-222` reports as
  `gate FAILED` and exits non-zero.
  So fixing `enc` turns Phase 7 red until `t6_apc_roundtrip.prog` (and, if it
  goes green, `t5_vt_parser.prog`) leaves the list. **The example does not
  mention this**; it is a hard obligation on commit 3. The prose above the list
  (`:145-146`) also mis-describes all three as *"pre-existing TUI breakage"* — the
  failure is `load: non-exhaustive case` from `enc` for two of them and a missing
  import block for the third, not a tty — and that comment is corrected in the
  same commit.

- **Live code this composes with (already built — compose, do not rebuild):**
  - **`lib/protocol/render.chiral`, 492 L**, `(import "prelude/prelude")` +
    `(import "ports/ports")`, **no `(module …)` line**. `(data Rendering ()` at
    `:6-14`; `r-face` at `:14`. `diff-node` `:223` and `render-to-ansi` `:424`
    are the **two exhaustive 8-arm cases** — the entire measured cost of a ninth
    constructor inside this file. `ansi-reset = ESC[0m` `:282`;
    `ansi-goto row col = ESC[<row>;<col>H` `:302-305`. Emitters:
    `rnd-emit-headers` `:351` (advance `(+ c (+ (str-len h) 2))` at `:360`),
    `rnd-emit-one-row` `:362` (advance `(+ col 16)` at `:368`), `render-table`
    `:378`, **`render-section` `:383-392`**, `render-tree` `:394` (child at
    `(+ col 2)`, `:401`), `render-lines` `:409-415` (steps `row`, **holds
    `col`**), `render-to-ansi-full` `:480`, `render-to-ansi-delta` `:488`.
    `rd-in-view` `:420` clips **by row only** and never by column, and the
    comment at `:426-429` states that containers do not clip and do not
    `ansi-goto`.
  - **`lib/protocol/utf8.chiral`** — `(import "prelude/prelude")` **only**, so
    `protocol/render` → `protocol/utf8` is acyclic. `cont?` `:31/:38`,
    `utf8-decode1 : (-> Bytes I64 (Pair I64 I64))` `:32/:46`, `decode-from`
    `:33/:95`, `decode-utf8 : (-> Bytes (List I64))` `:34/:104`. RFC-3629
    well-formed with U+FFFD resync, pure `->`. **A decoder only — there is no
    width function anywhere in `lib/` or `prog/`**, and `utf8.chiral:15` names
    *"the T4 wide-cell width computation"* as a **future** consumer.
  - **`lib/prelude/prelude.chiral`** — `max` `:150`, `min` `:153`,
    `str-len : (-> Str I64)` extern `:75` (**bytes**), `str-cat` `:83`,
    `i64->str` `:84`, `str->bytes` `:88`, `blen` `:93`, `str-sub` `:80`
    (**E176's hazard — E174 adds no call site**).
  - **`lib/protocol/apc.chiral`, 252 L.** `enc` `:41/:89`; the list walks
    `enc-rends`/`enc-rends-body` `:81-82` and `enc-rows`/`enc-rows-body`
    `:83-84`; lengths `list-len-str`/`list-len-rend`/`list-len-rows` `:75-77`.
    Tags in use: **`t T s S r h`** (`:87`) — `L`, `F`, `R` are free and are
    graphic ASCII, which the APC envelope rule (`:1-6`) requires.
    `block-id` `:127-134` matches `r-section`/`r-hole` **plus an existing `_`**
    — that `_` is pre-existing and semantically correct (only those two are
    addressable); it is **not** the catch-all the non-negotiables forbid and it
    stays.
  - **⚑ The DECODE side is not a closed sum.** `dec` (`:193-249`) is a `cond` on
    a tag `Str` ending in `(else (p-err (str-cat "bad tag " tag) pos))`. So a
    forgotten *decode* arm is **not** a compile error — it is a runtime `p-err`.
    That is the single most important gate-design fact in this SPEC and it is why
    §5's G2 is a **round-trip**, not a coverage check (mutant M7).
  - **`tools/test/run-tests.sh`.** `run_phase()` `:113`; registered
    3-6 at `:132-135`, **13** at `:188` (E157), **14** at `:197` (E158). The
    header (`:18-24`) records **8-12 as names still owed** (the five rows at `:18-22`) to unported old-tree
    phases. Phase 7's root sweep is `:153-178`.
  - **`tools/test/diag.sh` (E157, 30 assertions)** and **`tools/test/doc.sh`
    (E158, 26 assertions)** + their fixtures. `doc.sh` is the shape `row.sh`
    mirrors: `ok`/`bad` counters, `build_run`, `build_err`, `refuse_msg`, the
    `mutant()` runner (`:109-124`) that **copies `lib/`, seds it, and asserts the fixture
    fails at a named case** , the **assembled-pattern** census device
    (`UN='(d-''union'`, `:291`) and the **sha256 pins** on E157's gate
    (`:435-441`). Both are **pinned by this element** (§5 G7).

- **The defect, measured (not paraphrased):**
  - **No `Rendering` value means "these segments, side by side."** The only
    horizontal placement in the module is `r-table`'s, and its two placers
    disagree: `:360` advances by content + a 2-column gutter, `:368` by a
    hardcoded 16. `r-face` (`:469-476`) renders its body at the **same** row/col
    and emits no `ansi-goto`; `render-lines` steps `row` and holds `col`.
  - **`render.chiral` is a counterexample to its own arithmetic.** The
    `r-stream` arm draws `" — live stream]"` (`:459`). Measured with `od -c`:
    **17 bytes, 15 columns** — the em-dash is U+2014, three bytes.
  - **⚑ `render-section` never issues an `ansi-goto`, verified by running it.**
    A probe compiled with `bin/chirality-bin` and executed:

    ```
    render-to-ansi-full (r-section "Sec" false (r-text "body" false)) (24,80)
      → ESC[2J ESC[H ESC[1m S e c ESC[0m ESC[2;3H b o d y ESC[0m
    ```

    The title is **not** preceded by any positioning sequence; it lands at (1,1)
    only because `ansi-home` (`:483`) put the cursor there. `render-section`
    takes `col` (`:384`) and reads it **once**, as `(+ col 2)` for the body
    (`:392`). Every other drawing arm opens with `(put (ansi-goto row col))` —
    `:356` (each table header), `:439` (`r-text`), `:455` (`r-stream`), `:465`
    (`r-hole`). **`render-section` is the single outlier.**
  - **The measured blast radius, which corrects the catalog.** `grep -Rln` over
    `lib prog tools`: **17** files `import "protocol/render"`; **13** name a
    `Rendering` constructor; **5** actually `case` over the sum
    (`render.chiral`, `apc.chiral`, `scriba-runview-test.prog`,
    `scriba-runview-stream-test.prog`, `t6_apc_roundtrip.prog:82`); and
    **exactly 1 file has an exhaustive case that breaks** — `render.chiral`,
    **twice**, at `:223` and `:424`, 8 arms each. All three `.prog` matchers go
    through `(_ …)`. `apc.chiral` is the already-broken one. The catalog's
    *"12 files case over it"* (`:438`, `LEDGER.md:293`) is a count of
    constructor-naming files other than `render.chiral` — a different and much
    larger set.
  - **Name census, run tree-wide with `grep -R` (not `-r` — symlinks).** All
    seventeen names E174 introduces — `r-row`, `rnd-cols`, `rnd-cols-sum`,
    `rnd-cols-max`, `rnd-hdr-cols`, `rnd-row-cells`, `str-cols`, `cp-count`,
    `render-row`, `rnd-tree-indent`, `rnd-section-indent`, `rnd-table-cell`,
    `rnd-header-gutter`, `rnd-collapsed-mark`, `rnd-hole-mark`,
    `rnd-stream-open`, `rnd-stream-close` — have **zero** defining occurrences
    across `lib prog tools`. Sixteen have zero occurrences of any kind; `r-row`
    has 16 substring hits, **all** inside `infer-row` / `cursor-row-col` /
    `puf-cursor-row` and none a binding.
  - **`protocol/utf8` co-blobbing is free.** Its four names (`cont?`,
    `utf8-decode1`, `decode-from`, `decode-utf8`) are each defined **exactly
    once** tree-wide, so pulling it into all 17 `protocol/render` importers
    introduces no duplicate label. `vt-parser.chiral` already co-blobs the two
    (`:3` + `:4`).

- **⚑ BUILD-RULE state, measured: E174 changes NO compiler source, so the
  fixpoint does not fire.** `chirality_blob_file "lib:prog" prog/compiler.prog`
  produces **16 161 lines** (14 157 of them non-blank) and contains **zero**
  occurrences of `r-text` or
  `render-to-ansi` — `protocol/render` and `protocol/apc` are outside the
  compiler's import closure. Consequences, stated so they are not guessed at in
  §4: there is **no new compiler binary**, **no promotion**, and **no
  `cmp C1 C2`**. The rule and its trip condition are in §4's standing rules.

## 3. Decisions

Rows 1-4 are **BINDING from upstream** — the author's FLAG A block and the three
standing calls the example records — and are carried, not reopened. Rows 5-8 are
the example's open questions the audit judged **decidable**, closed here with the
measurement that decides them. Rows 9-14 are new to the spec run. **Rows 15-16
were the spec run's two NEEDS-AUTHOR items; the author ANSWERED both and minted
their rows (`da3e7b3`), so they are carried here as settled** — the catalog and
the ledger outrank this file. One recommendation (open question 5) is surfaced
with its blast radius.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Does `render-section` get its `ansi-goto` inside E174? | **BINDING — YES, inside E174. Author decision, `ea218aa`** | One line at `render.chiral:385`, wrapping `(put ansi-bold)` in `(let ((_ (put (ansi-goto row col)))) …)`. Measured (§2): `render-section` takes `row`/`col` and **never reads either to position itself** (it reads `col` exactly once, at `:392`, only to indent the body); `:356`, `:439`, `:455`, `:465` all position themselves, so it is the single outlier and the fix **removes** a special case. Without it, `r-row`'s whole contract — child *n* draws at `col + Σ widths` — is void for an `r-section` child no matter what `rnd-cols` returns, and §5's agreement row would be **unsatisfiable for one constructor**: a gate row that cannot fail. **It carries its own gate row** (§5 **G5**): a section rendered first-on-row must land exactly where it lands today, proving the fix is a no-op in the only configuration the tree currently produces. The screen map to pin is measured and printed in §5. |
| 2 | SGR escapes inside `r-text`'s `Str`? | **BINDING — REFUSED** | A `Str` carrying which-of-N presentation structure is the precise flattening defect E157 and E158 exist to remove (`pattern-boundary-sums`), and it would make `Rendering` unsafe to re-render to any non-ANSI medium — including `apc.chiral`'s codec, which transports the value itself. The alternative, **restricting `doc->rendering`'s contract** to single-segment lines, was **measured dead on E158's own first consumer** (`dg-doc`'s `r-redeclared` arm puts a tagged head, a space and a tagged site on one line at any width where the group fits). **Horizontal composition wins by elimination, not preference.** Both are already on the catalog row (`:438`); nothing below re-argues either. |
| 3 | Is E175 absorbed into E174? | **BINDING — NO, and the independence is a proof, not a scoping note** | SGR bytes are **non-printing**, so `rnd-cols`'s `r-face` arm is `(rnd-cols body)` under both today's `ansi-reset` and E175's restore: **`rnd-cols` is provably invariant under E175**. E174 is missing **layout**; E175 is non-nesting **SGR state** (`LEDGER.md:294`, minted). Folding them would conflate two failures with one symptom. §5's screen model ignores `ESC[…m` and **mutant M3** (`face-costs-a-column`) makes the zero-width claim a row that can fail. Order: E174, then E175; E158's G8 grades the pair. |
| 4 | Does `r-row` carry a separator? | **BINDING — NO. Bare juxtaposition** | The two existing horizontal placers each bake a spacing constant in — `+2` at `:360`, `+16` at `:368` — and the measured consequence is one `r-table` value with two column layouts. A combinator with a baked-in gap cannot express "no gap", which is exactly what a `d-cat` of two adjacent tagged spans needs; a caller who wants a gap writes one more child, `(r-text " " false)`. One constructor, one meaning. |
| 5 | What does `r-row` do with a multi-row child (example q3)? | **RESOLVED — option (i), allow it, and SAY SO. Was parked; it is decidable** | `rnd-cols` of an `r-lines` is `max`, which is the only defensible number, and `render-row` as written in the example's §5 **already** does (i) with no extra line: each child draws where it wants and `col` advances by the max. Option (iii), refuse it, needs a check `Rendering` has nowhere to put. So the question collapses to **(i) plus one sentence of doc**, and the sentence is the deliverable: `r-row`'s header comment states that a stacked child makes the row occupy several rows, and that this is allowed rather than accidental. A silently-2-D combinator is a surprise; a documented one is a feature. |
| 6 | Does `r-stream` reserve space for content it does not hold (example q4)? | **RESOLVED — it reserves nothing, and this is a DEFINITION, not an open question** | Not actually open: the emitter (`:451-460`) draws a **fixed placeholder** — `"["` + `source-id` + `" — live stream]"` — so the width **is** derived from what is drawn, exactly like every other arm. `rnd-cols`'s `r-stream` arm is `(+ (str-cols rnd-stream-open) (+ (str-cols source-id) (str-cols rnd-stream-close)))`. Recorded as a **visible definition**: a stream occupies no columns for content the value does not carry. A future streaming renderer that draws real content in place makes it underivable again and would need a declared reservation *field* on the constructor — which is a change to the constructor, and would be its own row. |
| 7 | One `I64` or a min/max pair (example q6)? | **RESOLVED — one `I64`, with the precondition written into the source** | Decidable and already decided by the module: **nothing in `Rendering` reflows.** No constructor carries a width field; `render-to-ansi` clips **by row** via `rd-in-view` (`:420`, `(and (<=i 1 row) (<=i row (- (rd-rows dims) 1)))` — `col` does not appear) and **never wraps by column**; the only wrapping is the terminal's, which `ansi-nowrap` (`:293`) turns **off**. `rich`'s `Measurement(minimum, maximum)` exists for the case chirality does not have. The signature is `(-> Rendering I64)` and its header states, in as many words, that **if a wrapping constructor ever lands this signature is wrong rather than imprecise**. |
| 8 | Does `rnd-hdr-cols` fold *n* gutters or *n−1*? | **RESOLVED — n−1** | The emitter advances `c` by `(+ (str-len h) 2)` after **every** header including the last (`:360`), but that final advance is consumed by the `nil` case and **nothing is ever drawn in it**. The last column the header row touches is therefore `Σ lengths + 2(n−1)`. Folding *n* gutters would bake a two-column trailing separator into a width function whose own decision (row 4) is that a row has **no implicit separator** — and §5's exact-adjacency row would convict it. (The example states this correctly; it is pinned here because it is the arm most likely to be "simplified" back.) |
| 9 | Where does the shared-constant invariant live? | **RESOLVED — EIGHT named `def`s with TWO readers, in `render.chiral`** | This is the substance of the element. Every constant `rnd-cols` needs is today a bare literal inside an emitter: `2` at `:392` (section body indent), `2` at `:401` (tree indent), `16` at `:368` (table cell), `2` at `:360` (header gutter), `" [+]"` at `:387`, `"<?>"` at `:466`, `"["`/`" — live stream]"` at `:457`/`:459`. Two literals that must agree across a function boundary is the bolted-on invariant PRINCIPLES §5 refuses; **one `def` read by both** is the substrate version. Names censused free (§2): `rnd-section-indent`, `rnd-tree-indent`, `rnd-table-cell`, `rnd-header-gutter`, `rnd-collapsed-mark`, `rnd-hole-mark`, `rnd-stream-open`, `rnd-stream-close`. **The emitters are edited to read them** — hoisting the name without repointing the emitter buys nothing, and §5's **M11** (`tree-forgets-its-indent`) is the row that proves the two are wired to one definition. |
| 10 | Does `protocol/render` importing `protocol/utf8` cost anything? | **RESOLVED — no. Acyclic, collision-free, and already co-blobbed once** | `utf8.chiral:1` imports `prelude/prelude` **only**, so there is no cycle. Its four names are each defined exactly once tree-wide (§2 census), so pulling it into all **17** `protocol/render` importers introduces no `duplicate label`. `vt-parser.chiral` already imports both (`:3`, `:4`), so the pair has co-blobbed in a live root since before this element. The cost that is real is **runtime**: `str-cols` is O(n) where `str-len` was O(1), once per node per render — see decision 15's fallback. |
| 11 | Which module owns `str-cols`? | **RESOLVED — `lib/protocol/render.chiral`, beside its only consumer** | It is not a general string utility today: its one caller is `rnd-cols`, its unit is *terminal columns* (a display concept, not a string concept), and `lib/prelude/string.chiral` has no display dependency and should not acquire `protocol/utf8` for one function. Put it where its consumer is; **move it to `prelude/string` the day a second consumer appears**, which is a one-line move under a name that already exists. Naming it `str-cols` rather than `str-width` is deliberate: **the name states the unit**, so E177's wcwidth landing (decision 15) is a **body change** and not a re-audit of every call site. That is the E176 lesson — a safety property in a *name and a type*, not in a comment — applied ahead of the defect. |
| 12 | `(module protocol/render …)` datasheet line? | **RESOLVED — NO, by the directory's own convention** | Measured: `lib/prelude` carries one in **9 of 9** files (`prelude`, `list`, `string`, `alist`, `maybe`, `map`, `set`, `ord`, plus E158's `doc`); **`lib/protocol` carries one in 0 of 8**. Adding one to `render.chiral` is E161 adoption, out of scope, and against the local convention E158's decision 14 already followed in the other direction. |
| 13 | Does the codec fix land inside E174 (example q5)? | **RESOLVED — INSIDE (author, 2026-08-31, answering the spec audit's FLAG B).** The plan already executed it unconditionally — commit 3, gate rows G1/G2, mutants M6/M7 and half of M5 — so `RECOMMEND` was a label the SPEC's own body contradicted. Three reasons it is IN, not a preference: **(1)** E174 adds a ninth constructor to a codec that is *already* missing two, so leaving it out ships a strictly worse red than the one inherited; **(2)** leaving a knowingly-red module behind is the exact failure `enc` itself documents — a previous arm addition shipped without updating it, which is why this element exists; **(3)** G1's red→green row was verified real, and `M6` was run both directions. The blast radius stands as written | Author-tier by the example, and the recommendation is well argued: leaving a knowingly-red module behind is precisely the failure mode `enc` itself documents (`r-lines`/`r-face` shipped and left it red, and nobody traced the second red sample back to it), and three constructors of codec is smaller than a separate element's ceremony. The audit strengthens it: **G1's red→green row exists only if E174 fixes it**, and the round-trip row (G2) is the only thing that can catch a forgotten *decode* arm, since `dec`'s `cond` ends in `else`. Blast radius in the block below. |
| 14 | Which phase number for the gate? | **RESOLVED — 15** | `run-tests.sh:18-22` and `tools/test/MIGRATION-NOTES.md:27` both record **8-12 as names still owed** to unported old-tree phases (module datasheet, sort adoption, the dropped C leg, resolver state, the E168 floor), and that reusing one would make an unported gate look ported. E157 took 13 for that reason, E158 took 14. **E174 takes 15.** Registration is a **required line**, not a courtesy: an unregistered `row.sh` is a gate that never runs, and §5 makes the registration itself a checked row with a mutant (M9), the way `doc.sh` does. |
| 15 | What does `str-cols` finally mean? (example open question 1; was NEEDS-AUTHOR-1) | **RESOLVED — codepoints, shipping in E174. Author-answered, `da3e7b3`; the table is E177** | `str-cols s` = the length of `(decode-utf8 (str->bytes s))`, derivable from `utf8.chiral` today, strictly better than the incumbent byte count, and localised in one named function whose **name states the unit**. The wide-cell table is **E177** (`SELF-IMPLEMENT-CATALOG.md:441`, `LEDGER.md:296`), minted, with **E174 as its first consumer**: E177 is a body change plus a table, and **the seam and the signature do not move**. E177's row records that the hard part is the **ambiguous class** — U+2014 is East-Asian Ambiguous, the one class where `wcwidth` implementations legitimately disagree (1 column narrow, 2 CJK-legacy), so E177 must pick a stance rather than copy a table. The residue E174 ships with, named in `str-cols`'s header: CJK/full-width 2 cells, combining/ZWJ 0 cells, and an **O(n) decode per node per render** where `str-len` was O(1). **Fallback if the O(n) decode measures badly:** keep `str-cols` as the seam and make its **body** `(str-len s)` — same signature, worse body, and §5's **G4/`r-stream`** row goes red and *says so*. Deleting the seam is not available. |
| 16 | `r-table`'s header/body layout disagreement (example open question 2; was NEEDS-AUTHOR-2) | **DEFERRED to E178. Author-answered, `da3e7b3`; out of E174, and the narrowing is a TRACKED debt** | Measured: `rnd-emit-headers` advances by `(+ (str-len h) 2)` — content-derived, 2-column gutter (`:360`); `rnd-emit-one-row` by `(+ col 16)` — a fixed grid, content ignored (`:368`). The **same `r-table` value has two column layouts** depending on which row you measure, and a header wider than 14 columns overruns its own cell. §4 answers `rnd-cols`'s `r-table` arm with **the grid** (`max (rnd-hdr-cols headers 0) (* rnd-table-cell (rnd-row-cells rows 0))`), because the grid is what a body cell actually obeys — a **defined, not derived** answer, and the only arm where that is forced by a *defect* rather than by missing information. **Consequence the gate must state and does (§5 G4):** the `r-table` row is fixtured with headers ≤ 14 columns and cells ≤ 16 and therefore **does not grade the overrun**; the script says so in as many words. The fix — per-column widths (the natural first consumer of `rnd-cols`) or deleting the header arithmetic — is **E178** (`SELF-IMPLEMENT-CATALOG.md:442`, `LEDGER.md:297`), minted *so that E174's narrowed gate is a tracked debt rather than a silent one*. |

### ⚑ Decision 13's blast radius, stated in red — read before commit 3

Fixing `apc.chiral` is **not** a free repair, and none of the following is
optional:

- **The APC wire format gains three tag letters** (`L`, `F`, `R`) on a grammar
  with **no version field**. A newer encoder's frame is a `p-err "bad tag …"` to
  an older decoder — a **value**, not a crash (`:249`), which is the codec's own
  design and the reason this is acceptable. It is still a compatibility surface
  and it is why the example lists "the APC wire format" under *against*.
- **The decode side has an `else` catch-all**, so half this repair is
  **invisible to the compiler**. `enc` without an arm is `load: non-exhaustive
  case`; `dec` without an arm is a silent runtime `p-err` that only a round-trip
  test sees. §5 **G2** and **mutant M7** exist for exactly this.
- **Phase 7 goes red on success** until `KNOWN_FAIL` moves (§2). This is the
  step most likely to be forgotten because it fires *because the fix worked*.
- **`t5_vt_parser` goes green too — measured at the SPEC audit** (§2). Two
  roots, not one, leave `KNOWN_FAIL` in commit 3, and `t5_utf8` stays with its
  real reason written (no imports at all), not with the inherited "TUI
  breakage" line.
- **No `_` arm anywhere.** Adding one to `enc` would "fix" the red by defeating
  the closed sum — the exact mechanism that made this element's cost knowable.
  §5 **M5** (`tenth-constructor`) is the row that proves none was added, and it
  is behavioural: a tenth constructor must make **both** `protocol/render` and
  `protocol/apc` fail to compile.

### ⚑ FLAG B — raised by the SPEC audit gate, author-tier, NOT resolved here

> **Decision 13 is labelled `RECOMMEND INSIDE`, but §4 and §5 execute it
> unconditionally.** The example put "does the codec fix land inside E174?" on
> the author's side of the line, and this SPEC answers it with a recommendation
> rather than a disposition — then builds commit 3 around it, and hangs **two of
> eight gate rows (G1, G2), two of twelve mutants outright (M6, M7), and half of
> a third (M5's `protocol/apc` assertion) off it**. If the author moves the codec to its own
> element, those rows leave E174 with it and the element's gate shrinks to five
> rows; if the author confirms, decision 13 should read **RESOLVED**, not
> **RECOMMEND**, because nothing downstream treats it as optional.
>
> The audit does not resolve it: a spec run may not decide the element's scope,
> and neither may its audit. **The recommendation is well argued and the audit
> found no reason against it** — leaving a knowingly-red module behind is the
> failure `enc` itself documents, and G1's red→green row was verified real
> (§6). This is a request for the label to be made honest, not for the plan to
> change.

### ⚑ Both of the spec run's NEEDS-AUTHOR items are ANSWERED and MINTED (`da3e7b3`)

This SPEC was written with two open author-tier questions. Both were decided and
given catalog + ledger rows in the same commit, so **neither is open and neither
is parked on a phantom**:

- **`str-cols` means codepoints, and it ships in E174** (decision 15). The
  wide-cell table is **E177** — `SELF-IMPLEMENT-CATALOG.md:441`,
  `LEDGER.md:296` — with E174 as its first consumer and the ambiguous class
  (U+2014) named as the real decision. The seam and the signature do not move,
  so E177 is a body change.
- **`r-table`'s header/body disagreement is out of E174** (decision 16),
  deferred to **E178** — `SELF-IMPLEMENT-CATALOG.md:442`, `LEDGER.md:297`.
  E174's table gate stays **deliberately narrowed** to the agreeing region
  (headers ≤ 14 columns, cells ≤ 16) and **must say so in the script**; E178
  exists so that narrowing is a tracked debt.

There is no remaining NEEDS-AUTHOR item on this element. The deferral rule is
satisfied: every follow-on named below has a minted row.

## 4. Change plan (ordered, commit-sized)

**Standing rules for every commit below.**

- **`bin/chirality-bin` (the committed compiler) compiles everything. Python
  compiles nothing, ever.** The flow is **build-new → test → promote**; nothing
  replaces itself in place.
- **The fixpoint obligation does NOT fire on this element, and the reason is
  measured, not assumed** (§2): `protocol/render` and `protocol/apc` are outside
  `prog/compiler.prog`'s import closure — its 16 161-line blob contains zero
  occurrences of `r-text` or `render-to-ansi`. So there is **no `C1`, no
  promotion, and no `cmp`**. **Trip condition, stated so it is not missed:** if
  an implement run finds itself rebuilding `bin/chirality-bin`, the closure has
  changed and the self-host check becomes **mandatory** — `bin/chirality-bin <
  blob > C1`, **verify `C1` is non-zero before `cmp`** (`cmp` of two empty files
  passes and is the classic false green), test C1, promote, then `./C1 < blob >
  C2; cmp C1 C2`. **The `cmp` is stability, never correctness** — Phase 15 is
  what says the widths are right.
- **No catch-all `_` arm is added anywhere to absorb `r-row`** — not in
  `render-to-ansi`, not in `diff-node`, not in `enc`. That defeats the closed sum,
  which is the whole reason the cost of this element is knowable. `block-id`'s
  pre-existing `_` (`apc.chiral:127-134`) is correct and stays.
- Module keys are **root-relative** (`(import "protocol/utf8")`, never
  `(import "utf8")`); the **extension is the kind** per `LAYOUT.md:5-10`.
- **Every new name is censused with `grep -R`, not `grep -r`** — `-r` does not
  follow symlinks and would let a skipped file read as a clean census
  (`tools/test/MIGRATION-NOTES.md` records this trap for `diag.sh` G6). The
  census for all seventeen names is already in §2 and must be **re-run**, not
  trusted, at implement time.
- **E157's and E158's gates must not move.** `tools/test/diag.sh`,
  `tools/test/samples/e157_diag.prog`, `tools/test/doc.sh` and
  `tools/test/samples/e158_doc.prog` are **byte-unchanged** by this element;
  Phase 13 (30 assertions) and Phase 14 (26) must still pass **unchanged**. §5
  **G7** pins all four by sha256.

### Commit 1 — `render.chiral`: the constants, `str-cols`, and `rnd-cols` — no new constructor yet

- **Target:** `lib/protocol/render.chiral` (**EDIT**, ~+70 L)
- **Change:**
  - `(import "protocol/utf8")` added beside the existing two (decision 10). No
    `(module …)` line (decision 12).
  - The **eight** layout constants as named `def`s (decision 9 -- the count is
    EIGHT, one per bare literal the emitters carry; the name list below has
    always had eight entries):
    `rnd-tree-indent 2` · `rnd-section-indent 2` · `rnd-table-cell 16` ·
    `rnd-header-gutter 2` · `rnd-collapsed-mark " [+]"` · `rnd-hole-mark "<?>"` ·
    `rnd-stream-open "["` · `rnd-stream-close " — live stream]"`.
  - **`rnd-emit-headers` (`:360`), `rnd-emit-one-row` (`:368`), `render-tree`
    (`:401`), `render-section` (`:387`, `:392`), the `r-stream` arm (`:457`,
    `:459`) and the `r-hole` arm (`:466`) are edited to READ those names.**
    Hoisting the constant without repointing its emitter buys nothing — the two
    readers are the deliverable.
  - `str-cols : (-> Str I64)` = `cp-count (decode-utf8 (str->bytes s)) 0`, with
    `cp-count : (-> (List I64) I64 I64)` a three-line accumulator walk in the
    module's existing style (cf. `rnd-append-list`). Header comment states the
    **unit is terminal columns**, that the body counts **codepoints**, and names
    the residue (CJK 2 cells, combining 0 cells, U+2014 ambiguous) and
    **points at E177**, which owns the table (decision 15).
  - `rnd-cols : (-> Rendering I64)` over the **eight** current constructors, plus
    `rnd-cols-max`, `rnd-hdr-cols` (**n−1 gutters**, decision 8) and
    `rnd-row-cells`. **No `_` arm.** Header comment carries the precondition from
    decision 7 verbatim.
- **Verify:** `./bin/chirality check lib/protocol/render.chiral` → **OK**
  (it is green today and must stay green). `./bin/chirality test` → Phase 7
  still `35 compiled, 0 failed, 3 known/negative, 0 newly passing`; Phases 13 and
  14 unchanged. `rnd-cols` is imported by nothing yet, so this commit changes no
  behaviour and no blob outside `protocol/render`'s own importers.

### Commit 2 — `render.chiral`: the ninth constructor, `render-row`, `diff-node`, and `render-section`'s `ansi-goto`

- **Target:** `lib/protocol/render.chiral` (**EDIT**, ~+25 L)
- **Change:**
  - `(r-row (children (List Rendering)))` appended to `(data Rendering ()` at
    `:14`. **`(declare rnd-cols-sum …)` + its fold, and `rnd-cols`'s ninth arm,
    `((r-row children) (rnd-cols-sum children 0))`** — a **sum**, because
    children abut (decision 4).
  - `render-row : (=> (List Rendering) (Pair I64 I64) I64 I64 I64 I64 Unit)` —
    a container, so **no `ansi-goto` of its own and no `rd-in-view` clip**,
    following `render-lines`/`render-tree` (`:426-429` says why): recurse on the
    head at `col`, then on the tail at `(+ col (rnd-cols child))`.
  - `render-to-ansi`'s ninth arm, `((r-row children) (render-row children dims
    row col drow dcol))`, beside the `r-lines`/`r-tree` arms at `:431-434`.
  - `diff-node`'s ninth arm (`:223`), structural, in the shape of the existing
    `r-lines` arm; `list-all-diff-same` (`:191`) needs no change.
  - **`render-section` gets `(put (ansi-goto row col))` as its first `put`** —
    one `let`, wrapping `:385` (decision 1 / FLAG A).
  - `r-row`'s header comment states decision 5 in as many words: a stacked child
    is **allowed** and makes the row occupy several rows.
- **Verify:** `./bin/chirality check lib/protocol/render.chiral` → OK.
  `./bin/chirality check lib/protocol/apc.chiral` → still **FAILED /
  non-exhaustive** (it is now six of **nine**), which is the expected
  intermediate state and is why commit 3 is not optional. Phase 7 unchanged
  (`t6_apc_roundtrip` was already on `KNOWN_FAIL`).

### Commit 3 — `apc.chiral`: the codec learns three arms, on BOTH sides; the tree goes green

- **Targets:** `lib/protocol/apc.chiral` (**EDIT**, ~+20 L) ·
  `tools/test/run-tests.sh` (**EDIT**, the `KNOWN_FAIL` line + its prose).
- **Change:**
  - `enc` (`:89`) gains three arms, tag letters continuing the existing scheme
    (`t T s S r h` → add `L F R`, all graphic ASCII per the envelope rule
    `:1-6`): `((r-lines children) (str-cat "L" (enc-rends children)))` ·
    `((r-face f body) (str-cat "F" (str-cat (enc-str f) (enc body))))` ·
    `((r-row children) (str-cat "R" (enc-rends children)))`. **No `_`.**
  - `dec` (`:193`) gains the three matching `cond` branches, reusing
    `dec-rends`/`dec-str` exactly as the `"r"` and `"s"` branches do. **⚑ These
    are invisible to the compiler** — `dec` ends in `else` (`:249`) — so they are
    graded only by §5's round-trip row.
  - `block-id` (`:127`) is **not touched**: `r-row` is not addressable and falls
    through the existing, correct `_`.
  - **`KNOWN_FAIL` (`run-tests.sh:153`) is updated to exactly the still-failing
    set**, and the prose above it (`:145-146`) is corrected: `t6_apc_roundtrip`
    and `t5_vt_parser` were **not** "pre-existing TUI breakage" — they were
    `load: non-exhaustive case` from `enc`, and **both leave the list** (§2).
    `t5_utf8` stays, with its real reason: it carries **zero `(import …)`
    lines** — an unported old-tree root — so `load: unknown name Unit` is a
    migration gap, not a codec one, and no `enc` fix can move it.
- **Verify — the red→green measurement, and it is the point of the commit:**
  - `./bin/chirality check lib/protocol/apc.chiral` → **OK** (FAILED today).
  - `./bin/chirality check prog/scriba/samples/t6_apc_roundtrip.prog` → **OK**.
  - `./bin/chirality check prog/scriba/samples/t5_vt_parser.prog` → **OK**.
    Measured at the SPEC audit against a scratch `lib/` carrying only `enc`'s
    missing arms: it compiles and runs to **exit 42**, its own all-passed
    sentinel. It leaves `KNOWN_FAIL` with `t6_apc_roundtrip`.
  - `./bin/chirality test` → Phase 7 reports **`37 compiled, 0 failed, 1
    known/negative, 0 newly passing`** — `0 newly passing` again, now over a
    smaller `KNOWN_FAIL`; Phases 13 and 14 unchanged.

### Commit 4 — the gate: `tools/test/row.sh` + fixture + registration

- **Targets:** `tools/test/samples/e174_row.prog` (**NEW**) ·
  `tools/test/row.sh` (**NEW**) · `tools/test/run-tests.sh` (**EDIT**, the
  `run_phase 15` line + the phase-list header at `:13-24`) ·
  `tools/test/MIGRATION-NOTES.md` (**EDIT**, one row in the "New here" table).
- **Change:** the fixture and script per §5, mirroring `doc.sh`'s shape —
  `ok`/`bad` counters, `build_run`, the `mutant()` runner (`:109-124`) that copies `lib/`,
  seds it and asserts a named case, the assembled-pattern census device, the
  sha256 pins — plus the one helper this element needs and `doc.sh` does not: a
  **`screen()` reducer** over the compiled program's **stdout** (§5).
  Registration beside `:197`:
  `run_phase 15 "horizontal composition (E174 r-row + rnd-cols)"  row.sh`
- **⚑ The fixture goes in `tools/test/samples/`, not `prog/scriba/samples/`**, for
  the reason `MIGRATION-NOTES.md` already gives for `e157_diag.prog` and
  `e158_doc.prog`: it is consumed by *this gate*, not read by path at runtime by
  a shipped program, so it sits outside the shipped tree — and therefore outside
  Phase 7's `lib prog` root sweep, so E174's assertions are counted once, by
  E174's own phase.
- **Verify:** `./bin/chirality test` — **Phase 15 green, Phases 13 and 14
  unchanged at 30 and 26, Phase 7 at `37 compiled, 0 failed, 1 known/negative,
  0 newly passing`, and the suite total at exactly `170 + <Phase 15's count>
  passed, 0 failed`.** The 170 is not a guess: `run_phase` tallies each
  sub-script's `N passed, M failed` line (`:122-126`) and `:179` tallies
  Phase 7's `r_pass`, so commit 3 moving two roots out of `KNOWN_FAIL` takes the
  today-measured 168 to 170 **before** Phase 15 adds its own.

**Not in this element, and each already has a MINTED home — no deferral here
rests on a phantom:** E175 (`SELF-IMPLEMENT-CATALOG.md:439`) · E176 (`:440`) ·
**E177**, the wide-cell width table (`:441`, decision 15) · **E178**,
`r-table`'s per-column widths (`:442`, decision 16) · E158 commit 4
(`E158-doc-formatter-SPEC.md` §4, `### Commit 4`) · E161's datasheet line
(decision 12).

## 5. Conformance gate — `tools/test/row.sh`, Phase 15

**A width function is exactly the thing that looks right and is off by one.** So
**no row here is a shape assertion** — not "`rnd-cols` returns 15", not "the sum
has nine arms by grep". Every row that matters **renders through
`render-to-ansi` and reads the emitted byte stream**, and every row carries a
**named mutant that must be RUN**. A row whose mutant also passes exercises
nothing (the E156 lesson, and the five self-matching grep gates found in this
repo this session).

**The `screen()` helper — the one piece `doc.sh` does not already have.**
`build_run` discards stdout; this gate needs it. `screen()` runs the compiled
fixture, captures stdout, and reduces the byte stream to a **cell map**, emitting
one `row col codepoint` line per painted cell. Verified live that this is
available and exact — a probe compiled with `bin/chirality-bin` and executed
produced, for `render-to-ansi (r-text "ab" false) … 3 5`:

```
ESC [ 3 ; 5 H a b ESC [ 0 m
```

The reducer's rules, and each is load-bearing:

| input | effect |
|---|---|
| `ESC[<r>;<c>H` | set cursor to (r, c) |
| `ESC[H` | set cursor to (1, 1) |
| `ESC[2J` | clear the map |
| `ESC[<params>m` | **ignored — SGR paints no cell.** This is what makes G4/`r-face` a real row rather than a comment |
| `ESC[?<n>h` / `ESC[?<n>l` / `ESC[K` | ignored |
| `\n` | row += 1, col = 1 |
| a UTF-8 **continuation** byte (0x80-0xBF) | appended to the current cell, **does not advance `col`** |
| any other byte | painted at (row, col); col += 1 |

**⚑ Stated in the script, because it bounds what this gate can prove:** the
reducer advances **one column per codepoint**, which is the **same unit**
`str-cols` uses. So Phase 15 grades **agreement between `rnd-cols` and the
emitter**, which is the invariant E174 introduces and the one that can silently
rot. It does **not** grade agreement with a real terminal — that is **E177**
(decision 15), and E177's landing must move the reducer and `str-cols`
**together**.

| row | assertion | named mutant that must convict |
|---|---|---|
| **G1 — the red module goes green** | `./bin/chirality check lib/protocol/apc.chiral` exits **0**. Measured **FAILED / `load: non-exhaustive case`** before this element, so the row can fail and did. Companions: `t6_apc_roundtrip.prog` checks **OK**; `render.chiral` still checks OK; `t5_utf8.prog` still fails on `unknown name Unit` (**the control that keeps the row specific** — an unrelated red stays red, so G1 is not reading a tree-wide state). | **M6 `drop-the-enc-arm`** — delete `enc`'s `r-row` arm in a copied `lib/`. `check lib/protocol/apc.chiral` must go back to `load: non-exhaustive case`. |
| **G2 — the codec ROUND-TRIPS all nine, including the three the compiler cannot see** | In the fixture: for each of the nine constructors (and one nested `r-row` inside an `r-face` inside an `r-row`), `str-eq (enc r) (enc (unwrap (dec-frame (enc-frame r))))` is **true**. Equality is asserted on the **encoding**, not via `diff-node` — measured reason: `diff-node`'s `r-stream` arm (`render.chiral:247-250`) returns `diff-changed` even for two identical streams, so it is not an equality oracle. **This row exists because `dec` ends in `(else (p-err …))` (`apc.chiral:249`): a forgotten decode arm is a runtime value, not a compile error.** | **M7 `drop-the-dec-arm`** — change `dec`'s `"R"` tag test to `"Z"`. **Both `protocol/render` and `protocol/apc` still COMPILE** (that is the finding), and G2 must go red at the `r-row` case. A gate that only ran G1 would call this element done. |
| **G3 — the row is a row (the emitter, three segments, one line)** | `render-to-ansi (r-row [ (r-face "diag-head" (r-text "a" false)), (r-text " " false), (r-face "diag-site" (r-text "bb" false)) ]) dims none 3 5 3 5`, through `screen()`, paints exactly: `3 5 a` · `3 6 ' '` · `3 7 b` · `3 8 b`, and **nothing on any other row**. This is E158's `dg-doc` `r-redeclared` shape — the forcing consumer — reduced to four cells. | **M1 `text-off-by-one`** — `rnd-cols`'s `r-text` arm becomes `(+ 1 (str-cols content))`. The segments land at 5, 7, 9. G3 red. |
| **G4 — widths agree with the emitter, per constructor, by EXACT ADJACENCY** | For each of the nine constructors `N`: render `(r-row [N, (r-text "|" false)])` at (1,1) through `screen()`, and assert **(a)** the `\|` is painted at column `1 + rnd-cols(N)` on row 1, and **(b)** **no cell painted by `N`**, on **any** row it touches, is at a column ≥ `1 + rnd-cols(N)`. (b) is the non-circular half: (a) alone is `render-row` agreeing with itself. Together they say the advance is **exactly** the extent — one column too many leaves a gap, one too few overwrites. **⚑ Two scope statements the script makes in as many words:** the `r-table` case is fixtured with headers ≤ 14 columns and cells ≤ 16, so it **does not** grade the measured header/body overrun (**E178**, decision 16 — the script NAMES the element, so the narrowing is traceable to a minted row); and the `r-section` case is the one FLAG A's fix makes satisfiable at all — before it, `render-section` ignored `col` and (b) could not hold for a non-first child. | **M2 `bytes-not-columns`** — `str-cols`'s body becomes `(str-len s)`. **Only the `r-stream` case reddens**, because `" — live stream]"` is 17 bytes / 15 columns — the module's own counterexample, now a convicting test. · **M3 `face-costs-a-column`** — `r-face` arm becomes `(+ 1 (rnd-cols body))`; the `r-face` case reddens, which is what makes "SGR is zero-width, so E175 changes no number" a *checked* claim (decision 3). · **M11 `tree-forgets-its-indent`** — `r-tree` arm drops `rnd-tree-indent`; the `r-tree` case reddens, proving the hoisted constant is wired to **both** readers (decision 9). · **M4 `row-uses-max`** — `rnd-cols-sum` folds `max` instead of `+`; the nested-`r-row` case reddens. |
| **G5 — FLAG A's own row: the fix is a NO-OP where the tree already worked** | `render-to-ansi-full (r-section "Sec" false (r-text "body" false)) (24,80)`, through `screen()`, paints **exactly** `1 1 S` · `1 2 e` · `1 3 c` · `2 3 b` · `2 4 o` · `2 5 d` · `2 6 y` — the **measured** map of today's tree, pinned before the change. (Today's raw stream, captured this session: `ESC[2J ESC[H ESC[1m S e c ESC[0m ESC[2;3H b o d y ESC[0m`; after the fix an `ESC[1;1H` appears before `ESC[1m` and the **map is identical**.) A section rendered first-on-row lands exactly where it lands today. | **M10 `section-forgets-its-goto`** — revert `render-section`'s new `ansi-goto`. **Two-sided, and both sides are asserted:** G5 must stay **GREEN** (that is the no-op proof — a section first-on-row is unaffected), and **G4's `r-section` case must go RED** (a section as a *non-first* child draws at the ambient cursor). A mutant that reddens both would mean the fix was not a no-op; one that reddens neither would mean it was never load-bearing. |
| **G6 — the sum is closed, and no `_` absorbs the new arm** | **Behavioural, not grep.** Append a tenth constructor `(r-fill (body Rendering))` to `Rendering` in a copied `lib/` and change **nothing else**: the compile of **`protocol/render` must FAIL** (`diff-node` and `render-to-ansi`) **and** the compile of **`protocol/apc` must FAIL** (`enc`). Both, separately asserted. If either compiles, a catch-all was added and the closed sum is buying nothing — which is the entire cost argument for this element. | **M5 `tenth-constructor`** is the row (it is run as the assertion, not beside it). Its own failure mode is a stale pattern, so `mutant()`'s existing `cmp -s` guard — *"the mutation did not change the file"* — applies. |
| **G7 — E157's and E158's gates are byte-unchanged, and still run** | (a) `sha256` pins, in `row.sh`, on **four** files: `tools/test/diag.sh`, `tools/test/samples/e157_diag.prog`, `tools/test/doc.sh`, `tools/test/samples/e158_doc.prog`. (b) Phase 13, Phase 14 **and Phase 15 itself** are registered in `run-tests.sh` — **three rows, not two** (⚑ corrected at the SPEC audit: M9 deletes the `run_phase 15` line, so without a Phase-15 row there is nothing for M9 to redden, and `doc.sh`'s precedent is to assert both the gate it pins *and its own*, `:455-458`). Asserted the way `doc.sh` actually asserts them (`:453-458`): `reg() { grep -cE "^run_phase $1 .* $2\$" "$3"; }` run against **`run-tests.sh`, a different file from the script doing the grep** — that, not an assembled pattern, is what makes a registration row unable to match its own source. (⚑ Corrected at the SPEC audit: the assembled-pattern device (`UN='(d-''union'`, `:291`; `PAT="dg""-msg"`, `:400`) is `doc.sh`'s device for the **tree-wide census** rows, which do read `tools/`; it is not used on, and is not what protects, the registration rows.) (c) Both run green, unchanged, in the same `bin/chirality test`: **30** and **26** assertions. | **M8 `move-e158s-gate`** — append one blank line to `tools/test/doc.sh` in a copy; the pin must move and G7(a) go red. · **M9 `unregister-the-phase`** — delete the `run_phase 15` line; the registration row must go red. **Both mutants are RUN**, because an unregistered gate reports ok forever and a pin nobody tested is a pin nobody has. |
| **G8 — name census, tree-wide** | Every name `lib/protocol/render.chiral` introduces is defined **exactly once** across `lib prog tools`. Names are **read out of the file** so a new binding is censused without editing the script, and the search is **`grep -R`, not `grep -r`** — `-r` does not follow symlinks (`MIGRATION-NOTES.md:51-52` records this exact trap). **⚑ This is the one row genuinely at self-match risk, and the device that removes it is `doc.sh`'s, copied exactly (`doc.sh:367-380`, the `census()` helper): the census pattern is `^\((def\|data\|declare) NAME[[:space:]]` — anchored at column 0 — and M12's mutation is written as a `printf … >>` line, so `row.sh`'s own source can never satisfy the anchor.** Censusing `tools/` while spelling a `(def …)` at the start of a line in the script is exactly how a census row becomes unfalsifiable, in either direction. | **M12 `redefine-rnd-cols`** — append a second `(def rnd-cols …)` to `lib/prelude/string.chiral` in a copied `lib/`; the census must report the duplicate. G8 red. |

**Registration:**
`run_phase 15 "horizontal composition (E174 r-row + rnd-cols)"  row.sh` beside
`run-tests.sh:197`, plus the header line at `:13-24` and a row in
`tools/test/MIGRATION-NOTES.md`'s "New here" table (which currently lists 13 and
14). **An unregistered script never runs.**

**Not gate rows, deliberately:** any fixpoint `cmp` (§4 — it does not fire here,
and stability is not correctness) · agreement with a real terminal's wcwidth
(**E177**) · `r-table`'s overrun case (**E178**) · nested-`r-face`
SGR restoration (**E175** — E158's G8 grades that) · a duplicate row asserting
`t5_vt_parser` goes green (measured green, §2, and **Phase 7's own `KNOWN_FAIL`
accounting is what grades it** — a second row here would grade it twice) ·
any `dg-msg` or `doc->str`
byte-identity row (E157 and E158 own those, and G7 is what keeps them out).

## 6. Residue & links

- **Corrections this SPEC applies to the example** (a spec run does not edit the
  example; the fixes are in §2/§3/§5):
  1. **⚑ Phase 7 goes RED on success.** `run-tests.sh:153`'s `KNOWN_FAIL` holds
     `t6_apc_roundtrip.prog`; `:166-167` prints **`NEWPASS`** and increments
     `r_newpass` when a known-failing root starts compiling, and `:176` turns a
     non-zero `r_newpass` into a suite `fail`. The example's gate 1
     ("the red sample goes green") is therefore **incomplete** — it is green only
     if `KNOWN_FAIL` moves in the same commit. **§4 commit 3.**
  2. **⚑ The decode side is not a closed sum.** `apc.chiral:249`'s `dec` ends in
     `(else (p-err …))`, so the three new *decode* branches are **invisible to
     the compiler**. The example sketches them as "the matching decode cases"
     without noting that nothing enforces them. **§5 G2 + M7.**
  3. **`diff-node` is not an equality oracle.** Its `r-stream` arm
     (`render.chiral:247-250`) returns `diff-changed` for two identical streams.
     The example's gate 3 leans on "the emitted byte stream"; a run-time equality
     row must compare **encodings** (`str-eq (enc a) (enc b)`), not diffs.
     **§5 G2.**
  4. **The example's gate 4 needed a non-circular form.** "The column the emitter
     leaves the cursor at equals `rnd-cols`" is circular for a probe placed *by*
     `render-row`. **§5 G4** splits it into probe-position **and** no-cell-at-or-
     beyond, which is the half that can fail.
  5. **The U+2014 nuance.** The example calls `" — live stream]"` *"17 bytes, 15
     columns"* and treats it as settling the unit. Verified 17 bytes with
     `od -c`; **15 columns is right for narrow-ambiguous rendering**, and U+2014
     is East-Asian **Ambiguous** — the one class where `wcwidth`
     implementations legitimately disagree. It proves byte-count is wrong; it
     does not settle the width table — which is why the table is **E177**, and
     why E177's row makes the *ambiguous class*, not the table, the decision.
  6. **Open question 3 (multi-row child) is not parked** — it collapses to option
     (i) plus a sentence, which the example's own §5 code already does.
     **RESOLVED, decision 5.** **Open question 4 (`r-stream` reserves nothing)
     was never open** — the emitter draws a fixed placeholder, so the width is
     derived. **RESOLVED as a visible definition, decision 6.** **Open question 6
     (single `I64`) is decided by the module** — nothing reflows, `rd-in-view`
     clips by row and never by column. **RESOLVED, decision 7.**
  7. **The gate needs a helper that does not exist.** `doc.sh`'s `build_run`
     discards stdout. **§5 specifies `screen()`**, and its availability was
     verified by compiling and running a probe.
  - **Verified correct, against the brief's "verify, don't trust":** the tree
    **is** already red at `lib/protocol/apc.chiral` with `load: non-exhaustive
    case`, and `render.chiral` **is** green · **17** import, **13** name a
    constructor, **5** case, **exactly 1** with an exhaustive case that breaks,
    twice (`:223`, `:424`, 8 arms each) · all three `.prog` matchers go through
    `(_ …)` · `t5_vt_parser` is red via `vt-parser.chiral:4` and `t5_utf8` is red
    for an unrelated reason — it carries **no imports at all** (`unknown name
    Unit`; `Unit` lives at `lib/prelude/prelude.chiral:17`) · **no width function exists
    anywhere** in `lib/` or `prog/`; `utf8` is a decoder only · `" — live
    stream]"` is **17 bytes / 15 codepoints** (`od -c`) · `render-section`
    really emits **no** `ansi-goto` (measured by running it) · `rnd-hdr-cols`
    folding **n−1** gutters is what the emitter's own `nil` case produces ·
    all seventeen new names are census-free · `protocol/utf8` is acyclic and
    collision-free · `protocol/render` is **outside the compiler's blob**, so
    no fixpoint fires · the suite is **168 assertions, 0 failed, exit 0** today.

- **⚑ Re-measured at the SPEC audit gate (2026-08-31, `/workspace/chirality-verify`
  @ `e158-doc`) — the rows that were RUN, not read:**
  1. **G1's red→green is real.** A scratch copy of `lib/` with only `enc`'s two
     missing arms (`r-lines`, `r-face`) added takes
     `lib/protocol/apc.chiral` from `load: non-exhaustive case` to **OK**.
     `t6_apc_roundtrip.prog` then compiles and runs to **exit 42** (all nine of
     its own sub-tests pass), and `t5_vt_parser.prog` to **exit 42** as well.
  2. **M5 `tenth-constructor` convicts, behaviourally, on BOTH modules.**
     Appending `(r-fill (body Rendering))` to `Rendering` in a copied `lib/` and
     changing nothing else: `protocol/render` → `load: non-exhaustive case`,
     `protocol/apc` → `load: non-exhaustive case`. G6 is not a grep.
  3. **M7 `drop-the-dec-arm` convicts, and the finding under it is real.** On the
     green scratch tree, changing `dec`'s `"r"` tag test to `"Z"` leaves **both**
     `protocol/render` and `protocol/apc` compiling **clean** — and drops
     `t6_apc_roundtrip` from exit 42 to **exit 254** (`-2`, its `r-tree`
     round-trip case). The decode side really is invisible to the compiler, and
     the round-trip really is what sees it.
  4. **G5's golden byte map re-derived, byte for byte.** A probe compiled with
     `bin/chirality-bin` and run: `render-to-ansi-full (r-section "Sec" false
     (r-text "body" false)) (pair 24 80)` emits exactly
     `ESC[2J ESC[H ESC[1m S e c ESC[0m ESC[2;3H b o d y ESC[0m` — no `ansi-goto`
     before the title. Cell map `1 1 S · 1 2 e · 1 3 c · 2 3 b · 2 4 o · 2 5 d ·
     2 6 y`, as §5 G5 pins it.
  5. **The `screen()` reducer's probe re-derived.**
     `render-to-ansi (r-text "ab" false) (pair 24 80) none 3 5 3 5` emits exactly
     `ESC[3;5H a b ESC[0m`. `doc.sh`'s `build_run` (`:63-73`) does discard
     stdout, so the helper really is the one piece that does not already exist.
  6. **Baseline re-run, whole suite:** `168 passed, 0 failed`, `gate PASSED`,
     exit 0; Phase 7 `35 compiled, 0 failed, 3 known/negative, 0 newly passing`;
     Phase 13 `30 passed, 0 failed`; Phase 14 `26 passed, 0 failed` — so E157's
     and E158's sha256 pins are green and their gates are byte-unchanged.
  7. **Counts re-run:** 17 importers · 13 constructor-naming files · 5 files
     `case` over the sum · exactly 1 with an exhaustive case that breaks
     (`render.chiral`, twice, 8 arms each at `:223` and `:424`) · all 17 new
     names have **zero** defining occurrences (16 have zero of any kind; `r-row`
     has 16 substring hits, none a binding) · `" — live stream]"` is 17 bytes /
     15 codepoints · `lib/prelude` 9-of-9 and `lib/protocol` 0-of-8 on
     `(module …)` · `CONFORMANCE-MAP.md` has 0 hits for E157/E158/E174/E175/E176.

- **Deliberately unbuilt (each named, none parked on a phantom):**
  - **A wide-cell (wcwidth) width table** — **E177**
    (`SELF-IMPLEMENT-CATALOG.md:441`, `LEDGER.md:296`), minted `da3e7b3`, with
    E174 as its first consumer; `utf8.chiral:15` anticipates it by name.
  - **`r-table`'s per-column widths / the header-gutter deletion** — **E178**
    (`SELF-IMPLEMENT-CATALOG.md:442`, `LEDGER.md:297`), minted `da3e7b3`,
    non-blocking; `rnd-cols`'s `r-table` arm is *defined* against the grid and
    says so, and the narrowed gate names E178.
  - **Nested-`r-face` SGR restoration** — **E175**
    (`SELF-IMPLEMENT-CATALOG.md:439`, `LEDGER.md:294`), minted. Orthogonal:
    `rnd-cols` is provably invariant under it, and §5's M3 checks that.
  - **`str-sub`'s clamp / refinement** — **E176** (`:440`, `LEDGER.md:295`),
    minted. E174 adds **no** `str-sub` call site.
  - **`doc->rendering`** — **E158 commit 4**
    (`.planning/specs/E158-doc-formatter-SPEC.md` §4), which depends on this
    element **and** on E175. E174 ships the target type; it does not ship the
    producer.
  - **An APC envelope version field** — three new tag letters land on a grammar
    with none. A newer frame is a `p-err "bad tag …"` **value** to an older
    decoder, which is the codec's own design (`apc.chiral:249`). Recorded, not
    deferred: there is no row and this SPEC does not mint one.
  - **Moving `str-cols` to `prelude/string`** — a one-line move the day a second
    consumer appears (decision 11). Not an element.
  - **`r-hole`'s dead `(put "")`** (`:468`) — real, inert, not this element.

- **Follow-on consumers, in order:** **E158 commit 4** (`doc->rendering`) is the
  forcing consumer and is gated on E174 **and** E175. Behind it,
  **U16 "the block algebra"** — `.planning/USER-LAYER-TRACKER.md:92`, status
  `blocked`, dependency `E158` — is the user layer's waiting consumer.

- **Tooling state, stated plainly:** `tools/pack/pack.py` **cannot run this
  element's pipeline** (it probes `examples/`, this tree has `docs/examples/`,
  and `tools/pack/MIGRATION-NOTES.md` records it as not repointed on purpose).
  So the deterministic status flip did not happen either: the
  `docs/examples/INDEX.md` row for E174 is flipped `reviewed → specced` **by
  hand** in the same commit as this file, with the SPEC link appended, matching
  E157's and E158's row shape. Nothing was repointed at a guess.

- **Related:** [[E158-doc-formatter]] (the forcing consumer; its commit 4
  consumes `r-row`) · [[E157-typed-diagnostics]] (the `Reason` sum `dg-doc`
  renders) · [[E112-apc-sidechannel]] (the codec that must learn the three arms)
  · [[pattern-boundary-sums]] (why SGR-in-`r-text`'s `Str` is refused) ·
  [[E161-kind-identifier]] (the `(module …)` coordinate, declined here by the
  directory's convention). Elements: **E158** · **E175** · **E176** · **E112** ·
  **E157** · **E161** · **E154** (the flat emitted-label namespace G8 censuses).
