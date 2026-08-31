---
element: S18
slug: scriba-record
title: The `Scriba` editor-state record — one value replacing the positional thread
kind: MECHANICAL-REFACTOR
lane: scriba (`.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` Tier A)
status: specced
pipeline: spec-first (no worked example — §6 of the checklist names S18 mechanical)
measured-at: HEAD `1b61120`, 2026-08-23
---

# S18 SPEC — the `Scriba` editor-state record

> Implementation contract. **Authority order:** live CODE >
> `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` > the task framing. Every place the
> code disagreed with either is recorded in §7, not silently reconciled.
>
> This is a mechanical refactor with **one** piece of real design content (the P4
> boundary, §3) and **one** real risk (commit granularity, §5). It is scoped to
> match: no worked example, no example audit — per checklist §6, which names S18
> mechanical.

---

## 1. Deliverable

**After this runs:** `command-loop.chiral`'s 81 state-threading defs take **one
`Scriba` value** in place of the leading positional state run. `command-loop`'s
external 5-parameter entry is **unchanged**, so `scriba-main.chiral` and
`scriba-test-b1.chiral` are not edited. Adding a field to the editor's state
becomes one line in one record and zero edits anywhere else — which is checklist
§5's third acceptance clause ("zero new threaded parameters") for every row after
this one.

**Blast radius: three files.**

| file | change |
|---|---|
| `TUI/scriba/editor-state.chiral` | **NEW** — `Scriba` + 11 accessors + 11 `sc-with-*` + 2 measured combinators (~70 L) |
| `TUI/scriba/dispatch.chiral` | the `command-loop-inner` forward declare (`:51-52`) collapses to `(=> Scriba Unit)`; one import added |
| `TUI/scriba/command-loop.chiral` | 76 type lines + 76 binder lines + 369 argument occurrences rewritten |

**Non-goals** (each already has a cataloged home — no phantom deferrals):

- The `chat` field stays. It retires into the buffer list in **S19** (D-S3 RESOLVED YES).
- No buffer-local slot, no `ChatView`/`ConvState` rehoming — **S20**.
- No orchestrator split, no `backend-open` rehoming — **S20b**.
- No `:`-command registry; the ~20-arm nested `case` at `command-loop.chiral:1838` is
  rewritten in place with the new binder and otherwise untouched — **S21**.
- No new fields. Whatever is threaded today goes in; nothing else does.

---

## 2. Baseline — measured, at HEAD `1b61120`

Every figure below was produced by running the command named beside it, on the
live tree, for this spec. **Three of the S18 row's own figures do not survive
re-measurement** (§7).

| measure | value | how |
|---|---|---|
| `command-loop.chiral` | **2,545 L / 155,291 B** | `wc -l -c` |
| defs in it | **140** | `^\(def ` at column 0 |
| …that thread loop state | **81** | lam binder containing both `renderers` and `ops` |
| distinct positional shapes among those 81 | **9** | table below |
| type lines to rewrite | **76** | `(=> Keymap …` in `command-loop.chiral` (75) + `dispatch.chiral` (1) |
| binder lines to rewrite | **76** | `(lam (km …` — 75 in `command-loop`, plus `command-loop` itself |
| `renderers ops` occurrences, total | **445** | `grep -o 'renderers ops' \| wc -l` |
| …in binder lists (declaration side) | **76** | |
| …as **arguments** at call sites | **369**, on **318** lines | 445 − 76 |
| applications of the form `(f km …` | **347**, **74** distinct callees | |
| `command-loop-inner` textual occurrences | **66** (49 are calls) | |
| scriba blob | **925,122 B** → B1 → **971,128 B**, rc 0 | `chirality_blob scaffold/lib scriba/scriba-main \| B1` |

### 2.1 The thread is not one shape — it is nine

The S18 row and `SCRIBA-STATE.md` both describe "the 11-param thread". **Only
`command-loop-inner` carries 11.** The other 80 defs carry one of eight other
prefixes:

