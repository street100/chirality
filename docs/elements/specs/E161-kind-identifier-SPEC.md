---
element: E161
slug: kind-identifier
title: The module datasheet — a compiler-filled record with one authored field, a declared extent, and a lookup
kind: BUILD-PROPER
reference_class: OURS
example: examples/E161-kind-identifier.md
requirements: examples/E161-REQUIREMENTS.md
status: audited
updated: 2026-08-23
---

# E161 SPEC — the module datasheet

> Implementation contract produced by the `example-to-spec` run.
>
> **Authority order for this file:** live CODE > `examples/E161-REQUIREMENTS.md`
> (the scope authority) > `examples/E161-kind-identifier.md` (the reviewed
> rationale). Every disagreement found while writing this spec is recorded in
> §6.4 rather than silently reconciled.

---

## 1. Deliverable

**After this runs:** every module in a blob has a **declared extent** and, if it
carries a `(module <n> …)` form, a **total `Sheet` record in the `Sig`** whose
`crossings` / `exports` / `mints` fields the compiler fills from the module's own
forms and which no surface production can write; the sole authored field `cat` is
**fenced** by those derived facts (`crossings` non-empty ⇒ not `(cat A)`); and
`(sig-sheet sig "<n>")` returns that record in one assoc scan. E160's authored
`(pure)` / `(crosses)` port-set claim and its whole emit-gate apparatus are
**retired**, not left dead.

**Non-goals (residue homes in §6):**

- No filename / layout projection, no `git mv` pass. R10: a projection is a
  *consumer* of the record, downstream and never a gate.
- No transitive (sense-b) crossings field. Decision D1 makes (b) a **fold over
  (a)** performed by the consumer — composition, no field, no new pass.
- No sense-(c) object-code analysis on the datasheet. It stays where it belongs,
  in the H8 profile gate (`xw-code` / `cw-wrappers` / `cw-extern-of` are
  untouched).
- No per-def typeability letter. The falsifier was **run** for this spec (§3, D6)
  and does not support building it.
- No annotation of the other ~143 unannotated modules (149 `.chiral` files under `scaffold/lib`, six annotated). R9 keeps them compiling untouched.
- No closure-conversion provenance. The lifted-lambda bound
  (`compile-emit.chiral:283-290`) is not in scope; under D1 it also stops
  mattering, because sense (a) never reads object code.

---

## 2. Baseline (what already exists)

**Conformance-map verdict:** none — E161 postdates the map snapshot; the pack
reports `(none — treat as BUILD)`. The build-state authority for this element is
therefore the E160 ledger row (`docs/elements/ledger.md:280`, `built` + a recorded
shipped defect) and the live code below, each line re-read for this spec.

**Live code this composes with — do NOT respec it:**

| shard | home | state |
|---|---|---|
| `ModKind` record (name/cat/alt/claim/open/defs) | `kernel.chiral:122-124` | ships |
| `KCat` / `KAlt` / `KClaim` sums | `kernel.chiral:91-93` | ships |
| `Sig`'s 8th field `kinds` + `sig-kinds` | `kernel.chiral:126-135`, `:145` | ships |
| `find-target` / `find-profile` / `sig-target` / `sig-profile` — the `(-> Sig Str (Maybe T))` house shape the lookup copies | `kernel.chiral:148-156` | ships |
| `ty-crosses` / `seat-crosses` — per-def crossing off the Pi spine | `kernel.chiral:162-168` | ships |
| `sig-prim-crosses` — the one-line twin `def-crosses` copies | `kernel.chiral:242-243` | ships |
| `sig-global-ty` | `kernel.chiral:235` | ships |
| `kinds-close` / `sig-add-kind` (a `kind` form closes any open coordinate) | `loader.chiral:150-161` | ships |
| `kinds-note-def` / `sig-note-def` (charge a def to the open coordinate) | `loader.chiral:162-172` | ships |
| `kinds-taken` / `sig-kind-taken` (redeclaration by NAME) | `loader.chiral:186-193` | ships |
| `handle-kind` + `KErr` + `k-msg` (load-time shape/axis/redecl refusals) | `parse.chiral:1046-1068`, `:1110-1149` | ships |
| toplevel head dispatch | `parse.chiral:1166-1189` | ships |
| the two providers that concatenate modules | `bin/chirality-resolve.sh:47-97` (`chirality_blob`), `lib/module/resolve.chiral:318-324` (`concat-mods`) | ship. **NOT pinned against each other today** — `scaffold/tests/test_resolve_chirality.py` runs only the shell provider (substring + ordering checks) and then type-checks `resolve.chiral` with the *Python* checker; it never runs `scaffold/build/resolve` and never compares two blobs. The differential is built by §5 G0, in bash. See §6.4 finding 8 |
| E160 gate | `scaffold/tests/test-module-kind.sh`, driven from `run-native.sh:190-199` (Phase 8) | ships, **29** assertions — measured by RUNNING it, not by counting call sites. Counting `refuse`/`accepts`/`mod_runs`/`mod_refuses` gives 26 and is wrong: there is a **fifth** helper, `appended` (`:277-293`), with 3 calls (`:297-299`). It builds `chirality_blob <root>` and appends the program, which is the shape R9's and G12's cases need. The ledger row's "29-case" figure is correct; an earlier draft of this spec called it stale |

**Retiring, not surviving** (§4 Step 7): `kind-offender` /
`kind-offender-go` (`compile-emit.chiral:322-348`), `kv-named` (`:307-312`),
`kv-first-crossing` (`:315-321`), `KvErr`'s three arms + `kv-msg`
(`:291-305`), the emit call site (`:364-365`), `kind-rows` + `krev`
(`compile-front.chiral:297-307`), `FR`'s `kinds` field (`:312-315`), its
producer (`:341-343`) and its consumer destructure (`compile-all.chiral:22`).
`xw-code`, `cw-wrappers` and `cw-extern-of` **survive** — H8 still uses them
(`compile-emit.chiral:263`, `:361`).

**True delta.** Five things, and only one is new analysis:

1. a **declared module extent** in the blob text (new form, both providers);
2. **charging** `extern` / `porttype` / `data` heads, which charge nothing today
   (`parse.chiral:1169-1171`);
3. the **`Sheet` schema + `Sig` field + `sig-sheet` lookup** (a ninth registry in
   the shape of the eight that ship);
4. the **`cat` fence** — the one genuinely new check;
5. the **retirement** of the authored claim and its gate.

Everything the derivation reads already exists. The example's honest phrasing
holds and this spec repeats it: *one new check, three charging hooks, one
one-line derivation, one lookup* — plus the extent, which is E160's shipped
defect and is prerequisite, not optional.

