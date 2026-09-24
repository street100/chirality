---
row: lowering-and-emit/LE18
arc: lowering-and-emit
title: the per-module label namespace, and the refusal that names the wrong cause
kind: primitive
origin: new
req: 4, 5
status: blocked
updated: 2026-09-23
---

# lowering-and-emit/LE18: the per-module label namespace

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

⚑ **This row's element was already minted, as `E154` on 2026-08-21, before
[[decisions/decision-design-before-mint]] moved the mint to the end of the
pipeline.** `python3 tools/pack/pack.py lowering-and-emit/LE18` prints that note
and scaffolds this file anyway. §6 is therefore a **no-op**: it mints nothing,
writes no catalog row and writes no ledger row. It records what the existing
`docs/elements/catalog.md:485` and `docs/elements/ledger.md:151` rows already
claim, what this run found wrong in them, and what `pack.py E154 --spec` may
now build on. A `design-to-spec` run refused this element for the absent design
artifact and that refusal was correct.

## 1. The obligation

- **The row:** two co-blobbed modules may each define the same internal name and
  still compile, and the refusal that stands where they cannot must name the
  collision it actually fired on.
- **Serves:** requirement **5** of [[arcs/lowering-and-emit-arc]], *"A name a
  module defines for itself cannot be broken by another module defining the same
  name"*, and requirement **4**, *"Every state claim over one of this arc's
  elements names code that says what the claim says"*, which the wrong message
  and the stale catalog citation both fail.
- **Goal:** [[goals/self-hosting]], condition 5. The arc's own `goals:` field
  assigns condition 4 to its requirements 1, 2 and 3, so this row reaches the
  goal through the roster invariant rather than through condition 4.

## 2. What the tree holds

Measured 2026-09-23 against the working tree at `c71ca2d`, with the probes named
inline. Every probe below was run through the tracked `bin/chirality-bin`.

### The bank first

[[banks/module]] is the home. §4 at `docs/banks/module.md:363-368` refutes *"You
need namespaces to avoid name collisions"* at the **design** tier: module
identity is by type, and *"name resolution is the surface elaborator's job
(`resolve`, E2)"*. §5 item 6 at `:431-448` is the bank's own caveat and it is
this row: *"below the surface, after resolution, every `def` becomes a label in
ONE flat emitted namespace, and two co-blobbed modules defining the same
internal name collide … it is a codegen-tier defect"*, catalogued as `E154`.
`docs/definitions/altitude-errors.md:74-85` states the same split as class
**A2**, mechanism altitude, and names `E154` as the fix for the A1 stdlib leak
it causes. So the concept is refracted, the phantom is already refuted, and the
shard this row owns is named in two places. Nothing here is a new feature.

⚑ **The bank's §4 sentence is load-bearing for §4 below.** It assigns name
resolution to the surface elaborator. A fix that attaches an owner during
resolution is inside the tier the bank already assigns, and adds no surface
syntax. The fence this row draws is against a design-tier *feature*, not against
touching resolution.

### There are four flat namespaces, not one, and only one of them is late

Probed today, three modules co-blobbed by hand with `(end-module "modA")`
markers between them, compiled through `bin/chirality-bin`:

| namespace | duplicate refuses | where | message |
|---|---|---|---|
| data type name | at **load** | `lib/module/loader.chiral:551`, `:572` | `load: data redeclared: Box`. Accurate |
| extern name | at **load** | `lib/module/loader.chiral:460` | `load: extern redeclared: zap`. Accurate |
| porttype / atom | at **load** | `lib/module/loader.chiral:490` | `atom type redeclared`, per `lib/typing/diag.chiral:345` |
| **top-level `def` name** | at **emit** | `lib/lowering/compile-emit.chiral:305` | `duplicate label (an object def collides with the linked runtime): helper`. **Wrong for this case** |

- the `Subject` sum (`lib/typing/diag.chiral:80`) carries a `subj-def` arm, and
  `dg-redeclared-msg` renders *"definition redeclared: "* for it at
  `lib/typing/diag.chiral:348`, but **no site raises `r-redeclared` with
  `subj-def`**. A grep over `lib/` and `prog/` returns raise sites for
  `subj-extern`, `subj-atom` and `subj-data` only. So the def namespace is the
  one of the four with no load-time judgment, and the message it does get is
  produced by a check two stages downstream that knows nothing about modules:
  `module/loader` closes at blob line 5,580 and `lowering/compile-emit` at
  17,923, in the 18,007-line blob regenerated today.
