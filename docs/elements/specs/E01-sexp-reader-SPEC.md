---
element: E01
slug: sexp-reader
title: S-expression reader (lexer/parser)
kind: SELF-HOST
example: examples/E01-sexp-reader.md
status: audited
updated: 2026-07-31
---

# E01 SPEC — S-expression reader (lexer/parser)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a new `scaffold/lib/sexp.chiral` — a total, pure,
  byte-directed S-expression reader in chirality source that, run on the RT
  interpreter, reproduces `scaffold/chirality/sexp.py`'s golden reading behavior:
  the same `Sexp` tree for every valid fixture and an `r-err` value (not a
  throw) on exactly the inputs `sexp.py` rejects.
- **Non-goals:**
  - Does **not** delete or wire-in `sexp.py`. The map row says E1 is
    *superseded (not deleted) by E49*; `sexp.py` stays as the bootstrap reader
    **and** the differential oracle until the front end actually switches (a
    downstream E2-integration concern). This SPEC validates the chirality reader,
    it does not make it *the* reader.
  - Does **not** implement the real human-facing concrete syntax — that is E49.
    E1 is the s-expression transcription only.
  - Does **not** carry source line numbers inside tree nodes (see decision #2).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** `CONFORMS · S · E1` — "Scaffold reader;
  superseded (not deleted) by E49 / Complete for scope; every lib parses through
  it. Regularity=P4." CONFORMS means the *frame* is settled: this is a faithful
  transcription of a complete artifact, not a reshape. The audit gate already
  passed the example; no decision is being re-argued.
- **Live code this composes with (do NOT respec):**
  - `scaffold/lib/prelude.chiral` — the whole floor: `List`/`Pair`/`Maybe`/`Bool`
    data; I64 externs `+ - * / % =i <i <=i` (note: **no `>`/`>=`** — only these
    three comparisons exist); `Bytes` externs `blen bget bslice bcat pack-u32 …`;
    `Str` externs incl. `str-len`, `str->i64` (documented "junk parses to 0"),
    `str->bytes`/`bytes->str`; `not`/`and`/`or`/`if`.
  - `scaffold/lib/json.chiral` — the **proven in-tree idiom** this mirrors: a
    fused byte-directed recursive-descent parser returning result sums
    (`data PR/SR/LR/FR`), with `code`/`c-*` byte constants (`json.chiral:24,28`),
    `skip-ws` (`:111`), `scan-string`/`scan-escape` (`:241,218`), the
    `parse-value` spine (`:315`), and the `json-parse-str (-> Str …)` top-level
    (`:340`). `code` is **json-local, not a prelude export** — sexp.chiral defines
    its own.
  - `scaffold/chirality/sexp.py` — the golden oracle: `read_all` (`:22`, returns a
    list of `(form, line)`), `_tokenize` (`:33`), `_parse` (`:75`).
- **True delta:** one new library file. The recursive-descent-over-`Bytes`,
  result-sum-with-position, structural-recursion idiom is already established by
  `json.chiral`; E1's *new* content is the s-expr-specific tokenization (trivia +
  `;` comments, the atom delimiter set, the int-vs-symbol classifier) and the
  `Sexp` tree shape.

## 3. Decisions