---

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| D1 | Which sense of "crossings" does the schema hold? (example Q1) | **RESOLVED — sense (a), DECLARED** | `PRINCIPLES.md` **P3**: *"you govern the membrane it must cross, not the interior."* A module's membrane is what it binds outward — its own `=>` externs. Cited as decided in `examples/E161-REQUIREMENTS.md:§11 FLAG 1` and on the ledger row (`docs/elements/ledger.md:281`). Producer: filter the charged names by `sig-prim-crosses` (`kernel.chiral:242`). On `backend` this is exactly `{backend-open}` (`backend.chiral:36`). |
| D1a | Does the record cover re-exported / transitive crossings? (example Q1, second half) | **RESOLVED — no field; it is a FOLD over (a) across imports** | Composition, not a new pass (global principle 3). A consumer that needs "does importing this put a crossing in my binary" folds the imported modules' sheets. Holding (b) as a field would duplicate what composition already gives. Requirements §11 FLAG 1. |
| D1b | Is a façade's empty `crossings` vacuous? (example Q1 / Finding 4) | **RESOLVED — empty is CORRECT, not vacuous** | Under (a), `ports.chiral` declares nothing and re-exports everything; empty *is* the true reading of its membrane. R7's live vacuity case is dissolved, not worked around. Requirements §11 FLAG 1. |
| D2 | Where does the object-code (sense c) analysis go when the emit gate retires? (example Q4) | **RESOLVED — it goes home to H8** | (c) is a property of an emitted **program**, not of a module; the profile gate already owns it (`compile-emit.chiral:238-263`, `:361`). E160 only borrowed it. Nothing is re-homed and nothing is lost: `xw-code` / `cw-wrappers` / `cw-extern-of` keep their live H8 callers. Requirements §11 FLAG 1. |
| D3 | How does a def-less coordinate close? (example Q6 — the shipped defect) | **RESOLVED — a DECLARED extent, marker chosen in this spec** | `PRINCIPLES.md` **P1** (*"the fix is never a longer denylist; it is a model that covers the whole surface"*) + global principle 5 (*push invariants into the substrate, not across a runtime seam*). The blob carries **no** module boundary; the provider knows every one and destroys it at concatenation (`chirality-resolve.sh:96`, `resolve.chiral:319-324`); `kinds-close-bodied` re-derives it by heuristic and the heuristic swallows 345 defs. Requirements §11 FLAG 5. **The exact marker is spec-grain and is decided in D3a.** |
| D3a | What is the extent marker? | **RESOLVED here, with reasoning — `(end-module "<name>")`, one provider-emitted toplevel form per module** | See the reasoning block below the table. |
| D3b | Is the coordinate NAME checked against the extent name? | **RESOLVED — yes, mismatch is a refusal** | Forced by D3a: once the extent is named, *not* checking the coordinate against it would leave two names for one thing with nothing comparing them — the exact second-source-of-truth disease this element treats (requirements §3). It also retires the standing caveat at `kernel.chiral:98-104` (*"not verifiable against the file"*): under a declared extent it becomes verifiable, so it is verified. |
| D3c | The interim "a `kind` charging no def is REFUSED" rule | **RESOLVED — carried as the FALLBACK only** | Requirements §11 FLAG 5 states it as the interim *until a declared extent lands*. This spec lands the extent (Step 1), so the interim is not the shipped shape. It is recorded here so that if Step 1 is descoped, the fallback is named and fail-closed rather than reinvented. Under Step 1 the analogous fail-closed rule becomes: **a second `(module …)` inside one extent is refused** (`k-two-in-extent`), and **a coordinate still open at EOF is legal and is CLOSED THERE** (a bare file piped to B1 has exactly one implicit extent) — legal, but not left open: build-at-close plus "never closed" would mean no sheet and therefore no fence for every provider-less source, which is fail-open. Step 1 runs the close at the end of `load-source`; §5 G12 gates it; §6.4 finding 9 records how it was found. |
| D4 | Is the "you wrote a derived field" error a new check? | **RESOLVED — no. It is the grammar.** | With one authored slot a derived field has no production; the reader's existing `(k-shape)` arm refuses it (`parse.chiral:1047`, rendered `:1057`). Requirements §10.3 says exactly this and corrects its own §5. **Only the fence is new code.** |
| D5 | Is the schema total (R7)? | **RESOLVED — total, no optional / "unspecified" field** | R7 verbatim; requirements §6. A façade carries the same fields with empty lists (D1b makes that the true reading, not a placeholder). |
| D6 | Does the per-def typeability letter survive? (example Q5) | **NEEDS-AUTHOR — but the falsifier is now RUN; result below** | See the falsifier block below the table. Not blocking: nothing in §4 builds or reads a per-def letter. |
| D7 | Is `alt` derived, a second authored field, or does it leave the schema? (example Q2) | **NEEDS-AUTHOR — non-blocking; the interim is EXPLICIT and is the status quo** | Nothing derives altitude today and nothing *reads* it either (verified: `KAlt` at `kernel.chiral:92` is stored by `handle-kind` and consumed by no analysis). The requirements' proposed tal-ir/TIFn inference reads the **import graph**, not the module, so it is a guess about the module rather than a reading of it — this spec will not build it. **Interim shipped by §4: `alt` stays AUTHORED, exactly as E160 ships it.** That is not a silent resolution — it is the baseline, carried forward unchanged, and it means §4's surface has **two** authored fields while requirements §4 says "one". The tension is real and is the author's to close: derive it, keep it authored and restate "one authored field", or drop it from the schema. **Two steps carry the interim and would both change if it closes the other way:** Step 3 puts `alt` on the total `Sheet`, and Step 5 keeps its grammar clause. Requirements §11 already rules FLAG 2 non-blocking for the spec, which is why this ships as an interim rather than a stop. |
| D8 | Does the full record live in the source file or in the `Sig`? (example Q3) | **NEEDS-AUTHOR — non-blocking; §4 builds the `Sig` side, which both answers require** | R5 and R6 hold either way, and the `Sig` record is the *common prefix*: the source-file option needs the record to exist before anything can print or compare it. Recorded so the author's later call is additive, not a rework. The example §4 states the cost asymmetry (a source-writing tool this `Str -> ELF` compiler does not have, landing a derived record in a writable text file — the `cbindgen`/`.mli` failure) and this spec neither hides nor pre-empts it. A `chirality datasheet <module>` printer is R10-class and is residue (§6). |
| D9 | Is the retired apparatus deleted or kept? | **RESOLVED — DELETED, by name, in Step 7** | The deferral rule + the built-but-unadopted pattern recorded seven times in this repo. Step 7 names every symbol and its disposition; nothing is left dead. |
| D10 | Does `crossings` mint a closed `Crossing` sum? | **RESOLVED — no; it holds extern NAMES** | `crossing-wraps.chiral:6` calls itself *"the one representation of the map the erase image can see"*. A hand-minted parallel sum would be a second source of truth for that table. `pattern-boundary-sums` is satisfied by there being one vocabulary; a genuine sum would have to be **generated from** that table, which is a separable change (§6 residue). Example Finding 8. |
| D11 | **How does the gate OBSERVE a record's contents?** | **RESOLVED — BOTH channels: an in-process reader for contents, the fence for verdicts** | Decided in `examples/E161-REQUIREMENTS.md:§12`. R6 *is* the element — *"a check is not an API"* — so a fence-only gate would ship the API untested **as an API**, which is E160's defect reproduced inside E161's own gate (global principle 6). The objection to channel (ii) was "no precedent in the tree"; **that is the finding, not a counter-argument**, and the precedent was created and measured for this spec: at HEAD, on the pre-E161 compiler, a program that `(import "parse")` and calls `load-source` (`parse.chiral:1309`, `(-> Str LoadR)`) on an inline `\n`-escaped fixture compiles in 0.15 s and exits 42, exits 3 against a deliberately wrong expectation, separates `=>` from `->` through `sig-prim-crosses`, and **already reproduces E160's live defect** (exit 4: an `(import …)` mid-module splits the module's defs). It needs **no new harness** — `mod_runs` (`test-module-kind.sh:127-141`) already resolves, compiles and runs such a program. Fence rows stay wherever a claim is fence-observable, because they exercise the real refusal path. Full verification log, harness constraints and per-row channels: §5. |

### D3a — the extent marker, and why

**Chosen: `(end-module "<name>")` — one toplevel form, emitted by the provider
immediately after each module's source text, naming the module the provider
resolved.**

Why this and not the alternatives:

- **Not "the next `(module …)` closes the previous one" (open-only, positional
  end).** This is the shape `sig-add-kind` already has (`loader.chiral:158-160`)
  and it is **unsound against R9**. An *unannotated* module that follows an
  annotated one carries no `(module …)` form, so nothing closes the annotated
  coordinate and the unannotated module's defs are charged to it. That is the
  345-def bug wearing a different hat, and it would break R9's promise that an
  unannotated module compiles exactly as today.
- **Not a paired `(begin-module …)` / `(end-module …)`.** The open is already
  declared — by the authored `(module <n> (cat …))` form. A provider-emitted
  begin would be a *second* declaration of the same boundary start, which is the
  disease. One end marker plus the authored header delimits the extent
  completely: extent *k* runs from end-marker *k-1* (or BOF) to end-marker *k*.
- **Not a comment / pragma.** Comments are stripped before the reader sees them
  (`chirality-resolve.sh:42` strips them in the import scan; the compiler's lexer
  drops them). A boundary that a lexer may discard is not declared.
- **A string argument, not a bare symbol**, to match `(import "ports")` — the
  provider's module names are already strings at that seam, and D3b compares
  this name against the coordinate's.

What it buys, all four at once: the façade closes at its **own** boundary (E160's
shipped defect fixed at the root, not patched); `kinds-close-bodied`'s heuristic
is **deleted** rather than tuned (P1 — a model, not a longer denylist); R9 holds
because an unannotated extent closes with nothing open and charges nobody; and
the coordinate name becomes verifiable (D3b).

What it costs: both providers change, and the differential test they are
supposed to have **does not exist** (`test_resolve_chirality.py` never runs the
native one — §6.4 finding 8), so §5's G0 builds it and pins both against a fixed
blob; the blob grows one line per module;
and a source compiled *without* the provider (a bare file piped to B1, and
`chirality_blob … > x.chiral && cat prog.chiral >> x.chiral`, which
`parse.chiral:1030` documents as how every sample is built) has one implicit
trailing extent running to EOF — **closed at EOF by Step 1, not merely
tolerated**, or it would carry no sheet and no fence (§5 G12). That last case is
**correct, not a hole**: one
file, one extent.

### D6 — the per-def typeability falsifier, RUN

The falsifier as the example states it (Q5): *hand-annotate `term.chiral` and
`backend.chiral` and see whether any def's letter differs from its module's.*
It had never been run. It was run for this spec, against `axis-typeability.md`'s
test — *what does its correctness rest on: proof (A) / an admitted hole the
language cannot type (B) / cross-checked evidence about a hole (C)*.

Both modules are unannotated today, so the module letter is itself part of the
hand-annotation. `term.chiral` (header `:1-10`: *"terminal-control typed wrappers
over per-request ioctl crossings"*) is **C** — a typed module whose referent is
the kernel's untypeable ioctl/termios ABI. `backend.chiral` is **C** — a typed
module over an HTTP model backend it cannot type.

**Result: letters DO differ, inside `term.chiral`.**

- `nul-byte` (`term.chiral:141`, `(bslice (pack-u32 0) 0 1)`) rests on nothing but
  proof. It is **A** in a **C** module.
- The ten ABI constants — `TERMIOS_LEN` / `TERMIOS_C_LFLAG_OFF` / `RAW_IFLAG_AND`
  / `RAW_OFLAG_AND` / `RAW_CFLAG_AND` / `RAW_CFLAG_SET` / `RAW_LFLAG_AND`
  (`:67-76`) and `F_GETFD` / `F_SETFD` / `FD_CLOEXEC` (`:185-187`) — are numbers
  transcribed from Linux headers with **no cross-check, no redundant copy, no
  attestation**. Under the axis test that is not C (which requires cross-checked
  evidence); it is **B**, an admitted hole. Ten B defs in a C module.
- `backend.chiral` by contrast is uniform: all 13 defs and 4 externs rest on
  evidence about the same untyped referent.

**So the falsifier is not satisfied — a per-def letter is not redundant with the
module letter.** And yet the result argues *against* building the field, for two
reasons the author should weigh:

1. `axis-typeability.md:12-14` — *"This is a partition, not a spectrum. If a
   module seems to be two kinds at once, it is not yet split (see
   [[splitting-law]])."* Differing per-def letters are the axis **raising its
   splitting signal**. A per-def field would let a module stay unsplit while
   looking fully annotated — it suppresses the signal the axis exists to raise.
   On this reading the finding is a diagnosis of `term.chiral`, not a schema gap.
2. The letter is not derivable at *any* grain (that is the whole reason `cat` is
   authored). A per-def letter is therefore **N authored fields**, each with the
   drift surface requirements §4 says is not worth taking by default.

**D6 stays NEEDS-AUTHOR** — the falsifier's outcome is recorded, not converted
into a decision. Nothing in §4 depends on it either way.

---

## 4. Change plan (ordered, commit-sized)

Steps 1–2 are prerequisite: without them a `Sheet` for `ports` would be charged
345 defs that are not its own (measured on `scaffold/build/blob.chiral`:
`(kind ports C upper)` at `:10781` is the last `kind` form; `345` `def` forms
follow it — re-verified for this spec). **Compiler sources change from Step 1
onward, so the full build ceremony in §5 applies to every step.**

### Step 1 — the declared extent (E160's shipped defect, fixed at the root)
- **Targets:**
  - `bin/chirality-resolve.sh` — `chirality_blob`'s emit loop (`:96`) and
    `chirality_blob_file` (`:106-145`).
  - `scaffold/lib/resolve.chiral` — `concat-mods` (`:318-324`).
  - `scaffold/lib/parse.chiral` — `load-form`'s head dispatch (`:1166-1189`).
  - `scaffold/lib/loader.chiral` — `kinds-close-bodied` / `sig-close-bodied`
    (`:174-184`), the KNOWN BOUND comment (`:141-146`).
  - `scaffold/lib/kernel.chiral` — the `open`/scope commentary (`:96-121`).
- **Change:** each provider emits `(end-module "<name>")` after a module's source
  (`<name>` = the resolver's module name, the same one E155's basename rule
  keys). New toplevel head `end-module` dispatches to `sig-close-extent`, which
  (a) refuses if the open coordinate's name differs from the extent name
  (`k-extent-name`, D3b), (b) closes the open coordinate **unconditionally**, and
  (c) is a no-op when nothing is open (R9). **The same close also runs at the end
  of `load-source`** (`parse.chiral`) **and at `rest-batched`'s `batch-done` arm
  in `load-batch.chiral`** — two sites, and the second is the one that matters:
  `load-source-batched` is the loader `compile-front` actually runs, so a close
  only in `load-source` is fail-open where it counts. Measured 2026-08-23 with a
  discriminating probe (extent open ⇒ exit 7, closed ⇒ 42): at Step 1 as first
  committed the batched path returned **7**. So a source compiled without the
  provider — `B1 < file`, and the `chirality_blob … && cat prog >>` shape
  `parse.chiral:1030` documents — closes its one implicit extent and therefore
  gets a sheet and a fence. Without this, D3c's "unclosed at EOF is legal" would
  mean *no sheet, no fence* for exactly those sources: fail-open, silent, and the
  same class as the defect being fixed. Found by writing §5's gate; pinned by
  G12. **The marker is emitted only for modules the provider RESOLVED from the
  libdir; a root file appended by `chirality_blob_file`'s third branch (`:155`) gets
  none** and closes at EOF instead. Precise, because the first two branches
  matter: when the root file *is* a module of the libdir (by canonical path, or
  reachable through one of the symlinked subdirectories), `chirality_blob_file`
  delegates to `chirality_blob` and the file **does** get a marker — it has a
  resolver key there. So `parse.chiral:1030`'s append shape has two forms and the
  gate must know which it is exercising. Decided here rather than left to the implementer,
  because the alternative — naming the root's extent after its file basename —
  would make D3b compare a coordinate against a `mktemp` name and would refuse
  ~10 of the gate's own fixtures. One consequence to build for: **every fence row
  whose module under test is the ROOT therefore closes at EOF**, so the EOF close
  is the gate's main path, not an edge case; the marker path is exercised
  separately by G0, G2b, G6 and G7. `kinds-close-bodied` /
  `sig-close-bodied` are **deleted** and `import` returns to installing nothing
  (`parse.chiral:1189`). A second `(module …)` inside one extent is refused
  (`k-two-in-extent`) instead of silently closing the first.
- **Size:** M. Touches both providers — and **the byte-for-byte differential
  this step needs does not exist yet**: `test_resolve_chirality.py` never runs the
  native provider (§6.4 finding 8). §5's **G0** builds it in bash against the
  committed `scaffold/build/resolve`, and pins both providers against a **fixed
  expected blob** as well as against each other, because a marker emitted
  identically-wrongly by both would pass a differential silently
  (`examples/E161-REQUIREMENTS.md:§12`). G0 is therefore this step's immediate
  check and lands with it.

### Step 2 — charge every export head at def grain
- **Targets:** `scaffold/lib/loader.chiral` (`kinds-note-def` / `sig-note-def`,
  `:162-172`); `scaffold/lib/parse.chiral` (`:583`, `:597` for `def`;
  `:1169-1171` for `data` / `extern` / `porttype`).
- **Change:** widen the charge from `Str` to `(Pair Str ExpHead)` — a **new**
  closed sum `(data ExpHead () (eh-def) (eh-data) (eh-extern) (eh-porttype))` in
  `kernel.chiral`, which is which-head-charged-this and is deliberately **not**
  the datasheet's `ExpKind`: `ek-fn`/`ek-proc` is a reading of the def's arrow,
  unknowable at charge time, and forcing it into one sum would need an
  "undetermined" arm — the `unspecified` value D5's total schema forbids. Step 4
  maps `eh-def` through `ty-crosses` and the other three straight across, a total
  function with no default arm. `fn` vs `proc` is **not** charged here, so there
  is no second copy.
- **⚑ THE HOIST — measured, and it changes this step's shape.** Two of the three
  heads **cannot** charge at their handler. `load-source` installs every
  porttype first, then the whole data group at once, and only then walks the rest
  linearly — over `keep-rest forms`, which **dropped** data and porttype forms.
  At install time no `kind` form has been read and no coordinate is open: the
  hoist destroys exactly the position the charge needs. So the charge goes where
  the module of origin is still visible — the linear pass — as a **charge-only**
  arm (`handle-hoisted`), `keep-rest` is deleted rather than left as an identity,
  and phase 1 installs through `install-porttypes` instead of the now
  charge-only dispatch. Two consequences outside this step's file list, both
  forced: `load-batch.chiral` (the twin `compile-front` actually runs) needs the
  same two-phase change, and `compile-front.chiral`'s `kind-rows` must project
  the `eh-def` charges so E160's port-set gate keeps its exact defs-only
  semantics. Also found: `handle-data` was **dead code at HEAD** — `load-form`'s
  `data` arm was its only caller and no path ever fed `load-form` a data form.
- **Size:** M.

### Step 3 — the `Sheet` schema, the `Sig` field, and the lookup
- **Target:** `lib/typing/kernel.chiral` — `ExpKind` / `Export` / `Sheet` beside
  `KCat` (`:101`) and `KAlt` (`:107`); a ninth `sheets` field on `Sig`
  (`:228-238`) with `sig-sheets` beside `sig-kinds` (`:248`); `find-sheet` /
  `sig-sheet` in the shape of `find-target` (`:255`) / `sig-profile` (`:263`).
- **Change:** exactly the example §5 block. `Sheet` is **total** (D5): `name`,
  `cat`, `alt`, `crossings`, `exports`, `mints`, every field present on every
  record, no `Maybe`. Adding the ninth field is the largest mechanical edit in
  this element: **38 real `mk-sig` sites across 5 files** — every construction and every
  `(case s ((mk-sig …)))` destructure gains a binder. `grep -o 'mk-sig'` reports
  **40**; two of those are the word inside an `(import "loader")` trailing
  comment (`closconv-driver.chiral:23`, `specialize-singleton.chiral:16`) and are
  not applications. Per file: `kernel.chiral` 9, `kernel-core.chiral` 1,
  `loader.chiral` 23, `closconv-driver.chiral` 2, `specialize-singleton.chiral` 3.
  Measured twice: `grep -c` gives 32 because it counts LINES and a destructure
  usually shares its line with a construction.
- **Size:** L (mechanically, not conceptually). Its own commit — a half-applied
  arity change does not compile, so it must not share a commit with Step 4.

### Step 4 — the derivation, run at coordinate close
- **Targets:** `scaffold/lib/kernel.chiral` (`def-crosses` beside
  `sig-prim-crosses`); `scaffold/lib/loader.chiral` (`build-sheet`). **There are
  THREE close sites, not the two this said** — `handle-end-module`,
  `load-source`'s EOF close, and `load-batch.chiral`'s
  `rest-batched`/`batch-done` — and all three funnel through the single
  `sig-close-extent`, so one edit there covers every path. Verified on all four
  combinations (marker close and EOF close × `load-source` and
  `load-source-batched`).
- **Change:** `def-crosses` = `sig-prim-crosses` over `sig-global-ty` instead of
  `sig-prim-ty` (one line, the twin). `def->export` tags `ek-fn`/`ek-proc` from
  it. `crossings-of` = filter the charged extern names by `sig-prim-crosses`
  (**sense (a)**, D1). `mints-of` = the porttype heads charged in Step 2.
  `build-sheet` runs **at close**, never lazily — a lazy first-query build
  reintroduces a half-derived window (example §5 "Knobs"). Source order comes
  from one reverse. **There is no reverse in the prelude** — measured; the
  polymorphic `reverse` / `rev-onto` live at `collections.chiral:26-34`, so
  `loader.chiral` imports `collections` for it. That honours the real instruction
  (do not mint a second `krev`; it is deleted in Step 7, and BUILD-ORDER §A1
  counts ad-hoc helper copies as an altitude defect) at the cost of one declared
  import edge. Blob module order is provably unchanged — `collections` already
  preceded `loader` through `surface`→`sexp`.
- **Size:** M.

### Step 5 — the surface: `(module <n> (cat …) (alt …))` replaces `(kind …)`
- **Target:** `scaffold/lib/parse.chiral` — `handle-kind` (`:1110-1149`), `KErr` +
  `k-msg` (`:1046-1068`), dispatch (`:1178`).
- **Change:** new head `module`; the `(pure)` / `(crosses)` clause is **removed
  from the grammar** and with it `KErr`'s `k-claim-unknown` / `k-claim-shape`
  arms and their `k-msg` cases (`:1051-1052`, `:1065-1068`). `KClaim`
  (`kernel.chiral:93`) and `ModKind`'s `claim` field (`:122-124`) are deleted.
  `(alt …)` stays authored per D7 — it is E160's field carried forward, with a
  `; ⚑ AUTHORED PENDING D7` marker at its declaration so the open decision is
  visible in the code, not only here. **Three** new `KErr` arms, added in Step 1 and listed here because Step 5 owns
  the grammar: `k-two-in-extent (n Str)`, `k-extent-name (declared Str) (extent
  Str)`, and `k-extent-shape` — a malformed `(end-module …)` needs its own
  message, since reusing `k-shape` would print the `(kind …)` grammar at someone
  who wrote an extent marker. (The spec said two; measured while building it.)
  The six annotated modules lose their claim clauses and keep their letters:
  `collections:12`, `pretty:12`, `prelude:13`, `ports:52`, `target-linux:17`,
  `string-utils:12`.
- **Size:** M.

### Step 6 — the fence (the one new check)
- **Target:** `scaffold/lib/loader.chiral` — `SheetErr` / `sh-msg` /
  `cat-fenced`, run from `build-sheet`'s close path so a bad letter is refused at
  **load**, not at emit.
- **Change:** exactly the example §5 `cat-fenced` block. `(cat A)` over a module
  whose derived `crossings` is non-empty is refused, naming **module + crossing**.
  One-directional on purpose (example Finding 7): `B`/`C` over a module with no
  crossings is legal — `target-linux` ships `B` and pure, `ports` ships `C` with
  none of its own.
  **Blame-chain note, and it is not a loss:** the retired gate named
  *module + def + crossing* (`kv-pure-crosses`, `compile-emit.chiral:292`). Under
  sense (a) there is no def to blame — the module binds the extern itself — so
  the missing component names nothing that exists. Stated so the message
  regression is a decision, not an oversight.
- **Size:** S.

### Step 7 — retirement, by name
- **Targets and disposition (all DELETED unless stated):**
  - `compile-emit.chiral` — `KvErr` + its three arms + `kv-msg` (`:291-305`);
    `kv-named` (`:307-312`); `kv-first-crossing` (`:315-321`);
    `kind-offender-go` (`:322-342`); `kind-offender` (`:344-348`); the call site
    and its `elf-err` (`:364-365`); the H7/H8 scope comment that describes the
    retired gate (`:283-290`) is **rewritten**, not deleted, since H8's own bound
    still needs stating.
  - `compile-front.chiral` — `kind-rows` (`:299-307`); `krev` (`:297-298`, no
    other caller — verified); `FR`'s `kinds` field (`:312-315`); its producer
    argument (`:341-343`); the comment at `:295-296`.
  - `compile-all.chiral:22` — the `(fr-ok defs datas prims ports kinds)`
    destructure loses its last binder.
  - **Not named above and forced:** deleting `FR`'s `kinds` field leaves nothing
    to pass, so `emit-elf-m` goes 5 → 4 parameters and `emit-elf` drops its
    `nil` argument. Likewise `KClaimR` / `k-claim-of` in `parse.chiral` are
    `KClaim`'s reader and go with it (replaced by one keyed `k-clause-of`), and
    `kdef-names` — added in Step 2 to project the `eh-def` charges for
    `kind-rows` — is orphaned when `kind-rows` goes and is deleted with it.
  - **SURVIVING, do not touch:** `xw-code` (`:238-249`), `cw-wrappers`
    (`:211-213`), `cw-extern-of` (`:215-218`) — all three have live H8 callers
    (`:263`, `:361`). This is D2 in code: sense (c) goes home, it does not die.
- **Size:** M. Ships in the same commit as Step 5 if the tree will not build
  between them; otherwise its own commit.

### Step 8 — the gate
- **Target:** `scaffold/tests/test-module-kind.sh` (rewritten as the E161
  datasheet gate) + `scaffold/tests/run-native.sh:190-199` (Phase 8 re-headed).
- **Change:** §5's case list (G0–G12, 26 assertions) on top of the **18** E160
  rows that still hold (shape, axis values, redeclaration-by-name, optionality,
  coordinate-before-or-after-imports, and the three `appended` boundary rows);
  the **11** port-set-claim rows retire with the claim. Fence rows use the
  script's **five** existing helpers — `refuse` / `accepts` / `mod_runs` /
  `mod_refuses` / `appended` (`:277-293`, the one an earlier draft missed;
  `chirality_blob <root>` + appended program is exactly the G9/G12 shape). **In-process rows need no new helper** — each is a
  `mod_runs <desc> 42 <reader-program>` whose source imports `parse`, calls
  `load-source` on a one-literal fixture and returns §5's exit-code table. Only
  **three** helpers are added: `blob_is` (a provider's output vs a committed
  expected blob, G0), `absent` / `present` (grep `scaffold/lib/`, G11), and
  `fx_blob` (a per-row fixture libdir, so the module under test is one the
  provider closed with a marker — G0, G2b, G6, G7). The
  fixtures obey the measured hermetic-loader constraint in §5: only `I64`,
  `Str`, `Bytes` and self-declared `data` types are in scope.
- **Size:** M.

---

## 5. Conformance gate

**Golden behavior.** The record is a projection, not a source: it cannot be
written, cannot disagree with the module, and cannot silently fail to change.

### D11 RESOLVED — both channels, and the reader is VERIFIED against the live tree

Decided in `examples/E161-REQUIREMENTS.md:§12`: **the gate reads the record in
process** (`load-source` + `sig-sheet`), *and* uses the fence wherever a claim is
fence-observable. R6 *is* the element — *"a check is not an API"* — so gating only
through checks would ship the API untested **as an API**, which is E160's exact
defect reproduced inside the gate of the element built to fix it.

The previous draft of this section left the channel open and five rows therefore
named no runnable check. That is now closed, and closed by **measurement rather
than by assertion**: the in-process reader was built and run **at HEAD, on the
pre-E161 compiler** (`scaffold/build/B1`, 2026-08-23), because "no precedent in
the tree" was the only argument against it and precedent is cheap to create.

| probe | fixture | result |
|---|---|---|
| the reader compiles and runs at all | `(import "parse")`; `load-source` on an inline `\n`-escaped source; destructure `sig-kinds` | `chirality_blob_file` → 231,973 B blob; B1 compiles it in **0.15 s**; **exit 42** |
| the reader DISCRIMINATES | same program, expecting the wrong module name | **exit 3** — so a reader that always exits 42 is not what was measured |
| the derivation's producer works on a hermetic fixture | `(extern zz-out (=> I64 I64))` + `(extern zz-pure (-> I64 I64))`, then `sig-prim-crosses` on each | **exit 42** — `=>` and `->` separated, sense (a) computable from the fixture alone |
| **the reader already sees E160's live defect** | `(kind m A upper)` · `(def a …)` · `(import "nosuch")` · `(def b …)` | **exit 4** = `b` is NOT charged to `m`. The unfixed compiler *is* the mutant, and the row fails on it today. |

The fourth probe is the strongest evidence this gate has teeth: its mutant is not
hypothetical, it is the shipped compiler, and the row already distinguishes it.
(The probes ran against the **pre-E161** compiler, where no `Sheet` exists, so
they read `sig-kinds` / `sig-prim-crosses` and use ad-hoc non-42 codes — 3 for a
wrong name, 4 for "only one def charged". The shipped rows use the exit-code
table below; the probes establish the channel, not the row bodies.)

**Harness facts, measured — these are what the implementation must respect:**

- **No new helper is needed for in-process rows.** `mod_runs <desc> 42 <src>`
  (`test-module-kind.sh:127-141`) already resolves through `chirality_blob_file`,
  compiles with B1, runs the ELF and compares the exit code. An in-process row
  *is* a `mod_runs` row whose source happens to import `parse`.
- **Three new helpers are needed**, all trivial, all for rows the four existing
  helpers genuinely cannot express: `blob_is` (a provider's output vs a fixed
  expected blob, G0); `absent` / `present` (grep `scaffold/lib/`, G11); and
  `fx_blob` (build a blob from a **fixture libdir** created for the row, so the
  module under test is one the provider resolved and therefore closed with a
  marker). `fx_blob` is not optional: `blob_of` (`:122-126`) only ever writes the
  ROOT, and a root carries no marker (Step 1), so without a fixture libdir the
  marker-close path — G0, G2b, G6, G7 — could not be reached at all.
- **The fixture is hermetic by construction.** `load-source` starts from
  `empty-sig` + `base-senv` (`parse.chiral:1315`), so the record the reader
  observes comes from the inline text alone — the ~232 KB of library modules
  ahead of it in the blob cannot contaminate it, and the reader needs no
  `end-module` discipline from the provider to isolate its fixture.
- **The hermetic fixture may name only `I64`, `Str`, `Bytes`** (`base-senv`,
  `parse.chiral:451`) plus whatever it declares itself with `data`. `Unit`, `Bool`
  and `Maybe` are **prelude data types and are not in scope**: measured —
  `(extern zz-out (=> Str Unit))` inside a fixture fails with
  `load: unknown name Unit`. Fixtures use `(=> I64 I64)`-shaped externs, or
  declare their own atom. This single fact would otherwise cost the implementer a
  debugging cycle per row.
- **One string literal carries a multi-form fixture.** The escape set is
  `\n \t \" \\` (`sexp.chiral:178-206`), so a whole module — `(module …)`,
  `def`s, `extern`s and its `(end-module …)` — is one `(def FIXTURE Str "…")`.
- **Only `(import "parse")` is required.** The blob is a flat concatenation, so
  `sig-sheet` / `sig-kinds` / `mk-modkind` are visible transitively; naming
  `kernel` too is harmless and is clearer, and neither was needed in the probes.

**Reader exit-code table** — every in-process program uses it, so a failure names
its branch instead of only saying "not 42":

```
42  the record matched the expectation exactly
 1  load-source returned (ld-err …)  -- the fixture did not even load
 2  sig-sheet returned none where some was expected
 3  sig-sheet returned some where none was expected
 4  name mismatch      5  cat mismatch       6  crossings mismatch
 7  exports mismatch   8  mints mismatch     9  list arity mismatch
```

### Tests to add — `scaffold/tests/test-module-kind.sh` (native, zero Python)

Every case was written so that **mutating the corresponding check in the compiler
source and rebuilding makes it FAIL**. The mutant is named per case. `channel` is
`fence` (compile status / refusal text / program exit — the four existing
helpers), `in-proc` (a `mod_runs` reader program, per the table above), or
`provider` (a resolver run compared against a fixed blob).

| # | n | channel | case | mutant it must catch |
|---|---|---|---|---|
| G0 | 4 | provider | **the extent marker, pinned against a FIXED blob — not only provider-against-provider.** A three-module fixture (`fa` with a coordinate, `sub/fc` in a subdirectory, root `fb` importing both) is resolved by (a) `chirality_blob`, (b) the native provider, **built by the row itself** (`chirality_blob scaffold/lib resolve \| B1 > $T/resolve`) and driven as `printf -- '-L <dir>\n<root>\n' \| $T/resolve` — `scaffold/build/` is **gitignored**, so a row that used the committed binary would either read a stale provider or silently skip, which is the "reported ok forever" failure §12 names; each compared against **one committed expected blob**; (c) the two outputs are `cmp`-identical; (d) `chirality_blob_file` on a root **outside** the libdir is pinned against its own fixed blob, showing the root's text appended with **no marker** (Step 1) — the case that decides whether the gate's own fixtures are refusable by name. Also pins that the marker's name is the **basename** (`sub/fc` ⇒ `(end-module "fc")`), which is the name D3b compares against. | **both providers emitting the same wrong marker** — the failure class §12 names, and the one a differential alone cannot see. Verified today: on this fixture minus the marker, both providers already agree byte-for-byte (native rc 0, shell rc 0, `cmp` identical), so (c) is a real check and not a tautology. |
| G1 | 1 | in-proc | a module binding one `=>` extern and several `->` externs, with defs ⇒ `(sheet-crossings s)` is exactly the **one** `=>` name and `exports` carries every charged head with `ek-fn`/`ek-proc` from its stored type | make `crossings-of` return all charged externs (sense drift) → 6; charge only `def` heads (Step 2 reverted) → 7 |
| G2 | 2 | fence | **the fence, on both close paths.** G2a: an inline root — `(module m (cat A) …)` binding one `=>` extern, no marker — is REFUSED naming **module + crossing** (closes at EOF). G2b: the same module placed in a **fixture libdir** and imported, so the provider closes it with `(end-module "m")` — also REFUSED, same message | make `cat-fenced` return `none` unconditionally → both fail. Running it on both paths is the point: a fence wired only to the marker close would pass G2b and silently ignore every hand-compiled source, which is G12's failure one row earlier |
| G3 | 3 | fence | **one-directionality.** `(cat B)` and `(cat C)` over that same crossing module are ACCEPTED; `(cat A)` over a module binding only `->` externs is ACCEPTED | make the fence bidirectional (`B`/`C` ⇒ must cross) → G3 fails. Step 6 / example Finding 7 |
| G4 | 1 | fence | **the grammar (D4).** `(module m (cat A) (crossings foo))` is REFUSED by the existing `(k-shape)` arm | add a `crossings` production to `handle-kind` → G4 accepts → fails. Pins "derived fields are not writable" as *absence of a production* |
| G5 | 2 | in-proc + fence | **FAÇADE, the R7/D1b case.** In-proc: a two-module fixture in one literal — a façade (`(module f (cat C) …)`, one `data`, **no def**, `(end-module "f")`) followed by a module with defs — ⇒ the façade's sheet is **total**, its `crossings` and `mints` empty and its `exports` holding **its own `data` head** — not empty: `data` is an export head, so `ports` really derives `exports=[Port:data]`, and the pre-build draft of this row was wrong — and the second module's defs land on the second module's sheet. Fence: the real blob, where `lib/ports/ports.chiral` is that façade | revert Step 1 (drop the `(end-module …)` emission, or make the close conditional on `ds` again) → the façade's `exports` lists the next module's defs → G5 fails. **This is the shipped-defect regression test.** |
| G5b | 1 | in-proc | **the deleted heuristic, from the other side.** `(module m (cat A))` · `def a` · `(import "x")` · `def b` · `(end-module "m")` ⇒ **both** `a` and `b` are on `m`'s sheet | restore `kinds-close-bodied` → `b` is charged to nobody → G5b fails. **Verified to fail on today's compiler (probe 4, exit 4).** |
| G6 | 1 | fence | **extent name (D3b).** `(module wrongname (cat A))` inside an extent the provider closed as `"right"` is REFUSED, naming both | drop the name comparison in `sig-close-extent` → G6 accepts → fails |
| G7 | 1 | fence | **two coordinates in one extent (D3c).** Two `(module …)` forms with no `(end-module …)` between them are REFUSED | restore "a `module` form closes the open one" → G7 accepts → fails |
| G8 | 3 | fence + in-proc | **R8, no silent staleness.** Fence, two rows so the "no author action" half is actually shown: the `(cat A)` module ACCEPTS as written, then the *same source plus* an appended **`extern`** is REFUSED — **with no edit to the `(module …)` form** between them. ⚑ The append must be an `extern`, not a `def`: `crossings-of` considers only `eh-extern` charges, so a `=>` **def** is `ek-proc` in `exports` and is never a crossing under sense (a) BINDS. The earlier draft wrote `(def be-stream (=> Str Bytes) …)` and would not have fired. In-proc: the same append on a `(cat C)` module ⇒ the sheet gains `be-stream` tagged `ek-proc` | cache the sheet across the def install → both fail. (A *lazy first-query* build does not fail either row — the query happens after the install. Build-at-close is pinned by Step 4's code, not by G8; stated so the coverage is not overstated.) |
| G9 | 2 | in-proc + fence | **R9, optionality.** In-proc: a fixture with no `(module …)` form loads and `(sig-sheet sig "anything")` is `none`. Fence: a real blob where an unannotated module **follows** an annotated one — it runs unchanged and charges nothing to the previous coordinate | any extent regression that charges an unannotated module's defs to the previous coordinate → G9 fails |
| G10 | 1 | in-proc | **R5/R6, one lookup — and this is now a real row, not an API pin.** One reader asks `sig-sheet` for a present name (`some`, fields match) and an absent name (`none`) | the previous draft recorded "no mutant falsifies G10". Under the in-process channel one does: make `sig-sheet` return `none` for a present name, or `some` of a default record for an absent one, and G10 fails. What still has no mutant is *re-deriving* inside `sig-sheet` instead of reading the stored field — that is pinned by Step 4's code, and is stated rather than dressed up |
| G11 | 2 | grep | **retirement is real.** `absent` for `kind-offender`, `kv-pure-crosses`, `kv-crosses-pure`, `kv-crosses-empty`, `kind-rows`, `krev`, `KClaim` in `scaffold/lib/`; `present` for `xw-code`, `cw-wrappers`, `cw-extern-of` | leaving any retired symbol in the tree → G11 fails. The built-but-unadopted guard, made mechanical |
| G12 | 2 | fence + in-proc | **EOF closes the last extent — fail-closed, not fail-open.** A single file with `(module m (cat A) …)` binding a `=>` extern and **no** `(end-module …)` (the `B1 < file` and `chirality_blob … && cat prog >>` shapes `parse.chiral:1030` documents) is REFUSED by the fence; in-proc, a fixture with no trailing `(end-module …)` still yields a sheet | make the EOF close a no-op ("unclosed at EOF is legal" read as "never closed") → `build-sheet` never runs → **the fence silently stops firing for every hand-compiled source** → G12 fails. See the note below: this is a hole the gate found in §4 |

**A hole this gate found in §4, and the one-line change it forces.** D3c says *"an
unclosed coordinate at EOF is legal"* — true, but Step 4 builds the sheet **at
close**, so "legal and never closed" would mean *no sheet, and therefore no
fence*, for exactly the sources compiled without the provider. Step 1 must
therefore close any open extent at the end of `load-source` as well as at an
`(end-module …)` form; that is now stated in Step 1, and G12 is its gate. Fixed
here rather than left as a spec-grain detail, because the failure mode is
fail-open and silent — the same class as the defect this element exists to fix.

**Floors compared, and a correction to this spec's own baseline.** G0(c) is a
genuine two-provider differential (shell `chirality_blob` ↔ native `resolve.chiral`),
run **in bash against the committed `scaffold/build/resolve` binary**, zero
Python. The previous draft credited that differential to
`scaffold/tests/test_resolve_chirality.py`. **That is wrong, and the code says so:**
that file runs only the shell resolver and then checks substrings and module
ordering (`test_02`/`test_03`), type-checks `resolve.chiral` with the *Python*
checker (`test_04`), and loads it into the Python elaborator (`test_05`). **It
never runs the native resolver and never compares two providers.** So Step 1's
"immediate check" did not exist; G0 builds it. Recorded in §6.4 (finding 8) under
the authority order, not silently patched. Every other row is a single-floor
native behavioural case; the Python oracle compiles nothing here and is not
consulted (CLAUDE.md's build rule).

*(Row labels differ from the pre-D11 draft: the old G12 provider-differential row
is absorbed into G0, and G5b / G12 are new.)*

### ⚑ Step 1 needs a TWO-STAGE BOOTSTRAP — measured, and not optional

`(end-module …)` is a **new toplevel form**, so the committed compiler cannot
read the blob its own updated provider emits: `B1 < blob.new` fails with
`load: unsupported toplevel form end-module`. The ordinary one-stage ceremony
below therefore cannot build Step 1, and reading that failure as a regression is
the trap. Build a boot compiler from the **marker-free** blob first:

```
chirality_blob … > /tmp/blob.new
grep -v '^(end-module "' /tmp/blob.new > /tmp/blob.nomark   # the OLD language
./scaffold/build/B1 < /tmp/blob.nomark > /tmp/Cboot         # boot: new sources, old surface
/tmp/Cboot            < /tmp/blob.new  > /tmp/C1            # C1 reads the marker
/tmp/C1               < /tmp/blob.new  > /tmp/C2 && cmp /tmp/C1 /tmp/C2
```

Measured 2026-08-23: `Cboot == C1` byte-identical (1,077,624 B) — the marker's
presence does not change codegen, which is the evidence that the boot stage is a
surface-acceptance bootstrap and not a semantic one. Only Step 1 needs this;
from Step 2 on the promoted compiler already knows the form.

### Build ceremony — compiler sources change, so all five steps run

Per `.planning/BUILD-ORDER.md:285-320`, in this order, and **do not skip step 3**:

```
ulimit -s unlimited ; . bin/chirality-resolve.sh
chirality_blob scaffold/lib sys-linkage compile-front compile-back compile-emit compile-all compile-driver > /tmp/blob.new
./scaffold/build/B1 < /tmp/blob.new > /tmp/C1 && chmod +x /tmp/C1
/tmp/C1 < /tmp/blob.new > /tmp/C2 && cmp /tmp/C1 /tmp/C2         # byte-identical fixpoint
#   behavioural gates (the fixpoint is NOT a correctness check):
#   e151_string_stdlib + e152_list_sort samples, exit 0 each, plus G0-G12 above
cp /tmp/C1 bin/chirality-bin && chmod +x bin/chirality-bin
cp /tmp/blob.new scaffold/build/blob.chiral                        # BOTH, together
./scaffold/build/B1 < scaffold/build/blob.chiral > /tmp/V && cmp /tmp/V bin/chirality-bin
bash tools/test/run-tests.sh
```

Then **rebuild the native test-runner** (`scaffold/build/test-runner`) against the
promoted B1 — a runner built by the previous compiler is the stale-artifact trap
BUILD-ORDER records, and it is **live, not hypothetical**: measured 2026-08-23,
the committed runner was dated before Steps 1–4 were promoted, so Phase 2's green
came from a compiler four generations old. Rebuild it at every promotion or
Phase 2 tests the past. **And rebuild `scaffold/build/resolve`** if anything local uses it: it is built by
the *previous* compiler and the previous `resolve.chiral`, so after Step 1 it is
stale by exactly the change under test. G0 does not depend on that rebuild — it
builds its own provider, because `scaffold/build/` is gitignored and a gate may
not rest on an artifact that need not exist.
A fixpoint check is **not** a correctness check; G0–G12 are what make this gate
have teeth.

**Green line, counted by running the gate.** `run-native.sh` Phase 8 goes from
**29** assertions to **44**. The 29 is measured — `bash scaffold/tests/run-native.sh`
prints `module coordinate (E160): 29 passed, 0 failed` — not counted from call
sites, which gives 26 and misses the fifth helper `appended` (§2). Of the 29,
**11 retire with the port-set claim**: the six `(pure)`/`(crosses)` rows of
section B (`:227,231,244,250,255,261`), section A's three claim-shape refusals
(`:188,214,219`), and section E's two KNOWN-GAP rows (`:360,370`), which exist
only to pin what a `(pure)` claim does and does not see. **18 are kept** (shape,
axis values, redeclaration-by-name, optionality, coordinate-before-or-after-
imports, and the three `appended` boundary rows — those keep their case and lose
only the `(pure)` clause inside `APPENDED`). G0–G12 add **26** (the `n` column
above: 4+1+2+3+1+2+1+1+1+3+2+2+1+2). G11 is **two** assertions, not one: its own
row text mandates two distinct greps — an absent list and a present list — and
one assertion cannot carry both without making one of them silent. 18 + 26 =
**44**, which is what the shipped gate reports. The Phase 8 banner (`run-native.sh:190-199`) is
re-headed from E160's port-set wording to the datasheet. The Python suite is an
oracle, not a gate, and E161 adds nothing to it: 709 test functions across 77
files → ≥ 709. `ledger-lint.py` checks A–H clean.

**Done when:** on the promoted compiler (Phase 8 reporting **44 passed, 0
failed**), a façade carries a total sheet with
empty derived lists while the module after it in the blob carries its own defs
(G5), an `(import …)` mid-module no longer splits a module's defs across two
coordinates (G5b, which fails on today's compiler), `(cat A)` over a crossing
module is refused by name (G2) **including in a single file with no provider
marker** (G12), a new `=>` def changes its module's sheet with no author action
(G8), `sig-sheet` answers both the present and the absent name from a program
that is not the compiler (G10 — R6's live witness), both providers emit the
extent marker byte-identically **and** as the committed blob says (G0), every
retired symbol is absent from `scaffold/lib/` while H8's three survivors are
present (G11), and B1 reproduces itself byte-identically over the promoted blob.

## 6. Residue & links

### 6.1 Deliberately unbuilt (each with its home)

- **Transitive (sense-b) crossings as a materialised field** — home: the
  consumer, as a fold over sheets (D1a). Nobody's yet; no element needed.
- **A generated closed `Crossing` sum** — home: `crossing-wraps.chiral:6`, which
  must remain the single vocabulary. Generating a sum *from* it (or the table
  from the sum) is a separable change with no minted element; do not mint one
  until something needs it (deferral rule).
- **`chirality datasheet <module>` printer** — R10-class consumer of the record;
  also the cheap way to buy D8's legibility without a writable artifact.
  Unbuilt, no element, and correctly not a gate.
- **Closure-conversion provenance for lifted lambdas** —
  `compile-emit.chiral:283-290`'s stated bound. Under D1 the datasheet never reads
  object code, so this bound leaves the datasheet's scope entirely and remains
  H8's, where it already is.
- **Annotating the remaining ~143 unannotated modules** — R9 makes this optional and
  incremental; no element.

### 6.2 Open, author-tier (repeated so they are not lost)

- **D7 — `alt`.** Shipping authored (the E160 status quo). Closing it means:
  derive it, keep it authored and restate requirements §4's "one authored
  field", or drop it from the schema.
- **D8 — source file vs `Sig`.** §4 builds the `Sig` side, which both answers
  need. The source-file option additionally needs a source-writing tool this
  `Str -> ELF` compiler does not have.
- **D6 — the per-def typeability letter.** Falsifier run (§3); result recorded;
  decision not taken.
*(D11 — the gate's observation channel — was the blocking item here and is now
CLOSED: both channels, requirements §12, with the in-process reader verified
against the live tree. See §3 D11 and §5.)*

### 6.3 Follow-on

This unblocks nothing already minted, and this spec **mints nothing** — per the
deferral rule, no work here is deferred to an unminted `E#`/`T#`. Every item in
§6.1 is either "nobody's yet, and that is stated" or lands inside an existing
home.

### 6.4 Where the CODE contradicted the inputs (authority: code > requirements > example)

1. **The surface head is `kind`, not `module`** (`parse.chiral:1178`). Both the
   requirements (§5) and the example (§4) write `(module backend (cat C))` as if
   it existed. It does not; Step 5 is a head **rename**, and that is a grammar
   change with its own migration of the six annotated modules — not the free
   restatement both documents imply.
2. **The requirements' §5 sample record omits `alt` entirely** while E160's
   grammar makes altitude **positionally required** (`(kind <m> A|B|C
   upper|tal|metal …)`, `k-msg`'s own shape string at `parse.chiral:1057`).
   Dropping `alt` from the sample is not "the decision is open" — it silently
   drops a field the shipped grammar requires. D7 makes the carry-forward
   explicit instead.
3. **`kinds-close` already closes unconditionally** (`loader.chiral:150-161`), and
   `kernel.chiral:105-121` documents that as intended. The 345-def defect is
   *only* the `import` path (`kinds-close-bodied`, `:174-181`) plus the absence
   of any final boundary. Both documents describe the bug as "a coordinate is
   never closed", which is true but under-specified: it is never closed *by an
   import or by EOF*; a later `kind` form would have closed it. `ports` is the
   last `kind` in the compiler blob, which is why the bug is live there and
   nowhere else. Re-verified for this spec on `scaffold/build/blob.chiral`:
   five `kind` forms (`:13`, `:1642`, `:1877`, `:9834`, `:10781`), 345 `def`
   forms after the last.
4. **`pretty.chiral` is not in the compiler blob.** Both documents list six
   annotated modules; the committed compiler blob contains five (`pretty` is not
   reachable from the compiler roots). The sixth is still annotated in `lib/` and
   still needs migrating in Step 5 — but any gate that expects six coordinates in
   *the compiler blob* would be wrong.
5. **`cw-extern-of` survives the retirement.** The example §6 lists it among the
   emit-gate machinery losing its subject; it has a second, live H8 caller
   (`compile-emit.chiral:361`). Deleting it would break the profile gate. Step 7
   states this explicitly.
6. **`alt` is not merely underived — it is unread.** The example says "nothing
   derives it"; verified stronger: the only occurrences of `KAlt` / `alt-upper` /
   `alt-tal` / `alt-metal` in `scaffold/lib/` are its declaration
   (`kernel.chiral:92`), its field on `ModKind` (`:123`), and the string parser
   `k-alt-of` (`parse.chiral:1077-1083`). **No analysis consumes it.** That
   sharpens D7 — a field with no producer *and* no consumer has a weak claim on
   a total schema — without deciding it.
7. **The `Sig` widening is the biggest edit here and neither document says so.**
   Both treat "a ninth field on `Sig`" as a one-liner beside `sig-kinds`. It is
   40 `mk-sig` sites across 5 files (Step 3). Conceptually trivial,
   mechanically the largest single change in the element, and it must be its own
   commit because a half-applied arity change does not compile.

8. **`test_resolve_chirality.py` is not a provider differential** — and this spec's
   own §2 and Step 1 said it was. The file runs the *shell* resolver once, checks
   that 13 module names appear and that a few appear before others
   (`test_02`/`test_03`), type-checks `resolve.chiral` with the **Python** checker
   (`test_04`), loads it into the Python elaborator (`test_05`), and asserts a
   blob-size band (`test_06`). It **never executes `scaffold/build/resolve`** and
   **never compares two providers' bytes**. Measured for this spec, and the
   replacement measured too: both providers *are* drivable from bash today —
   `printf -- '-L <dir>\n<root>\n' | ./scaffold/build/resolve` against
   `chirality_blob <dir> <root>` — and on a three-module fixture (including a
   subdirectory module) their output is byte-identical. §5 G0 makes that the
   real check, in bash, zero Python.

9. **Build-at-close plus "unclosed at EOF is legal" is fail-open.** D3c's rule is
   right, but combined with Step 4's build-at-close it would leave every
   provider-less source (`B1 < file`) with no sheet and therefore **no fence**.
   Neither input document raises it; it surfaced only when §5's rows were written
   as executable checks. Step 1 now closes the open extent at the end of
   `load-source`, and G12 gates it. Recorded here because the pattern — a rule
   that is correct in isolation and silently fail-open in composition — is the
   same one that produced the 345-def defect.

### 6.5 Links

[[E160]] · [[certificate-discipline]] · [[axis-typeability]] · [[splitting-law]] ·
[[decision-effect-facets]] · [[pattern-boundary-sums]] · [[docs/banks/module]] ·
`examples/E161-REQUIREMENTS.md` (scope authority) ·
`examples/E161-kind-identifier.md` (rationale) ·
`.planning/BUILD-ORDER.md:285-320` (the build ceremony this gate runs)