- `lib/module/loader.chiral:75-76` is why: `sig-add-global` conses onto a list,
  and `lib/typing/kernel.chiral:382-384` reads it with `assoc-tt`, first match
  wins over a most-recent-first list. A second `def helper` silently shadows the
  first for every reference loaded after it, and both are still lowered.
- `lib/lowering/compile-emit.chiral:168-171` already says this in its own words:
  *"A collision … silently rebinds every call on that name, the self-compile
  shipped a compiler whose put/bcat called the wrong code. REFUSE loudly."*

### The refusal, and the two cases it cannot tell apart

`first-dup-go` (`lib/lowering/compile-emit.chiral:176-183`) walks
`image = native-lib ++ link-lib ++ obj` (`:296`) comparing `tifn-nm`
(`:172-173`), which projects `TIFn`'s bare `name Str`. One message serves two
structurally different collisions. Both probed today:

| probe | result |
|---|---|
| object def named `nb-bcat`, the linked runtime's own label | exit 1, `duplicate label (an object def collides with the linked runtime): nb-bcat`. **Correct** |
| two co-blobbed modules each defining `helper` | exit 1, `duplicate label (an object def collides with the linked runtime): helper`. **False**: no runtime label is involved, and neither owning module is named |
| the same two `helper` defs, neither reachable from `compile-main` | exit 1, identical message. The prune pass (`lib/lowering/compile-back.chiral:205-220`) is an availability prune, not a reachability prune, so unreachable duplicates still refuse |

Both refusals fail closed with no ELF written, 0 bytes on stdout.

The linked runtime contributes **97** distinct labels, the union of the
`ti-fn "…"` strings in `lib/lowering/tal/{bytes,sys,sys-linkage}.chiral`: **93**
spelled `nb-*` and **4** spelled `wrap-*`, with no third prefix.
`lib/lowering/tal/sys-linkage.chiral:98-99` composes `link-lib` as the four
wrappers plus `sys-lib`, and `lib/lowering/compile-emit.chiral:296` appends
`native-lib` in front of it. Every one of the 97 is kept distinct from surface
code by that prefix convention alone, with nothing enforcing it.

### Constructor heads and type names are not in the label space

`lib/lowering/tal/ir.chiral:9-10`: *"Constructor names arrive as tag numbers
(declaration order); only function names survive as strings, because they become
labels."* Probed: two co-blobbed modules declaring **distinct** data types that
share a constructor head (`(data BoxA () (box …))` and `(data BoxB () (box …))`)
compile to a 33,144 B ELF, exit 0. A constructor head colliding with a `def`
name compiles. An extern name colliding with a `def` name compiles.

⚑ **So any flat-space total that sums constructor heads into the label space is
wrong**, including the figures handed to this run. The emitted-label space is
`def` names plus the 97 runtime labels. Type names and constructor heads are a
separate flat space with its own, earlier, correct refusal.

### The census, re-derived

Method: `^\(def NAME` and `^\(data NAME` at column 0 over every `.chiral`,
`.prog` and `.manifest` under the named roots, constructor heads taken from the
data form's second and later parenthesised groups. Script in the session
scratchpad, not committed.

| scope | distinct def names | def sites | dup def names | distinct type names | dup type names | distinct ctor heads | dup ctor heads |
|---|---|---|---|---|---|---|---|
| `lib/` + `prog/`, 304 files | **4,165** | 4,502 | **93** | **469** | **22** | **1,169** | **29** |
| `lib/` alone, 96 files | 2,203 | 2,218 | 14 | 333 | 11 | 889 | 16 |
| `prog/compiler.prog`'s blob, 61 modules | **1,540** | 1,540 | **0** | | | | |

⚑ **The figures handed to this run do not reproduce and are not used.** A prior
reading of 3,543 def names / 454 type names / 31 duplicated def names, and an
earlier 1,367 constructor heads, match neither scope above. The 22 duplicated
**type** names reproduce exactly, name for name: `BR FR PR SR RLR LoadR OpenR
RunR Box Child Obs Reap St Step Term Ty Turn Value Verdict ExitStatus SpawnErr
SpawnRes`. The re-measured constructor figure of 1,147 heads / 1,180 sites is
close to this run's 1,169 / 1,202 and is moot either way, because constructor
heads are not labels.