| count | leading state parameters |
|---|---|
| 58 | `km puf chat dims scroll old-rendering renderers ops` |
| 15 | `km puf chat dims old-rendering renderers ops` |
| 2 | `puf dims rendering renderers ops` (`try-dispatch`, `dispatch.chiral:73`) |
| 1 | `km puf chat dims scroll msg old-rendering renderers ops mode pending` (`command-loop-inner`, `:2045`) |
| 1 | `km puf chat dims scroll msg rendering renderers ops` (`resume-normal`, `:2103`) |
| 1 | `km puf dims renderers ops` (`command-loop`, `:265` — the external entry) |
| 1 | `puf dims old-rendering renderers ops` (`try-dispatch-n`, `:703`) |
| 1 | `puf dims unused renderers ops` |
| 1 | `dir query anchor current chat km dims old-rendering renderers ops` (`isearch-loop`, `:2430`) |

`isearch-loop` threads the same state **in a different order**, with four of its
own parameters in front. `try-dispatch`/`try-dispatch-n` thread a sub-run with no
`km` and no `chat`. This is the strongest argument for the record that exists and
it is not in the row: the thread is not merely long, it is **not a convention** —
nine shapes, none of which the compiler relates to any other.

### 2.2 Which slots actually vary

Parsing the 47 fully-applied `command-loop-inner` call sites and comparing each
argument against the bound name:

| slot | varies at | slot | varies at |
|---|---|---|---|
| `km` | **0 / 47** | `msg` | 42 / 47 |
| `dims` | **0 / 47** | `pending` | 38 / 47 |
| `renderers` | **0 / 47** | `mode` | 35 / 47 |
| `ops` | **0 / 47** | `scroll` | 16 / 47 |
| `chat` | 1 / 47 | `puf` | 14 / 47 |
| | | `rendering` | 12 / 47 |

Five of eleven slots are **pure carriage** — re-typed at 369 sites and never once
changed. And the varying slots co-vary in exactly two blocks:

```
 21  msg, mode, pending
  7  puf, scroll, msg, old-rendering, mode, pending
  5  mode, pending
  4  msg
  3  puf, scroll, msg, old-rendering, pending
  3  scroll, msg
  2  puf, scroll, old-rendering, msg
  1  puf, chat, scroll, msg, mode, pending
  1  puf, msg, mode, pending
```

`puf` never changes without `scroll` and `rendering` changing with it (12 of 14) —
that block is **a repaint**. `mode` and `pending` change together in 35 of 47 —
that block is **a mode transition**. §4.2's two combinators are read off this
table, not chosen.

### 2.3 Existing gates this composes with — do not build a second one

- **`scaffold/tests/run-native.sh` Phase 7** sweeps every root in the tree
  (`grep -rl '^(def compile-main' scaffold/lib TUI agent scaffold/samples`, symlinks
  excluded): **93 candidates → 6 `*_reject_*` skipped → 87 swept → 81 pass, 6
  KNOWN_FAIL.** `TUI/scriba/scriba-main.chiral` and the five other scriba roots are
  in the swept set. Compile-only, no run.
- `bin/scriba` — resolve (native `scaffold/build/resolve`) → append linkage → B1 → exec.
- `bin/scriba-run-smoke.py` — PTY smoke (ioctl 40×120, one byte at a time + `\r`).
  Drives `:run`, which needs a reachable `rv-endpoint` backend. It gates the RUN
  path, not the editing core. **Not a substitute for §6.**
- `bin/test-scriba-funcs.sh` — five crossing-level compile probes. Untouched.
- `TUI/scriba/scriba-test-b1.chiral` — compile-only, no assertions; calls the
  5-parameter `command-loop`, which this spec leaves alone.

**No self-hosting obligation.** Verified, not assumed:
`grep -c 'end-module "command-loop"' scaffold/build/blob.chiral` → **0**; the blob's
50 modules are all compiler modules; the 8 `scriba` hits in it are comment text.
scriba is not in the compiler blob, so there is no fixpoint step in this change's
ceremony. **No `Flow`/`PureFn` constructor changes**, so `flow-view.chiral`'s
exhaustive `Flow` case is untouched.

---

## 3. The P4 constraint — checked per parameter, not asserted

The row's constraint: *a single record makes "add to central state" the cheap path
and "make it its own node" the expensive one — the gradient that produced Emacs's
single image, which `docs/live-environment.md` explicitly inverts. Authority-bearing
state (anything holding a port) does not go in this record; it earns a node (S20b).*

### 3.1 The check, per parameter

