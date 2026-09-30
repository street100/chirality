---
element: E175
slug: face-restore
title: **A face survives its body** — the ANSI renderer carries the ambient face and restores it, instead of full-resetting at every close
kind: BUILD-PROPER
example: docs/examples/E175-face-restore.md
status: audited
updated: 2026-08-31
---

# E175 SPEC — **A face survives its body**

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

> **⚑ The pack did not run, and was not repointed.** `tools/pack/pack.py` probes
> `examples/`; this tree's corpus is `docs/examples/`, and
> `tools/pack/MIGRATION-NOTES.md` records the tool as **not repointed on
> purpose**. Per the brief this SPEC was written **by hand** against the tree,
> and nothing was repointed at a guess — the disposition E158's and E174's SPECs
> took. Every citation, count, byte string and cell map below was **read or
> executed live on 2026-08-31** in `/workspace/chirality-verify` @ `e158-doc`
> (`3d3e931`), with E174 landed.
>
> **⚑ The whole fix was BUILT AND RUN in a scratch tree before this file was
> written.** A patched copy of `lib/` (the §4 change applied in full) plus four
> edits to `tools/test/row.sh` was assembled outside the repo, and
> `tools/test/run-tests.sh` was run against it: **`211 passed, 0 failed`,
> `gate PASSED`, Phase 15 `41 passed, 0 failed`.** Ten of §5's twelve mutants
> were executed against that tree and each convicted at a named cell or a named
> compiler error. The probe trees were torn down; §6 carries the RUN log. So the
> numbers below are not predictions — they are measurements, and where one
> contradicted the example it is called out in §6.

## 1. Deliverable