**The third row is the measurement that matters.** The compiler's own 61-module
closure holds 1,540 top-level def names and **zero** duplicates. That is not a
property of the code; it is the cost of the hand-prefixing below.

### The hand-patches, and there are more than the rows say

`E154` is named by number in **eleven** files under `lib/` and `prog/`
(`lib/prelude/{list,string,doc}.chiral`, `lib/typing/diag.chiral`,
`lib/lowering/tal/check.chiral`, `prog/scriba/puffer.chiral`,
`prog/e185-apply-word.prog`, `prog/e186-capture-fields.prog`,
`prog/e188-apply-spine.prog`, `prog/e189-widening-multiply.prog`,
`prog/samples/e200-coverage-composite.prog`), and five more files carry a
workaround for it without naming the number. The tracked cells name three
instances.

| instance | where | named by a tracked row |
|---|---|---|
| `str-contains` → `gate-contains` | `prog/prapanca/core/gate.chiral:17-21` | yes, catalog and ledger |
| `ok2xx` → `agent-ok2xx` | `prog/shilpa/turn.chiral:206-209` | yes, catalog and ledger |
| the `collections` import dropped and its helper inlined | the note is at `prog/scriba/cmd-types.chiral:2` | yes, with a **stale path** (below) |
| eleven `tck-` internals, 6 defs + 2 types + 3 ctors | `lib/lowering/tal/check.chiral:20-33` | only in prose, `docs/arcs/enforcement-arc.md:645` calls it *"E154's fifth instance"* |
| `dg-` prefix, 30 `def`s, 133 occurrences, 32 distinct names | `lib/typing/diag.chiral:27-30` | **no ledger, catalog or arc row** |
| `su-` prefix, 10 `def`s, against `ty-cmp.chiral`'s `cmp-bytes` | `lib/prelude/string.chiral:62-66` | **no row** |
| `ms-`/`dd-` prefix, 5 `def`s | `lib/prelude/list.chiral:166-169` | **no row** |
| `fits` → `doc-fits`, `fr` → `dfr`, `Mode` → `DMode` | `lib/prelude/doc.chiral:42-48` | **no row** |
| `cenv-get` → `opt-cenv-get` (`lib/lowering/upper/optimize.chiral:49`) and `two-srcs` → `opt-two-srcs` (`:76`) | `lib/lowering/upper/optimize.chiral` | only in `records/enforcement-arc.md:291` |
| `find-ctor` → `l-find-ctor`, against `lib/typing/kernel.chiral:459` | `lib/lowering/upper/lower.chiral:169` | **no row** |
| four roots that import nothing under `lowering/tal/` **because of** the collisions | `prog/e185-apply-word.prog:10`, `prog/e186-capture-fields.prog:27`, `prog/e188-apply-spine.prog:17`, `prog/e189-widening-multiply.prog:33` | **no row** |
| `prog/samples/e200-coverage-composite.prog:20`, same constraint | | **no row** |
| the clone-instead-of-import pattern, self-declared | `prog/scriba/puffer.chiral:16` | catalog, as the second-order cost |

That is **thirteen** rows against the three the tracked cells count, over
sixteen files. The last two rows are a **cost class the tracked cells do not
name at all**: five gate roots state in their own headers that they cannot
import a module they need, so the defect has cost reachability and not only
spelling.

### The identity the fix needs already exists, and nothing keeps it

`E161` put a declared module extent in the surface language.

- The provider emits `(end-module "<key>")` after each module's source.
  `lib/module/loader.chiral:120-123` states the rule; `bin/chirality-resolve.sh`
  is the provider the BUILD RULE runs.
- `lib/surface/parse.chiral:1294` dispatches it to `handle-end-module`
  (`:1237-1256`), with a `k-extent-shape` / `k-extent-name` error class at
  `:1096-1113`.
- **61 markers appear in the compiler's own blob**, one per module, counted
  today over a freshly regenerated 18,007-line blob. Each carries the resolver's
  root-relative key: `prelude/prelude`, `lowering/compile-emit`, and so on. They
  survive blobbing because they are in the blob.