| # | param | type | defined at | port-bearing? |
|---|---|---|---|---|
| 1 | `km` | `Keymap` = `(keymap (bindings (List (Pair KeySeq Str))))` | `scaffold/lib/ports/tty.chiral:23` | **no** — lives in a port registry but is plain data; `KeySeq`/`Str` only |
| 2 | `puf` | `(Puffer Str)` — 9 fields incl. `(handle Port)` | `TUI/scriba/puffer.chiral:36-39` | **no** — see 3.2 |
| 3 | `chat` | `(Maybe (Puffer Str))` | same | **no** — same value |
| 4 | `dims` | `(Pair I64 I64)` | prelude | **no** |
| 5 | `scroll` | `I64` | prelude | **no** |
| 6 | `msg` | `Str` | prelude | **no** |
| 7 | `rendering` | `Rendering` — 8 ctors, all `Str`/`Bool`/`List Rendering` | `TUI/scriba/render.chiral:6-13` | **no** |
| 8 | `renderers` | `(List (Pair Str Mode))`; `Mode = (mode (renderer RendererFn) (faces …))`; `RendererFn = (rf (fn (-> Str (Pair I64 I64) I64 Rendering)))` | `render.chiral:16,24` | **no** — the stored arrow is **pure `->`**; it cannot cross |
| 9 | `ops` | `(List ScribaOp)`; `ScribaOp = (op (name Str) (fn (=> (Puffer Str) (Puffer Str))) (doc Str))` | `TUI/scriba/cmd-types.chiral:10-11` | **no, but the only one that needed thought** — the stored arrow is effectful `=>`, so a registered op *may* cross. It carries no captured capability: see 3.2 |
| 10 | `mode` | `VimMode` — payloads `ChatView` (`Exchange`/`ConvState`/`I64`), `Outline` (`ManasDoc`/`I64`/`List Str`), `RunView` (7 plain fields), `Catalog` (`List CatEntry`/`I64`) | `vim-mode.chiral:22-40`, `chat-view.chiral:34`, `manas-mode.chiral:621,941`, `manas-runview.chiral:48-56` | **no** — every payload is plain data. `ConvState` is `(Intent, Str, Str, I64)` (`router.chiral:170-172`) |
| 11 | `pending` | `Pending` — `Str`/`Bool` payloads | `vim-mode.chiral:48-` | **no** |

**All 11 qualify. Every one is editor's-own-state.**

### 3.2 Why that is machine-checked, not a reading

Two independent structural facts, both citable:

1. **scriba's `Port` is not a port.** `(data Port () (port))` — `scaffold/lib/ports.chiral:63`,
   a nullary sum with no crossing behind it. `ports.chiral` says so by name in the
   E161 comment block (`:57-60`): *"The one declaration that is not a port: `Port` is
   scriba's puffer HANDLE placeholder … a nullary data type with no crossing behind
   it."* So `Puffer`'s `(handle Port)` field carries no authority.
2. **The linear-mint discipline already proves the negative for the whole thread.**
   `porttype` introduces a linear atom: *"a value of it (or anything transitively
   holding one) can only ever be bound with quantity 1"* (`ports.chiral:3-8`), enforced
   by E159 and gated by run-native.sh Phase 6. Every one of these 11 values is bound,
   re-read and duplicated at hundreds of sites today. **If any of them transitively
   held a capability, the program would not type-check.** The proof that the loop
   state is port-free is the fact that it compiles.

The live editor confirms the shape from the other side: scriba **does** hold network
authority, and it holds it *in code, not in state* — `backend-open rv-endpoint` is
opened inline at `command-loop.chiral:1327, 1443, 1477, 1645, 1648` and, per the E159
comments there, is **"INLINED into the drive call, never let-bound"** precisely
because it is linear. That authority is real and S20b is the row that moves it. It
is not in the thread, so it is not in this record, and no judgment was needed to keep
it out.

### 3.3 The record's boundary — a rule, not a precedent

Two rules. A later row adding a field applies them; it does not copy what S18 did.

> **R1 — the authority rule.** A field belongs in `Scriba` **iff its type can be
> bound at unrestricted quantity**, i.e. it transitively holds no linear `porttype`
> capability. This is not a convention to remember: `Scriba` is duplicated at every
> `sc-with-*` and read at every accessor, so a capability inside it would be moved
> more than once and **the checker refuses the program**. State that holds a port
> cannot be added here even by an author who wants to. It earns a node — S20b.

