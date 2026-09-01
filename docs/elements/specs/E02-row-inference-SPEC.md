---
element: E02
slug: row-inference
title: Effect-row inference — the call-graph monotone closure producing `def_rows` (the sig-driver's row half)
kind: SELF-HOST
example: examples/E02-row-inference.md
status: audited
updated: 2026-08-03
---

# E02 SPEC — Effect-row inference: the call-graph monotone closure producing `def_rows`

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
>
> **Scope note.** This is the deferred E2 §6 slice ("Effect-row inference
> `_infer_row`/`_elab_stamped` — E39-coupled"), now unblocked (E39's row carrier
> is built scaffold-side). It is the **row half of the sig-driver**: the pure
> chirality-side derivation of `def_rows` that E70's floor gate + preserve-check
> (`lib/eff-lower.chiral`) currently take as a *given* input. It does NOT build
> the signature representation that carries `def_rows` for `lower-all` to
> consult, nor the loader that fills the closure's inputs — those are named
> sibling slices (§3, §6). Same shape as the E70 port slices: a pure computation
> over given loader data, differential vs its Python original.

## 1. Deliverable

- **After this runs:** `lib/row-infer.chiral` exists, exporting
  `infer-row : (-> RowSig Str (List Str))` — the monotone call-graph closure
  that, given a signature view `RowSig` (the port-crossing set, the syntactic
  call graph, and the already-final rows of earlier globals) and a def name,
  returns that def's **effect row**: the sorted, de-duplicated set of crossings
  it transitively performs. Ports `surface.py._infer_row` (:113). This is the
  producer of `def_rows`, the input `lib/eff-lower.chiral`
  (`eff-gate`/`row-check`/`sysface`) and E51 consume.
- **Non-goals (residue in §6):**
  - the **sig representation** that carries `def_rows` (+ `sys-bindings` + port
    classification) so `lower-all` consults it — the sig-driver's *other* half
    (a `SigV` extension or a bridged `RowSig` view; DEFERRED, §3#1);
  - **building the closure's inputs** — `_calls` (the elaboration write-back
    that records each call) and `prim_is_port` (the kernel eff-bit seed); this
    slice takes them as given `RowSig` fields (DEFERRED, §3#2);
  - `_elab_stamped`'s **stamping the row onto the type's effect arrows** (the
    write-back into the elaborated `Core` — a separate slice, §3#4);
  - **cross-unit stamping order** for mutual-recursion SCCs (the elaboration
    driver's job; the *closure itself* handles intra-unit mutual recursion —
    §3#3);
  - DYN row polymorphism at the floor (never arises; E69 defunctionalizes it).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** E2 "Surface elaborator" is **CONFORMS / M** —
  "Fully built; elab/resolve, arrow/lam/let/case/do/cond/the/refine." The chirality
  port `lib/surface.chiral` (321 lines) is the elab/resolve **core**; its E39-
  coupled row-inference slice was explicitly deferred (E2 SPEC §6 / this
  element). The row *carrier* is E39 (scaffold "carrier edit BUILT 2026-07-28";
  `surface.py._infer_row`/`sig.def_rows`/`row_of` are live — verified this
  session, and consumed by the built scaffold E70 in `lower.py`). So the
  algorithm being ported is present and stable in Python; only its chirality image
  is missing.
- **Live code this composes with (do NOT respec):**
  - `surface.py._infer_row` (:113) — the oracle: a `seen`/`stack`/`names`
    worklist; `prim_is_port` name → leaf contributing itself; already-final
    `def_rows[n]` (with `n != name`) → leaf contributing its row; else expand
    `_calls[n]`; `discard(ROW_DYN_NAME)`; `row_of` (sorted canonical).
  - `lib/eff-lower.chiral` (E70 slices, 183 lines) — the **consumer**: `dr-get`,
    `keep-in`, `row-check`, `eff-gate`, `sysface` all read `def_rows`/rows as
    `(List (Pair Str (List Str)))` / `(List Str)`. `infer-row`'s output shape
    (`(List Str)`, sorted) must match what these consume.
  - `lib/effects.chiral` (E12) — `row-join` (dedup union), `mem-str`; reused for
    the leaf accumulation. `lib/ty-cmp.chiral` (D-1) — the byte-lex `str` order
    to compose `row-of`'s canonical sort (`str->bytes`+`bget`, no new primitive).
  - `lib/surface.chiral` — the E2 elab port whose `SEnv` (`se-prims` etc.) and
    forthcoming call-recording will eventually *fill* `RowSig` (the deferred
    driver, §3#2); this SPEC does not touch it.
- **True delta:** one new leaf module `lib/row-infer.chiral` — the `RowSig` view,
  the `infer-row` worklist closure, and `row-of` — plus its differential test.
  Nothing existing changes.

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | The sig-driver's second half — does the chirality sig carry `def_rows` as a `SigV` extension or a new bridged `RowSig` view? | **DEFERRED → sibling slice (sig-driver, row-representation half)** | Out of this slice's scope by construction: `infer-row` is defined over a *given* `RowSig` (ports/calls/stamped as immutable data), exactly as the E70 slices took `def_rows`/`crossing_sigs` as given. Which carrier `lower-all` reads (extend E69's `SigV` vs. bridge a `RowSig`) is a representation decision the *wiring* slice makes; deciding it here would front-run it. Homed with the E70 gate-wiring follow-on. |
| 2 | How `_calls` / `prim_is_port` are built chirality-side. | **DEFERRED → the E2 elab-port driver (`_calls`) + kernel eff-bit (`prim_is_port`)** | `_calls` is the syntactic call graph accumulated during elaboration (`surface.py._scan_unit`:98 records callees); its chirality home is the `lib/surface.chiral` elab write-back. `prim_is_port` is OR-ed over each arrow's eff field at `declare_extern` (`kernel.py:586-592`); its chirality home is the kernel port classification. Both are given `RowSig` fields here, bridged from a real loaded sig in the test — the same "given loader data" posture E69 slice-3's `SigV` and the E70 slices used. |
| 3 | Mutual-SCC iteration — does the closure need a joint fixpoint? | **RESOLVED — no iteration; the seen-set transitive closure already yields the SCC's joint row** | `surface._infer_row` does NOT iterate: per name it runs one `seen`-bounded transitive closure, so for a mutual pair `f↔g` (neither yet stamped) it expands `f→g→f`, dedups via `seen`, and accumulates every reachable port — which *is* the shared fixpoint row (mutually-reachable defs have identical reachable-port sets). The only SCC concern is *cross-unit stamping order* (whether a callee is a stamped leaf or expanded), which is the elaboration driver's, not the closure's (§3#2 / §6). The example's "iterate to a joint fixpoint" phrasing is corrected here: the closure is single-pass. |
| 4 | `_elab_stamped`'s row write-back (stamping the row onto the type's effect arrows). | **DEFERRED → a row-stamping write-back slice** | `_elab_stamped` (:135) does two things: record `def_rows[name] = row` (the driver's bookkeeping, §3#2) and stamp the row onto the elaborated type's effect arrows during `elab`. The stamping mutates elaborated `Core` and belongs with the elab-port write-back, not the pure inference. This slice delivers only the row *computation*. |

No NEEDS-AUTHOR blockers — all dispositioned RESOLVED or DEFERRED to a named home. Frontmatter `status: draft`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — the `RowSig` view + `row-of` canonical form
- **Target:** `lib/row-infer.chiral` (NEW) — `(import "prelude")`, `(import "effects")`
  (`row-join`/`mem-str`), and the byte-lex `str` order (compose `str->bytes`+`bget`
  per D-1's `ty-cmp`; a local `str<`/`str-cmp` helper — no new primitive).
- **Change:** the `RowSig` datatype
  `(rowsig (ports (List Str)) (calls (List (Pair Str (List Str)))) (stamped (List (Pair Str (List Str)))))`;
  its field-read helpers (chirality has no auto-accessors — `rowsig-ports`,
  `callees` = assoc `calls`→`(List Str)` or nil, `stamped-row` = assoc `stamped`
  guarded by `n != name` → `(Maybe (List Str))`, `node-count` = the fuel bound);
  and `row-of : (-> (List Str) (List Str))` = discard `ROW_DYN_NAME` (`"*"`),
  insertion-sort by byte-lex `str<`, dedup. `row-of` is the canonical normal
  form (the determinism property).
- **Size:** ~M.

### Step 2 — the `infer-row` worklist closure
- **Target:** `lib/row-infer.chiral` (same file).
- **Change:** adapt the example §5 snippet verbatim — `infer-row` seeds
  `(irow sg name (node-count sg) (cons name nil) nil nil)` and wraps in `row-of`;
  `irow` (the `(stack seen names)`-threaded worklist, fuel = measure) skips
  `seen`, else `irow-visit`; `irow-visit` classifies `n`: a `rowsig-ports`
  member → `(cons n names)` leaf; else `stamped-row sg n name` → `(row-join r
  names)` leaf; else expand `(append (callees sg n) rest)`. Totality: `seen`
  strictly grows on every non-skip step, bounded by `node-count`, so it
  terminates by that numeric measure (E11).
- **Size:** ~M.

### Step 3 — the differential test
- **Target:** `scaffold/tests/test_row_infer_chirality.py` (NEW).
- **Change:** load `lib/row-infer.chiral` into the RT; bridge a real loaded
  signature's `prim_is_port` / `_calls` / `def_rows` into a `RowSig` RT value
  (as E69's test bridges a real sig into `SigV`); for a corpus of names, assert
  `unlist(infer-row(sg, name)) == surface._infer_row(name)` (the REAL oracle),
  and assert the chirality output is already sorted+deduped (the canonical property).
- **Size:** ~M.

## 5. Conformance gate

- **Golden behavior:** for every def in the corpus, `infer-row(sg, name)` equals
  `surface._infer_row(name)` **byte-identically as a sorted list**, and the
  chirality output is already canonical (sorted, de-duplicated, DYN-free) with no
  Python-side re-sort needed.
- **Tests to add (`scaffold/tests/test_row_infer_chirality.py`, NEW):** a corpus
  spanning every closure path —
  1. a **port leaf** (a def calling one crossing extern → `{crossing}`);
  2. an **already-stamped-global leaf** (a def calling a stamped global → its row);
  3. a **transitive chain** (`f→g→h→port`, none stamped → the port);
  4. a **self-recursive** def (the `n != name` guard — must expand, not read a
     half-built row);
  5. a **mutual-recursion pair** `f↔g` (§3#3 — both yield the same joint row);
  6. a **DYN discard** (a `*`-containing source → `*` absent from the result);
  7. an **empty (`->`) row** (a pure def → `nil`).
  Differential vs `surface._infer_row` (the RT floor vs the Python oracle).
- **Green line:** 523 → ≥ 530 (Step 3 adds ~7 test functions); the pure suite
  stays green (additive, new leaf module); `ledger-lint` clean.
- **Done when:** `infer-row` reproduces `surface._infer_row` on the corpus and
  its output is canonical — so `lib/eff-lower.chiral` could consume a
  chirality-derived `def_rows` unchanged.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - *The sig-representation carrying `def_rows` + wiring `eff-gate`/`row-check`
    into `lower-all`* — the sig-driver's second half (§3#1); the E70 gate-wiring
    follow-on.
  - *Building `_calls` (elab write-back) + `prim_is_port` (kernel eff-bit)* —
    the `lib/surface.chiral` elab-port driver + kernel port classification (§3#2).
  - *`_elab_stamped`'s stamping the row onto `Core` effect arrows* — a row-
    stamping write-back slice (§3#4).
  - *Cross-unit SCC stamping order* — the elaboration driver / [[E79]] groups.
- **Follow-on:** unblocks the E70 gate/row-check *wiring* (once a sig carries the
  derived `def_rows`), which unblocks native self-emission → the Stage1==Stage2
  fixpoint.
- **Related:** [[E02-row-inference]] (the rationale), [[E39-effect-row]] (the row
  carrier this fills), [[E70-effectful-lowering]] (the consumer —
  `eff-gate`/`row-check`/`sysface`), [[E51-sys-linkage]] (sys-bindings/ports),
  [[E79]] (mutual data / SCC groups — cross-unit ordering), [[E11]] (the
  numeric-measure termination the fuel bound uses), D-1 `ty-cmp` (the byte-lex
  `str` order `row-of` composes).