Three facts about that extent decide §4, and two of them cut against the
handed premise.

1. ⚑ **The marker closes, it does not open.** `lib/module/loader.chiral:121-123`:
   *"Extent k runs from end-marker k-1 (or BOF) to end-marker k."* When module
   A's `def`s are loaded, the name "modA" has not been read yet. Any name to
   owner association therefore needs a pending list in `Sig`, stamped at the
   close, rather than a field read at the charge.
2. ⚑ **The charged record covers 10 modules of 61, not 61.** `sig-charge`
   (`lib/module/loader.chiral:373-381`) delegates to `kinds-charge`, which
   returns its input unchanged when no coordinate is open. A coordinate is
   opened only by an authored `(module …)` form, and the blob holds **10** of
   them against 61 markers (15 tree-wide, re-counted 2026-09-23 by
   `grep -rn '^(module ' lib/ prog/`:
   `lib/prelude/{alist,map,ord,set,prelude,list,string,maybe,doc}.chiral`,
   `lib/surface/pretty.chiral`, `lib/ports/ports.chiral`,
   `lib/text/matcher.chiral`, `lib/crypto/{chacha,poly1305}.chiral`, and
   `lib/lowering/tal/target-linux.manifest:18`, which is the only one of the ten
   in the blob that is not a `.chiral` file). R9 at
   `lib/module/loader.chiral:129-132` makes that deliberate: an unannotated
   module *"closes nothing and charges nobody"*.
3. **The marker's own name string is read and discarded for the other 51.**
   `handle-end-module` with nothing open returns `(step-ok (sst sig env))`
   (`lib/surface/parse.chiral:1247`), dropping `ext` on the floor.

So the owner identity is **declared** for 61 of 61 and **retained** for 10 of
61, and the retention is at the wrong end of the extent.

### What the code forces below the loader

| carrier | shape | sites that would move |
|---|---|---|
| `t-global` | `(t-global (n Str))`, `lib/surface/syntax.chiral:27`. A top-level reference is a bare name and carries no owner | the kernel reads it at `lib/typing/kernel.chiral:682`, `:781`, `:829`, `:1224` |
| `NFn` | `(n-fn (name Str) (nparams I64) (nregs I64) (code NCode))`, `lib/typing/erased-nf.chiral:47` | **3** construction or match sites, in `erased-nf`, `tal/reify` and `tal/erase` |
| `TIFn` | `(ti-fn (name Str) (nparams I64) (nregs I64) (code TCode))`, `lib/lowering/tal/ir.chiral:48-49` | **104** sites across 8 files, of which `lib/lowering/tal/sys.chiral` holds 63 and `lib/lowering/tal/bytes.chiral` 30. Positional application, so a fourth field breaks all 104 |
| `ti-call` | `(ti-call (dst I64) (fname Str) (args (List I64)))`, `lib/lowering/tal/ir.chiral:24`. **A call names its callee by string** | **175** sites, of which `sys.chiral` holds 131 and `bytes.chiral` 27 |

⚑ **`ti-call` is the fact the row's `Wanted` did not account for.** The binding
of a call to a body is decided by the emitter's label table, keyed on that
string. Mangling a definition's label without mangling its call sites breaks
every call. Mangling a call site requires knowing which definition it meant, and
that is exactly what a bare `t-global` discarded upstream.

### Rung

`docs/definitions/status-ledger.md` carries no rung for `E154`;
`docs/elements/ledger.md:151` reads `design` and `docs/elements/catalog.md:485`
reads *"Not built"*. Both agree, and the defect reproduces at HEAD.

### Drift found in §2, reported and not fixed here

1. `docs/elements/catalog.md:485` cites `TUI/scriba/cmd-types.chiral:2`. **There
   is no `TUI/` directory**; the file is `prog/scriba/cmd-types.chiral` and the
   quoted comment is at its line 2. `docs/banks/module.md:438` repeats the same
   stale path.
2. Both the catalog cell and `docs/elements/ledger.md:151` say the defect was
   *"hand-patched three times"*. The table above counts thirteen, over sixteen files.
3. `lib/typing/diag.chiral`'s `dg-` prefix, 30 definitions, is the single largest
   instance in the tree and **no ledger, catalog, arc or lens row names it**.
   `lib/lowering/tal/check.chiral:28-29` calls it *"the same hand-patch for the
   same defect"*.
