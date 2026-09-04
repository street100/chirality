---
element: E161
slug: kind-identifier
title: The module datasheet — a certificate with a fixed schema, one authored field, everything else compiler-filled and unwritable
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none — design from E160 + kernel.chiral/loader.chiral/compile-emit.chiral; no Python baseline)
status: drafted
updated: 2026-08-23
---

# E161 — The module datasheet

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
>
> **Rescoped 2026-08-23 against `examples/E161-REQUIREMENTS.md`, which is the
> authority for this element.** Where this file and the requirements disagree,
> the requirements win — except where the CODE contradicts both, which is flagged
> inline and reported at §6.

## 1. Scope

- **Element:** E161 — give every module a **datasheet**: one small fixed-schema
  record holding what a consumer would otherwise derive by traversal. **One
  authored field (`cat`); every other field is filled by the compiler and is not
  writable.**
- **Kind:** BUILD-PROPER.

**Lineage — this is not a new hierarchy.** `certificate` is already this repo's
word for the mechanism: untrusted producer, small trusted checker, re-run the
derivation (`docs/certificate-discipline.md`). A datasheet is **a certificate
with a fixed schema** — same discipline, one category of statement, mostly
*derived* rather than *proved*. The hardware analogy fixes the shape: you read a
datasheet *instead of* characterizing the part, and it is worth reading only
because it is guaranteed to match the part.

**The framing that makes it legible is error handling.** This is errors-as-values,
twice:

| the old way | the good way | here |
|---|---|---|
| a comment saying "this can fail" | `Result` in the return type — the compiler carries it, you cannot forget it | "this module crosses" as a comment rots; as a derived field it cannot |
| a `case` with a catch-all arm | exhaustive case — a new variant breaks every consumer | adding a crossing def must change the record, with **no path** where it silently does not |