Every §6 open question is decidable from the golden oracle + the established
idiom — none is author-tier (values/taste/scope). `status: draft`, not blocked.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Single `read-form` or a streaming `read-all` (list of toplevel forms)? | **RESOLVED — both** | The golden public API *is* `read_all` (`sexp.py:22`), which the elaborator consumes; `read-form` is its recursive core. Mirror the pair, plus a `read-all-str (-> Str …)` convenience exactly as `json-parse-str` (`json.chiral:340`) wraps `json-parse` (`:335`). Not taste — the API is fixed by the oracle. |
| 2 | Keep line numbers in the tree, or only in errors? | **RESOLVED (E1) + DEFERRED (E2)** | `sexp.py` puts line numbers *beside* forms (`read_all` returns `(form, line)`) and in errors — **never inside tree nodes**. E1 mirrors: `Sexp` nodes carry no line; the result sum carries a byte `pos`. Whether E2 diagnostics want richer per-form source positions (line vs byte-pos) is a downstream, additive question → **DEFER to [[E02-surface-elaborator]]**. |
| 3 | Fuse the tokenizer into the parser, or keep a separate token pass to mirror `sexp.py` 1:1? | **RESOLVED — fuse (byte-directed)** | `json.chiral` proves the fused idiom works and is the in-tree standard; the conformance diff runs on the **tree**, which the fused parser reproduces identically, so a separate `List Token` pass buys nothing but an allocation. Matches example §4's "no intermediate mutable token list." |
| 4 | *(surfaced by the golden body)* What exactly counts as an i64 atom vs a symbol? | **RESOLVED — `-?[0-9]+`, with a named limit** | `sexp.py` classifies by Python `int(val)` succeeding. `str->i64` cannot classify ("junk→0"), so the port needs its own predicate: nonempty, optional single leading `-`, all remaining bytes digits. Python `int()` additionally accepts `+5`, `1_000`, surrounding whitespace; those exotic spellings are **out of scope** and named as an honest conformance limit — the fixture corpus uses plain integers. |

## 4. Change plan (ordered, commit-sized)

### Step 1 — tree + result sums + byte constants
- **Target:** `scaffold/lib/sexp.chiral` (new) — `(import "prelude")`; `data Sexp`
  (`s-list`/`s-sym`/`s-i64`/`s-str`), `data RR` (`r-ok`/`r-err`), `data AllR`
  (`a-ok (forms (List Sexp))` / `a-err (msg Str) (pos I64)`); a local
  `code (-> Str I64)` (copy `json.chiral:24`) and the `CH-*` constants
  (`CH-LPAREN`/`CH-RPAREN`/`CH-DQUOTE`/`CH-SEMI`/`CH-BSLASH`/`CH-NL`/`CH-SP`/
  `CH-TAB`/`CH-CR`/`CH-MINUS`/`CH-0`/`CH-9`) as `(def CH-LPAREN I64 (code "("))`.
- **Change:** exactly the example §5 `Sexp`/`RR` decls; add `AllR` for the
  top-level and the constant block.
- **Size:** ~S

### Step 2 — trivia + comment skipping
- **Target:** `sexp.chiral` — `skip-trivia (-> Bytes I64 I64)`
- **Change:** advance over ` \t\r\n` and `;`-to-end-of-line comments to the next
  significant index; extends `json.chiral:111 skip-ws` with the comment arm.
  Total via the numeric measure `blen − i` under the `(<i i (blen b))` guard.
- **Size:** ~S