4. `records/enforcement-arc.md` EN-16 reads `state: RETIRED` and *"MOVED to
   PRB-44"*. The live row is `records/lenses/problems.md:612-624`, not EN-16.
5. ⚑ **PRB-44 carries an author ruling of 2026-09-08 that bears directly on §5**:
   *"the fix is E154, and a shared module is a shorter denylist rather than a
   model"*, given on `PRINCIPLES.md` §1. So the five byte-identical twins of
   `lib/lowering/upper/lower.chiral:163-194` are ruled to `E154` and **ruled
   against** the shared-owner reading, which is the opposite of what this run was
   handed.
6. ⚑ Found by the design audit, 2026-09-23. Both cells name a clone set as the
   defect's second-order cost, *"`puf-length`, `se-length`, `list-nth`×2,
   `str-cmp`×4"*, and two of the four are retired: `str-cmp` has one definition
   (`lib/prelude/string.chiral:91`), and `puf-length` does not exist
   (`prog/scriba/puffer.chiral:9`). `docs/banks/module.md:443` inherits the
   `str-cmp` figure from the same source. §5 stated the stale set and now states
   the measured one.

## 3. The delta

Subtracting §2, four things are missing and they are not the same size.

1. **A retained owner.** The extent is declared 61 times and kept 10 times, at
   the closing end. `Sig` needs a pending-names list stamped at each close, so
   every top-level name in the blob acquires the key of the module that defined
   it. Nothing in the tree does this today.
2. **A truthful refusal.** One message serves two collisions and names the wrong
   one for the case that actually bites. Splitting it needs (1) and nothing else.
3. **A resolution that can tell two same-named defs apart.** `t-global` carries
   a bare `Str` and `sig-add-global` accepts a silent shadow, so by the time
   `ti-call` is built the information is gone. This is the half the row's
   `Wanted` states and the half `ti-call`'s 175 sites price.
4. **A gate, and the one that exists asserts the opposite.** ⚑ Corrected by the
   design audit, 2026-09-23. The suite already compiles a two-module `def`
   collision and asserts the refusal: `tools/test/pretty.sh:572-578` mutant
   **M13** injects `(def nlen …)` into `lib/surface/pretty.chiral` against
   `lib/lowering/tal/erase.chiral:35`'s `nlen` and requires the build to fail
   with `duplicate label … nlen`, dispatched by Phase 18
   (`tools/test/run-tests.sh:284`). So requirement 5's *refusal* half is
   observed, and it is observed as a row that **E154 must flip**: the two
   `nlen`s are exactly the case this element exists to let co-exist. What is
   absent is a row asserting the co-existence and a row asserting a mangled
   program links. M12 beside it (`data redeclared: Term`) stays green either
   way, because the data namespace is not this element's. Shape E flips M13 too,
   to `definition redeclared: nlen`.

**Verdict: a real delta**, and larger than the row states. The row's own
`Wanted` reads as one change at emit; §2 measures it as a change at name
resolution with a consequence at emit.

## 4. The shapes

Five were drawn. Two are ruled out by measurement, which is itself a result.

### Shape A: a fourth field on `TIFn`, stamped at reify

- **Form:** `(ti-fn (name Str) (owner Str) …)`. `tifn-nm` returns
  `str-cat owner (str-cat "$" name)`. `first-dup-go` compares the mangled name.
- **Costs:** **104** `ti-fn` sites, 93 of them in hand-authored tal
  (`lib/lowering/tal/sys.chiral` 63, `bytes.chiral` 30), every one edited for a
  field they do not use. `C2 == C3` convergence on every generation.
- **Forbids:** nothing, and that is the problem. `ti-call` still carries a bare
  `fname`, so either calls stay unmangled and every call breaks, or calls are
  rewritten through a name to owner map that is **ambiguous exactly in the
  duplicate case this element exists for**. Under the most-recent-wins rule the
  loader already uses, the rewrite reproduces today's semantics and turns a
  fail-closed refusal into a silent miscompile, which is the failure
  `lib/lowering/compile-emit.chiral:168-171` records as already having shipped
  once.
- **RULED OUT** on that last line.

### Shape B: a name to owner side table threaded into `emit-elf-m`

