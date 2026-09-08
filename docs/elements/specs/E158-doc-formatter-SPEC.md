---
element: E158
slug: doc-formatter
title: **`Doc` — structured formatting; printf's template split from its flatten**
kind: BUILD-PROPER
example: docs/examples/E158-doc-formatter.md
status: audited
updated: 2026-08-31
---

# E158 SPEC — **`Doc` — structured formatting; printf's template split from its flatten**

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

> **⚑ The pack did not run.** `tools/pack/pack.py E158 --spec` prints the ledger
> row and then stops: `no drafted example examples/E158-*.md — run the
> worked-example pre-run first`. It probes `examples/`, this tree's corpus is
> `docs/examples/`, and `tools/pack/MIGRATION-NOTES.md` records the tool as **not
> repointed** on purpose (its Python-oracle baseline half has no source here at
> all). Per the brief, this SPEC was written **by hand** against the tree; nothing
> was repointed at a guess. Every citation below was read live on
> **2026-08-31** in `/workspace/chirality-verify` @ `e158-doc`.

## 1. Deliverable

- **After this runs:** `lib/prelude/doc.chiral` exists and owns a closed
  **six-constructor** `Doc` with **no `d-union`**, a three-arm `Brk`, and a
  **strict Lindig worklist** renderer (`doc-fits` / `doc-best` / `dc-line`)
  behind one exit, `doc->str : (-> I64 Doc Str)`. `lib/typing/diag.chiral` gains
  `dg-doc : (-> Reason Doc)` — the **sibling** of `dg-msg`, over all **nine**
  `Reason` arms (`diag.chiral:120-138`, counted live: `r-redeclared`,
  `r-mismatch`, `r-usage`, `r-linear`, `r-arrow`, `r-unbound`, `r-skipped`,
  `r-judged`, `r-relayed`). `tools/test/doc.sh` runs as **Phase 14** of
  `tools/test/run-tests.sh` and grades the element on **evidence survival**, not
  on text. `lib/protocol/render-doc.chiral` ships `doc->rendering` **correct for
  nested tags** — *gated on **E174** (§3, NEEDS-AUTHOR-1 as answered), a measured
  obstruction in `Rendering`, not a scoping doubt — and see **NEEDS-AUTHOR-2**
  (§3), open, on whether "correct for nested tags" needs a second element.*

- **Non-goals** (each with where it actually lives):
  - **`doc->json`** — named as an exit, consumed by nothing. Building an
    unconsumed exit is the "built but unadopted" trap this repo has logged four
    times. One `case` over six constructors when a consumer appears.
  - **`typing/pretty.chiral`** — see decision 12. It is a **rewrite**, not a
    signature change, and it must not ride this gate.
  - **`prog/manas/core/assemble.chiral`** (`:48-57`, the ten-deep `str-cat`) — the
    loudest instance and the least load-bearing consumer. A follow-on commit in
    `prog/`, after `Doc` is proven on `Reason`.
  - **E146's five emitters** returning `Doc` — accepted and **already enacted on
    E146's own row** (`docs/elements/catalog.md:411`). E158 owns the
    *law* (§5 G2); E146 owns the consequence. Not re-specified here.
  - **E182** — the `Judg` arity residue. Minted
    (`SELF-IMPLEMENT-CATALOG.md:437`, `LEDGER.md:292`). Not E158's work and does
    not gate it. Adding `Doc` shrinks `Judg` by **zero** arms.
  - **`d-align` / `d-fill` / `d-column`** (Leijen). Nothing needs them; each is
    additive later.
  - **A totality *certificate*** — decision 5. The measure is real; the gate
    cannot see it. That is E50.
  - **A dependently-typed printf** — orthogonal (argument side vs result side),
    and it needs its own catalog row minted before any work is parked on it.

## 2. Baseline (what already exists — do NOT respec these)