`pretty.chiral` already states the second rule for itself (*"no `<k>` catch-all — a
new former with no arm is a compile error"*). The datasheet is that rule applied
to a module's description of itself.

**Where E160 left it.** E160 (`0407cfa`) shipped one optional toplevel form —

```
(kind <module>  A|B|C  upper|tal|metal  [(pure)|(crosses)])
```

— stored as a **Sig-resident record** (`ModKind`, `kernel.chiral:122-124`:
`(mk-modkind (name Str) (cat KCat) (alt KAlt) (claim KClaim) (open Bool) (defs
(List Str)))`), reachable through `sig-kinds` (`kernel.chiral:145`). Six modules
carry it: `collections`, `pretty`, `prelude`, `ports`, `target-linux`,
`string-utils` (each file's line 12–52). The port-set claim is checked at emit
(`kind-offender`, `compile-emit.chiral` lines 344-348); shape/axis/redeclaration are
checked at load (`handle-kind`, `parse.chiral:1110-1149`).

2026-09-04, citation repair: E161 shipped and its step 7 retired the emit gate. `kind-offender` and `kind-offender-go` are gone from `compile-emit.chiral`; the line numbers this pre-run records have no live successor.

**What E161 is.** Per the requirements' §7 cut: **R2-derived, R3, R5, R6, R7** —
turn E160's single authored boolean into a compiler-filled, queryable, def-grain
record; **retire the authored `(pure)`/`(crosses)` claim**, which becomes derived.

**What E161 is NOT — killed by measurement, do not resurrect.**

1. **`(kind-def <name> A|B|C)` and any per-def `(pure)|(crosses)`.** A def's
   crossing is already its **arrow** — `->` is an empty effect row, `=>` a
   nonempty one — and `ty-crosses` (`kernel.chiral:163-168`) already reads it off
   the Pi spine. Declaring it would mint a second source of truth for a fact the
   type states. The per-def *typeability letter* is a separate question that this
   revision does **not** carry forward: its falsifier (hand-annotate `term.chiral`
   and `backend.chiral`, see whether any def's letter differs from its module's)
   has never been run, so no claim about its value is made here.
2. **"A module must be wholly pure or wholly crossing."** FALSE, verified.
   `kind-offender-go` (`compile-emit.chiral` lines 322-342) reads `(crosses)`
   **existentially**: the claim is met the moment one def crosses, pure defs
   beside it are fine. A mixed module compiles today.
3. **The double-extension file scheme as a centrepiece.** Settled and cosmetic —
   R10: any filename/layout scheme is a **consumer** of the record, downstream,
   never a gate. §5 shows what one projection looks like and stops there; no
   surfaces are weighed.
4. **The CEILING/TIGHT roll-up rule as new policy.** Already implemented:
   `kind-offender-go` is `declared == empty?(join(defs))`, tightness arm included
   (`kv-crosses-pure` / `kv-crosses-empty`, `compile-emit.chiral:293-294`,
   `:301-305`).

## 2. Research

**Reference class:** `OURS` — E160's shipped record, the Sig registries in
`kernel.chiral`, the loader's coordinate machinery in `loader.chiral`, the emit
gate in `compile-emit.chiral`, and `docs/certificate-discipline.md`. No Python
baseline; §3's conventional comparison is from knowledge, no web fetch.

**Finding 1 — the record already lives in the Sig; what is missing is its
derived fields and a by-name lookup.** This corrects the requirements' §7 rows
R5/R6 from *missing* to *partial*. `ModKind` is a `Sig` field
(`kernel.chiral:126-135`), `sig-kinds` is a public accessor (`:145`), and the
loader already charges def names to the open coordinate (`sig-note-def`,
`loader.chiral:170-172`, called at `parse.chiral:583` and `:597`). What genuinely
does not exist:

- a lookup returning the record — the only one today is `sig-kind-taken`
  (`loader.chiral:192-193`), which returns `Bool`;
- any derived field on it;
- charging for `extern` / `porttype` / `data` — only `def` installs are charged
  (`parse.chiral:1169-1171` dispatch those three heads and none of them calls
  `sig-note-def`), so `defs` is defs-only, not exports.

**Finding 2 — the per-def purity derivation is a one-line twin of code that
ships.** `sig-prim-crosses` (`kernel.chiral:242-243`) is
`(case (sig-prim-ty s n) (none false) ((some ty) (ty-crosses ty)))`. The same
line over `sig-global-ty` (`:236`) gives per-def crossing for every def in the
program. `ty-crosses` and `seat-crosses` (`:162-168`) are already written, and
their comment states the principle this element generalizes: *"Computed from the
stored type rather than cached in a registry — the type IS the authority, so
there is no second copy to fall out of sync."* **The work here is plumbing what
exists to somewhere addressable, not new analysis.**

**Finding 3 — "which crossings" is derivable in THREE inequivalent senses, and
the schema must name which one it holds.** Measured on `prog/manas/backend.chiral`:

- **(a) crossings the module BINDS** — its own `extern` forms with an effectful
  arrow. `ty-crosses` says **exactly one**: `backend-open (=> Str Backend)`
  (`backend.chiral:36`). `be-base` (`:37`), `backend-close` (`:43`) and `be-peek`
  (`:56`) are all `->`, and their own comments say why — *"Pure (`->`): no
  syscall"* (`:42`), *"Pure (`->`): it crosses no membrane and issues no syscall"*
  (`:51-52`). ⚑ The requirements' §5 sample record shows
  `(crossings backend-open be-peek be-base backend-close)`; on the code, three of
  those four do not cross.
- **(b) crossings the module's defs REACH transitively** — needs a call graph.
  Nothing in the Sig computes it.
- **(c) crossings the OBJECT CODE calls** — `xw-code` with an empty allow-set
  (`compile-emit.chiral:238-249`), whose vocabulary is the codomain of
  `crossing-wraps` (`crossing-wraps.chiral:13-57`). On `backend` this is
  **empty**: none of its four externs appears in `crossing-wraps`, and
  `backend-open` erases to `nb-id` (`tal-erase.chiral:123`). The emit gate can
  never charge `backend` with a crossing.

Sense (c) also carries a stated bound the code already documents
(`compile-emit.chiral:283-290`): closure conversion lifts lambdas into
whole-program globals in nobody's module, so a crossing inside a lifted lambda is
in no module's set. Under R7 an unnamed sense is exactly
`certificate-discipline`'s residual vacuity (`certificate-discipline.md:33-38`),
whose words are *"a real proof of a **weak** statement … the work is real, the
statement empty"* — a real derivation nobody can use.

**Finding 4 — the façade is the concrete vacuity case, and the tree already has
one.** `ports.chiral` is a C module that defines **no def at all** (60 lines:
imports, the `kind` line, one `data`). Its own comment (`:44-51`) says a `(pure)`
claim there would be *"true only vacuously, which is a worse lie than silence"* —
and its crossings *"are real; they live one import down, in ports/fd, ports/sock
and the rest."* A total schema forces this module to carry values for every
derived field. Whether the record covers re-exported crossings is therefore not a
nicety — it decides whether `ports`'s datasheet says anything. Open question 1.

⚑ **And on the shipped loader those fields would not be empty — they would be
someone else's.** `loader.chiral:141-146` documents the bound: a coordinate that
charges no def is never closed by the next module's imports
(`kinds-close-bodied` returns the list unchanged while `ds` is `nil`,
`loader.chiral:174-181`), so every following `def` is charged to it until some
later `kind` form closes it. Today the bound is inert — a coordinate with no
port-set claim contributes no row to the emit gate (`compile-front.chiral:305`).
E161 removes that immunity: every coordinate gets a record. Measured on the
committed blob: `(kind ports C upper)` is the **last** `kind` form
(`blob.chiral:10781`) and **345 `def` forms follow it**, all charged to `ports`.
A `ports` datasheet built by the loader as it stands would list 345 defs that
are not its own. That is a record actively disagreeing with its module — the one
thing R3 exists to make unrepresentable — so closing a def-less coordinate is
prerequisite work for R7, not a nicety. Open question 6.

**Finding 5 — one derived field has no honest derivation today: `alt`.** E160
authors it (`KCat`/`KAlt`/`KClaim`, `kernel.chiral:91-93`). The requirements list
altitude as *derivable (infer from tal-ir / TIFn use)*, and their §5 sample record
marks `(alt upper)` **derived** — but nothing computes it, and an import-graph
heuristic is a guess about the module rather than a reading of it. Note also that
the requirements' §4 and §8 name only the `(pure)`/`(crosses)` retirement, while
§5 silently retires `alt` too. Open question 2.

**Finding 6 — the "wrote a derived field" error is the grammar's job, not a
check's.** With one authored slot the surface is `(module <name> (cat A|B|C))` and
a derived field has **no production**. The reader's refusal sum already has the
arm: `KErr`'s `(k-shape)` (`parse.chiral:1046-1052`), rendered at `:1057`. So of
the requirements' "exactly two errors", one is not a new mechanism — it is the
absence of one. Only the `cat` fence (error 2) is new code. That is the design
working, and it is worth stating plainly rather than counting two checks.

**Finding 7 — the fence direction is one-way, and the shipped tree agrees.**
Category A is *"correctness by proof (the kernel's judgment)"*; C is *"a typed
module over an untyped referent, governed by evidence"*. A module that reaches a
crossing rests on evidence about a referent the kernel cannot type, so
**crossings ⇒ not A**. The converse does not hold: `target-linux` ships as
`B upper (pure)` and `ports` as `C upper` with no crossings of its own. No
shipped module contradicts the fence — all four `A` modules declare only `->`
externs (checked: zero `(extern … (=>` in `prelude`, `collections`, `pretty`,
`string-utils`).

**Finding 8 — the crossing vocabulary already has exactly one home, so the
datasheet must reference it, not re-declare it.** `crossing-wraps`
(`crossing-wraps.chiral:13`) is a `(List (Pair Str Str))` of extern→wrapper rows
whose header calls itself *"the one representation of the map the erase image can
see"*. Minting a closed `Crossing` sum by hand would be a second source of truth
for that table — the disease this element treats. The boundary-sums directive is
satisfied by there being one vocabulary, not by a parallel sum; a genuine sum
would have to be *generated from* `crossing-wraps` (or the table generated from
it), which is a separable change.

## 3. Conventional (other-language) approach

The test each mechanism has to pass: **can what it says drift from what the
module contains?**

**OCaml `.mli` + `ocamlc -i` — the closest real mechanism, and the most
instructive failure.**

```ocaml
(* ocamlc -i backend.ml > backend.mli   -- the compiler INFERS the interface *)
val be_url  : string -> string -> string
val be_chat : backend -> string -> msg list -> chat_r
(* then: backend.ml is checked AGAINST backend.mli; disagreement is refused. *)
```

It genuinely gets the hard half right: the record is *generated* from the code,
and the compiler refuses a `.ml` that does not implement its `.mli`. Where it
fails the drift test:

- **The `.mli` is a writable file.** `ocamlc -i` generates it once; from then on
  you edit it. Nothing forces regeneration, so what you keep is a hand-maintained
  artifact seeded by a derivation — R3's inversion exactly.
- **The check is one-directional.** The `.ml` must implement the `.mli`; the
  `.mli` need not mention everything in the `.ml`. A stale interface that
  silently stops exporting a newly added function is *legal* — the omission is a
  value, not an error. That is R7's failure: one unspecified field and a consumer
  must re-derive.
- **There are no fields for the questions we ask.** No effect field, no
  "what does its correctness rest on" — OCaml has neither concept, so the schema
  is absent even where the mechanism is right.

**Rust `#[derive(...)]` — the closest thing to R3.**

```rust
#[derive(Clone, Debug)]      // the impl is GENERATED; you cannot write it
struct Backend { base: String }
```

Non-writable derivation is the right shape. Its limit is R7: derives are opt-in
per type, there is no total schema, so a consumer cannot ask a uniform question
of an arbitrary type and get an answer.

**Generated headers (`cbindgen`, `javah`, `protoc`) — derivation into a writable
artifact.** The generator is honest; the artifact is a text file that the build
does not force it to regenerate. `make check-generated` / `git diff --exit-code`
CI steps exist for exactly this. Derivation without non-writability buys nothing.

**Package manifests (`Cargo.toml`, `BUILD.bazel`, `package.json`) — the canonical
drift failure.** Fully hand-maintained descriptions of code they sit beside.
`cargo-udeps` and `gazelle` exist because they are routinely wrong.

**Go build-tag filenames / Java package paths — the opposite failure.**
`term_linux.go`, `com/foo/Bar.java`: the name **is** the source of truth, so
there is no independent claim and nothing to check. Nothing can be wrong because
nothing is asserted.

**Haskell `IO a` — "a check is not an API", in another language.** Purity is
per-function in the type and evaporates at the module boundary: you cannot state
"this module is pure" and have GHC check it, and no consumer can ask. The fact
exists; nothing aggregates or exposes it. That is E160's residue at the emit
gate, stated in a different language.

**Assumptions all of these bake in, which chirality refuses:**

- a self-description that is a **source** (writable) rather than a **projection**;
- a **partial** schema, where an absent field is a legal value;
- **regeneration by convention** rather than by construction;
- an analysis that runs, decides, and **discards** its answer.

## 4. The chirality idea

**Chirality features in play:** certificate discipline (`certificate-discipline.md`) ·
the effect membrane (`->` empty row vs `=>` nonempty) · categories A/B/C ·
errors as values · boundary sums · the `Sig` registries · the `Str -> ELF`
compiler seam.

### The mechanism

What the author writes, whole:

```
(module backend (cat C))
```

What happens at load: the compiler walks the module's own forms — it already
charges def names to the open coordinate (`sig-note-def`, `loader.chiral:170`) and
already decides per-def crossing from the arrow (`ty-crosses`,
`kernel.chiral:163`) — fills the derived fields, and puts the record in the `Sig`
where anything can ask for it.

What a consumer reads back:

```
(module backend
  (cat C)                                        ; authored
  (alt upper)                                    ; ⚑ NOT DERIVED TODAY — authored in
                                                 ;   E160 (KAlt, kernel.chiral:92); nothing
                                                 ;   computes altitude [open question 2]
  (crossings backend-open)                       ; derived — WHICH, not whether
  (exports (be-url fn) (ok2xx fn) (msg->json fn) (chat-body fn) (chat-content fn)
           (parse-hit fn) (be-chat proc) (drain-stream proc) (be-chat-stream proc)
           (be-health proc) (be-models proc) (be-embed proc) (be-search proc)
           (Backend porttype) (backend-open extern) (be-base extern)
           (backend-close extern) (be-peek extern)
           (Msg data) (BePeekR data) (ChatR data) (DrainR data) (HealthR data)
           (ModelsR data) (EmbedR data) (Hit data) (SearchR data))
  (mints Backend))                               ; derived — the linear porttypes
```

Counts are measured, not illustrative: `backend.chiral` has **13 defs (7 `=>`,
6 `->`)**, 4 externs, 1 porttype, 9 data decls. And per Finding 3 the `crossings`
field holds **one** name, not four — the correction to the requirements' sample.

### Derived fields are not writable — that is the whole design

The slot takes no input. So:

- a record-vs-reality **mismatch is not representable**, and there is nothing to
  "check";
- the question *"may I write this?"* stops existing. This is a **mechanism, not a
  rule** — the design removes the occasion for discipline instead of asking for it.

**Exactly two errors exist, and one of them is already the grammar** (Finding 6):

1. **You wrote a derived field.** There is no production for it. The reader's
   existing `(k-shape)` arm refuses the form (`parse.chiral:1046`, `:1057`). No
   new code.
2. **Your `cat` contradicts derivable facts.** A module with crossings cannot be
   `(cat A)` (Finding 7). This is the one new check, and it is the fence — the
   authored field is fenced by the derived ones (R4).

### The failure that must be impossible

```chirality
(def be-stream (=> Str Unit) (lam (s) (do (print s) unit)))   ; added; nothing else touched
```

The record changes on its own. No edit, no reminder, no review step — and no path
on which it silently does not. Structurally that is the exhaustive-case rule:
`sig-note-def` runs on the install, `ty-crosses` reads the arrow, and neither has
a catch-all arm that could absorb the new def quietly.

### Where the derivation comes from — mostly plumbing, and it should say so

| field | derivation | build-state |
|---|---|---|
| `cat` | **AUTHORED** — no traversal answers *"what does its correctness rest on"* (`k-msg`'s own wording, `parse.chiral:1061-1062`) | ships (`KCat`, `kernel.chiral:91`) |
| `exports` (def grain) | names charged to the open coordinate | **partial** — `defs (List Str)` ships (`kernel.chiral:123`; `sig-note-def`, `loader.chiral:170`); `extern`/`porttype`/`data` are **not** charged (`parse.chiral:1169-1171`) |
| per-export `fn`/`proc` | `ty-crosses` over the Pi spine | **built, unplumbed** — one line, the twin of `sig-prim-crosses` (`kernel.chiral:242`) |
| `crossings` | one of the three senses in Finding 3 | **built in sense (c) and discarded** — `kv-first-crossing` (`compile-emit.chiral:315-321`) stops at the first crosser; the crossing travels as a bare `Str` out of `cw-extern-of` (`:215-218`) |
| `mints` | the porttypes this module installs | **partial** — `sig-latoms`/`sig-ldatas` ship (`kernel.chiral:139-140`); not charged per module (`handle-porttype`, `parse.chiral:685-697`) |
| `alt` | nothing derives it (Finding 5) | authored today (`KAlt`, `kernel.chiral:92`) |

So the honest shape of the work: **one new check (the fence), three charging
hooks, one one-line derivation, one un-truncated walk, and a lookup.** No new
analysis. Saying otherwise would oversell the element.

### R6 — reachability is the element's real content

*A check is not an API.* E160's defect is not that it computes the wrong thing; it
is that `kind-offender` computes exactly these facts inside emit, truncates at the
first crossing, and discards them. Nothing can ask.

The query shape is **already the house shape** for every other `Sig` registry —
`sig-target` and `sig-profile` (`kernel.chiral:155-156`) are both
`(-> Sig Str (Maybe T))` over a linear `find-…` scan. The datasheet gets the same
pair, and R5's "one lookup" means exactly that: one assoc scan over the module
list, no traversal of the module's defs and no re-derivation — not `O(1)`, and no
registry in this codebase is.

```
(sig-sheet sig "backend")            -> (some (sheet …))
(sheet-crossings s)                  -> (cons "backend-open" nil)
(exports-by s (ek-proc))             -> the 7 crossing defs, by name
```

### Where the record lives — STILL OPEN, not decided here

R5 and R6 hold either way. The difference is whether the thing a human reads is
the file or the `Sig`.

| | **source file** | **`Sig`** |
|---|---|---|
| legibility | maximum — `head -20` answers everything | the file shows a human less; a printer is needed |
| churn | the file changes on **every** def edit | zero |
| who writes it | something must **write source**, and this compiler cannot: it is `Str -> ELF`, never sees a filename, never writes a file | the loader, in memory, where it already puts `ModKind` |
| cost shape | a new artifact-producing tool **plus** a comparison gate | a data-shape change on a record that already exists |
| §3 risk | this is the generated-header shape: derivation into a writable artifact, regeneration by convention | none of that surface exists |

**My read, explicitly not a decision.** The two options are not symmetric in cost
or in risk. The `Sig` option is a widening of a record that already lives there
(Finding 1) and inherits an existing query shape; the source-file option requires
a source-writing tool chirality does not have, and lands the record in a writable text
file, which is the exact failure §3 catalogues in `cbindgen`/`.mli`. The
legibility that motivates the source option can be bought separately and without
that risk: a `chirality datasheet <module>` printer is a **consumer** of the record
(R10's class) and can be build-checked against it. That is a real basis, and it
points one way — but the author owns the call, and "the file a human opens should
tell them what the module is" is a legitimate reason to pay the cost.

### What chirality makes impossible here

- **A record that disagrees with the module.** Not "is caught disagreeing" —
  cannot be written.
- **A partially-specified record.** Total schema, no `Maybe` field: a façade gets
  empty lists, not absent fields (and Finding 4 is why that matters — on today's
  loader it would get someone *else's* defs, which open question 6 must fix
  before R7 means anything).
- **A silent staleness path.** A new def is charged at install and its arrow is
  read at derivation; neither step has a catch-all arm.
- **`(cat A)` over a module that crosses.** The fence, and it is one-directional
  on purpose (Finding 7).
- **A filename that is a claim.** Any layout scheme reads the record; nothing
  reads a filename (R10).

## 5. Chirality example (fleshed)

Real surface syntax. Skeleton: helpers declared, spine defined, mechanical loops
elided with `; …`.

```chirality
; ─────────────────────────────────────────────────────────────────────────────
; E161 — THE MODULE DATASHEET.  A certificate with a fixed schema
; (docs/certificate-discipline.md owns the general mechanism).  ONE authored
; field; every other field is filled by the compiler and has no surface
; production, so it cannot be written and cannot disagree.
; ─────────────────────────────────────────────────────────────────────────────

; ── the ONE authored axis — unchanged from E160 (kernel.chiral:91) ────────────
; A/B/C is authored because no traversal answers "what does this module's
; correctness rest on: proof, an admitted hole, or cross-checked evidence about
; a hole" — parse.chiral:1061-1062 already says exactly that in its refusal.
; (data KCat () (cat-a) (cat-b) (cat-c))       ; SHIPS — shown for orientation
; (data KAlt () (alt-upper) (alt-tal) (alt-metal))

; ── what a module exports, at DEF GRAIN.  A closed sum: which-of-N decided at
;    the point of decision, never a Str compared downstream. ─────────────────
;    `ek-fn` vs `ek-proc` is NOT a new declaration — it is ty-crosses over the
;    def's arrow (kernel.chiral:163-168), read, not written.
(data ExpKind () (ek-fn) (ek-proc) (ek-data) (ek-porttype) (ek-extern))
(data Export  () (exp (name Str) (ek ExpKind)))

; ── THE SCHEMA.  TOTAL (R7): every field present on every record, no Maybe and
;    no "unspecified".  A façade (lib/ports/ports.chiral: no defs at all) carries the
;    same six fields with EMPTY lists — a real derivation of a weak statement,
;    which is certificate-discipline.md:33-38's residual vacuity in this
;    setting, and the reason open question 1 has to be answered.  ⚑ "Empty" is
;    the TARGET, not today's behaviour: on the shipped loader a façade's
;    coordinate never closes and swallows the next module's defs (Finding 4,
;    open question 6).
;    `crossings` holds extern NAMES keyed to the ONE existing vocabulary,
;    crossing-wraps.chiral:13 — not a hand-minted parallel sum (Finding 8).
(data Sheet ()
  (sheet (name      Str)                ; the coordinate
         (cat       KCat)               ; AUTHORED — the only writable field
         (alt       KAlt)               ; ⚑ UNBACKED — nothing derives altitude
         ;                              today; authored in E160 (kernel.chiral:92).
         ;                              A total schema cannot hold a field with no
         ;                              producer: it is derived, or it is a SECOND
         ;                              authored field, or it leaves. [open q. 2]
         (crossings (List Str))         ; derived — WHICH, not whether
         (exports   (List Export))      ; derived — def grain
         (mints     (List Str))))       ; derived — linear porttypes minted here

; ── ERROR 1 is the GRAMMAR, not a check ──────────────────────────────────────
; The surface is `(module <name> (cat A|B|C))`.  A derived field has no
; production, so writing one is refused by the reader's EXISTING shape arm --
; KErr's (k-shape), parse.chiral:1046 / :1057.  Nothing new is built for it.
; That absence IS the mechanism: the slot takes no input, so a record-vs-reality
; mismatch is not representable and there is nothing to detect.

; ── ERROR 2 is the FENCE — the one new check (R4) ────────────────────────────
; The authored field is fenced by the derived ones.  Category A is "correctness
; by proof"; a module that reaches a crossing rests on evidence about a referent
; the kernel cannot type, so crossings ⇒ NOT A.  One-directional on purpose:
; target-linux ships as B and pure, ports as C with no crossings of its own.
(data SheetErr ()
  (sh-cat-crosses (m Str) (x Str)))          ; (cat A) declared; it reaches x
(declare sh-msg (-> SheetErr Str))
(def sh-msg
  (lam (e)
    (case e
      ((sh-cat-crosses m x)
        (str-cat "module " (str-cat m (str-cat " declared (cat A) -- correctness by proof -- but reaches the crossing "
          (str-cat x " (a crossing is an admitted hole; this module is B or C)"))))))))

(declare cat-fenced (-> Sheet (Maybe SheetErr)))
(def cat-fenced
  (lam (s)
    (case s ((sheet nm cat alt xs exps mints)
      (case cat
        ((cat-a) (case xs (nil none) ((cons x r) (some (sh-cat-crosses nm x)))))
        (_       none))))))

; ── THE DERIVATION — plumbing what already exists, not new analysis ──────────
; The per-def half is one line: the twin of sig-prim-crosses (kernel.chiral:242),
; over globals instead of prims.  The type IS the authority; there is no second
; copy to fall out of sync (that comment is already in kernel.chiral:158-161).
(def def-crosses (-> Sig Str Bool)
  (lam (sg n) (case (sig-global-ty sg n) (none false) ((some ty) (ty-crosses ty)))))

(declare def->export (-> Sig Str Export))
(def def->export
  (lam (sg n)
    (case (def-crosses sg n) (true (exp n (ek-proc))) (false (exp n (ek-fn))))))

; The names come from the coordinate the loader already keeps open.  TODAY only
; `def` installs are charged (sig-note-def, loader.chiral:170, called from
; parse.chiral:583 and :597); `extern` / `porttype` / `data` are dispatched at
; parse.chiral:1169-1171 and charge NOTHING.  Three hooks, one per head, and the
; `defs` list becomes an export list.
;
; ⚑ KNOWN BOUND -- and it is the OPPOSITE of "a façade charges nothing".
; loader.chiral:141-146 states it: a coordinate whose module charges NO def (a
; façade, whose only body is a hoisted data/porttype form the linear pass never
; sees) is NOT closed by the next module's imports -- kinds-close-bodied returns
; the list unchanged while ds is nil (loader.chiral:174-181) -- so the FOLLOWING
; module's defs are charged TO IT, until some later `kind` form closes it via
; sig-add-kind.  Today that is inert, because a coordinate with no port-set
; claim contributes no row to the emit gate (loader.chiral:144-146,
; compile-front.chiral:305).  E161 REMOVES that immunity: every coordinate
; gets a record, so the bound goes live.  Measured on the committed blob:
; `(kind ports C upper)` is the LAST kind form (blob.chiral:10781) and 345 `def`
; forms follow it, every one of them charged to `ports`.  A `ports` datasheet
; built today would list 345 defs that are not its own -- a record that actively
; lies, which is exactly what R3 exists to make unrepresentable.  Closing a
; def-less coordinate is therefore PREREQUISITE work for R7, not a nicety; see
; open question 6.
(declare exports-of (-> Sig (List Str) (List Export)))
; …  map def->export over the charged names, reversed once (krev,
;    compile-front.chiral:298) so the record reads in source order.

; The crossings half.  THREE inequivalent senses exist and the schema names ONE:
;   (a) BINDS      — this module's own effectful externs; ty-crosses over
;                    sig-prims restricted to the charged names.  On backend this
;                    is exactly {backend-open} (backend.chiral:36); be-base :37,
;                    backend-close :43 and be-peek :56 are `->` and say so.
;   (b) REACHES    — transitive through calls; nothing computes it.
;   (c) OBJECT     — xw-code with an empty allow-set (compile-emit.chiral:238),
;                    vocabulary = codomain of crossing-wraps.  On backend this is
;                    EMPTY: backend-open erases to nb-id (tal-erase.chiral:123).
; Leaving the sense unnamed is certificate-discipline's residual vacuity.
(declare crossings-of (-> Sig (List Str) (List Str)))
; …  filter the charged names by sig-prim-crosses (kernel.chiral:242).  This is
;    sense (a).  Sense (c) is what the emit gate has and what R6 says is
;    discarded; kv-first-crossing (compile-emit.chiral:315-321) must stop
;    truncating at the first crosser to give a LIST rather than a first hit.

; The mints half: the linear porttypes this module installs.  sig-latoms /
; sig-ldatas ship (kernel.chiral:139-140) but are PROGRAM-wide, not per module --
; handle-porttype (parse.chiral:685-697) charges no coordinate, so this needs the
; same hook as the export heads.
(declare mints-of (-> Sig (List Str) (List Str)))

(declare build-sheet (-> Sig ModKind Sheet))
; …  read cat/alt off the ModKind, run exports-of / crossings-of / mints-of over
;    its charged names.  Called once per coordinate as the loader CLOSES it
;    (kinds-close, loader.chiral:150-157), so for a coordinate that DOES close
;    the record is finished exactly when the module is and there is no window in
;    which it is half-derived.  ⚑ A façade's coordinate does not close on its own
;    (the bound above), so "at close" is only a sound trigger once def-less
;    coordinates close too -- open question 6.

; ── R6: REACHABILITY.  A check is not an API. ────────────────────────────────
; The record already lives in the Sig (ModKind, kernel.chiral:122-124, reachable
; via sig-kinds :145).  What is missing is a lookup that RETURNS it -- the only
; one today is sig-kind-taken (loader.chiral:192), which returns Bool.  The shape
; is not invented here: sig-target and sig-profile (kernel.chiral:155-156) are
; both (-> Sig Str (Maybe T)) over a linear find-… scan, and this is that pair.
; R5's "one lookup" means one assoc scan and NO traversal of the module's defs.
(declare find-sheet (-> (List Sheet) Str (Maybe Sheet)))
(def find-sheet
  (lam (ss n)
    (case ss
      (nil none)
      ((cons s r)
        (case s ((sheet nm c a xs es ms)
          (case (str-eq n nm) (true (some s)) (false (find-sheet r n)))))))))

; `sig-sheets` is a new Sig field + accessor, added beside `kinds`/`sig-kinds`
; (kernel.chiral:126-135, :145) -- the NINTH field on Sig (globals, prims,
; datas, latoms, ldatas, targets, profiles, kinds are the eight that ship),
; installed the same way.
(def sig-sheet (-> Sig Str (Maybe Sheet)) (lam (s n) (find-sheet (sig-sheets s) n)))

; the queries a consumer actually asks, all off ONE lookup:
(def sheet-crossings (-> Sheet (List Str))
  (lam (s) (case s ((sheet nm c a xs es ms) xs))))
(declare exports-by (-> Sheet ExpKind (List Str)))
; …  filter the export list by kind.  `(exports-by s (ek-proc))` is "which of
;    this module's defs cross" -- the question E160 could only answer as a bit,
;    inside emit, for one module at a time, and then threw away.
(def sheet-crosses (-> Sheet Bool)
  (lam (s) (case (sheet-crossings s) (nil false) ((cons x r) true))))
; ^ E160's authored (pure)/(crosses) claim, RETIRED as a declaration and reborn
;   as this one-line reader.  The claim is no longer writable, so kv-pure-crosses
;   / kv-crosses-pure (compile-emit.chiral:291-294) lose their subject: there is
;   no declaration left to contradict.

; ── A PROJECTION — a CONSUMER of the record (R10), downstream and cosmetic ───
; It reads the sheet; nothing reads it; it is never a gate on the record.  Shown
; to fix what "projection" means here, NOT to weigh surfaces -- the surface is
; settled ("in-file identifiers to a fine grain, the file extension mostly
; cosmetic and an easy way to lay out file structure").
(declare sheet-line (-> Sheet Str))
; …  one line per module for a listing: name, cat letter, crossing count.
;    A filename scheme, if one is ever wanted, is another function of the same
;    shape and the same rank — never an input to anything above.
```

**Knobs to modify:**

- **The crossings SENSE.** `crossings-of` is the whole choice. Switching from
  (a) BINDS to (c) OBJECT is a different producer for the same field — but they
  disagree on `backend` (one name vs zero), so this is a real decision, not a
  tuning knob. See open question 1.
- **`ExpKind`.** Add an `(ek-entry)` arm if "does it define an entry" is wanted
  as a grain of `exports` rather than a seventh field. Adding an arm breaks every
  consumer's `case` on purpose — that is the exhaustive-case guarantee.
- **`Sheet`'s field list.** It is total by construction: adding a field is a
  deliberate act that touches every producer. That cost is the point.
- **Where `build-sheet` runs.** At coordinate close (`kinds-close`) it is
  finished with the module. Running it lazily at first query would make it
  cheaper and would reintroduce a half-derived window; do not.

**Deliberately omitted:**

- **A per-def typeability letter.** Its falsifier has never been run; making a
  claim about it here is how a wrong shape gets built twice.
- **A closed `Crossing` sum.** It would duplicate `crossing-wraps` (Finding 8);
  generating one *from* that table is a separable change.
- **The `git mv` pass and any filename scheme.** R10 — downstream of everything
  here.
- **Annotating the other ~128 modules.** R9 keeps them compiling untouched.

## 6. Use / modify notes

**Lands in:**

- `scaffold/lib/kernel.chiral` — the `Sheet` / `Export` / `ExpKind` sums beside
  `KCat`/`KAlt` (`:91-93`); a `sheets` field on `Sig` (`:126-135`) with its
  accessor beside `sig-kinds` (`:145`); `find-sheet` / `sig-sheet` beside
  `find-target` / `sig-profile` (`:148-156`); `def-crosses` beside
  `sig-prim-crosses` (`:242-243`).
- `scaffold/lib/loader.chiral` — `build-sheet` called from `kinds-close`
  (`:150-157`), so the record is finished exactly when the coordinate closes.
  ⚑ **And `kinds-close-bodied` (`:174-181`) must learn to close a def-less
  coordinate**, or a façade's record is charged the next module's defs (345 of
  them on the committed blob — Finding 4). The bound is documented at `:141-146`
  and is inert only because a claimless coordinate contributes no emit row;
  E161 removes that immunity. Open question 6.
- `scaffold/lib/parse.chiral` — the `(module … (cat …))` reader replacing/aliasing
  `handle-kind` (`:1110-1149`, dispatched `:1178`); the `(pure)`/`(crosses)`
  clause and its `KErr` arms `k-claim-unknown` / `k-claim-shape` (`:1051-1052`)
  are **removed**, not repurposed; charging hooks on the `extern` / `porttype` /
  `data` heads (`:1169-1171`).
- `scaffold/lib/compile-emit.chiral` — `kv-first-crossing` (`:315-321`) stops
  truncating at the first crosser if sense (c) is chosen; `kind-offender`
  (`:344-348`) and `KvErr`'s `kv-pure-crosses` / `kv-crosses-pure` /
  `kv-crosses-empty` (`:291-294`) lose their subject once the claim is not
  writable, and must be **retired**, not left dead.
- `scaffold/lib/compile-front.chiral` — `kind-rows` (`:299-307`) and `FR`'s
  `kinds` field (`:312-315`) exist only to carry the claim to the emit gate; if
  the gate goes, so do they.
- The six annotated modules — `collections:12`, `pretty:12`, `prelude:13`,
  `ports:52`, `target-linux:17`, `string-utils:12`: their `(pure)`/`(crosses)`
  clauses are dropped, their letters kept.
- **NOT** the compiler's file seam: it is `Str -> ELF` and never sees a filename.

**Conformance target (golden behavior):**

1. The six annotated modules load with their letters, without their claims, and
   the program compiles.
2. `backend.chiral` (13 defs: 7 `=>`, 6 `->`; 4 externs; 1 porttype; 9 data)
   yields a record whose `exports` reproduces those counts at def grain and whose
   `crossings` reproduces the chosen sense exactly — one name under (a), zero
   under (c). Both are checkable; the target must name which.
3. `ports.chiral` — the façade — yields a **total** record with no absent field
   and with derived lists that are **empty rather than borrowed** (Finding 4).
   This fails on the loader as it stands: `ports`'s coordinate never closes, so
   the 345 defs that follow it in the blob are charged to it. The target is the
   gate on that fix, not an assumption that it is already true.
4. Adding `(def be-stream (=> Str Unit) …)` to a module changes its record with
   **no** author action, and the new name appears with `ek-proc`.
5. Writing a derived field is refused by the reader's existing `(k-shape)` arm
   (`parse.chiral:1057`), with no new check.
6. `(module <m> (cat A))` over a module whose `crossings` is non-empty is a
   compile error naming **module + crossing**. Baseline for comparison: the
   existing emit gate's refusal names **module + def + crossing** (`kv-pure-crosses
   (m Str) (fn Str) (x Str)`, `compile-emit.chiral:292`, rendered `:298-300`).
   Under sense (a) there is no def to blame — the module binds the extern itself —
   so the missing component is not a lost blame chain; under sense (c) it is, and
   `SheetErr` would need the `fn` field back. Another consequence of open
   question 1.
7. `(sig-sheet sig "backend")` returns the record in one assoc scan, with no
   traversal of the module's defs.
8. A module with no `(module …)` form compiles exactly as today (R9).
9. B1 over the same blob still reproduces itself byte-identically.

**Open questions (author-tier — not resolved here):**

1. **Which sense of "crossings", and does the record cover re-exports?**
   Finding 3 measures three inequivalent derivations that disagree on `backend`
   (one name / unknown / zero). Finding 4 shows `ports.chiral` — a façade whose
   crossings *"live one import down"* — gets an empty record under all three
   unless the field is transitive through imports. The schema is worth nothing
   until this is named; leaving it open is `certificate-discipline`'s residual
   vacuity with the label on.
2. **Is `alt` derived, and by what?** The requirements' §5 sample marks it
   derived while §4 and §8 retire only the port-set claim (Finding 5). Nothing
   computes altitude today, and the proposed tal-ir/TIFn heuristic reads the
   import graph, not the module. Under R7 a field with no honest derivation is
   the schema's weakest point: either it stays authored (two authored fields, and
   §4's "one authored field" needs restating) or it needs a real derivation.
3. **Source file or `Sig`?** Presented in §4 with both cost columns and a stated
   basis. **Not decided here** — the author's call.
4. **Where does the object-code crossing analysis go?** *Not* whether the emit
   gate is retired — that is settled by the requirements (§4, §10.6): the
   authored claim goes, so `kind-offender`, its three `KvErr` arms, `kind-rows`
   and `FR`'s `kinds` field lose their subject and are **retired, not left dead**.
   What is open is that retiring them removes the only consumer of sense (c),
   the object-code analysis (`xw-code` with an empty allow-set). Either the
   datasheet holds sense (c) and inherits it, or sense (c) keeps a home
   elsewhere, or the analysis goes with the gate. A consequence of question 1.
5. **Does the per-def typeability letter survive at all?** Its falsifier —
   hand-annotate `term.chiral` and `backend.chiral` and see whether any def's
   letter differs from its module's — **has never been run**. Run it before any
   spec claims value for it.
6. **How does a def-less coordinate close?** ⚑ Found by this audit and measured,
   not a taste question — only the remedy is the author's. `kinds-close-bodied`
   (`loader.chiral:174-181`) will not close a coordinate that has charged no def,
   so on the committed blob `ports` swallows the 345 defs that follow it
   (`blob.chiral:10781`). E160 is immune because a claimless coordinate raises no
   emit row (`compile-front.chiral:305`); a total schema is not. The candidates
   are: close on the next `kind`/`import` regardless of `ds`; charge `data` /
   `porttype` / `extern` (the R2 hooks) so a façade has a body and closes
   normally; or make the record explicitly transitive so a façade's fields come
   from its imports (which is question 1's sense (b)). **R7 and R9 are both
   unmeetable until one is picked** — a façade's record is otherwise wrong, not
   merely weak.

**Related:** [[E160]] · [[certificate-discipline]] · [[decision-effect-facets]] ·
[[pattern-boundary-sums]] · [[axis-typeability]] · [[docs/banks/module]]