- **Form:** `TIFn` unchanged. `emit-elf-m` takes a
  `(List (Pair Str Str))` built by the loader, mangles definitions and rewrites
  `ti-call` heads through it.
- **Costs:** zero construction-site edits, one extra parameter on `emit-elf-m`
  and `emit-elf`, the pending-list work in `Sig`, and the carry from
  `compile-all` down.
- **Forbids:** the same ambiguity as Shape A. A side table keyed on a name that
  two modules define has two entries and the call site cannot pick.
- **RULED OUT for the mangling half.** It survives as the carrier for Shape D.

### Shape C: the owner attached at resolution

- **Form:** `sig-add-global` records the pending owner alongside the entry.
  `t-global` gains the owner the elaborator resolved it to. The owner rides
  `Core` to `Term` to `NFn` to `TIFn` and becomes the label; `ti-call` carries
  the resolved owner, so the emitter's label table is keyed on the pair.
  Resolution inside an open extent prefers that extent's own entry, which is
  what makes two `helper`s two things.
- **Costs:** the largest. `lib/surface/syntax.chiral`, `lib/typing/kernel.chiral`
  at four read sites, `lib/module/loader.chiral`, `lib/surface/parse.chiral`,
  `lib/lowering/compile-back.chiral`, `lib/typing/erased-nf.chiral`,
  `lib/lowering/tal/{erase,reify,ir}.chiral`,
  `lib/lowering/{mach/emit-core,x64/emit}.chiral`,
  `lib/lowering/compile-emit.chiral`. Every one is inside the 61-module closure,
  so the first agreement is `C2 == C3`. The 104 `ti-fn` and 175 `ti-call` sites
  are reachable unless the owner is defaulted for hand-authored tal, which is a
  design question the SPEC owes.
- **Forbids:** it forbids the silent shadow. Two modules defining `helper` stop
  being one name with one winner, so a program that today compiles by relying on
  the shadow stops compiling. That is wanted and it is a behaviour change.
- **Against the fence:** this touches name resolution.
  `docs/banks/module.md:364` assigns name resolution to the surface elaborator
  and §5 item 6 at `:431` places the collision below resolution, so the two
  halves meet here. It adds **no surface syntax** and changes **no surface
  name**, which is the row's own `Wanted`; the owner is derived from an extent
  the provider already emits. On that reading the fence holds. §5 disposes it.

### Shape D: split the refusal, mangle nothing

- **Form:** `first-dup-go` becomes two judgments over the side table of Shape B:
  an object label equal to one of the 97 runtime labels keeps today's message;
  two object labels equal to each other get a new message naming both owning
  extents.
- **Costs:** `lib/lowering/compile-emit.chiral` plus the `Sig` pending list plus
  the carry. No IR change, no call-site change, no behaviour change.
- **Forbids:** nothing new. It closes the row's second `Wanted` and leaves the
  first open.

### Shape E: give the def namespace the load-time judgment the other three have

- **Form:** `load-def` refuses a redeclared `def` the way `load-data`
  (`lib/module/loader.chiral:551`) refuses a redeclared `data`, raising
  `r-redeclared` with `subj-def`, whose message string
  `lib/typing/diag.chiral:348` already carries and nothing raises.
- **Costs:** `lib/module/loader.chiral` alone, plus care to keep the
  `declare`-then-`def` path (`:434`, `jg-no-prior-declare`) working.
- **Forbids:** the shadow, immediately and without any owner at all. It makes the
  four namespaces consistent and moves the refusal two stages earlier, into the
  loader, where the extent is still open and the module is still in scope.
- **Cheapest correct diagnostic, and it is strictly weaker than the row asks**:
  it makes the collision legible, it does not make the two names co-exist.

**The tree does not settle the shape.** Five differ, two are ruled out by
measurement, and the remaining three differ in what they make possible rather
than in style.

## 5. The call

- **Chosen: Shape C, staged, with Shape D as its first commit.**

The reason is the row's own two-part `Wanted`. Shape D delivers *"the refusal's
message naming the case it fired on"* on its own, needs only the retained owner,
and is a change nothing else depends on, so it is a commit that can land and be
judged. Shape C is the only shape measured here that delivers *"labels mangled by
owning module at emit with the surface name unchanged"*, because §2 shows the
binding is decided by `ti-call`'s string and no emit-tier rewrite can recover
which definition a call meant. Shapes A and B are ruled out by that same
measurement rather than by preference. Shape E is not chosen as the element's
shape because it forecloses the co-existence the row exists to create, but its
judgment is the right fallback if Shape C is refused, and it is cheap enough to
be worth stating as such.