- **After this runs:** `lib/protocol/render.chiral` carries an **ambient face**.
  Three new names sit beside the existing face block — **`face-join`**
  (`(-> Face Face Face)`, attrs OR, inner's colour wins when set),
  **`rnd-face-plain`** (`Face`, the default ambient), and **`rnd-restore`**
  (`(=> Face Unit)`, the **one** new emitter and the only place `ansi-reset` may
  still be spelled inside the tree walk). Nine walker signatures gain **one
  trailing `Face`**; **21 call sites** inside that one file gain a trailing
  `Face` argument (19 pass `amb` through unchanged, `:720` passes `(face-join amb f)`,
  and `:729` seeds `rnd-face-plain`); and **six closes** — `:569, 610, 624, 687,
  705, 721` — stop emitting `(put ansi-reset)` and start emitting
  `(rnd-restore amb)`. `tools/test/row.sh` gains the seed on its three
  `render-to-ansi` probes **and one updated `sed` pattern** (§3 row 8). A new
  **Phase 16** gate, `tools/test/face.sh` + `tools/test/samples/e175_face.prog`,
  grades the element against **the emitted byte stream** — a **cell map with the
  SGR register set per painted cell** for the rows that are about what the
  screen shows, and **raw bytes** for the two rows that are about bytes which
  paint nothing.

- **⚑ The element is the CLOSE, and the catalog row's prescription was refuted
  by probe.** The row (`SELF-IMPLEMENT-CATALOG.md:439`, `LEDGER.md:294`, both
  since corrected in place) said *nested* `r-face` loses the outer face and
  prescribed *"a face stack in the `r-face` arm"*. All three parts are wrong and
  the corrections are the element:
  1. **Nesting is not required.** Measured, byte-exact, this session:
     `(r-face "keyword" (r-row [(r-text "ab") (r-text "cd")]))` emits
     `@[1m@[31m@[3;1Hab@[0m@[3;3Hcd@[0m@[0m` — `cd` carries **no SGR at all**.
     The same happens through `r-lines`, which predates `r-face` in the sum, so
     **the defect is older than E174**.
  2. **The killing `\e[0m` is `r-text`'s (`:687`), not `r-face`'s (`:721`).**
     Six drawing sites open with an SGR and close with an unconditional full
     reset; **five of the six are ad-hoc `ansi-bold`** the face registry does not
     know about. A stack in the `r-face` arm never sees them.
  3. **The forcing consumer does not nest either.**
     `dg-doc` (`lib/typing/diag.chiral:565`) has thirteen `d-tag` sites and they
     are all **siblings**; `dg-decl-doc` (`:724`), the one function called from
     inside a `d-tag` body, emits no tag. E158 commit 4 hits the sibling case.

  The honest statement is that **the emitter is self-inconsistent — the open is
  a delta and the close is a replacement** — and only the close changes.

- **Non-goals** (each with where it actually lives, and every follow-on is
  already MINTED):
  - **E179 — the registry stops being advisory.** Minted
    (`SELF-IMPLEMENT-CATALOG.md:443`, `LEDGER.md:298`). Five drawing sites
    hardcode `ansi-bold` past the registry, and `lookup-face` (`:160-169`)
    *synthesizes* `(face name -1 -1 0)` for an unknown name, so a typo and an
    explicit `"default"` are indistinguishable. **E175 fixes those five sites'
    CLOSES and leaves them ad-hoc**, because turning them into registry faces
    changes what they draw and touches `r-text`'s constructor.
  - **E180 — face-aware incremental redraw.** Minted (`:444`, `LEDGER.md:299`).
    **E175 CREATES this hazard**: a node's emitted SGR now depends on its
    ancestors, while `diff-node`'s `r-face` arm (`:306`) hands back a
    `diff-changed` payload stripped of the face it was found under. Unreachable
    today — `render-to-ansi-delta` (`:733-737`) is a full redraw that goes
    through `render-to-ansi-full` — and named, not shelved.
  - **E177 (display width) and E178 (`r-table`'s two layouts).** Minted
    (`:441`, `:442`). Both live in `render.chiral`; E175 touches neither.
  - **`rnd-cols` and every number in it.** SGR bytes paint no cell, so
    `rnd-cols`'s `r-face` arm (`:515`) is `(rnd-cols body)` before and after.
    This is **checked, not asserted**: `row.sh`'s screen reducer discards
    `ESC[…m` by construction, and Phase 15 was **run green (41/41) against the
    fixed tree** (§6 RUN 6).
  - **`lib/protocol/apc.chiral`.** The codec transports the face **NAME**, a
    `Str` (`:115`, `:276`) — never a `Face` value. Nothing in E175 reaches it.
  - **`prog/`.** **No `prog/` file calls `render-to-ansi`** — 41 call sites of
    `render-to-ansi-full`, 0 of `-delta`, whose signatures do not move. Measured
    by compiling `prog/scriba/scriba-main.prog`,
    `prog/scriba/samples/t6_apc_roundtrip.prog` and `prog/compiler.prog` against
    the fixed `lib/`: **all three OK, unedited**.
  - **`command-loop.chiral:478` and `:1546`,** the two `put ansi-reset` sites
    outside this module. Both run outside the tree walk at depth 0, where
    restore and reset are the same four bytes. They must NOT be touched.
  - **The dead `prev : (Maybe Rendering)` slot** (`:99`, `none` at all seven
    internal call sites, read nowhere). Deliberately not deleted and not
    repurposed — §3 row 7.
  - **`r-hole`'s dead `(put "")`** (`:713`). It is E174's residue, it is the
    control that proves E175 is not a blanket `sed`, and it stays.
  - **The E161 `(module protocol/render …)` datasheet line.** `lib/protocol`
    carries one in 0 of 8 files; adding one here is E161 adoption against the
    directory's own convention (E174 decision 12).

## 2. Baseline (what already exists — do NOT respec these)

- **Conformance-map verdict: none.** `records/conformance-map.md` has
  **zero** rows matching `E17[4-9]` or `E18[0-9]` — all postdate the map
  snapshot. Treat as **BUILD**, with the live measurements below standing in as
  the build-state authority. Same disposition E157's, E158's and E174's SPECs
  took.

- **Ledger / catalog state.** `LEDGER.md:294` and
  `SELF-IMPLEMENT-CATALOG.md:439` both carry E175 at `design`, each followed by a
  **⚑ PREMISE CORRECTED** block that withdraws the nesting framing, the
  `r-face`-stack prescription **and** the byte-identity claim, and fixes the
  census to **14**. E179 (`:443` / `LEDGER.md:298`) and E180 (`:444` /
  `LEDGER.md:299`) were minted with that correction (`3d3e931`). The example's
  INDEX row (`docs/examples/INDEX.md:136`) read `reviewed` when this spec run
  began and is flipped to `specced` by hand with this file (§6).

- **⚑ The suite is GREEN today, and the number is the baseline this element must
  not move.** Measured, one run, this session:

  ```
  $ ./bin/chirality test
  …
  typed diagnostics (E157): 30 passed, 0 failed
  layout algebra (E158): 26 passed, 0 failed
  horizontal composition (E174): 41 passed, 0 failed
  assertions: 211 passed, 0 failed
  chirality test: gate PASSED          (exit 0)
  ```

  Ten phases run (1–7, 13, 14, 15); 8–12 are names still owed and are printed as
  such (`run-tests.sh:225-229`).

- **Live code this composes with (already built — compose, do not rebuild):**
  - **`lib/protocol/render.chiral`, 737 L**, `(import "prelude/prelude")` +
    `(import "ports/ports")` + `(import "protocol/utf8")`, no `(module …)` line.
    ⚑ *Citations re-read against the live file 2026-09-04. E175 has landed since
    this section was drafted (737 L → 790 L) and its own two declares sit inside
    the block below, so every number in these two bullets is the LIVE one and is
    four above the pre-E175 baseline it was written as. The 21 call-site numbers
    in the next bullet are the pre-E175 list and are left standing as the record
    of what the commit changed.*
    `(data Face () (face (name Str) (fg I64) (bg I64) (attrs I64)))` at
    **`:37-38`**. `lookup-face` declared `:57` / defined `:164`, and its `nil`
    case (`:167`) **synthesizes** `(face name -1 -1 0)`. `face-sgr` declared
    `:61` / defined `:188-198`: six conditional emits, each producing `""` when
    its bit is clear, and `""` for `fg`/`bg` `< 0`. `default-faces` `:148-162`,
    **eleven** rows (audit: counted, not twelve); `"default"` is `(face "default" -1 -1 0)` (`:149`),
    `"keyword"` `(1 -1 1)` (`:151`), `"comment"` `(2 -1 0)` (`:150`),
    `"error"` `(1 -1 2)` (`:153`), `"manas-cursor"` `(-1 -1 8)` (`:161`).
    `ansi-reset` `:329`, `ansi-bold` `:331`.
  - **The nine walker signatures**, all `(… Unit))`-terminated and all
    contiguous: `render-row` **`:101`**, `render-to-ansi` **`:103-105`**,
    `render-table` **`:107`**, `rnd-emit-headers` **`:109`**, `rnd-emit-rows`
    **`:111`**, `rnd-emit-one-row` **`:113`**, `render-section` **`:115`**,
    `render-tree` **`:119`**, `render-lines` **`:121`**. `render-to-ansi-full`
    (`:123`) and `render-to-ansi-delta` (`:125`) are the entry points and **do
    not move**.
  - **The 21 call sites**, all inside this file: `:570, 577, 578, 585, 586, 590,
    591, 614, 623, 625, 636, 637, 655, 656, 673, 675, 679, 691, 695` (19
    pass-through), `:720` (the descent under a face — takes the **join**), and
    `:729` (`render-to-ansi-full`'s, the **seed**).
  - **`tools/test/row.sh` (E174, Phase 15, 41 assertions)** — the shape
    `face.sh` mirrors: `ok`/`bad` counters, `build_run` (`:88`), **`build_out`**
    (`:103`, the stdout-capturing helper `doc.sh` lacks), `mutlib` (`:125-136`,
    which copies `lib/`, seds it, and **reports a stale pattern rather than
    passing silently** — the `cmp -s` guard is `:132-134`), the `SCREEN_AWK` cell
    reducer (`:152-177`) whose `ESC[<p>m` case is a **documented no-op**,
    `cell_at`/`band_stat` (`:183-188`), the sha256 `pin` helper (`:645-650`, its
    four calls at `:651-654`) and the `reg()` registration device
    (`:676`) that greps `run-tests.sh` — **a different file from the script doing
    the grep**.
  - **`tools/test/diag.sh` (E157, Phase 13, 30)** and **`tools/test/doc.sh`
    (E158, Phase 14, 26)**. Neither names `render-to-ansi` anywhere; `doc.sh`
    carries sha256 pins. Both must stay **byte-unchanged**.
  - **`tools/test/run-tests.sh`.** `run_phase()` `:115`; registered 3–6 at
    `:134-137`, **13** at `:201`, **14** at `:210`, **15** at `:221`. The header
    (`:10-27`) records **8–12 as names still owed**.

- **The defect, measured (not paraphrased).** A probe built outside the source
  tree — the `row.sh` shape, `chirality_blob_file` → `bin/chirality-bin` → run,
  `od -An -v -tu1` — rendering four nodes at rows 1/3/5/7 through
  `render-to-ansi`, `dims = (pair 40 200)`. `ESC` shown as `@`; **this is a
  verbatim re-derivation of the example's finding 1 and it matched byte for
  byte**:

  ```
  A (r-face "keyword" (r-text "ab" false))
      @[1m@[31m@[1;1Hab@[0m@[0m
  B (r-face "keyword" (r-row [(r-text "ab") (r-text "cd")]))
      @[1m@[31m@[3;1Hab@[0m@[3;3Hcd@[0m@[0m
  C (r-face "keyword" (r-row [(r-face "error" (r-text "xy")) (r-text "zw")]))
      @[1m@[31m@[4m@[31m@[5;1Hxy@[0m@[0m@[5;3Hzw@[0m@[0m
  D (r-face "keyword" (r-lines [(r-text "ab") (r-text "cd")]))
      @[1m@[31m@[7;1Hab@[0m@[8;1Hcd@[0m@[0m
  ```

  - **A is correct** — one face, one leaf, then two redundant resets.
  - **B and D are wrong and neither nests.** The reset that unfaced `cd` is
    `r-text`'s, at `:687`.
  - **⚑ C carries the design question in one line.** The inner face's open is
    `@[4m@[31m` — underline and red, and **no bold**, because `face-sgr` emits
    only the bits that are set. The terminal's bold is still on, so `xy` renders
    bold + underline + red: **the open composed as a delta.** The close then
    emits `@[0m`: **a replacement.**

- **The six close sites, and the five that are ad-hoc.** Each is
  `put <SGR>` … content … `put ansi-reset`:

  | site | opens with | closes at | registry? |
  |---|---|---|---|
  | `rnd-emit-headers` (`:567`) | `ansi-bold` | **`:569`** | ad-hoc |
  | `render-section` (`:607`) | `ansi-bold` | **`:610`** | ad-hoc |
  | `render-tree` (`:622`) | `ansi-bold`, only when selected | **`:624`**, guarded to match | ad-hoc |
  | `r-text` arm (`:685`) | `ansi-bold`, only when `bold` | **`:687`** | ad-hoc |
  | `r-stream` arm (`:702`) | `ansi-bold` | **`:705`** | ad-hoc |
  | `r-face` arm (`:718`) | `face-sgr (lookup-face …)` | **`:721`** | **registry** |

  `r-hole` (`:707-713`) is the exception: it emits **no** SGR and closes with
  `(put "")`. It needs nothing, and it is the control (§5 G6).

- **The latency claim holds, and here is the census — 14, not 11.** Live
  `r-face` construction sites, every one of them `(r-face <name> (r-text …))`:
  `chat-view:125,141,195` · `manas-runview:74,76,101` · `command-loop:1471` ·
  `init-loader:135,138,234` · `manas-mode:472,473,919,1003`. **No live consumer
  builds a face over more than one leaf, and none nests.** (`scriba-runview-test`
  and `scriba-runview-stream-test` *match* on `r-face`; they do not build one.
  `tools/test/samples/e174_row.prog:61` already builds the broken shape, but that
  sample exercises only the APC codec and never calls `render-to-ansi`.)

- **`face-sgr` of the default face is `""`, and it is load-bearing.** Confirmed
  in the probe above: A's tail is exactly `@[0m@[0m`, not `@[0m@[m`. So
  `(str-cat ansi-reset (face-sgr rnd-face-plain))` **is** `ansi-reset`, byte for
  byte, which is what lets §4 handle depth 0 with no special case.

- **⚑ The live consumers are SCREEN-identical, NOT byte-identical.** Measured by
  applying §4's change to a scratch `lib/` and re-running the probe with an
  **SGR-tracking** reducer (`row col bytes sgrset`). For the live shape
  `(r-face f (r-text …))`:

  | | bytes |
  |---|---|
  | before | `@[1m@[31m` `@[1;1H` `ab` `@[0m` `@[0m` |
  | after  | `@[1m@[31m` `@[1;1H` `ab` `@[0m@[1m@[31m` `@[0m` |

  because the inner close restores the **ambient**, and inside an `r-face` the
  ambient **is** that face. The full before/after cell maps over all four probe
  nodes:

  ```
  before                    after
  1 1 a {1,31}              1 1 a {1,31}
  1 2 b {1,31}              1 2 b {1,31}
  3 1 a {1,31}              3 1 a {1,31}
  3 2 b {1,31}              3 2 b {1,31}
  3 3 c {}         <—       3 3 c {1,31}
  3 4 d {}         <—       3 4 d {1,31}
  5 1 x {1,4,31}            5 1 x {1,4,31}
  5 2 y {1,4,31}            5 2 y {1,4,31}
  5 3 z {}         <—       5 3 z {1,31}
  5 4 w {}         <—       5 4 w {1,31}
  7 1 a {1,31}              7 1 a {1,31}
  7 2 b {1,31}              7 2 b {1,31}
  8 1 c {}         <—       8 1 c {1,31}
  8 2 d {}         <—       8 2 d {1,31}
  ```

  **The only cells that move are exactly the six the defect loses.** Every other
  painted cell is identical in position, byte and SGR set. **§5's G1 is written
  against the SCREEN for that reason**, and no row may assert byte-identity —
  it is not merely unproven, it is false.

- **⚑ BUILD-RULE state, measured: E175 changes NO compiler source, so the
  fixpoint does not fire.** `chirality_blob_file "lib:prog" prog/compiler.prog`
  produces **16 161 lines** and contains **zero** occurrences of
  `render-to-ansi`, `r-text`, `face-sgr` or `ansi-reset`. It contains exactly
  one occurrence of `r-face`, at blob line 2176 — **inside a comment**, from
  `lib/prelude/doc.chiral:182`. `protocol/render` is outside the compiler's
  import closure. Consequences, stated so §4 does not guess: there is **no new
  compiler binary, no promotion, and no `cmp C1 C2`**. The trip condition is in
  §4's standing rules.

## 3. Decisions

Rows 1–5 are **BINDING from upstream** — the corrections the catalog and ledger
rows now carry, and the calls the example makes on repaired grounds. Rows 6–13
are new to the spec run, each closed by the measurement that decides it. **Row
14 was the single NEEDS-AUTHOR item and is now ANSWERED** — the author resolved
it on 2026-08-31 (`6a5ffa2`, appended verbatim at the foot of this file):
**option (i), `-1` means *no opinion*; (iii) refused as a magic string; (ii) — a
fourth `Face` field carrying an attrs clear-mask — deliberately NOT minted.** The
question is kept below the table as the record of what was asked; the
disposition is the author's.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Is the defect *nesting*, and is the fix a face stack in the `r-face` arm? | **BINDING — NO to both. The catalog row is corrected in place (`3d3e931`)** | Measured, byte-exact (§2): `(r-face f (r-row [text text]))` emits the second leaf with **no SGR**, and so does the same shape through `r-lines`, which predates `r-face`. The killing `\e[0m` is `r-text`'s (`:687`). A stack scoped to `r-face` repairs **one of six** close sites and would pass its own review. The forcing consumer (`dg-doc`'s thirteen `d-tag`s) does not nest either — they are siblings, and `dg-decl-doc` (`:647`) emits no tag. |
| 2 | Are faces **deltas** or **replacements**? | **BINDING — DELTAS, and the ground is repaired** | Three measurements, none of them the example's original (false) one. **(a)** `face-sgr` (`:184-195`) **already emits a delta** — six conditional emits, `""` for every unset bit and for `fg`/`bg` `< 0`; it has **no vocabulary for "off"**. **(b)** The terminal **already composes** them: probe node C's `xy` renders bold because the outer's bold was never cleared. **(c)** Replacement means emitting `\e[0m` **plus the full resolved join at every open** — strictly more bytes for an identical screen, and it couples the OPEN to the ambient, so `face-sgr` of the looked-up face would no longer be enough to open a face. **Delta keeps the open a function of the face alone.** ⚑ The example's *original* second reason — "replacement changes every consumer's bytes, delta does not" — **was false** and is withdrawn (§2, §6). |
| 3 | One trailing `Face`, or a `(List Face)` stack? | **BINDING — ONE trailing `Face`** | A stack is what you need when pushes and pops are separated in **time**. Here they are separated by a **call**: `render-to-ansi` descends and returns, so the chirality call stack already holds every enclosing face, one frame each. A `(List Face)` is a shadow copy that can desynchronise. Measured cost of the parameter: **21 call sites, all inside one file, zero external callers** (`prog/` compiles unedited — §2). The S18 precedent is read the *other* way: the editor record earned itself at 11 parameters over 436 sites; this is one over 21. **Flip condition, named so it is not a matter of taste: if a SECOND piece of renderer state lands, build the record then and move both.** |
| 4 | Is the ambient the immediately-enclosing face, or the **join**? | **BINDING — the JOIN** | Probe node C settles it: at `zw` the correct state is `keyword`; at `xy` it is `keyword ⊔ error`. Only a joined value gives both without a re-walk. `face-join` is therefore a **description of what the emitter already does** — attrs OR, inner's colour wins when set — written down so the close can agree with the open. |
| 5 | Is depth 0 special-cased? | **BINDING — NO. The general rule IS the base case** | `face-sgr (face "default" -1 -1 0)` is `""` (measured: probe A's tail is exactly `@[0m@[0m`), so `(rnd-restore rnd-face-plain)` emits exactly `\e[0m`. Confirmed on the fixed tree: its **final four bytes are `27 91 48 109`** and nothing else. No `(case depth (0 …))`, no bottom-of-stack sentinel — which is the difference between an invariant and a guard. |
| 6 | Does `render-to-ansi-delta` need its own seed? | **RESOLVED — NO, and the example says otherwise** | `render-to-ansi-delta` (`:733-737`) is `(case (diff-node prev new) (diff-same unit) ((diff-changed _) (render-to-ansi-full new dims)))` — it goes **through `render-to-ansi-full`**, which seeds. There is **exactly ONE seed site, `:729`.** The example's §6 lists "two seeds in `render-to-ansi-full` (`:725`) and … `render-to-ansi-delta` (`:733`)"; `:725` is the `def` line, not the call, and `-delta` needs nothing. Corrected. |
| 7 | Is the dead `prev : (Maybe Rendering)` slot reused for the ambient, or deleted? | **RESOLVED — NEITHER** | Repurposing a parameter to a type it was not declared for is exactly the "a `Str` carries which-of-N" flattening this repo removes elsewhere (`pattern-boundary-sums`). Deleting it is right, unrelated, and doing it **inside E175 would make §5's G1 cell-map row grade two changes at once**. It stays: declared `:99`, passed `none` at all seven internal call sites, bound once at `:666` and read nowhere. Not deferred to a number, because it is not an element. |
| 8 | What exactly does `tools/test/row.sh` need? | **RESOLVED — FOUR edits, not three. ⚑ The example named three and they contradicted its own G8** | `:236`, `:241` and `:305` call `render-to-ansi` with **seven** arguments and gain the trailing `rnd-face-plain` seed — the example has this right. **It missed the fourth:** `:595` is M10's `sed` expression, and it matches `render-section`'s body line **verbatim**, ending `drow dcol))))))))))$`. E175 rewrites that line to `… drow dcol amb))))))))))` and the pattern goes stale — **Phase 15 goes RED because the fix worked.** Both halves of `:595`'s pattern gain ` amb`. ⚑ **The MECHANISM stated here was wrong, and the audit corrected it by running it.** It is *not* `mutlib`'s stale-pattern guard: M10 passes `mutlib` **two** expressions and the first (`:594`, the `ansi-goto` delete) still applies, so `cmp -s` sees a changed file and the guard **passes**. The stale second expression simply no-ops, leaving M10's paren re-balance undone, so the mutant `lib/` **fails to compile** and M10's two rows report *"the mutant G5 probe did not build"* / *"the mutant layout probes did not build"*. **Measured with the other three edits in place and this one omitted: `horizontal composition (E174): 39 passed, 2 failed`.** The conclusion and the required edit are unchanged; the failure an implement run will actually see is a compile failure, not a guard message. **Measured: with exactly those four edits, `row.sh` reports `41 passed, 0 failed` and the whole suite reports `211 passed, 0 failed` against the fixed `lib/`.** |
| 9 | Do `diag.sh`, `doc.sh` or any `prog/` file change? | **RESOLVED — NO, all of them, and it is measured rather than argued** | `diag.sh` and `doc.sh` name `render-to-ansi` **nowhere** (`grep`), and `doc.sh` carries sha256 pins that would move if they did. `prog/` has **41** `render-to-ansi-full` call sites, **0** `-delta`, and **0** bare `render-to-ansi` — verified by compiling `scriba-main.prog`, `t6_apc_roundtrip.prog` and `prog/compiler.prog` against the fixed `lib/` with **no `prog/` edit at all**: three OK. The two `put ansi-reset` sites at `command-loop:478,1546` run at depth 0 outside the tree walk and **must not be touched**. |
| 10 | Which phase number for the gate? | **RESOLVED — 16** | `run-tests.sh:10-27` and `tools/test/MIGRATION-NOTES.md:19-31` record **8–12 as names still owed** to unported old-tree phases; reusing one would make an unported gate look ported. E157 took 13, E158 took 14, **E174 took 15**, so **E175 takes 16**. Registration is a **required line**: an unregistered `face.sh` is a gate that never runs, and §5 makes the registration a checked row with a mutant. |
| 11 | Cell map, byte diff, or both? | **RESOLVED — CELL MAP for G1–G4, RAW BYTES for G5 and G6, and the split is forced** | Byte-identity is **false** (§2), so no row may assert it. But a **trailing SGR paints no cell**, so a tracking reducer cannot see G5's depth-0 tail or G6's `r-hole` close at all: measured, the `r-hole` mutant produces a **cell map identical to the fixed tree's** while the raw stream gains `@[0m@[1m@[31m` between `<?>h` and `@[8;1H`. A gate that graded G6 on the cell map would be grading nothing. |
| 12 | How does the SGR-tracking reducer model state? | **RESOLVED — fg and bg are single-valued REGISTERS; attribute codes are flags; `0` clears all. ⚑ A naive set-union reducer gets the example's own numbers wrong** | Measured both ways. Under a set-union model, G4 shape (a)'s first leaf reads `{1,31,32}` — the outer's `31` never leaves the set when the inner emits `32`. The example's expected `{1,32}` only comes out with fg as a register (`30-37` set it, `39` clears it; `40-47`/`49` likewise for bg). The reducer is `row.sh`'s `SCREEN_AWK` with the `ESC[<p>m` no-op replaced by this model, emitting **`row col bytes sgrset`**. |
| 13 | Does the fixpoint obligation fire? | **RESOLVED — NO, measured** | `prog/compiler.prog`'s blob is 16 161 lines with **zero** occurrences of `render-to-ansi`, `r-text`, `face-sgr` or `ansi-reset`, and its one `r-face` hit (blob `:2176`) is a **comment** carried in from `lib/prelude/doc.chiral:182`. `protocol/render` is outside the closure. No `C1`, no promotion, no `cmp`. Trip condition in §4. |
| 14 | What does `-1` mean once faces are deltas? | **RESOLVED by the AUTHOR, 2026-08-31 (`6a5ffa2`) — option (i)** | Raised as NEEDS-AUTHOR by the spec run and answered in the appended block at the foot of this file, which is binding. **`-1` means *no opinion*, which is the semantics `face-sgr`'s open already implements** — so §4's choice is a naming of the existing rule, not a stopgap. **(iii)** — the literal name `"default"` as reset-to-plain — is **refused**: a `Str` carrying a which-of-N, the move `pattern-boundary-sums` forbids and this arc has already refused twice (SGR-in-`r-text` for E174, `from Str` on `r-relayed` for E158). **(ii)** — a fourth `Face` field with an attrs clear-mask — is **deliberately NOT minted**: a face that can say *not bold* is a new requirement, not residue E175 incurs, and requirements are not residue. The genuinely defective half — `"default"` and a typo being indistinguishable — is **E179**'s (`lookup-face` synthesizing for an unknown name), already minted. |
| 15 | The five ad-hoc `ansi-bold` faces, and `lookup-face` synthesizing for an unknown name | **DEFERRED to E179 — MINTED (`SELF-IMPLEMENT-CATALOG.md:443`, `LEDGER.md:298`)** | E175 fixes their **closes** and leaves them ad-hoc. Turning them into registry faces changes what those five draw and touches `r-text`'s constructor — a different element with different consumers. |
| 16 | The redraw hazard E175 creates | **DEFERRED to E180 — MINTED (`SELF-IMPLEMENT-CATALOG.md:444`, `LEDGER.md:299`)** | E175 makes a node's SGR a function of its **ancestors**, while `diff-node`'s `r-face` arm (`:306`) recurses into the body when the names match and hands back the *body's* `Diff` — a `diff-changed` payload that escapes a face carries no face. Unreachable today because `render-to-ansi-delta` is a full redraw (`:733-737`). ⚑ This is **E175's own residue**, not an inherited defect: before E175 an escaped payload rendered unfaced like everything else. |

### ⚑ Decision 14, as the spec run raised it — ANSWERED 2026-08-31 (`6a5ffa2`)

> **Kept verbatim as the record of the question.** The answer is the author's
> appended block at the foot of this file, and it is binding: **option (i)**.

> **Under delta semantics a face cannot turn anything off, and `"default"` stops
> meaning "plain".** `face-sgr (face "default" -1 -1 0)` is `""`, so
> `(r-face "default" body)` becomes a no-op inside a `keyword`, where today's
> full reset accidentally gives it teeth at the close. `lookup-face` returns that
> same face for an **unknown name**, so a typo and an explicit `"default"` are
> indistinguishable — also true today, but today nobody nests so nobody notices.
> Three dispositions, none free: **(i)** accept it, and document that `-1` means
> *no opinion*; **(ii)** give `Face` a fourth field — an attrs *clear* mask — so
> a face can say "not bold"; **(iii)** treat the literal name `"default"` as a
> reset-to-plain, which is a magic string and a boundary-sum violation. §4 takes
> **(i)**. **The author's call**, and (ii) is a constructor change with its own
> element if it is wanted.

**⚑ One correction the spec run owes this item, because the brief's blast radius
is wrong and a wrong blast radius makes an author's call harder, not easier.**
The brief states that an attrs clear-mask "would ripple into `apc.chiral`'s
codec". Measured: it would **not**. `apc.chiral` encodes and decodes the `r-face`
constructor's **first field, which is a `Str` face NAME** (`:115`, `:276`), never
a `Face` value. The `(face …)` constructor is applied at **twelve sites, all inside
`lib/protocol/render.chiral`** — `default-faces`' eleven rows (`:145-157`) plus
`lookup-face`'s `nil` synthesis (`:163`); ⚑ **the spec run's "11" and its
"twelve rows" were each off by one in opposite directions and cancelled, and the
audit counted both** (`prog/scriba/chat-view.chiral:121`'s `(lam (face …)` is a
binder, not a construction, and is the only near-miss tree-wide); `prog/scriba/init-loader.chiral:149,152,243` name
the *type* `Face` but build their entries through `lookup-face`, so a fourth
field would not touch them either. **The real blast radius of option (ii) is
`render.chiral` alone** — `default-faces`' eleven rows, `lookup-face`,
`face-sgr`, and `face-join`. That makes (ii) cheaper than the brief implies; it
does not make the choice this SPEC's to make. **The author has since chosen —
option (i) — and declined to mint (ii)**; see the appended block. (The audit
recounted the two figures in this paragraph: **eleven** `default-faces` rows and
**twelve** `(face …)` applications, all in `render.chiral`. Both were off by one
in opposite directions, and the conclusion — one module — is unaffected.)

**No other item on this element is author-tier, and no deferral above rests on a
phantom: E177, E178, E179 and E180 all have catalog and ledger rows today.**

## 4. Change plan (ordered, commit-sized)

**Standing rules for every commit below.**

- **`bin/chirality-bin` (the committed compiler) compiles everything. Python
  compiles nothing, ever.** The flow is **build-new → test → promote**; nothing
  replaces itself in place.
- **The fixpoint obligation does NOT fire on this element, and the reason is
  measured, not assumed** (§2, decision 13): `protocol/render` is outside
  `prog/compiler.prog`'s import closure. There is **no `C1`, no promotion and no
  `cmp`**. **Trip condition, stated so it is not missed:** if an implement run
  finds itself rebuilding `bin/chirality-bin`, the closure has changed and the
  self-host check becomes **mandatory** — `bin/chirality-bin < blob > C1`,
  **verify `C1` is non-zero before `cmp`** (a `cmp` of two empty files passes and
  is the classic false green), test C1, promote, then `./C1 < blob > C2;
  cmp C1 C2`. **The `cmp` is stability, never correctness** — Phase 16 is what
  says the faces are right.
- **`ansi-reset` may be spelled in exactly ONE place inside the tree walk after
  this element: `rnd-restore`'s body.** Six sites stop spelling it; none gains a
  new spelling. `command-loop:478,1546` are outside the walk and stay.
- **No `_` arm is added anywhere**, and no arm of `render-to-ansi` is collapsed.
  `r-hole` keeps its `(put "")` — it is the control that shows the edit was not a
  blanket `sed`.
- Module keys are **root-relative**; the **extension is the kind** per
  `MAP.md:5-10`.
- **Every new name is censused with `grep -R`, not `grep -r`** — `-r` does not
  follow symlinks and would let a skipped file read as a clean census
  (`tools/test/MIGRATION-NOTES.md:68`). Measured this session: `face-join`,
  `rnd-face-plain` and `rnd-restore` have **zero occurrences of any kind** across
  `lib prog tools`. **Re-run it, do not trust it.**
- **⚑ ANY scratch tree a `mutlib`-shaped harness runs against MUST be a real
  directory copy of `lib/`, never a symlink.** This is an obligation on the
  implement run, not a war story: `mutlib`'s `cp -a "$REPO/lib" "$MUTLIB"`
  copies a **symlink** as a symlink, so every subsequent `sed -i` writes
  **through it into the tree under test**. It cost the spec run nineteen phantom
  failures, including a `Rendering` that had silently grown a tenth constructor
  (§6). Check it explicitly — `[ -L "$SCRATCH/lib" ] && exit 1` — before
  believing any suite number measured outside the repo.
- **E157's, E158's and E174's gates must not regress.** `diag.sh`,
  `samples/e157_diag.prog`, `doc.sh` and `samples/e158_doc.prog` are
  **byte-unchanged**; `samples/e174_row.prog` is **byte-unchanged**;
  `tools/test/row.sh` changes by **exactly the four edits in decision 8** and must
  still report `41 passed, 0 failed`.

### Commit 1 — `render.chiral` carries the ambient, and `row.sh` keeps up

- **Targets:** `lib/protocol/render.chiral` (**EDIT**, ~+20 L) ·
  `tools/test/row.sh` (**EDIT**, four lines).
- **⚑ These are one commit on purpose.** A signature change is not splittable —
  a partial threading does not compile — and `row.sh`'s three probes are
  seven-argument callers, so `render.chiral` alone leaves Phase 15 red. The tree
  is green before and after; it is never red in between.
- **Change:** ⚑ *This commit landed 2026-08-31; the line numbers in this plan
  are the pre-E175 baseline it was written against and are left standing as the
  record of what moved. Live positions are in §2. Re-read 2026-09-04.*
  - Three new names beside the face block. `(declare face-join (-> Face Face
    Face))` and `(declare rnd-restore (=> Face Unit))` after `face-sgr`'s declare
    (`:61`); the three `def`s **after the `ansi-*` string block (`:323-330`)** and
    before `rnd-emit-headers`. ⚑ **The placement is forced, and this SPEC's own
    first instruction — "after `face-sgr`'s body" (`:188-198` live; the draft
    said `:195`) — DOES NOT COMPILE**
    (audit, measured): `ansi-reset` is a bare `(def ansi-reset Str …)` at `:325`
    **with no `declare`**, so a `rnd-restore` written above it forward-references
    an undeclared name and the module fails with **`load: unknown name
    ansi-reset`**. `rnd-restore`'s own `declare` at `:62` declares *`rnd-restore`*,
    not `ansi-reset`. `face-join` and `rnd-face-plain` carry no such constraint;
    keeping the three together below `ansi-reset` is the shape that was built,
    compiled and run:
    - **`face-join`** — attrs `(bor oat iat)`; `fg`/`bg` take the inner's when
      `>= 0`, the outer's otherwise; the joined face's **name is the inner's**,
      because nothing reads it and carrying the outer's would make a debug print
      lie about which face is on top. Its header comment states, in as many
      words, that this is a **description of the existing emitter**, not a new
      policy (decision 4).
    - **`rnd-face-plain`** = `(face "default" -1 -1 0)`, with the measured note
      that `face-sgr` of it is `""` and that this is what makes depth 0 fall out
      (decision 5).
    - **`rnd-restore`** = `(put (str-cat ansi-reset (face-sgr amb)))`. **Reset
      then reapply, NOT per-attribute off codes** — `face-sgr` has no vocabulary
      for "off", the ambient is in hand either way, and this is one expression
      instead of six conditional off-codes that must stay in step with
      `face-sgr`'s six on-codes. Its header comment records that a faced leaf's
      close is **longer than today's by exactly `face-sgr amb`**, that the
      enclosing `r-face`'s own close then wipes it, and that the invariant is the
      **screen**, not the byte stream.
  - **Nine signatures** gain one trailing `Face`, at the pre-E175
    `:97, 101, 103, 105, 107, 109, 111, 115, 117`. `render-to-ansi-full` and
    `render-to-ansi-delta` (`:123-125` live, `:119` and `:121` as drafted) **do
    not move**.
  - **Nine `lam` binders** gain a trailing `amb`, at `:562, 573, 581, 589, 594,
    617, 632, 651, 666`.
  - **21 call sites** gain a trailing `Face` argument: `amb` at `:570, 577, 578,
    585, 586, 590, 591, 614, 623, 625, 636, 637, 655, 656, 673, 675, 679, 691,
    695`; **`(face-join amb f)`** at `:720`; **`rnd-face-plain`** at `:729`.
    ⚑ **Two of the nineteen do not take the argument at end-of-line, and inserting
    it before the closing paren run is wrong** (audit, hit while building this):
    `:570` ends `… (+ c (+ (str-len h) rnd-header-gutter)))))))))))` and `:578`
    ends `… (+ col rnd-table-cell)))))))` — the trailing run closes the `(+ …)`
    forms first, so `amb` must land **after** the arithmetic's own `)`, as
    `… rnd-header-gutter)) amb)` and `… rnd-table-cell) amb)`. A blanket
    end-of-line insertion puts `amb` inside the `(+ …)`, which type-checks as an
    `I64` argument count error or shifts the paren balance; the failure surfaces
    far away as `load: parse: unexpected )`.
  - **The `r-face` arm** (`:718-721`) rebinds `prefix` as the looked-up **face**
    rather than its SGR, so the join has a `Face` to work with:
    `(let ((f (lookup-face default-faces face-name))) (let ((_ (put (face-sgr
    f)))) …))`. **The emitted open bytes are unchanged** — measured (decision 2).
  - **Six closes** become `(rnd-restore amb)`: `:569, 610, 624, 687, 705, 721`.
    `r-hole`'s `(put "")` (`:713`) is **not** touched.
  - **`tools/test/row.sh`:** `rnd-face-plain` appended to the
    `render-to-ansi` calls at `:236`, `:241`, `:305`; ` amb` inserted into **both
    halves** of M10's `sed` expression at `:595` (decision 8).
- **Verify — and every number here was measured on a scratch tree carrying
  exactly this change:**
  - `./bin/chirality check lib/protocol/render.chiral` → **OK**.
  - `./bin/chirality check lib/protocol/apc.chiral` → **OK** (unchanged).
  - `./bin/chirality test` → **`assertions: 211 passed, 0 failed`,
    `gate PASSED`, exit 0**; Phase 13 `30`, Phase 14 `26`, Phase 15
    **`41 passed, 0 failed`**, Phase 7 unmoved.
  - `row.sh`'s own census row reports **76** names in `protocol/render.chiral`
    (73 today + the three new ones), each defined exactly once tree-wide.

### Commit 2 — the gate: `tools/test/face.sh` + fixture + registration

- **Targets:** `tools/test/samples/e175_face.prog` (**NEW**) ·
  `tools/test/face.sh` (**NEW**) · `tools/test/run-tests.sh` (**EDIT**: the
  `run_phase 16` line beside `:221`, and the phase-list header at `:10-27`) ·
  `tools/test/MIGRATION-NOTES.md` (**EDIT**: one row in the "New here" table at
  `:21-25`, whose heading also becomes "Phases 13, 14, 15 and 16").
- **Change:** the fixture and script per §5, mirroring `row.sh`'s shape —
  `ok`/`bad` counters, `build_out`, the `mutlib` runner with its stale-pattern
  guard, the sha256 `pin` helper and the `reg()` registration device — plus the
  one helper `row.sh` does not have: **an SGR-tracking reducer** (decision 12).
  Registration beside `:221`:
  `run_phase 16 "ambient face restore (E175 face-join + rnd-restore)"  face.sh`
- **⚑ The gate lands AFTER the fix, and the reason is mechanical, not lax.**
  Every probe in it calls `render-to-ansi` with **eight** arguments, so it cannot
  compile against the pre-E175 tree at all. Its "before" state therefore comes
  from **mutants** (`mutlib`, which reverts the close in a scratch `lib/`), not
  from git history — which is stronger, because a mutant is re-run on every
  future suite run and a git tag is not.
- **⚑ The fixture goes in `tools/test/samples/`, not `prog/scriba/samples/`**,
  for the reason `MIGRATION-NOTES.md` already gives for `e157_diag.prog`,
  `e158_doc.prog` and `e174_row.prog`: it is consumed by *this gate*, not read by
  path at runtime by a shipped program, so it sits outside Phase 7's `lib prog`
  root sweep and E175's assertions are counted once, by E175's own phase.
- **Verify:** `./bin/chirality test` — **Phase 16 green; Phases 13, 14 and 15
  unchanged at 30, 26 and 41; Phase 7 unmoved; and the suite total at exactly
  `211 + <Phase 16's count>` passed, 0 failed.** The 211 is not a guess: it is
  the measured post-commit-1 total.

### Commit 3 — the state rows say built

- **Targets:** `docs/elements/catalog.md:439` ·
  `docs/elements/ledger.md:294` · `docs/examples/INDEX.md:136`.
- **Change:** E175's catalog and ledger rows flip `design → built` with the
  measured landing note (three names, nine signatures, 21 call sites, six closes,
  Phase 16's script and count, and the residue: E179, E180). The INDEX row flips
  `specced → implemented`. **⚑ The stale byte-identity clause this SPEC promised
  to correct here is ALREADY CORRECTED — do not go looking for it** (audit,
  measured): `docs/examples/INDEX.md:136` reads *"only the CLOSE changes and every
  live consumer's SCREEN is unchanged"* today, fixed by **this SPEC's own commit
  `d853c62`**, whose message says so in as many words. An implement run that hunts
  for the `bytes` wording finds a stale pattern — the same class of trap as
  `row.sh:595`, one document up.

**Not in this element, and each already has a MINTED home — no deferral here
rests on a phantom:** **E179** (`SELF-IMPLEMENT-CATALOG.md:443`,
`LEDGER.md:298`) · **E180** (`:444`, `LEDGER.md:299`) · **E177** (`:441`) ·
**E178** (`:442`) · **E158 commit 4**, `doc->rendering`
(`docs/elements/specs/E158-doc-formatter-SPEC.md` §4), which is gated on E174 **and**
this element.

## 5. Conformance gate — `tools/test/face.sh`, Phase 16

**A rendering defect that is invisible on screen cannot be graded by a shape
assertion, and a rendering defect that is invisible in the bytes cannot be graded
by a cell map.** This element has both kinds, so the gate has both kinds of row
— and **every row carries a named mutant that is RUN**. Ten of the twelve below
were executed against a scratch tree carrying the full §4 change while this SPEC
was being written; each convicted at a named cell or a named compiler error, and
§6 logs what each one printed. **⚑ Seven toothless or self-matching gate rows
have been found in this repo this session; a row whose mutant also passes
exercises nothing.**

**The `sgr_screen()` helper — the one piece `row.sh` does not already have.**
`row.sh`'s `SCREEN_AWK` treats `ESC[<p>m` as a **documented no-op**, which is
exactly what makes `rnd-cols` provably invariant under E175 and exactly what
makes it useless for grading E175. `face.sh` carries a variant that **tracks the
SGR register set** and emits **`row col bytes sgrset`** per painted cell. Its
model, and each rule is load-bearing (decision 12):

| input | effect |
|---|---|
| `ESC[<r>;<c>H` / `ESC[H` / `ESC[2J` | as `row.sh` — set cursor, home, clear the map |
| `ESC[0m` (or a bare `ESC[m`) | clear **all** attribute flags **and** both colour registers |
| `ESC[30m`–`ESC[37m` / `ESC[39m` | **set / clear the fg REGISTER** — it replaces, it does not accumulate |
| `ESC[40m`–`ESC[47m` / `ESC[49m` | the same for bg |
| any other `ESC[<n>m` | set attribute flag `n` |
| `ESC[?<n>h` / `ESC[?<n>l` / `ESC[K` | ignored |
| `\n` | row += 1, col = 1 |
| a UTF-8 continuation byte (0x80–0xBF) | appended to the current cell, **does not advance `col`** |
| any other byte | painted at (row, col) with the **current register set**; col += 1 |

`sgrset` is rendered sorted and comma-joined, e.g. `{1,31}`, `{1,7,31}`, `{}`.

**⚑ What this gate cannot prove, stated because it bounds the rows.** It grades
the **emitter's own byte stream** against the SGR state machine above, not
against a real terminal. It does **not** grade `rnd-cols` (E174's Phase 15 owns
that, and E175 changes no width — G7c), nor display width (E177), nor
`r-table`'s two layouts (E178), nor whether the five ad-hoc faces should be in
the registry at all (**E179**), nor an incremental repaint that lands inside a
face (**E180**, which this element *creates* and which is unreachable today).

| row | assertion | named mutant that must convict |
|---|---|---|
| **G1 — NO-OP where the tree already works, ON THE SCREEN** | The live shape at depth 0 — `(r-row [(r-face f (r-text "ab" b)) (r-text "cd" false)])`, over the faces the fourteen live sites actually use (`keyword`, `comment`, `manas-header`, `manas-ok`, `manas-bad`), bold and plain — reduces to a cell map **identical to the pre-E175 golden pinned literally in the script**. Measured golden for `keyword`: `5 1 a {1,31}` · `5 2 b {1,31}` · `5 3 c {}` · `5 4 d {}`. ⚑ **The byte streams are NOT identical and no row may assert that they are** (§2). ⚑ **The trailing unfaced sibling is not decoration**: without a cell painted *after* the faced node, both mutants below paint nothing different and the row is self-matching. | **M1 `plain-seed-is-bold`** — `rnd-face-plain` becomes `(face "default" -1 -1 1)`. **RUN: `5 3 c` and `5 4 d` go `{}` → `{1}`.** · **M2 `restore-forgets-the-reset`** — `rnd-restore`'s body drops `str-cat ansi-reset`. **RUN: every cell after the first faced leaf inherits it — `{}` → `{1,7,31}` across the whole probe.** ⚑ Audit, re-run: `7` can only come from a reverse-video face (`manas-cursor`), which is **not** in this row's stated face list — on a `keyword`-only probe the conviction is `{}` → `{1,31}`. The row keeps its teeth either way; **pin the set the gate's own probe emits, not this literal.** |
| **G2 — the defect itself, through `r-row`** | `(r-face "keyword" (r-row [(r-text "ab") (r-text "cd")]))` at row 3: cells `(3,3)` and `(3,4)` carry `{1,31}`. **Today they carry `{}`.** | **M3 `text-close-resets`** — `r-text`'s close reverts to `(put ansi-reset)`. **RUN: `(3,3)`/`(3,4)` go `{1,31}` → `{}`.** ⚑ Note what this mutant proves: it **passes** any fix scoped to the `r-face` arm, which is §1's whole point. |
| **G3 — the same defect without `r-row`, through `r-lines`** | `(r-face "keyword" (r-lines [(r-text "ab") (r-text "cd")]))` at rows 7/8: cells `(8,1)` and `(8,2)` carry `{1,31}`. Proves the fix predates and outlives E174. | **M3**, the same mutant. **RUN: `(8,1)`/`(8,2)` go `{1,31}` → `{}` in the same pass.** |
| **G4 — the JOIN, and it needs TWO shapes each with a TWO-leaf inner face** | ⚑ `face-join` feeds `rnd-restore` and **nothing else** — an open is always `face-sgr` of the *looked-up* face, never the join. So the only cell that reads a join is **the leaf after another leaf inside the same inner face**; the first leaf is painted straight off the two opens and carries the right set on the **unfixed** tree too. **An inner face with one leaf grades nothing.** Two shapes, because the fg rule and the attrs rule are convicted by different inner faces. **(a)** `(r-face "keyword" (r-row [(r-face "comment" (r-row [(r-text "xy") (r-text "zw")])) (r-text "pq")]))` — `x,y,z,w` = `{1,32}`, `p,q` = `{1,31}`. **(b)** the same with `manas-cursor (-1 -1 8)`, an inner face with **no fg opinion** — `x,y,z,w` = `{1,7,31}`, `p,q` = `{1,31}`. Unfixed, `z,w,p,q` are `{}` in both. All four maps measured. | **M4 `join-drops-the-attrs`** — `(bor oat iat)` → `oat`. **RUN: (a) `z,w`→`{32}`, `p,q`→`{31}`; (b) `z,w`→`{31}`, `p,q`→`{31}`.** · **M5 `join-keeps-the-outer-fg`** — the colour rule → `ofg`. **RUN: (a) `z,w`,`p,q`→`{1}`; (b) `z,w`→`{1,7}`, `p,q`→`{1}`.** · **M6 `join-keeps-the-inner-fg`** — the colour rule → `ifg`. **RUN: shape (a) is COMPLETELY UNCHANGED and only (b) convicts, `z,w`→`{1,7}` — which is why shape (b) is not optional.** |
| **G5 — depth 0 emits exactly `\e[0m`** | ⚑ **Raw bytes, not the cell map**: a trailing SGR paints no cell, so the tracking reducer cannot see this row at all. The stream's final four bytes are exactly **`27 91 48 109`** — no trailing `\e[m`, no doubled parameters, nothing after. Measured on the fixed tree. | **M1 `plain-seed-is-bold`**, read here as bytes rather than cells: the tail becomes `27 91 48 109 27 91 49 109`. **RUN** (the same mutant tree as G1). |
| **G6 — `r-hole` is unchanged** | ⚑ **Raw bytes, and this row exists BECAUSE the cell map cannot see it.** In `(r-face "keyword" (r-lines [(r-hole "h") (r-text "ab")]))`, the bytes between `<?>h` and the next `ESC[<r>;<c>H` number **zero**. The control that shows the edit was not a blanket `sed`. | **M7 `hole-restores-too`** — `r-hole`'s `(put "")` becomes `(rnd-restore amb)`. **RUN, and the finding under it is the row's justification: the CELL MAP IS BYTE-FOR-BYTE IDENTICAL under this mutant** (because the restore there re-asserts the face already on), while the raw stream gains `@[0m@[1m@[31m` in that gap. A cell-map-only gate would call this element done. |
| **G7 — the neighbouring gates hold** | **(a)** sha256 pins on **five** files: `tools/test/diag.sh`, `samples/e157_diag.prog`, `tools/test/doc.sh`, `samples/e158_doc.prog` and **`samples/e174_row.prog`** — E175 touches none of them. ⚑ **`row.sh` itself is deliberately NOT pinned**, because E175 edits it (decision 8); what stands in for a pin is (c). **(b)** Phases 13, 14, 15 **and 16** are registered in `run-tests.sh` — **four rows**, asserted `row.sh`'s way (`reg() { grep -cE "^run_phase $1 .* $2\$" "$3"; }` run against `run-tests.sh`, **a different file from the script doing the grep**, which is what makes a registration row unable to match its own source). **(c)** **No seven-argument `render-to-ansi` call survives anywhere under `tools/`** — the arity check that replaces `row.sh`'s missing pin. | **M8 `move-a-pinned-gate`** — append one line to a **copy** of each of the five pinned files; **every** pin must move (pinning four while exercising one is the same hole one file smaller). · **M9 `unregister-the-phase`** — delete all four `run_phase` lines from a copy of `run-tests.sh`; every registration row must notice. Both are `row.sh`'s own devices, green in the live suite today (`:655-690`). · **M12 `a-seven-arg-caller`** (below) is what reddens (c). |
| **G8 — the nine signatures moved TOGETHER** | **Behavioural, not grep.** Three separate compiles, each on a copied `lib/` with one thing changed and nothing else. **(i)** Drop `Face` from **one** walker's `declare` → `protocol/render` must FAIL. **(ii)** Drop `amb` from **one** walker's `lam` binder → `protocol/render` must FAIL. **(iii)** A **seven-argument** caller **carrying its declared result type** — the pre-E175 `row.sh:236` shape, i.e. `(declare ez-alone (=> Rendering I64 Unit))` beside `(def ez-alone (lam (nd rw) (render-to-ansi nd ez-dims none rw 1 rw 1)))` — must FAIL. The arity is the coverage check here, the way the closed sum is `row.sh`'s. ⚑ **The `declare` is load-bearing and the row is TOOTHLESS without it** (audit, measured): chirality is curried, so a bare seven-argument call bound to `_` in a `let` is a **partial application of type `(=> Face Unit)`** and **compiles clean** — `chirality check` returns OK on it. The mismatch is detectable only where a declared `Unit` result contradicts a function type. Write M12 as the declared shape or G8(iii) exercises nothing. | **M10 `declare-drops-the-face`** — **RUN: `load: lambda checked against a non-function type`.** · **M11 `binder-drops-the-amb`** — **RUN: `load: unknown name amb`.** · **M12 `a-seven-arg-caller`** (the **declared** shape — see (iii)) — **RUN: `load: type mismatch`.** All three convict, and each with a *different* message, so a row cannot pass by reading the wrong failure. |

**Registration:**
`run_phase 16 "ambient face restore (E175 face-join + rnd-restore)"  face.sh`
beside `run-tests.sh:221`, plus the header line at `:10-27` and a row in
`tools/test/MIGRATION-NOTES.md`'s "New here" table. **An unregistered script
never runs.**

**Fixture placement follows E174:** the probe nodes are spelled **once** in
`tools/test/samples/e175_face.prog` and interpolated into the emit probes written
outside the source tree, so the measured cell maps and the measured raw bytes
cannot be reading two different fixtures.

**Not gate rows, deliberately, and each says where it lives:**
- **Any byte-identity row for the live consumers.** It is **false** (§2) and a
  row asserting it could never go green. G1 is the screen row that replaces it.
- **A `rnd-cols` invariance row.** E174's Phase 15 grades that, and it was **run
  green (41/41) against the fixed tree** — a row here would grade it twice, which
  is the double-grading E174's SPEC already refuses.
- **A name-census row.** `row.sh`'s G8 reads the names **out of
  `render.chiral`**, so it censuses `face-join`, `rnd-face-plain` and
  `rnd-restore` without editing anything — measured going from 73 names to **76**
  and staying green. A second census here would grade it twice.
- **Any fixpoint `cmp`.** It does not fire (decision 13), and stability is not
  correctness.
- **Anything about the five ad-hoc faces (E179), an incremental repaint
  (E180), display width (E177) or `r-table`'s layouts (E178).**

## 6. Residue & links

- **Corrections this SPEC applies to the example** (a spec run does not edit the
  example; the fixes are in §2/§3/§5):
  1. **⚑ `row.sh` needs FOUR edits, not three, and the example's own two rows
     contradicted each other.** Its §6 named `:236,241,305` and its G7 said
     `row.sh` passes with "its three probes' only edit being the added
     `rnd-face-plain` seed". `tools/test/row.sh:595` is M10's `sed` expression
     and it matches `render-section`'s body line verbatim; E175 rewrites that
     line, the pattern goes stale, and `mutlib`'s guard turns Phase 15 red
     **because the fix worked**. **§3 decision 8, §4 commit 1.**
  2. **⚑ `render-to-ansi-delta` needs no seed.** The example lists "two seeds …
     `render-to-ansi-full` (`:725`) and … `-delta` (`:733`)". `-delta`
     (`:733-737`) calls `render-to-ansi-full`, which seeds; there is **one** seed
     site, and it is `:729`, not `:725` (which is the `def` line). **§3 decision
     6.**
  3. **⚑ The SGR-tracking reducer must model fg and bg as REGISTERS.** The
     example specifies "`row col bytes sgrset` per painted cell" without saying
     how the set is maintained. Measured: a naive set-union reducer reports
     `{1,31,32}` for G4 shape (a)'s first leaf, not the `{1,32}` the example
     states — the outer's `31` never leaves the set when the inner emits `32`.
     Every one of the example's expected sets requires the register model.
     **§3 decision 12, §5's reducer table.**
  4. **The `oat` mutant convicts more widely than stated.** The example's G4 row
     gives M4's conviction for shape (b) as `z,w`→`{31}`. Measured, **`p,q` move
     too** (`{1,31}` → `{31}`). Not a contradiction, and the row is written to
     assert the whole map rather than two cells.
  5. **The NEEDS-AUTHOR item's blast radius is smaller than the brief says.** An
     attrs clear-mask on `Face` would **not** ripple into `apc.chiral` — the
     codec transports the face **name**, a `Str` (`:115`, `:276`). The `(face …)`
     constructor is applied at **twelve sites, all inside `render.chiral`** —
     `default-faces`' eleven rows plus `lookup-face`'s `nil` synthesis (`:163`);
     the spec run said 11 and the audit recounted. **All twelve are in one
     module, which is the load-bearing half and is unaffected. §3, the
     NEEDS-AUTHOR block.**
  6. **`docs/examples/INDEX.md:136` still carries the withdrawn byte-identity
     claim.** The example audit stripped it from the catalog and ledger rows
     (`3d3e931`) and from the example's own body, but the INDEX row still reads
     *"every live consumer's bytes are unchanged"*. **§4 commit 3** corrects it.

- **Verified correct, against the brief's "verify, don't trust":** the four-node
  probe reproduces the example's finding 1 **byte for byte** · six close sites at
  `:569, 610, 624, 687, 705, 721`, five ad-hoc · `r-hole` (`:713`) emits no SGR ·
  **14** live `r-face` sites, every one over a single `r-text`, none nesting ·
  nine signatures at `:97, 101, 103, 105, 107, 109, 111, 115, 117` · **21** call
  sites, all in one file · `face-sgr` of the plain face is `""` (probe A's tail is
  `@[0m@[0m`) · **41** `render-to-ansi-full` sites in `prog/`, **0** `-delta`,
  **0** bare `render-to-ansi` · `diag.sh` and `doc.sh` name `render-to-ansi`
  nowhere · `face-join`, `rnd-face-plain`, `rnd-restore` have **zero**
  occurrences of any kind across `lib prog tools` (`grep -R`) · `CONFORMANCE-MAP`
  has **0** rows for E174–E180 · E177/E178/E179/E180 all have catalog **and**
  ledger rows · Phases 8–12 are names still owed, 13/14/15 taken, so **16** is
  free · the suite is **211 passed, 0 failed, exit 0** today ·
  `prog/compiler.prog`'s blob is 16 161 lines with **zero** occurrences of
  `render-to-ansi` / `r-text` / `face-sgr` / `ansi-reset`, its lone `r-face` hit
  being a comment at blob `:2176` from `lib/prelude/doc.chiral:182`.

- **⚑ RUN log — the scratch trees, and what each command printed.** Built under
  `/workspace/`, outside the repo, and **torn down** after; nothing in `/tmp`.
  1. **The full §4 change was applied and compiled.**
     `./bin/chirality check lib/protocol/render.chiral`-equivalent (a bare root
     importing `protocol/render`, compiled with `bin/chirality-bin`) → **OK**.
  2. **The whole suite was run against it.** With `lib/` replaced by the patched
     copy and `row.sh` carrying exactly the four edits of decision 8:
     **`assertions: 211 passed, 0 failed`, `chirality test: gate PASSED`;
     Phase 13 `30`, Phase 14 `26`, Phase 15 `41 passed, 0 failed`.**
  3. **`prog/` needs no edit.** `prog/scriba/scriba-main.prog`,
     `prog/scriba/samples/t6_apc_roundtrip.prog` and `prog/compiler.prog` all
     compiled **OK** against the patched `lib/`, unedited.
  4. **The before/after cell maps** are in §2, reduced by the register-model
     tracker: exactly six cells move, all of them cells the defect loses.
  5. **The G4 shapes were built and measured on both trees.** Fixed: (a)
     `x,y,z,w` `{1,32}` / `p,q` `{1,31}`; (b) `x,y,z,w` `{1,7,31}` / `p,q`
     `{1,31}`. Unfixed: `z,w,p,q` `{}` in both.
  6. **Ten mutants were executed**, each against a copied `lib/` with one change:
     **M1** `plain-seed-is-bold` (G1 cells → `{1}`; G5's tail gains `27 91 49
     109`) · **M2** `restore-forgets-the-reset` (SGR leaks across the whole
     stream; ⚑ audit: the `{1,7,31}` G1's row quotes is the *combined* probe
     stream, which carries a reverse-video face — re-run on a `keyword`-only
     shape the conviction is `{}` → `{1,31}`. The row must pin the set ITS OWN
     probe emits) · **M3** `text-close-resets` (G2's `(3,3)`,`(3,4)` and G3's
     `(8,1)`,`(8,2)` → `{}`; G4's `z,w` → `{}`) · **M4** `join-drops-the-attrs` ·
     **M5** `join-keeps-the-outer-fg` · **M6** `join-keeps-the-inner-fg`
     (**shape (a) unchanged, only (b) convicts** — the reason G4 has two shapes)
     · **M7** `hole-restores-too` (**cell map identical, raw bytes differ** — the
     reason G6 is a byte row) · **M10** `declare-drops-the-face`
     (`load: lambda checked against a non-function type`) · **M11**
     `binder-drops-the-amb` (`load: unknown name amb`) · **M12**
     `a-seven-arg-caller` (`load: type mismatch`). **M8** and **M9** were not
     re-run here because they are `row.sh`'s own devices verbatim (`:655-690`),
     green in today's live suite.
  7. **⚑ One trap the RUN log owes the implement run.** The first attempt built
     the scratch repo with `lib` as a **symlink** to the patched tree.
     `mutlib`'s `cp -a "$REPO/lib" "$MUTLIB"` then copied the *symlink*, so every
     `sed -i` wrote **through it into the tree under test**, and the suite
     reported nineteen failures that were entirely artefacts — including a
     `Rendering` that had silently grown a tenth constructor. **Use a real
     directory copy for any scratch tree a `mutlib`-shaped harness will run
     against.**

- **Deliberately unbuilt (each named, none parked on a phantom):**
  - **The five ad-hoc `ansi-bold` faces, and `lookup-face`'s synthesis for an
    unknown name** — **E179** (`SELF-IMPLEMENT-CATALOG.md:443`,
    `LEDGER.md:298`), minted `3d3e931`. E175 fixes their closes and leaves them
    ad-hoc.
  - **Face-aware incremental redraw** — **E180** (`:444`, `LEDGER.md:299`),
    minted `3d3e931`. **E175 creates it**; it is unreachable today because
    `render-to-ansi-delta` (`:733-737`) is a full redraw.
  - **An attrs clear-mask on `Face`** — decision 14's option (ii). **Recorded,
    not deferred: there is no row, and the AUTHOR has ruled that none is minted**
    (`6a5ffa2`) — a face that can say *not bold* is a new requirement, not
    residue E175 incurs. ⚑ **The audit second-guessed that call and agrees, with
    one measurement the ruling did not need but is stronger for:** the *open* has
    always been a delta — `face-sgr (face "default" -1 -1 0)` is `""` — so the
    body of a `"default"` face inside a `keyword` renders bold **today**, before
    E175. E175 changes only the CLOSE, where it removes an *accidental* clear
    that nothing in the tree relies on (14 live `r-face` sites, all single-leaf,
    none nesting, and no `"default"` construction outside `default-faces`). The
    inability of a face to turn an attribute off is therefore **pre-existing and
    unchanged**, not incurred here. Minting a row for it would be a phantom in
    the other direction.
  - **Deleting the dead `prev` slot** — real, unrelated, and doing it inside E175
    would make G1 grade two changes at once (decision 7). Not an element.
  - **`r-hole`'s dead `(put "")`** (`:713`) — E174's residue, and E175's control.
  - **⚑ A stale E175 claim in LIVE SOURCE, found by the audit and recorded with
    its cost.** `lib/prelude/doc.chiral:182` reads *"E175 (nested `r-face` resets
    rather than restores)"* — the **withdrawn nesting framing**, in the same
    comment that names E158 commit 4 as blocked on E174 and E175. It is also the
    lone `r-face` hit this SPEC cites at blob line 2176, which is exactly how the
    audit found it. **The cost is measured and it is why this is recorded rather
    than folded into commit 3:** `lib/prelude/doc.chiral` **IS** inside
    `prog/compiler.prog`'s import closure (that is why the comment reaches the
    blob at all), so editing it — comment or not — changes compiler source and
    **trips the self-host obligation decision 13 says does not fire.** Correcting
    one stale sentence would turn a no-fixpoint element into a fixpoint element.
    Named here so it is neither missed nor smuggled in.
  - **Display width (E177)** and **`r-table`'s two layouts (E178)** — both
    minted, both in `render.chiral`, neither touched.

- **Follow-on consumers, in order:** **E158 commit 4** (`doc->rendering`,
  `docs/elements/specs/E158-doc-formatter-SPEC.md` §4) is the forcing consumer and is
  gated on E174 **and** this element — and it hits the **sibling** case, not the
  nested one, so a face-stack fix would have left it broken. Behind it,
  **U16 "the block algebra"** is the user layer's waiting consumer.

- **Tooling state, stated plainly:** `tools/pack/pack.py` **cannot run this
  element's pipeline** (it probes `examples/`, this tree has `docs/examples/`,
  and `tools/pack/MIGRATION-NOTES.md` records it as not repointed on purpose).
  So the deterministic status flip did not happen either: the
  `docs/examples/INDEX.md` row for E175 is flipped `reviewed → specced` **by
  hand** in the same commit as this file, with the SPEC link appended, matching
  E157's, E158's and E174's row shape. Nothing was repointed at a guess.

- **Related:** [[E174-r-row-width]] (built; supplies the `r-row` that makes the
  defect reachable a second way, and whose `rnd-cols` is provably — and now
  measurably — invariant here) · [[E158-doc-formatter]] (commit 4,
  `doc->rendering`, the forcing consumer, whose tags are **siblings**) ·
  [[E157-typed-diagnostics]] (`dg-doc`'s `Reason` sum, whose gate must not move)
  · [[pattern-boundary-sums]] (why the dead `prev` slot is not repurposed, and
  why a magic `"default"` is refused) · [[E112-apc-sidechannel]] (the codec that
  carries the face **name** and is therefore untouched). Elements: **E174** ·
  **E158** · **E157** · **E177** · **E178** · **E179** · **E180** · **E112**.


---

## Author decision on decision 14 (2026-08-31) — RESOLVED, option (i), nothing minted

**`-1` means *no opinion*. §4's choice stands, and it is a complete answer rather
than a stopgap.**

**(iii) is refused outright.** Treating the literal name `"default"` as
reset-to-plain is a magic string deciding behaviour — a `Str` carrying a
which-of-N, which `pattern-boundary-sums` exists to forbid. This arc has already
refused that move twice (SGR-in-`r-text` for E174, `from Str` on `r-relayed` for
E158). Refusing it a third time is consistency, not caution.

**(i) is chosen because it is coherent, not because it is cheap.** Under delta
semantics "unset" meaning *inherit* is the same rule CSS settled on, and it is
what `face-sgr` already implements — the open has always been a delta. Option (i)
is therefore not a compromise: it is naming the semantics the emitter already
has, which is exactly what this element does at the close.

**(ii) — a fourth `Face` field carrying an attrs clear-mask — is NOT minted, on
purpose, and this is the interesting half.** The deferral rule forbids naming
follow-on work without a row; it does not require inventing rows for capabilities
nobody has asked for. "A face can say *not bold*" is a **new requirement**, not
residue of this change: no consumer nests today, none has wanted to un-set an
attribute, and E175 does not make anything worse in that direction — before it,
the close reset everything, so "not bold" was reachable only by accident and only
at the cost of the bug being fixed here. **Requirements are not residue.** Minting
a row for it would be a phantom in the other direction: a tracked obligation
nobody incurred, which is its own kind of dishonesty in a ledger.

**The genuinely defective half already has a home.** "`"default"` and a typo'd
name are indistinguishable" is *not* about `-1` — it is `lookup-face`
synthesizing a face for an unknown name instead of failing, which is **E179**
(minted). Splitting the question that way is what makes (i) safe: the part that
is a defect is tracked, and the part that is a wish is not pretended to be one.

**Correction owed to my own brief, recorded because it was load-bearing:** I told
the spec run that option (ii) "would ripple into `apc.chiral`'s codec". It would
not. `apc.chiral` encodes and decodes the `r-face` constructor's first field — a
`Str` face **name** (`:115`, `:276`) — and never a `Face`. The `(face …)`
constructor is applied at **twelve** sites — `default-faces`' eleven rows (`:145-157`)
plus `lookup-face`'s `nil` synthesis (`:163`) — all inside `render.chiral`. *(11 →
12 corrected at the spec audit, FLAG A. The load-bearing half is "all inside
`render.chiral`", which holds; the ruling above explicitly does not rest on the
count, and does not change.)* The real blast
radius is one module. I inflated the cost of the option I then declined; the
decision above does not rest on that cost, and stands without it.


---

## SPEC audit (2026-08-31) — the implement-ready gate

**Verdict: PASS.** Charter run by hand in `/workspace/chirality-verify` @ `e158-doc`
(`6a5ffa2`); `tools/pack/pack.py` still probes `examples/` and was **not**
repointed. Findings applied in place above are marked *(audit …)* at the point of
the claim; nothing author-tier was resolved.

### ⚑ The "BUILT AND RUN" claim HOLDS — independently re-run, not read

The audit rebuilt the whole §4 change from this file's own instructions into a
**real-directory** copy of `bin lib prog tools` outside the repo, applied the four
`row.sh` edits, and ran the suite. What it measured:

- **`assertions: 211 passed, 0 failed`, `chirality test: gate PASSED`, exit 0.**
  Phase 13 `30`, Phase 14 `26`, **Phase 15 `41 passed, 0 failed`**.
- `chirality check` **OK** on `lib/protocol/render.chiral` and, unchanged,
  `lib/protocol/apc.chiral`.
- `prog/scriba/scriba-main.prog`, `prog/scriba/samples/t6_apc_roundtrip.prog` and
  `prog/compiler.prog` — **all three OK, unedited**.
- `row.sh`'s census: **73 → 76** names, each defined once tree-wide.
- The four-node probe reproduces §2's byte string **exactly**, including
  `@[1m@[31m@[4m@[31m@[5;1Hxy@[0m@[0m@[5;3Hzw@[0m@[0m` for node C.
- §2's before/after cell map reproduces **cell for cell and set for set** — six
  cells move, the six the defect loses, and nothing else.
- The fixed stream's **final four bytes are `27 91 48 109`** (G5).
- **G4's four maps are exact**: fixed (a) `x,y,z,w {1,32}` / `p,q {1,31}`, (b)
  `x,y,z,w {1,7,31}` / `p,q {1,31}`; unfixed `z,w,p,q {}` in both.
- **The `row.sh:595` trap is real.** With the other three edits in place and this
  one omitted, Phase 15 reports **`39 passed, 2 failed`** — the fix reddens the
  gate. (⚑ by a different mechanism than the SPEC stated; corrected at decision 8.)
- **Mutants re-run and convicting exactly as logged:** M1 (`{}`→`{1}`, and the
  tail gains `27 91 49 109`) · M3 (G2 `(3,3)/(3,4)` and G3 `(8,1)/(8,2)` →`{}`;
  G4's `z,w`→`{}`) · M4 ((a) `z,w {32}`, `p,q {31}`; (b) `z,w {31}`, `p,q {31}`)
  · M5 ((a) `{1}`; (b) `z,w {1,7}`, `p,q {1}`) · M6 (**shape (a) COMPLETELY
  unchanged**, (b) `z,w {1,7}`) · M7 (**cell map byte-for-byte identical**, raw
  stream gains `@[0m@[1m@[31m` between `<?>h` and `@[8;1H`) · M10
  (`load: lambda checked against a non-function type`) · M11 (`load: unknown name
  amb`) · M12 (`load: type mismatch`, *with the declared shape* — see G8(iii)).
  M2 convicts (SGR leaks past cells that must be `{}`) with a probe-dependent set.
  M8 and M9 were observed **green in the live suite** rather than re-derived.
- **G1's trailing unfaced sibling is load-bearing, checked by removing it:** on
  the solo shape `(r-face "keyword" (r-text "ab" false))` both M1 and M2 produce
  cell maps **byte-for-byte identical** to the fixed tree. The row would be
  self-matching without it.
- **Decision 13 stands, re-measured:** `prog/compiler.prog`'s blob is **16 161**
  lines with **zero** `render-to-ansi` / `r-text` / `face-sgr` / `ansi-reset`, its
  lone `r-face` hit at blob `:2176` a comment from `lib/prelude/doc.chiral:182`.
  No `C1`, no promotion, no `cmp`.
- Also re-derived: **14** live `r-face` sites (and the two test files only *match*)
  · **41** real `render-to-ansi-full` applications in `prog/`, **0** `-delta`
  (its one textual hit is a comment at `command-loop.chiral:12`), **0** bare ·
  `diag.sh`/`doc.sh` name `render-to-ansi` **nowhere** · `face-join`,
  `rnd-face-plain`, `rnd-restore` at **zero** occurrences across `lib prog tools`
  · `CONFORMANCE-MAP` **0** rows for E174–E180 · E177/E178/E179/E180 carry catalog
  **and** ledger rows at the cited lines · Phase **16** free.

### FIXes applied above

1. **§4 commit 1's placement does not compile.** "the three `def`s after
   `face-sgr`'s body (`:195`)" fails with **`load: unknown name ansi-reset`** —
   `ansi-reset` is an undeclared `def` at `:325`. Tightened to *after the `ansi-*`
   block (`:323-330`)*, with the measurement.
2. **§3 decision 8's mechanism.** Not `mutlib`'s stale-pattern guard (M10's first
   sed still applies, so `cmp -s` passes) — the mutant `lib/` fails to **compile**.
   Conclusion and required edit unchanged; measured `39 passed, 2 failed`.
3. **§5 G8(iii) / M12 was toothless as written.** A bare seven-argument call bound
   to `_` is a **partial application** and compiles clean; only the declared
   `row.sh:236` shape yields `load: type mismatch`. Row now names the `declare`.
4. `rnd-cols`'s `r-face` arm is **`:515`**, not `:513`.
5. `default-faces` has **eleven** rows, not twelve.
6. `(face …)` is applied at **twelve** sites, not eleven (the eleven rows plus
   `lookup-face`'s `nil` synthesis at `:163`) — all in `render.chiral`.
7. `row.sh` helper citations: `build_out` **`:103`**, `mutlib` **`:125-136`** with
   its guard at **`:132-134`**, `SCREEN_AWK` **`:152-177`**, `pin` **`:645-650`**
   (calls `:651-654`).
8. **§4 commit 3's INDEX correction is already done** — `d853c62`, this SPEC's own
   commit, already replaced *bytes* with *SCREEN* at `docs/examples/INDEX.md:136`.
   Left as an instruction it is a stale pattern one document up.
9. §1's and §4's "gain an **eighth** argument" is true only of
   `render-to-ansi`'s callers (`rnd-emit-headers` gains a fourth, `render-table`
   a sixth, …); now "a trailing `Face` argument". §4 also now names the two call
   sites — `:570` and `:578` — where the new argument does **not** go at
   end-of-line, which is a paren-balance trap the audit hit while building it.
10. **The symlink trap is now an OBLIGATION in §4's standing rules**, not a war
    story in §6, with the explicit `[ -L "$SCRATCH/lib" ]` check.
11. §6's M2 conviction `{}` → `{1,7,31}` is probe-dependent (`7` needs a
    reverse-video face, which G1's face list does not carry); qualified.
12. **A stale E175 claim in live source** — `lib/prelude/doc.chiral:182` still
    says *"nested `r-face` resets rather than restores"* — recorded in §6 **with
    its measured cost**: that file IS inside `prog/compiler.prog`'s closure, so
    correcting it inside E175 trips the fixpoint decision 13 says does not fire.
13. **Decision 14's disposition updated** to the author's ruling (`6a5ffa2`).

### FLAG — author-tier, surfaced verbatim, not resolved

> **FLAG A — the two miscounts also appear inside the author's own appended
> decision block, which this audit will not edit.** That block reads: *"The
> `(face …)` constructor is applied at 11 sites, all inside `render.chiral`."*
> Measured at the audit: **twelve** — `default-faces`' eleven rows (`:145-157`)
> plus `lookup-face`'s `nil` synthesis (`:163`). The load-bearing half, *all
> inside `render.chiral`*, is correct, and the ruling explicitly does not rest on
> the cost, so nothing about the decision changes. The author's text is the
> author's to amend.

### On decision 14's option (ii) — the audit was asked to second-guess it, and it agrees

**(ii) is not residue E175 incurs.** The ruling's own argument is right, and one
measurement makes it stronger than it needed to be: the **open has always been a
delta** — `face-sgr (face "default" -1 -1 0)` is `""` — so the *body* of a
`"default"` face nested inside a `keyword` renders bold **today**, before E175.
The inability of a face to turn an attribute off inside its own body is therefore
**pre-existing and untouched by this element**. What E175 changes is the CLOSE,
and there it removes an *accidental* clear that nothing relies on: the census is
14 live `r-face` sites, every one a single `r-text`, none nesting, and no `(face
…)` construction anywhere outside `default-faces` and `lookup-face`. A face that
can say *not bold* is a capability nobody has asked for and nothing exercises —
**a requirement, not residue**, and minting a row for it would be the phantom in
the other direction. The split the ruling makes is also the right one: the half
that IS a defect — an unknown name and `"default"` being indistinguishable — is
`lookup-face` synthesizing rather than failing, which is **E179**, minted.