> **R2 — the transposition rule.** The 11 field types are **pairwise distinct**, and
> that is a requirement rather than an accident. It is what makes a mis-ordered
> destructure — the one failure mode a 400-site mechanical rewrite actually has — a
> *type error*. Any future field whose type duplicates an existing one must be
> wrapped in a one-field newtype before it goes in.

### 3.4 The honest cost — say it, do not hide it

Today 58 defs cannot see `msg`, `mode` or `pending`; after this they can. The record
**erases the incidental least-privilege that arity was providing**. That is the P4
gradient in its true form, and the answer is not to pretend arity was a control:
visibility inside one process is not an authority boundary, and a parameter list is
not a capability. R1 is the boundary that is real, because the checker enforces it.
The boundary that separates *authority* — the editor from the orchestrator — is
S20b, and this spec does not move it, weaken it, or make it cheaper to violate.

---

## 4. The shape

### 4.1 Placement — a new module, and why not an existing one

`TUI/scriba/editor-state.chiral` (reachable as `scriba/editor-state`; note
`scaffold/lib/scriba` **is a symlink** to `TUI/scriba` — §7 finding 4 — so this is
one file, not two).

```
(import "prelude") (import "puffer") (import "keymap") (import "render")
(import "cmd-types") (import "vim-mode")
```

- **Not `cmd-types.chiral`** — it is a 60-line registry module with four imports, and
  `Scriba` needs `VimMode`, which would drag `vim-mode → manas-mode / manas-runview /
  chat-view` and the manas stack in behind it. That is an altitude leak into the module
  that sits *below* the loop.
- **Not `dispatch.chiral`** — it already imports the exact six, and it owns the
  `command-loop-inner` contract, so it is the tempting home. But its job is "resolve an
  op name and run it" (138 L); the editor's central state is not a dispatch concern.
- **Cycle check:** `editor-state` → {cmd-types, vim-mode, puffer, keymap, render, prelude};
  `dispatch` → editor-state; `command-loop` → dispatch. None of `cmd-types`,
  `vim-mode`, `manas-mode`, `manas-runview`, `chat-view` imports `dispatch`,
  `command-loop` or `editor-state`. Acyclic.

### 4.2 The record — flat, 11 fields

Flat, not nested. Nesting would buy one thing (grouping the five never-varying slots)
and cost two destructures on every access plus a second name to teach; §2.2 shows the
carriage slots are never *written*, which is a read-cost problem, and accessors already
solve that.

```chirality
(data Scriba ()
  (scriba
    (km        Keymap)                     ; active keymap
    (puf       (Puffer Str))               ; current buffer
    (chat      (Maybe (Puffer Str)))       ; retires into the buffer list — S19
    (dims      (Pair I64 I64))             ; terminal (rows, cols)
    (scroll    I64)                        ; first visible row
    (msg       Str)                        ; status line for THIS frame
    (rendering Rendering)                  ; last painted frame (diff base)
    (renderers (List (Pair Str Mode)))     ; renderer registry
    (ops       (List ScribaOp))            ; op registry
    (mode      VimMode)                    ; editing mode
    (pending   Pending)))                  ; armed operator
```

Field order = `command-loop-inner`'s current parameter order, so the migration of
that one def is a transcription. All 11 types are pairwise distinct (R2).

**Measured, not assumed:** B1 compiles an 11-field record with accessors and
`with-*` updaters and the result runs correctly (probe: 11-field `R` over
`prelude.chiral`, `with-a` + `r-a` round trip, B1 rc 0, binary exit 42). There is no
arity ceiling to work around and — since scriba is not in the blob — **no
two-stage bootstrap** of the kind E161's ninth `Sig` field needed.

### 4.3 Accessors and updaters — the convention

House style is `<short>-<field>` (`cv-xs`, `rv-req`, `outline-doc`, `catalog-cursor`),
with the same prefix on derived builders (`cv-add`, `cv-back`, `rv-with-calls`).
`Scriba` takes `sc-`.

- **11 accessors** `(-> Scriba T)`: `sc-km sc-puf sc-chat sc-dims sc-scroll sc-msg
  sc-rendering sc-renderers sc-ops sc-mode sc-pending`.
- **11 updaters** `(-> Scriba T Scriba)`: `sc-with-km … sc-with-pending`. One `case`
  destructure, one re-construction with the named field replaced.