- **Conformance-map verdict: none.** `records/conformance-map.md` has no
  row for E157, E158 or E146 — all three postdate the map snapshot. Treat as
  **BUILD**, with the live-code measurements below standing in as the build-state
  authority (the same disposition E157's SPEC took, §2).

- **Ledger / catalog state:** `LEDGER.md:283` — `E158 | doc | design | … | ←E157`.
  `SELF-IMPLEMENT-CATALOG.md:420` — `Not built.` The dependency `←E157` is
  **satisfied**: `LEDGER.md:282` reads `E157 | diagnostics | **built**`.

- **Live code this composes with (already built — compose, do not rebuild):**
  - **`lib/typing/diag.chiral`, 469 L.** `Reason` = 9 arms carrying real
    evidence. `dg-msg : (-> Reason Str)` declared `:302`, defined `:315`.
    ⚑ **`dg-qty-name : (-> Qty Str)` ALREADY EXISTS** — declared `:284`, defined
    `:285` as `(case q ((q0) "0") ((q1) "1") ((qw) "omega"))`, with **14 live
    call sites** in `diag.chiral` and `tools/test/samples/e157_diag.prog`. See
    decision 9: the example lists it as an *addition*; adding it is a duplicate
    label in one file.
  - **`dg-subject-tag`** (`:173`), **`dg-subject-name`** (`:156`),
    **`dg-usage-msg`** (`:349`), **`dg-declared`** (`:256`), **`dg-observed`**
    (`:270`) — the accessors `dg-doc` reuses. `dg-usage-msg` answers **nine of
    twelve** subjects with `"binder usage mismatch"` and drops both quantities in
    **all twelve** (`:349-363`; the twelve arms are `:352-363`). That is the
    measured hole G3 fills. ⚑ *Corrected at the spec audit: `:373-390` is inside
    `dg-linear-msg` (`:368-`), a different function.*
  - **`Judg` = 38 nullary arms** (`diag.chiral:97-110`, counted: 38 distinct
    `(jg-…)` tokens). E182's territory, stated here only so §5 does not try to
    fix it.
  - **`lib/protocol/render.chiral`.** `Rendering` = 8 constructors when this was
    measured and nine today, E174 having added `r-row` (`:7-32`),
    `r-face (face Str) (body Rendering)` at `:15`, `r-lines` at `:13`,
    `lookup-face` declared `:57`. **`(data Mode ()` at `:42`** — decision 4's
    citation, verified; re-read 2026-09-04.
  - **`lib/prelude/string.chiral`** — `str-join` `:215`, **`str-pad` `:209`**
    (decision 11: this is `nl-indent`'s spaces; no new primitive).
    **`lib/prelude/list.chiral`** — `reverse` `:33`, signature
    `(-> (0 A (type 0)) (List A) (List A))`, so the call is `(reverse Str xs)`
    with the **erased** first argument written.
  - **`lib/prelude/prelude.chiral`** — `str-len` `:78`, `str-eq` `:79`,
    `str-cat` `:86`, `i64->str` `:87`.
  - **`tools/test/run-tests.sh`.** `run_phase()` at `:112`; registered phases
    3,4,5,6 at `:131-134` and **13 at `:187`** (`diag.sh`, E157). Its header
    (`:8-9`) states that 8–12 are names still owed, which is why E157 took 13.
  - **`tools/test/diag.sh`, 309 L** + `tools/test/samples/e157_diag.prog`, 126 L
    — the shape `doc.sh` mirrors: G-groups, named mutants, `ok`/`bad` counters,
    `build_run`, `refuse_msg`, and a `grep -R` name census (G6, `:282`).

- **The defect, measured (not paraphrased):**
  - `prog/manas/core/assemble.chiral` — `def assemble-prompt` at **`:48`**, the
    ten-deep `str-cat` nest at **`:52-57`**, closing `))))))))))`.
    ⚑ *Correction:* the example says `:47-57`; the catalog row (`catalog.md:470`) says
    `:51-56`. Measured, the def opens at 48 and the nest runs 52-57.
  - `lib/typing/pretty.chiral` — **51 lines**, hardcodes `sp`/`parens` (`:22-23`),
    goes straight to `Str`, and is imported by **zero** modules
    (`grep -Rn 'import "typing/pretty"' lib prog` → 0).

## 3. Decisions

Rows 1-8 are **SETTLED** upstream and are carried, not reopened; each is shown
with the citation that was re-verified for this SPEC. Rows 9-15 are new to the
spec run. NEEDS-AUTHOR-1 was the one thing that run could not resolve; the
author answered it by minting **E174** (`d16113e`) — see the block below.
**NEEDS-AUTHOR-2**, raised at the spec audit, is open.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Wadler's algebra with or without `<|>`? | **SETTLED (carried) — `d-group`, deliberately NO `d-union`** | `<|>`'s side condition (both branches flatten to the same text; the left's first line no shorter) is **not statable in the type**, so every hand-built union is a latent bug. `d-group` *is* `union (flatten body) body`, so the only union anyone can write is the correct one. Six `Doc` constructors + a three-arm `Brk` aux sum. Invariant pushed into the substrate, not documented beside it. |
| 2 | Wadler's lazy `best`, or Lindig's worklist? | **SETTLED (carried) — Lindig, *Strictly Pretty* (2000)** | Chirality is **strict**. The lazy `best`/`fits` stream has no meaning here. Lindig's explicit `(List Frame)` of `(indent, mode, doc)` is directly writable and is the form whose measure is legible. |
| 3 | Does `Doc` unify with `Rendering`? | **SETTLED (carried) — NO. Three homes** | `Rendering` is a **screen tree**: four of its eight constructors carry interaction state (`r-section` collapsed, `r-stream` source-id, `r-tree` selected, `r-hole`), its consumers are `=>` process functions, and it has a `Diff` for delta redraw. `Doc` has none of that and must not acquire it — width is an *argument to the exit*, not a field of the value. Homes: `lib/prelude/doc.chiral` (new) · `dg-doc` **added to** `lib/typing/diag.chiral` · `lib/protocol/render-doc.chiral` (new). `protocol` is universal, `typing` is lang-impl-only (`LAYOUT.md` §Tiers), so the display exit cannot live in `typing/`. |
| 4 | `Mode` or `DMode`? | **SETTLED (carried) — `DMode`; citation verified** | `(data Mode ()` is at **`lib/protocol/render.chiral:24`**, measured. `protocol/render-doc.chiral` imports both `prelude/doc` and `protocol/render`, so the two **co-blob**, and names are flat in a blob — "two defs of one name is `duplicate label`" (`lib/module/resolve.chiral:57-61`, which renamed `read-fd-all` for exactly this). Rename taken here rather than discovered there. |
| 5 | Is the totality argument a certificate? | **SETTLED (carried) — PROSE, not gate; verified against the checker** | `typing/totality.chiral` is E11, the **single-function** classifier: its refusal text names exactly what it can see — *"structural (a case-bound field) or numeric (a parameter stepped toward a constant bound a guard proves)"* (`totality.chiral:387`) — and its own header (`:12-13`) scopes mutual recursion out to **E50**, whose catalog row (`:127`) reads **`not built; totality gap`**. `doc-fits`↔`doc-fits-frame` and `doc-best`↔`dc-line` are two mutually-recursive pairs over a worklist that **grows** at `d-cat`. The measure (total `Doc`-node count across the worklist, strictly decreasing because every pop pushes only strict subterms) is real and is written in the source header. **The SPEC must not claim the gate certifies it, and §5 does not test it.** E158 is a natural first client for E50, not evidence E50 is covered. |
| 6 | Test policy for `doc->str` vs `dg-msg`? | **SETTLED (carried) — no byte-identity inheritance; verified against what `diag.sh` really asserts** | `diag.sh`'s own header (`:10-16`) refuses to call byte-identity its gate, but byte-identity **is** pinned there: G3's nine goldens compare compiler stderr with `[ "$got" = "$2" ]` (`:128-176`) and mutant **M4** (`reword-the-let-message`, one byte) must convict. That constraint is E157's, it is live, and it is what made a per-message `Judg` the cheap way out at 38 arms. **`doc->str` must not inherit it.** `dg-msg` keeps its goldens **unchanged and untouched**; `dg-doc` is graded by evidence survival only. Cross-asserting the two re-imports the exact constraint `Doc` exists to lift — so §5 **G7 makes the non-cross-assertion a checked row**, not a promise. |
| 7 | E146's signature change — specified here? | **SETTLED (carried) — NO. Enacted on E146's row; E158 owns only the LAW** | Verified: `SELF-IMPLEMENT-CATALOG.md:411` now opens `⚑ SIGNATURE AMENDED 2026-08-31 by the E158 example audit (FLAG A, author-accepted): the five emitters return `Doc`, not `Str`.` E158's obligation is **§5 G2, width independence** — identical token sequence at every width — and nothing else. `config->source w = doc->str w . config->doc` stays as E146's thin wrapper. |
| 8 | The `Judg` arity residue? | **SETTLED (carried) — E182, minted; does not gate E158** | Verified live: `SELF-IMPLEMENT-CATALOG.md:437` and `LEDGER.md:292` both carry `E182 — The arity judgments carry their arity`. Orthogonal to E158's cause (adding `Doc` shrinks `Judg` by zero arms) and a lever on its cure. **The hazard is real and §5 answers it:** per-message layout is cheap under `Doc`, which makes a 39th nullary arm feel free. It is not. Grading by evidence survival is the guard, because a nullary arm has no evidence to survive. |
| 9 | Does `diag.chiral` need a new `dg-qty-name`? | **RESOLVED — NO, by measurement. Reuse the existing one** | ⚑ **This corrects the example.** Its §6 "Lands in" table lists `dg-qty-name` among the additions to `diag.chiral`. It **already exists there**: declared `:284`, defined `:285`, exactly `(-> Qty Str)`, with **12 call sites in `diag.chiral`** (all in `dg-linear-msg`) plus **5 in `tools/test/samples/e157_diag.prog`**. Adding it is a `duplicate label` **in a single file**. ⚑ *Corrected at the spec audit: the earlier "14" was `grep -c` on `diag.chiral`, which counts the `declare` (`:284`) and the `def` (`:285`) as call sites.* `dg-doc` and `dg-decl-doc` are the only new names in that file. |
| 10 | Name census for every new binding (flat namespace) | **RESOLVED — census run tree-wide with `grep -R`; two renames, one confirmed-free set** | Censused across `lib` + `prog`, all four kinds: `Doc`, `Brk`, `DMode`, `Frame`, `d-text`, `d-cat`, `d-line`, `d-nest`, `d-group`, `d-tag`, `brk-soft`, `brk-space`, `brk-hard`, `m-flat`, `m-brk`, `doc-best`, `dc-line`, `nl-indent`, `doc->str`, `doc->rendering`, `doc-concat`, `doc-punctuate`, `doc-words`, `dg-doc`, `dg-decl-doc` → **all zero**. Two changes from the example's names: **(a) `fits` → `doc-fits` / `doc-fits-frame`.** No `def fits` exists, but `const-fits?` (`lib/lowering/tal/check.chiral:180`) occupies the concept **in the same blob** — `typing/diag` importing `prelude/doc` puts `prelude/doc` into the compiler blob alongside `lowering/tal/check`. A bare `fits` in a tree-flat namespace is the cheapest possible future collision. **(b) the `Frame` constructor `fr` → `dfr`.** `lib/lowering/compile-front.chiral:292` declares `(data FR () (fr-ok …) (fr-err …))`, co-blobbed with `prelude/doc` for the same reason. `fr` is free, but one keystroke from two live constructors in the same blob, and the `DMode` precedent (row 4) already establishes the `D`-prefix for a doc-local name that would otherwise be generic. The type name `Frame` stays — censused free. |
| 11 | `nl-indent`'s spaces — new primitive? | **RESOLVED — NO. `str-pad`** | `lib/prelude/string.chiral:209`, `(-> Str I64 Str Str)`, returns `s` unchanged when `width <= (str-len s)`. So `nl-indent i = (str-cat "\n" (str-pad "" i " "))`, correct at `i = 0`. `prelude/doc` imports `prelude/string` for this and for `str-join`. |
| 12 | What happens to `typing/pretty.chiral`? | **RESOLVED — OUT of E158, and it must not ride this gate. Verified, as the brief required** | Measured: `pretty.chiral` is **51 lines**, renders **5 of 16** formers (`t-type`/`t-var`/`t-lam`/`t-app`/`t-let`, `:44-51`), and **declares its own local 5-constructor `Term`** at `:15-20`. `lib/surface/syntax.chiral:18`'s `Term` has **16** constructors, its `t-lam` carries **no name** (de Bruijn: `(t-lam (body Term))`) and its `t-let` carries a `Qty`. So `Term -> Doc` is not a signature change: the module must first be **repointed at the real `Term`** and grown eleven arms, and only `names-snoc`/`nth-name`/`get-at` survive. It is imported by **zero** modules, so nothing regresses by leaving it. **Confirmed: a rewrite, a separate commit at minimum, and out of E158's gate.** |
| 13 | Does `prelude/doc` drag new modules into the compiler blob? | **RESOLVED — no; only `prelude/doc` itself is new** | `prelude/doc` imports `prelude/prelude`, `prelude/list`, `prelude/string`. Both are already in the compiler's own import closure: `prelude/list` via `lib/module/loader.chiral` and `lib/typing/row-infer.chiral`; `prelude/string` via `lib/typing/row-infer.chiral`, `lib/typing/ty-cmp.chiral`, `lib/lowering/compile-back.chiral`. **Consequence for the BUILD RULE:** commit 1 (the algebra, imported by nobody) changes no blob at all; **commit 2** is the one that changes the compiler's own sources and therefore carries the self-host obligation (§4). |
| 14 | `(module …)` datasheet coordinate on the new files? | **RESOLVED by local convention, measured** | 12 of `lib/`'s 92 `.chiral` files carry one (`prog/`'s 63 carry none); by directory: `prelude` **8 of 8**, `typing` 1, `lowering/c` 2, `ports` 1, **`protocol` 0 of 8**. So `lib/prelude/doc.chiral` gets `(module prelude/doc (cat A) (alt upper))` — matching all eight siblings — and `lib/protocol/render-doc.chiral` gets **none**, matching all eight of its. Neither choice is invention; both follow the directory. |
| 15 | Which phase number for the gate? | **RESOLVED — 14** | `run-tests.sh:8-9` and `tools/test/MIGRATION-NOTES.md` both state that 8-12 are **names still owed** to unported old-tree phases, and that reusing one would make an unported gate look ported. E157 took 13 for that reason. E158 takes 14. And the registration is a **required line**, not a courtesy: an unregistered `doc.sh` is a gate that never runs. |

### NEEDS-AUTHOR-1 — `Rendering` cannot express a multi-segment line — **ANSWERED: E174, minted `d16113e`**

> **⚑ Status at the spec audit (2026-08-31): RESOLVED — this is no longer a
> question, and no longer a blocked commit behind one.** The finding below was
> confirmed live at the audit, line by line. Its *disposition* changed after this
> SPEC was written: commit `d16113e` mints **E174 — `Rendering` gains horizontal
> composition (`r-row`) + the per-node width function it needs**
> (`docs/elements/catalog.md:438`, `docs/elements/ledger.md:293`), taking
> **option (A) by elimination, not preference**: (B) is refused on the standing
> boundary-sums directive (a `Str` carrying which-of-N presentation structure is
> the precise flattening defect E157/E158 exist to remove), and (C) was already
> measured dead on E158's own first consumer. **Commit 4 now depends on a MINTED
> element** (`←E158, →E158c4`) rather than sitting behind an open question, which
> is what the repo's no-defer-without-a-cataloged-dep rule requires. The
> measurement and the three costed options are kept verbatim below as E174's
> rationale of record.
>
> FLAG C is carried as binding: **`doc->rendering` ships correct for nested tags
> or it does not land**, scoped IN, not deferred. The mechanism the decision
> names — a face-name stack threaded through the render walk, popped at each
> `d-tag` close — is correct and cheap for computing *which faces are active at
> each emitted segment*. The obstruction is one layer down, in the **target type**.
>
> **`Rendering` has no horizontal composition constructor.** Measured in
> `lib/protocol/render.chiral`:
> - `r-lines` places each child on **its own row** at the **same column**
>   (`render-lines`, `:405-415`: `(render-to-ansi child … row col …)` then
>   `(+ row 1)`).
> - `r-face` renders its body at the **same** `row`/`col` and emits no
>   `ansi-goto` of its own (`:469-475`) — it is a wrapper, not a placer.
> - `r-text` draws at `(ansi-goto row col)` and stops (`:435-441`).
> - The **only** horizontal composition in the whole module is `r-table`, and it
>   is a **fixed 16-column grid**: `rnd-emit-one-row` (`:362-368`) advances
>   `(+ col 16)` per cell. It is not a flow and cannot carry a wrapped line.
>
> So a rendered `Doc` line that mixes a tagged span with anything else — e.g.
> `dg-doc`'s own `r-redeclared` arm, whose `d-tag "diag-head"` head sits on the
> **same output line** as the following material whenever the group fits — has
> **no representation in `Rendering` at all**. This is not "naively wrong"; it is
> unrepresentable, which is why the stack alone does not close it. E158's *first
> consumer* hits it at wide widths, so it cannot be dodged by scoping.
>
> Three options, with their real costs. **All three touch a decision that is
> currently settled, which is why none of them is mine to take:**
>
> - **(A) Extend `Rendering` with a horizontal run** — one constructor, e.g.
>   `(r-row (children (List Rendering)))`, plus one arm in `render-to-ansi`
>   advancing `col` by each child's rendered width, one arm in `diff-node`, and
>   an arm in every exhaustive `case` on `Rendering` tree-wide — **12 files case
>   over the sum** (E174's measured figure; 17 import `protocol/render`). **Cost:** contradicts the example's stated
>   "`Rendering` is not extended" (§6) — though *not* decision 3, which only
>   forbids **unifying** `Doc` with `Rendering`. This is the option that leaves
>   both types honest, and it is a real gap in `Rendering` independent of E158.
> - **(B) Bake the SGR into `r-text` content** — `doc->rendering` emits
>   `r-lines` of `r-text` whose `content` already carries
>   `face-sgr (lookup-face …)` prefixes and resets. **Zero** new constructors,
>   correct on screen, and `diff-node`'s `r-text` string compare still gives
>   correct delta redraw. **Cost:** puts presentation bytes inside a
>   medium-independent value and bypasses `r-face` entirely — so `d-tag` would
>   **not** become `r-face`, contradicting the ledger row (`LEDGER.md:283`) and
>   the example. It also makes `Rendering` no longer safe to re-render to a
>   non-ANSI medium.
> - **(C) Restrict the contract** — `doc->rendering` accepts only `Doc`s whose
>   tags are line-aligned, and **refuses** (a result sum, not a silent wrong
>   answer) otherwise. **Cost:** measured to fail on E158's own first consumer,
>   as above, so it would ship an exit that `dg-doc` cannot use. Recorded for
>   completeness; not recommended.
>
> **Commit 4 lands after E174, not before** — which is exactly what FLAG C
> requires, now with a cataloged dependency instead of a shelf. Commits 1-3 and
> the whole Phase 14 gate are independent of it and land regardless.
>
> *(Written as `NEEDS-AUTHOR-1` because a spec run cannot mint an element row.
> The author minted E174 in `d16113e`; the row is real and this block is now a
> pointer to it.)*

### NEEDS-AUTHOR-2 — nested `r-face` does not restore the outer face, and E174 does not cover it

> **Raised verbatim at the spec audit (2026-08-31). Not resolved here — the fix
> is a choice, not a derivation.** This is a *second*, independent obstruction
> under the same deliverable, found while confirming NEEDS-AUTHOR-1.
>
> §1 promises `doc->rendering` **correct for nested tags**. E174 buys horizontal
> composition — `r-row` plus a per-node width function. It does not touch the
> other half of "nested".
>
> **Measured, `lib/protocol/render.chiral`:** the `r-face` arm (`:469-476`) emits
> `(face-sgr (lookup-face default-faces face-name))`, renders its body, then
> emits `ansi-reset` — and `ansi-reset` is `(str-cat ansi-esc "[0m")` (`:282`), a
> **full** SGR reset, not a restore of the enclosing face. So for
> `r-face(outer, … r-face(inner, …) … rest …)` the inner tag's close clears the
> outer tag's attributes and `rest` renders **unfaced**. That is exactly the
> shape a nested `d-tag` maps to under the `d-tag`→`r-face` rule
> (`LEDGER.md:283`), so E158's own nested-tag case is wrong on screen even after
> `r-row` exists — and **G8** ("a two-level nested `d-tag` produces correctly
> nested faces") is the row that would catch it.
>
> Three dispositions, none of them mine to take:
>
> - **(i) Widen E174** to include face-state restore in `render-to-ansi` — carry
>   the enclosing face down the walk and re-emit its SGR at each inner close
>   instead of `ansi-reset`. Keeps `d-tag`→`r-face` intact. Cost: E174's row is
>   already written and scoped to composition; widening it changes what was
>   minted.
> - **(ii) Mint a separate row** for the face-stack fix, with E158 commit 4
>   depending on both it and E174.
> - **(iii) Narrow §1** — `doc->rendering` correct for *non-nested* tags, said in
>   as many words, with G8 struck. This contradicts FLAG C as carried, so it is
>   a reversal, not a scoping note.
>
> **Nothing in commits 1-3 or the Phase 14 gate depends on this.** Commit 4 is
> already dependency-gated on E174; this says the dependency may be two elements,
> not one.

## 4. Change plan (ordered, commit-sized)

**Standing rules for every commit below.** `bin/chirality-bin` (the committed
compiler) compiles everything; **Python compiles nothing**. The flow is
**build-new → test → promote**; nothing replaces itself in place. Module keys are
**root-relative** (`(import "typing/diag")`, never `(import "diag")`); the
extension is the kind per `LAYOUT.md`; **there is no `formatting/` directory** —
subject matter is neither the extension nor the role.

### Commit 1 — `lib/prelude/doc.chiral`: the algebra and `doc->str`, imported by nobody
- **Target:** `lib/prelude/doc.chiral` (**NEW**)
- **Header:** `(import "prelude/prelude")` · `(import "prelude/list")` ·
  `(import "prelude/string")` · `(module prelude/doc (cat A) (alt upper))`
  (decision 14). Pure `->` throughout — a formatter that provably crosses no
  port. The file header carries the **totality argument as prose** and says in
  as many words that the gate does not certify it (decision 5).
- **Change:**
  - `(data Brk () (brk-soft) (brk-space) (brk-hard))` — which-of-three is a sum,
    never a `Str` tag or an `I64` flag (`pattern-boundary-sums`).
  - `(data Doc () (d-text (s Str)) (d-cat (l Doc) (r Doc)) (d-line (b Brk))
    (d-nest (i I64) (body Doc)) (d-group (body Doc)) (d-tag (name Str) (body Doc)))`
    — **six**, and the absent seventh is the element. `d-text` is **atomic**;
    `d-tag`'s `Str` is a face-registry key over the open set `lookup-face`
    already indexes (`render.chiral:39`), not a which-of-N, so it is correctly
    not a sum.
  - `(data DMode () (m-flat) (m-brk))` (decision 4) ·
    `(data Frame () (dfr (indent I64) (mode DMode) (doc Doc)))` (decision 10b).
  - `doc-fits : (-> I64 (List Frame) Bool)` + `doc-fits-frame` (decision 10a).
    **`doc-fits` returns `false` on a `brk-hard` frame.** ⚑ *Added at the spec
    audit: this is the invariant that makes the `(m-flat, brk-hard)` arm below
    "unreachable in practice" — without it `d-group` can choose `m-flat` over a
    body containing a hard break and the arm IS reached. The claim needed its
    cause stated, and there is only one thing that can supply it.*
  - `doc-best : (-> I64 I64 (List Frame) (List Str) (List Str))` — the one
    decision point is the `d-group` arm; `dc-line : (-> I64 I64 I64 DMode Brk
    (List Frame) (List Str) (List Str))`. The `(m-flat, brk-hard)` arm is
    unreachable in practice and is **written anyway, and it breaks** — a total
    function does not halt on "can't happen".
  - `nl-indent : (-> I64 Str)` over `str-pad` (decision 11).
  - `doc->str : (-> I64 Doc Str)` = `str-join ""` over `(reverse Str …)` — the
    erased type argument written out (`list.chiral:33`).
  - The anti-`str-cat` helpers callers actually reach for: `doc-concat`,
    `doc-punctuate`, `doc-words`.
- **Verify:** compile the module through a throwaway root with
  `bin/chirality-bin`. **No blob changes** — nothing imports it yet (decision
  13), so there is no self-host obligation on this commit.

### Commit 2 — `lib/typing/diag.chiral`: `dg-doc`, the sibling
- **Target:** `lib/typing/diag.chiral` (**EDIT**, ~+70 L)
- **Change:** `(import "prelude/doc")` added to the existing five imports
  (`:53-57`). `dg-doc : (-> Reason Doc)` with **nine** arms, and `dg-decl-doc`
  as its one helper. **`dg-qty-name` is reused, not added** (decision 9).
  `dg-msg` is **not touched** — not one line.
  - Both `case`s obey the file's **accessor-function pattern**: one `case` on
    `Reason` as the **direct body of a `lam`**; callers construct and never
    match (the nested-`case` "unknown name" compiler bug the file's header
    records).
  - Not one `str-cat` in `dg-doc`. That absence is the element.
  - The two arms that carry the thesis: `r-redeclared` puts **both**
    declarations on their own indented lines; `r-usage` names **both**
    quantities via the existing `dg-qty-name`.
- **⚑ BUILD RULE obligation, and it lands here.** This is the commit that puts
  `prelude/doc` into the compiler's own blob (decision 13). So: `bin/chirality-bin
  < blob > C1` → **test C1** (Phase 14 plus the full `bin/chirality test`) →
  promote → then `./C1 < blob > C2; cmp C1 C2` once. **The `cmp` is the
  self-hosting check and it is NOT a correctness check** — it proves the
  compiler reproduces itself, nothing about whether `dg-doc` is right. Phase 14
  is what says that.

### Commit 3 — the gate: `tools/test/doc.sh` + fixture + registration
- **Targets:** `tools/test/samples/e158_doc.prog` (**NEW**) ·
  `tools/test/doc.sh` (**NEW**) · `tools/test/run-tests.sh` (**EDIT, 1 line**) ·
  `tools/test/MIGRATION-NOTES.md` (**EDIT**, one table row).
- **Change:** the fixture and script per §5, mirroring `diag.sh`'s shape
  (`ok`/`bad` counters, `build_run`, named mutants, `grep -R` census). The
  registration line goes beside `:187`:
  `run_phase 14 "layout algebra (E158 Doc)"                       doc.sh`
  ⚑ **The fixture goes in `tools/test/samples/`, not `prog/samples/`**, for the
  reason `MIGRATION-NOTES.md` already gives for `e157_diag.prog`: it is consumed
  by *this gate*, not read by path at runtime by a shipped program, so it must
  sit outside the shipped tree — and therefore outside Phase 7's `lib prog` root
  sweep, so E158's assertions are counted once, by E158's own phase.
- **Verify:** `bin/chirality test` — Phase 14 green **and Phase 13 unchanged**.

### Commit 4 — `lib/protocol/render-doc.chiral`: `doc->rendering` — **DEPENDS ON E174**
- **Target:** `lib/protocol/render-doc.chiral` (**NEW**). No `(module …)`
  coordinate (decision 14). `(import "prelude/doc")` + `(import "protocol/render")`.
- **Change:** `doc->rendering : (-> I64 Doc Rendering)` — a re-run of the
  `doc-best` walk carrying a **face-name stack** in the accumulator, pushed at
  `d-tag` open and popped at its close, emitting one faced node per segment per
  line. Correct for nested tags, per FLAG C.
- **Dependency:** the emission half has no target constructor until **E174**
  lands `r-row` + the per-node width function (`catalog.md:487`,
  `ledger.md:309`; NEEDS-AUTHOR-1 as answered).
  **Do not land a version that is plausibly right and quietly wrong** — that is
  precisely what FLAG C refused, and the artifact's own reasoning (four logged
  "built but unadopted" findings) cuts against it.
- **When E174 has landed:** add gate rows **G8** (a two-level nested `d-tag` produces
  correctly nested faces) and **G9** (a `d-tag` spanning a break faces **both**
  output lines) to `doc.sh`, each with its named mutant.

**Not in this element, and each already has a home:** E146's emitters
(`SELF-IMPLEMENT-CATALOG.md:411`) · E182 (`:437`) · `typing/pretty.chiral`
(decision 12, needs its own row before anything is parked on it) ·
`assemble-prompt` (a follow-on `prog/` commit) · `doc->json`.

## 5. Conformance gate — `tools/test/doc.sh`, Phase 14

**The gate is behavioural and every row that matters carries a named mutant** —
a stated corruption of the source and the outcome it must produce. A row whose
mutant also passes exercises nothing (the E156 lesson: a gate fixture can be
blind to its own mutant). **The fixpoint `cmp` from commit 2 is not a row here**
— it is a stability check, and stability is not correctness.

| row | assertion | named mutant that must convict |
|---|---|---|
| **G1 — flat law** | `doc->str 1000000 d` equals the same document with every `d-line` replaced by its `Brk`'s flat text (`brk-soft`→`""`, `brk-space`→`" "`), for a fixture doc containing all six constructors. **`brk-hard` has no flat text and is excluded from the reference doc** — it breaks in either mode (§4 commit 1), so the flat law is over the non-hard `d-line`s. This is what makes `d-group` sound. | **M1 `swap-soft-and-space`** — `dc-line`'s `(m-flat)` arm emits `" "` for `brk-soft`. G1 goes red; G2 stays green (proving the two rows are not the same row). |
| **G2 — width independence** | For `w ∈ {1, 40, 1000000}`, the **token sequence** of `doc->str w d` is identical; only breaks and leading indent differ. Asserted by **stripping every whitespace byte** from each of the three outputs and comparing all three for equality. ⚑ *Corrected at the spec audit: the earlier form — strip `"\n"` + leading spaces — goes RED on correct code, because a `brk-space` flattens to `" "` at wide width and to `"\n"`+indent at narrow, so `"a b"` and `"ab"` are compared; it also reddens under M1, destroying the G1/G2 asymmetry this table claims. Stripping all whitespace is correct for all three `Brk` arms at once, and M2 still convicts because it changes content bytes, not whitespace.* This is the law E146 consumes; E158 owns it. | **M2 `clip-d-text`** — `doc-best`'s `d-text` arm truncates `s` to the remaining width. G2 goes red. This is the mutant that proves `d-text` atomicity is *tested*, not merely asserted in a comment. |
| **G3 — evidence survival (THE element's row)** | For each of `Reason`'s **nine** arms, `doc->str 80 (dg-doc r)` **contains every field the arm carries**. Two rows carry the thesis and are asserted explicitly: `r-redeclared` names **both** declarations and they **differ**; `r-usage` with `(q1)`/`(qw)` contains **both** `"1"` and `"omega"`. | **M3 `drop-observed`** — `dg-doc`'s `r-usage` arm stops emitting `oq`. G3 goes red. |
| **G3c — the control that states the win** | The **same** `r-usage` value: `dg-msg r` contains **neither** `"1"` nor `"omega"` (it returns `"binder usage mismatch"` — `diag.chiral:349-363`, nine of twelve subjects), while `doc->str 80 (dg-doc r)` contains both. This is a *positive assertion about the baseline*, so it also fails if someone "fixes" `dg-msg` — at which point E157's goldens and this row must be reconciled deliberately, not silently. | **M3c `make-dg-msg-verbose`** — `dg-msg`'s `r-usage` arm (`diag.chiral:320`) appends `(dg-qty-name d)` / `(dg-qty-name o)` around the `dg-usage-msg` call. ⚑ *Corrected at the spec audit: the mutation cannot go in `dg-usage-msg`, whose type is `(-> Subject Str)` — the quantities are not in scope there; `:320` is where they are.* G3c goes red **and** `diag.sh` Phase 13's G3 goldens go red. Both, which is the point. |
| **G4 — the group decision actually happens** | One fixture doc renders **flat** at `w = 40` (contains no `"\n"`) and **broken** at `w = 10` (contains `"\n"` and the nested indent). | **M4 `always-break`** — `doc-best`'s `d-group` arm always picks `(m-brk)`. G4 goes red; **G2 stays green**, because the token sequence is unchanged. That asymmetry is why G4 exists separately. |
| **G5 — the sum is closed and has no union** | (a) `grep -R 'd-union' lib prog tools` → **zero hits**. (b) `Doc` has exactly six constructors, read out of `lib/prelude/doc.chiral` itself so a new arm is censused without editing the script. (c) A probe casing all six arms of `Doc` and all three of `Brk` compiles. | **M5 `add-seventh-constructor`** — append a `(d-fill (body Doc))` arm to `Doc` and nothing else. The compile of `prelude/doc` must **fail** on `doc-best`'s coverage. If it compiles, the closed sum is buying nothing. |
| **G6 — E154 name census, tree-wide** | Every name `lib/prelude/doc.chiral` introduces is defined **exactly once** across `lib prog tools`. Names are read out of the file; the search is **`grep -R`, not `grep -r`** — `-r` does not follow symlinks and would let a skipped file read as a clean census (`tools/test/MIGRATION-NOTES.md` records this exact trap for `diag.sh` G6). | **M6 `redefine-doc-fits`** — add a second `(def doc-fits …)` in `lib/prelude/string.chiral`. G6 goes red. |
| **G7 — the two exits are NOT cross-asserted (decision 6, made checkable)** | (a) **No byte-equality assertion on `dg-msg` anywhere in this element**: `doc.sh` contains zero golden rows (`[ "$got" = … ]`) over a `dg-msg` value, and the fixture's only `dg-msg` reference is G3c's substring-*absence* control — so the count is pinned at **exactly the G3c control**, not at zero. ⚑ *The census pattern is assembled (`pat="dg""-msg"`) so the row does not match its own source line; the earlier form, `grep -c 'dg-msg' tools/test/doc.sh` → 0, can never hold — the grep line contains the literal — and it contradicted G3c, which must call `dg-msg` to assert anything about it. Corrected at the spec audit.* (b) `tools/test/diag.sh` and `tools/test/samples/e157_diag.prog` are **byte-unchanged** by this element, asserted against a **`sha256` pinned in `doc.sh`**. *(The `git diff --stat` alternative is dropped: once the E158 commits land, a diff against them is empty forever, so the row would report ok for the rest of time.)* (c) Phase 13 runs green, unchanged, in the same `bin/chirality test`. | **M7 `cross-assert`, both directions** — (i) add one `doc->str` golden row to `diag.sh`: **G7(b)** goes red (the checksum moves); (ii) add one `dg-msg` golden row to `doc.sh`: **G7(a)** goes red. ⚑ *Corrected at the spec audit: (i) alone does not redden (a) — it never touches `doc.sh` — so the pair is needed to give both halves teeth.* This row is what stops `Doc` from re-importing the byte-identity constraint it exists to lift. |
| **G8/G9 — nested and break-spanning tags** | *Deferred to commit 4 and written there.* They are rows of this same gate, gated on **E174** (the minted blocker under commit 4) and landing with the code they grade. | see §4 commit 4 |

**Registration:** `run_phase 14 "layout algebra (E158 Doc)" doc.sh` in
`tools/test/run-tests.sh` beside `:187`, plus a row in `tools/test/MIGRATION-NOTES.md`'s
"New here" table. **An unregistered script never runs**, and a phase that
silently vanishes is a gate that reports ok forever.

**Not gate rows, deliberately:** totality (decision 5 — the checker cannot see
the measure; E50), any `dg-msg` byte-identity row (decision 6), any `Judg` arm
count (E182), any `pretty.chiral` behaviour (decision 12).

## 6. Residue & links

- **Corrections this SPEC applies to the example** (the example itself is not
  edited by a spec run; these are recorded here and the fixes are in §2/§3):
  1. **`dg-qty-name` already exists** — `diag.chiral:284-285`, 14 call sites. The
     example's §6 lands-in table lists it as an addition; adding it is a
     duplicate label in one file. **Decision 9.**
  2. **`assemble.chiral` line numbers** — the example says `:47-57`, the catalog
     row (`catalog.md:470`) says `:51-56`. Measured: `def assemble-prompt` at **`:48`**,
     the `str-cat` nest at **`:52-57`**.
  3. **Open question 2 / FLAG C is obstructed by the target type**, not by
     effort: `Rendering` has no horizontal composition constructor, so the
     face-name stack is necessary but not sufficient. Raised as **NEEDS-AUTHOR-1**;
     **answered by E174**, minted `d16113e`.
  4. Two names moved on census grounds: `fits` → `doc-fits`, `fr` → `dfr`.
     **Decision 10.**
  - **Verified correct, against the brief's "verify, don't trust":**
    `pretty.chiral` is 51 lines, renders **5 of 16** formers, declares its **own
    local 5-constructor `Term`**, and `surface/syntax.chiral:18`'s `Term` really
    has **16** constructors. Repointing it is a rewrite. **Decision 12.**
    `render.chiral:24` really is `(data Mode ()`. `Judg` really is 38 arms.
    `Reason` really is 9 arms.

- **Deliberately unbuilt (each with a real home, none parked on a phantom):**
  - **`doc->json`** — no consumer. Not deferred to an element; it is one `case`
    over six constructors the day a consumer exists.
  - **`doc->rendering`** — scoped IN (commit 4), dependent on **E174**
    (`catalog.md:487`, `ledger.md:309`), landing correct or not at
    all. **NEEDS-AUTHOR-2 (§3) is open**: nested `r-face` does not restore the
    outer face, which E174 does not cover, so the dependency may be two elements.
  - **A totality certificate for the renderer** — **E50**
    (`SELF-IMPLEMENT-CATALOG.md:127`, `not built; totality gap`). E158 is a
    natural first client. Nothing is parked on it: the code ships and runs;
    only the *proof obligation* waits.
  - **The `Judg` arity residue** — **E182** (`:437`, `LEDGER.md:292`), minted.
  - **E146's five emitters returning `Doc`** — **E146's row** (`:411`), amended.
  - **`typing/pretty.chiral`'s repoint** — no row, and this SPEC does not defer
    work to one. It is stated as **out of scope with its cost measured**
    (decision 12); if it is ever to be tracked it needs a row minted first, and
    a spec run cannot mint one.
  - **`assemble-prompt`'s conversion** — a follow-on commit in `prog/`, not an
    element.
  - **`.protocol`** — `Doc` owes it nothing: it round-trips against **bytes**,
    which have no layout freedom. It is also not yet a minted extension
    (`LAYOUT.md` lists five, `.protocol` is not among them).

- **⚑ Pre-existing finding, outside this SPEC's write surface.**
  `prog/scriba/render-str.chiral` imports `prelude/string` (`:17`) **and**
  defines its own `str-join` (`:22`) — a duplicate label with
  `prelude/string.chiral:215`. It does not fire because the module is imported by
  **zero** roots (`grep -Rn 'render-str' lib prog | grep import` → 0), i.e. it is
  an orphan that never enters a blob. Unrelated to E158 and not touched by it;
  recorded because the census that found it is the same census decision 10 ran,
  and because a live `str-join` collision would be a hazard the day that module
  is adopted.

- **Tooling state, stated plainly:** `tools/pack/pack.py` **cannot run this
  element's pipeline** (it probes `examples/`, this tree has `docs/examples/`,
  and its Python-oracle baseline half has no source here — `MIGRATION-NOTES.md`).
  So the deterministic status flips did not happen either: the
  `docs/examples/INDEX.md` row for E158 is flipped to `specced` **by hand** in
  the same commit as this file, matching E157's row shape. Nothing was repointed
  at a guess.

- **Follow-on:** **U16 "the block algebra"** —
  `.planning/USER-LAYER-TRACKER.md:92`, status `blocked`, dependency `E158`. It
  is the user layer's waiting consumer.

- **Related:** [[E157-typed-diagnostics]] (built — supplies the `Reason` this
  renders) · [[E97-skip-chain-diagnostics]] (the accessor-function pattern and
  the blame chain `r-skipped` joins) · [[E161-kind-identifier]] (the `(module …)`
  coordinate) · [[pattern-boundary-sums]] (why `Brk` is a sum and `d-tag`'s `Str`
  is not). Elements: **E157** · **E182** · **E146** · **E163** · **E50** ·
  **E11** · **E14**.