The staging is forced, not chosen: Shape C cannot begin without the retained
owner, and the retained owner is the whole of Shape D's cost.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Does attaching an owner during name resolution cross the row's own fence against a design-tier namespace feature | **RESOLVED** | It does not. `docs/banks/module.md:363-368` assigns name resolution to the surface elaborator and refutes the *design-tier* phantom, module identity by name; `:431-448` places this collision below resolution and calls it codegen-tier. Shape C adds no surface syntax, changes no surface name, and derives the owner from the `(end-module …)` extent `E161` already emits. The fence is against a feature, and no feature is added |
| 2 | Whether the five byte-identical twins of `lib/lowering/upper/lower.chiral:163-194` are fixed by mangling or by a shared owner | **RESOLVED** | Ruled by the author 2026-09-08, recorded at `records/lenses/problems.md:616` (PRB-44): *"the fix is E154, and a shared module is a shorter denylist rather than a model"*, on `PRINCIPLES.md` §1. `records/enforcement-arc.md` EN-16 is `RETIRED` and superseded by that row |
| 3 | Where the owner is retained, given the marker closes rather than opens | **RESOLVED** | `Sig` carries a pending-names list stamped at each `sig-close-extent`. Forced by `lib/module/loader.chiral:121-123`, the extent running from marker k-1 to marker k, and by `kinds-charge` charging only the 10 modules with an authored coordinate against 61 markers |
| 4 | Whether hand-authored tal (`lib/lowering/tal/sys.chiral`, `bytes.chiral`) gets a real owner or a reserved one | **DEFERRED** to `E154`'s SPEC | It decides whether the 104 `ti-fn` and 175 `ti-call` sites move. Both arms are expressible once the carrier exists, and the SPEC is where a change plan is sized |
| 5 | **Whether the existing hand-prefixed names are reverted once mangling lands** | **NEEDS-AUTHOR** | Thirteen instances over sixteen files, in four cost classes with four different answers, and no tracked document rules the general case. A row is written to `records/author-calls.md` |
| 6 | Where the co-existence row is asserted, given a phase already asserts the refusal | **DEFERRED** to `lowering-and-emit/LE24` | ⚑ Narrowed by the design audit: §3 item 4 measures Phase 18's M13 (`tools/test/pretty.sh:572-578`) already asserting the two-module refusal, so requirement 5's open half is the co-existence row and the mangled-link row, not a collision fixture. `LE24` takes Phase 11's slot and is the arc's only open phase work, so the new rows land beside it |

### The NEEDS-AUTHOR, stated

**Whether the existing hand-prefixed names are reverted once mangling lands.**
The instances in §2 are not one thing, and they fall in four classes:

- **Genuine homonyms.** `dg-` ×30, `tck-` ×11, `su-` ×10, `opt-` ×2,
  `doc-fits` / `dfr` / `DMode`, `l-find-ctor`, `gate-contains`, `agent-ok2xx`.
  Two modules meaning two different things by one word. Mangling makes reverting
  them *possible*. Every revert inside the 61-module closure owes a full
  rebuild-and-promote, and `dg-`, `tck-`, `su-`, `opt-` and `l-find-ctor` are all
  inside it.
- **The five twins.** Ruled already, question 2 above. `E154` owns them.
- **Duplication that is not a meaning collision.** ⚑ Re-measured by the design
  audit, 2026-09-23, because the set this bullet named was copied from `E154`'s
  own catalog and ledger cells and most of it is already retired. What lives is
  `list-nth` ×2 (`lib/evidence/interp.chiral:50`,
  `prog/scriba/list-utils.chiral:14`) and `se-length` / `se-reverse`
  (`prog/scriba/str-edit.chiral:30`, `:26`), which is what
  `docs/definitions/altitude-errors.md:59-66` class A1 still lists against the
  shelf `E151` / `E152` own. The other two the cells name are gone: `str-cmp`
  has exactly one definition, `lib/prelude/string.chiral:91`, which
  `docs/definitions/altitude-errors.md:53-54` states and `E151`'s catalog row
  confirms by reporting `ar-str-cmp` and `cb-str-cmp` grep-clean; `puf-length`
  no longer exists, and `prog/scriba/puffer.chiral:9` records it in the past
  tense. ⚑ **Mangling may entrench what is left**, because the pressure that
  makes the duplication visible is exactly the collision. Stating it rather than
  burying it: doing `E154` in isolation removes a diagnostic the tree currently
  gets for free, over three names rather than the eight the cells imply.