### Step 3 — atom scan + int/symbol classifier
- **Target:** `sexp.chiral` — `read-atom (-> Bytes I64 RR)` + helpers
  `atom-end (-> Bytes I64 I64)` (scan to the first delimiter in ` \t\r\n();"`),
  `is-i64-lit (-> Bytes I64 I64 Bool)` (the decision #4 predicate over the slice).
- **Change:** slice `[i, atom-end)`; if `is-i64-lit` → `(s-i64 (str->i64 …))`
  else `(s-sym …)` via `bytes->str`. Structural on the delimiter scan → total.
- **Size:** ~M

### Step 4 — string scan with escapes
- **Target:** `sexp.chiral` — `read-string (-> Bytes I64 RR)` + `scan-str-go`
  accumulator helper
- **Change:** mirror `json.chiral:229 scan-str-go`/`:218 scan-escape` but with the
  **sexp escape set only** — `\n \t \" \\`, any other `\X` → literal byte `X`
  (`sexp.py:_tokenize`); `r-err "unterminated escape"` on backslash-at-EOF,
  `r-err "unterminated string"` on missing close quote. No `\u`.
- **Size:** ~M

### Step 5 — the recursive spine (`read-form` + `read-list`)
- **Target:** `sexp.chiral` — `read-form`/`read-list`, verbatim from the
  audited example §5 (already syntax-legal: `<i` guards, `=i CH-*`, `reverse
  Sexp`, `cons`).
- **Change:** paste the two defs; wire `read-string`/`read-atom` from Steps 3–4.
- **Size:** ~S

### Step 6 — top-level `read-all` / `read-all-str`
- **Target:** `sexp.chiral` — `read-all (-> Bytes AllR)`, `read-all-str (-> Str AllR)`
- **Change:** loop `read-form` from `(skip-trivia b 0)`, cons each form onto a
  reversed accumulator, stop at EOF → `(a-ok (reverse Sexp acc))`; propagate any
  `r-err` as `a-err`. `read-all-str` = `(read-all (str->bytes s))`, mirroring
  `json-parse-str`. Numeric-measure total on the advancing cursor.
- **Size:** ~S

### Step 7 — differential test file
- **Target:** `scaffold/tests/test_sexp.py` (new)
- **Change:** mirror `test_json.py`'s harness (`Elab().load_file(lib/sexp.chiral)`,
  `RT`, curried `apply1` driver); a chirality-`Sexp`→Python adapter; a fixture corpus
  (atoms, nested lists, all four escapes + unknown-escape passthrough, `;`
  comments, negative ints, and the four error inputs) asserting tree-equality
  vs `sexp.py.read_all` and `a-err`/`r-err` on the reject set.
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior:** for every source in the fixture corpus,
  `sexp.chiral::read-all-str(src)` yields a `Sexp` tree equal (adapter-normalized)
  to `sexp.py.read_all(src)`'s forms — same atom int-vs-symbol split, same string
  escapes, comments stripped — and returns `a-err`/`r-err` on exactly the inputs
  `sexp.py` raises `ReadError` for (`unclosed (`, `unexpected )`,
  `unterminated string`, `unterminated escape`). **Scope caveat (decision #4):**
  the corpus uses only plain `-?[0-9]+` integers, where the split matches
  exactly; exotic Python-`int()` spellings (`+5`, `1_000`, padded) are a named
  divergence, deliberately excluded from the corpus rather than reproduced — so
  "same split" is a claim over the plain-integer corpus, not over all inputs.
- **Floors compared:** the **chirality RT interpreter** running `sexp.chiral` vs the
  **Python `sexp.py` oracle** (lib-level chirality-vs-golden, exactly the `test_json.py`
  shape — not a native/tal differential).
- **Green line:** 344 → ≥ 344 + k (the new `test_sexp.py` functions); the full
  suite stays green and `sexp.py` is unchanged; ledger-lint clean.
- **Done when:** `test_sexp.py` passes — the chirality reader parses the corpus
  identically to `sexp.py`, with the four golden error inputs surfacing as
  `*-err` values instead of throws.

## 6. Residue & links

- **Deliberately unbuilt:**
  - Exotic i64 spellings (`+5`, `1_000`, whitespace-padded) — named limit under
    decision #4; not needed until a corpus demands it.
  - `\u` unicode string escapes — `sexp.py` has none; if ever wanted, the
    `json.chiral:194 scan-uescape` machinery is the copy source (its own follow-on,
    not E1).
  - Per-form source positions / line numbers in the tree — decision #2, DEFERRED
    to [[E02-surface-elaborator]].
  - Retiring `sexp.py` and switching the front end onto `sexp.chiral` — downstream
    of E2 being self-hosted and a bootstrap path existing; not E1.
- **Follow-on:** unblocks nothing hard, but it is the bottom of the front-end
  self-host stack that [[E02-surface-elaborator]] sits on; both are superseded
  in concrete syntax by **E49** (real surface syntax).
- **Related:** [[E01-sexp-reader]] (rationale), [[E02-surface-elaborator]] (the
  consumer + decision-#2 owner), [[E26-alarms]] (errors-as-values vs control
  flow), [[E25-byte-cells]] / [[E24-i64-arith]] (the `Bytes`/`I64` floor).