- **2 combinators, read off §2.2** — these exist because the data says those slots
  co-vary, not for convenience:
  - `sc-repaint : (-> Scriba (Puffer Str) I64 Rendering Scriba)` — the repaint block
    (`puf`, `scroll`, `rendering`). 12 of 14 `puf` changes are exactly this.
  - `sc-enter : (-> Scriba VimMode Pending Scriba)` — the mode transition
    (`mode`, `pending`). 35 of 47 sites.
  - `msg` needs no combinator: it is one field, so `sc-with-msg` *is* the idiom.

25 defs, ~70 lines. All pure `->`.

### 4.4 The rewrite rule — one rule, applied 76+369 times

> Replace the **contiguous run of state parameters** with a single `s : Scriba`,
> leaving every non-state parameter in place and in order. At each call site,
> replace the corresponding argument run with `s`, wrapped in whichever
> `sc-with-*` / `sc-repaint` / `sc-enter` the site's *changed* arguments name.

Worked, on the three helpers that absorb 127 of the 347 applications:

```chirality
; before  (:739-743)
(def beep-recurse (=> Keymap (Puffer Str) (Maybe (Puffer Str)) (Pair I64 I64) I64
                     Rendering (List (Pair Str Mode)) (List ScribaOp) VimMode Pending Unit)
  (lam (km puf chat dims scroll old-rendering renderers ops mode pending)
    (let (_ (put bel-byte))
      (command-loop-inner km puf chat dims scroll "" old-rendering renderers ops mode pending))))
; after
(def beep-recurse (=> Scriba Unit)
  (lam (s) (let (_ (put bel-byte)) (command-loop-inner (sc-with-msg s "")))))

; resume-normal (:2101-2104) →
(def resume-normal (=> Scriba Unit)
  (lam (s) (command-loop-inner (sc-enter s vm-normal pending-none))))

; recurse-mode (:733-736) →
(def recurse-mode (=> Scriba VimMode Pending Unit)
  (lam (s mode pending) (command-loop-inner (sc-enter (sc-with-msg s "") mode pending))))
```

The two irregular cases, spelled out so nobody improvises:

- **`isearch-loop` (`:2425-2430`)** — its state run is non-contiguous
  (`… anchor current chat km dims old-rendering renderers ops`). It becomes
  `(=> Dir Str (Puffer Str) (Puffer Str) Scriba Unit)` / `(lam (dir query anchor current s))`.
  **`current` is not folded into `sc-puf`**: it is the search cursor, a different value
  from the committed buffer. Do not re-thread; the rule replaces state, it does not
  redesign the def.
- **`try-dispatch` (`dispatch.chiral:69-73`) / `try-dispatch-n` (`:702`)** — their run has
  no `km` and no `chat`, and callers routinely pass a *different* puffer than the bound
  one (`command-loop.chiral:1596` passes `puf2`). They become `(=> Scriba Str (Puffer Str))`
  and the caller supplies the substitution explicitly:
  `(try-dispatch (sc-with-puf s puf2) "previous-line")`.

`command-loop` (`:263-274`) keeps its 5-parameter `(=> Keymap (Puffer Str) (Pair I64 I64)
(List (Pair Str Mode)) (List ScribaOp) Unit)` signature and constructs the initial
`Scriba` in its tail. That is what keeps `scriba-main.chiral:38` and
`scriba-test-b1.chiral:35,56` — the only three external call sites in the tree — out of
this change entirely.

---

## 5. Change plan — commit granularity

A 369-site arity change does not compile half-applied. `command-loop.chiral`'s 81 defs
are one mutual-recursion cluster funnelled through `command-loop-inner`; the moment
that def's arity changes, every caller must already be migrated. This is E161's ninth
`Sig` field problem, in one file.

**Two commits.**

### Commit 1 — the record (compiles, zero behaviour change)

`TUI/scriba/editor-state.chiral` + its `(import "editor-state")` in `dispatch.chiral`.
Nothing constructs or consumes a `Scriba` yet. **Gate:** Phase 7 green (87 swept, 81
pass); scriba blob compiles rc 0. This commit exists so the record's own shape,
imports and cycle-freedom are proved before 369 sites depend on them.

### Commit 2 — the migration (atomic; nothing compiles between its parts)

`dispatch.chiral` declare + `command-loop.chiral` in full: 76 type lines, 76 binder
lines, 369 argument occurrences. One commit, because there is no intermediate state of
this file that type-checks.