- **The reachability cost.** Five roots that import nothing under
  `lowering/tal/` because of the collisions. These are not renames and a revert
  does not describe them; what they get back is an import.

## 6. The mint packet

⚑ **No-op. `E154` was minted 2026-08-21 and this row's element cell already
reads it.** Nothing below is written to `docs/elements/catalog.md` or
`docs/elements/ledger.md` by this run.

- **Elements:** one, `E154`, and it does not split. The two halves of the row's
  `Wanted` constrain each other: the truthful message needs the retained owner,
  and the retained owner is the first half of the mangling. Where two parts
  constrain each other one element covers both, so the staging is two commits
  under one element rather than two elements.
- **Band: UNASSIGNED.** The arc reserves no element block and twenty-three of its
  twenty-four rows carry elements minted before the arc file existed.
- **Catalog row:** exists at `docs/elements/catalog.md:485`. It is **wrong in
  three places** and the repointing is `revisit` work, not this run's: the
  `TUI/scriba/cmd-types.chiral:2` path (no `TUI/` directory exists), the
  *"hand-patched three times"* count against thirteen, and the reference class
  `name mangling (IMPL, any linker)`, which is honest for Shape A and describes
  neither Shape C nor what §2 measured.
- **Ledger row:** exists at `docs/elements/ledger.md:151`, category `label-ns`,
  state `design`, track `SH`. The state is correct. The cell repeats the same
  *"THREE times"* count and the same catalog prose.
- **Size, for the SPEC:** two commits.
  - **Commit 1, the retained owner and the split refusal.** `lib/module/loader.chiral`
    (pending list, close stamp, accessor), `lib/surface/parse.chiral` (carry the
    marker name into the close for the 51 unannotated extents),
    `lib/lowering/compile-all.chiral` and `lib/lowering/compile-emit.chiral`
    (one parameter, two messages, `first-dup-go` split in two). **5 files, 80 to
    140 lines.** Basis: `first-dup-go` plus `names-mem` plus `tifn-nm` is 12
    lines today, `sig-close-extent` plus `kinds-charge` is 18, and the parameter
    carry crosses three call sites.
  - **Commit 2, the owner through resolution to the label.**
    `lib/surface/syntax.chiral`, `lib/typing/kernel.chiral` (4 read sites),
    `lib/module/loader.chiral`, `lib/lowering/compile-back.chiral`,
    `lib/typing/erased-nf.chiral`, `lib/lowering/tal/{erase,reify,ir}.chiral`,
    `lib/lowering/{mach/emit-core,x64/emit}.chiral`, and `tools/test/pretty.sh`,
    whose M13 row asserts the refusal this commit removes (§3 item 4).
    **11 to 13 files.** Line
    count is decided by question 4: reserved-owner for hand-authored tal keeps it
    near 250 to 400 lines; a real owner for every `ti-fn` reaches the 104 and 175
    sites and is a different change.
  - **Build cost, both commits.** Every file named is inside `prog/compiler.prog`'s
    61-module closure and both commits touch emission, so the first agreement is
    **`C2 == C3`**, per `docs/definitions/working-discipline.md:35-41`.
    `(ulimit -s unlimited; …)` on every generation, every artifact checked
    non-empty before every `cmp`, stop after `C4`.
- **Related:** [[banks/module]] §4 and §5 item 6, `docs/definitions/altitude-errors.md`
  A2, `records/lenses/problems.md` PRB-44, [[arcs/lowering-and-emit-arc]]
  requirements 4 and 5, `lowering-and-emit/LE24` for the phase.

Every `E#` named here is already minted: `E154`, `E151`, `E152`, `E161`, `E2`.
The only forward work named without a number is `lowering-and-emit/LE24`, which
is a roster row that exists.