**Documented fallback, if a single pass does not converge.** Do not improvise a split.
Add exactly one shim — a pack-direction wrapper that keeps the old arity alive:

```chirality
(def cli-11 (=> Keymap (Puffer Str) (Maybe (Puffer Str)) (Pair I64 I64) I64 Str
                Rendering (List (Pair Str Mode)) (List ScribaOp) VimMode Pending Unit)
  (lam (km puf chat dims scroll msg rendering renderers ops mode pending)
    (command-loop-inner (scriba km puf chat dims scroll msg rendering renderers ops mode pending))))
```

Migrate `command-loop-inner` plus the 15 leaf defs (`km puf chat dims old-rendering
renderers ops` — none of which recurse into `command-loop-inner`) first, leaving every
un-migrated caller pointed at `cli-11`; compile; migrate the rest; delete `cli-11` in a
third commit. One extra name, two extra compiles, and strictly better than an
improvised half-migration — but it is the fallback, not the plan.

### Not a commit: LOC

The row predicts "net LOC ≈ −200". **That is not what this change does** and the
implementer should not chase it. The savings are per-*character*, and the file is
roughly one form per line, so line count barely moves while bytes fall sharply:
369 argument runs × ~55 characters + 76 type lines × ~90 characters ≈ **−27 KB of
155,291 B (~−17%)**, against **+70 lines** of new module. Measure both after; do not
report a line delta as the win.

---

## 6. The gate — what it proves, and what it cannot see

### 6.1 What already gates this, with no new machinery

**G1 — Phase 7.** `scaffold/tests/run-native.sh` compiles `TUI/scriba/scriba-main.chiral`
in its downstream-roots sweep. Must stay at **81 pass / 6 KNOWN_FAIL / 0 fail**, with
zero NEWPASS-or-FAIL churn. This is genuinely strong for *this* refactor, because R2
(§3.3) makes the one realistic mechanical error — a transposed field in a `case`
destructure — a type error rather than a silent bug. Whole-suite: all nine phases,
exit 0.

**G2 — the blob compiles.** `chirality_blob scaffold/lib scriba/scriba-main | B1` → rc 0,
binary produced. Baseline for comparison: **925,122 B blob → 971,128 B binary**.
Per checklist §2b, **do not read a size match or mismatch as evidence** — the image is
zero-padded. Compare content or compare behaviour.

**No fixpoint step.** scriba is not in the compiler blob (verified, §2.3). The compiler
sources are untouched, so `B1` is not rebuilt and the self-hosting check does not run.

### 6.2 What that cannot see — stated plainly

G1 proves the 81 defs type-check and lower. It **does not prove the editor still
works.** The failure mode a 369-site rewrite actually has and the type checker cannot
catch is a **wrong-value substitution**: passing `s` where `(sc-with-puf s puf3)` was
meant, or carrying `msg` forward where `""` belonged. §2.2 measures `msg` as varying at
42 of 47 sites — every one of those is a place where the correct rewrite and a stale
one are both well-typed. The result is a stale frame, a stale status line, or a lost
cursor: invisible to every gate the repo has today.

And the repo has no headless behavioural gate for scriba's editing core.
`scriba-test-b1.chiral` is compile-only and running it launches the editor;
`bin/scriba-run-smoke.py` drives `:run` and needs a reachable `rv-endpoint` backend,
so it exercises the RUN path and depends on the mesh. **Neither sees an edit.** That
is the hole, and it is the reason this section exists before the implementation
rather than after it.

### 6.3 G3 — the gate this change must build

One new file, ~50 lines: **`bin/scriba-edit-smoke.py`** — a PTY harness (Python is a
harness here; per the BUILD RULE it compiles nothing). Copy the `pty.fork` /
`TIOCSWINSZ 40×120` / one-byte-at-a-time-`send` / ANSI-stripping `drain` scaffolding
verbatim from `bin/scriba-run-smoke.py:1-35`; drop the `:run` body.

It must be **differential**: run it against the **pre-change** binary first, save the
ANSI-stripped frames, then against the post-change binary and diff. A frame-by-frame
match across an editing session is the only evidence available that 369 substitutions
were the right ones.

The session must exercise, at minimum, one path through each block §2.2 identified:

| keys | exercises |
|---|---|
| `i` `hello` `<ESC>` | `sc-enter` (insert→normal), `sc-repaint` (puffer + scroll + rendering) |
| `dd` then `p` | pending-operator path (`Pending`, 38/47) + the register ops |
| `:w` `<CR>` | `msg` — the status line, the slot that varies at 42/47 |
| `:q` `<CR>` | teardown, `term-restore` |

Assertions on the stripped frames: the typed text appears; the status line after `:w`
is the write message and **not** a stale prior message; the frame after `<ESC>` differs
from the frame during insert; exit is clean.

**Honest limits of G3.** It is a smoke test, not coverage: it walks perhaps six of the
81 defs. It cannot reach the manas/catalog/runview/chat surfaces without a backend, and
those are where 40 of the 81 defs live. So the truthful statement of this change's
gate is: **the compiler proves the whole cluster, and behaviour is proved only along
one editing path.** The remaining 40 defs are covered by type-checking and by review,
and by nothing else. Do not write it up as more than that.

---

## 7. Where the code contradicted the inputs

Authority: **live code > the checklist > the task framing.**

1. **"74 signatures, 436 arg sites" (S18 row) — both figures are low.** Re-measured at
   HEAD `1b61120`: **76** signature lines (and 76 binder lines, so **152** declaration-side
   edits, not 74), and **369** argument occurrences of `renderers ops` out of **445**
   total. The row's 74 comes from `grep -c 'lam (km puf chat'`, which misses
   `command-loop` (`lam (km puf dims renderers ops)`); its 436 counts raw `renderers ops`
   occurrences without subtracting the binder lists — which at the time would have given
   a number *including* ~74 declarations. `SCRIBA-STATE.md` already says **76**, so the
   row also disagrees with its own companion doc. The count of defs threading *any* part
   of the state is **81** (the row does not have this number at all).
2. **"the 11-param thread" — there are nine positional shapes, not one** (§2.1), and only
   `command-loop-inner` carries 11. `isearch-loop` threads the same state in a *different
   order*. This strengthens the row's case and should be added to it.
3. **"net LOC ≈ −200" is not supported** (§5). The win is bytes (~−17%), not lines.
4. **`scaffold/lib/scriba` is a SYMLINK to `TUI/scriba`** — `ls -l scaffold/lib/scriba`
   → `scriba -> ../../TUI/scriba`. Checklist §0 says the two directories are
   "byte-identical (verified `diff -rq`) … keep them synced via `bin/make-public.sh` —
   never hand-copy." There is nothing to sync: it is one directory. `diff -rq` returning
   clean was the symptom, not the mechanism — which is exactly the §2b hazard *"do not
   reason about file identity from `stat` or from mutation experiments — use `ls -l`"*,
   biting the document that records it. Consequence for the implementer: **edit one
   file**, and `bin/make-public.sh` is not part of this change (it deliberately does not
   mirror `lib/scriba` at all — `bin/make-public.sh:37`).
5. **`run-native.sh:178` does not compile `scriba-main`.** The task framing cites it; that
   loop is inside `if false; then … fi` (`:177-191`) and is dead. `scriba-main` is compiled
   by the **enumerated** sweep at `:153-176` instead, which reaches it via
   `TUI/scriba/scriba-main.chiral`. The gate the framing points at is real; the line number
   and mechanism are not. Root arithmetic: **93 candidates, 6 `*_reject_*` skipped, 87
   swept, 81 pass, 6 KNOWN_FAIL** — the framing's "81 roots" is the pass count.
6. **`dispatch.chiral:40` says "command-loop-inner lives in scriba-main.chiral".** It lives
   in `command-loop.chiral:2044`. Stale comment; fix it while editing the declare at `:51-52`.

---

## 8. Links

`.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` (the S18 row, §4 order, §5 acceptance, §6
pipeline, §2b hazards) · `.planning/SCRIBA-STATE.md` (what is built) ·
`.planning/BUILD-ORDER.md` §A6 (the P4 constraint) · `docs/live-environment.md` (the
thesis the constraint answers to) · `.planning/specs/E161-kind-identifier-SPEC.md`
(the atomic-arity-change precedent) · rows this unblocks: **S21** (`:` registry — next
in §4 order), **S19** (buffer list; retires `chat`), **S20** (buffer-local slot),
**S20b** (the orchestrator node — where authority-bearing state goes).
