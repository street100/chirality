---
element: E187
slug: stated-invented-names
title: "**The `sk-defunc` blame channel: `closconv` states why it dropped a family**"
kind: BUILD-PROPER
example: examples/E187-stated-invented-names.md
status: draft
updated: 2026-09-05
---

# E187 SPEC — **The `sk-defunc` blame channel: `closconv` states why it dropped a family**

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

**Measured at HEAD `e04168f`, 2026-09-05**, against `bin/chirality-bin`
1,184,120 bytes, sha256 `cadc5bb9a4f24b91f9be…`. Three measurements this run
performed are §2's evidence, and none of them is derived. They correct the
example on three counts: the symptom string, the file count, and whether
`format-blame` renders `sk-defunc` at all.

**The filename keeps the `stated-invented-names` slug.** It is the provenance of
what this artifact was minted to examine, recorded in the example's §6 question 1,
and `pack.py` resolves the element by globbing `E187-*`.

## 1. Deliverable

- **After this runs:** a family `closconv` poisons at `st-add-gsite` reaches the
  user with **the reason attached to the global's name**. On
  `tools/test/samples/e188_slot_break.prog`, today's refusal

  ```
  no emitted label for entry compile-main | skip chain for compile-main: compile-main: extern does not lower: reference stays upper: e188-plus
  ```

  becomes

  ```
  no emitted label for entry compile-main | skip chain for compile-main: compile-main: extern does not lower: reference stays upper: e188-plus | defunctionalization refused: e188-plus: family arity disagrees with the global's
  ```

  `sk-defunc` (`lib/lowering/skip-diag.chiral:15`) gains its first caller, and
  the `why` it carries reaches the message for the first time.

- **Non-goals.**
  - **The existing chain is not rewritten.** `format-blame`'s output is
    byte-identical on every program, including this one. The cause is a second
    clause appended after it. §3 decision D2 gives the reason and §5 row R5
    gates it.
  - **`pois` keeps its shape and `keep-fams` keeps its predicate.** Decision D1.
  - **A family drop that does not break the program stays silent.** The cause
    clause rides the `elf-err` path only, which is the granularity the existing
    skip channel already has.
  - **No second stated channel through `datas->n`,** and no edit to `apply-ty`.
    The example's §1.3 and §1.4 measure both as spent, and
    [[decisions/decision-erased-word-level]] forbids the only honest replacement
    for the second.
  - **No suite phase number.** Decision D5.
  - **Nothing is minted.** Decision D8.
  - **The emitted code over `lib/` and `prog/` must be BYTE-IDENTICAL.** E188
    measured a guard-off rebuild identical there, so no family in this tree is
    poisoned and no cause clause should appear anywhere in the self-compile.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none. E187 postdates the map snapshot, so the row
  is BUILD by default and every claim below is read from the live tree.

### 2.1 The three measurements

**M-A. The symptom string in the example, in the catalog row and in
`docs/examples/INDEX.md:170` is wrong, and the fixture's own header is right.**
All three say the user meets `body is not a lambda chain`. Measured on the
breaker at HEAD with the tracked binary, the refusal reads
`extern does not lower: reference stays upper: e188-plus`. The string comes from
`lib/lowering/upper/lower.chiral:246`, not from `:417`, and
`tools/test/samples/e188_slot_break.prog:15-17` recorded it correctly on
2026-09-04. The distinction matters to §5: `e188-plus` **already appears** in
today's message, so a gate row grepping for the global name anywhere in the
stderr passes before any work is done.

**M-B. The pattern-site census: nine files move, not six.** The example's §6
names six and misses three. Every site that destructures a widened constructor,
counted with `grep -rn` over `lib/`, `prog/` and `tools/`:

| widened | declaration | destructuring / constructing sites |
|---|---|---|
| `CState` 3 → 4 | `closconv.chiral:618` | `closconv.chiral:669`, `:672`, `:675`, `:678`, `:961`; **`closconv-driver.chiral:281`** |
| `CCOut` 2 → 3 | `closconv-driver.chiral:142` | `closconv-driver.chiral:283`, `:286`; `compile-front.chiral:342`; **`prog/e186-capture-fields.prog:287`** |
| `fr-ok` 4 → 5 | `compile-front.chiral:315-317` | `compile-front.chiral:348`; `compile-all.chiral:22`; **`prog/e185-apply-word.prog:120`**; **`prog/e188-apply-spine.prog:62`** |
| `back-program` 3 → 4 | `compile-back.chiral:297` | `compile-all.chiral:23` |

The three the example does not name are `prog/e185-apply-word.prog:120` and
`prog/e188-apply-spine.prog:62`, both Phase 7 roots and both probes whose own
gates run by hand, and `lib/lowering/skip-diag.chiral`, which M-C makes a target.
`prog/e186-capture-fields.prog:287` is the one the example does name, and its
line number is right.

**M-C. `format-blame` does not render `sk-defunc`'s `why`, and there is no
accessor that reads it.** `blame-chain` (`skip-diag.chiral:53-68`) dispatches on
`skwhy-tag`: `"extern"` is a leaf through `leaf-label`, and **everything else
recurses on `skwhy-name`**. A `sk-defunc` record therefore renders as a bare
name and continues the walk, and `why` is read by nothing. The accessor set is
`skwhy-name` (`:25-26`) and `skwhy-tag` (`:28-29`); there is no `skwhy-why`. So
routing the record into `br-ok`'s skip list is **necessary and not sufficient**,
and `skip-diag.chiral` is a target of this element rather than a dependency of
it. This answers the example's §6 question 4, which asked whether the rendered
line reads well: it does not render at all.

⚑ **A second consequence, measured.** The chain in the breaker leafs at
`compile-main` through the `extern` arm, so a defunc record keyed by
`e188-plus` is never reached by `blame-chain` even after it is in the list.
Decision D2 is what this forces.

### 2.2 Live code this composes with, all of it built

- **The poison channel, end to end.** `CState`'s `pois` (`closconv.chiral:618`),
  `key-add` / `key-in?` (`:639-645`), `st-add-pois` (`:676-678`), `st-add-gsite`
  (`:700-706`) with its two refusing arms at `:703` and `:706`, `keep-fams`
  (`closconv-driver.chiral:96-106`), reached from `closconv-sig` (`:277-289`).
  E188 built the guard, and the standing comment at `closconv.chiral:686-699`
  states its argument.
- **`st-add-pois`' three call sites**, and only two carry a global name:
  `closconv.chiral:703` and `:706` do; `cwalk-app-head` (`closconv.chiral:844`)
  does not, and its poison call sits at `closconv.chiral:851`. It poisons an
  **unsaturated higher-order variable** keyed by `hty`, a type with no global
  attached. This is D1's decisive fact.
- **`SkReason` / `SkRec` and the whole skip-diagnostic module** (E97,
  `lib/lowering/skip-diag.chiral`), including `sk-defunc` itself
  (`:15`), minted by E188 with no caller, and its two discriminants named in the
  comment at `:11-14`: `"no declared type"` and
  `"family arity disagrees with the global's"`.
- **The back's skip list**, `BR`'s `(skips (List SkRec))`
  (`compile-back.chiral:125`), `lower-defs`' `skips` accumulator (`:220-240`),
  and the assembly `(lapp-skip skips (lapp-skip fskips (lapp-skip pskips esk)))`
  at `:227`, which puts the accumulator's contents FIRST.
- **`back-program`'s seat.** `compile-back.chiral:297-301` already passes
  `nil nil` as `lower-defs`' seed `TFn` and seed `SkRec` lists. The seat exists;
  only the entry needs to offer it.
- **The one renderer.** `compile-all.chiral:36-39`, whose `elf-err` arm calls
  `format-blame` when `skips` is non-nil.
- **The observable's fixture**, `tools/test/samples/e188_slot_break.prog`, built
  by E188, whose header records both measured diagnostics.

### 2.3 True delta

Four constructor widenings, one new recording function, one new accessor, one new
formatter, one new clause in the error message, one function signature, nine
files under `lib/` and `prog/`, three comment repoints, one gate script with one
declaration line, and one stale mutation needle in an existing gate. Nothing
else moves, and `format-blame`'s own output does not move at all.

## 3. Decisions

Every open question from the example §6, dispositioned, plus the three the
measurements above opened. No silent design calls.

| # | Question | Disposition | Rationale / owner |
|---|---|---|---|
| D1 | `pois` and `dsk` as two lists, against one list of pairs | **RESOLVED: two lists** | §3.1, by measurement at `closconv.chiral:851` |
| D2 | Where the cause is rendered | **RESOLVED: a second clause beside `format-blame`** | §3.2, by M-C |
| D3 | `why` as `Str`, or a nested sum | **RESOLVED: `Str`** | `skip-diag.chiral:11-14` already names the two discriminants and `SkReason`'s other two arms carry `Str` |
| D4 | Where the seed enters the back half | **RESOLVED: `back-program` gains the parameter** | `back-program` (`compile-back.chiral:297`) already passes `nil nil`; the alternative reaches past the back's entry |
| D5 | Which suite phase number the gate takes | **DEFERRED: `records/author-calls.md:30`** | The standing call; the gate declares itself out with a reason, as `apply-spine.sh`, `apply-word.sh` and `capture-fields.sh` do |
| D6 | The three `shape-eq` comments citing `:335-356` | **RESOLVED: folded into Steps 2 and 4** | Example §6 question 3; a comment-only edit owes the rebuild, and these steps already own the rebuild |
| D7 | Does `format-blame` render `sk-defunc` acceptably | **RESOLVED: it does not render it at all** | M-C. Question 4 is answered by measurement and its answer is D2 |
| D8 | Whether a sibling element is owed | **NEEDS-AUTHOR, non-blocking** | §3.3. `E189` was spent by the author at `e04168f` and Lane A's band is now full |

### 3.1 D1: two lists, and the merged shape removes neither of them

The example's §6 question 2 calls this the fork that makes E187 element-sized.
Both shapes were weighed against the constraint the re-scope run measured.

**The merged shape.** `pois` becomes `(List (Pair Core (Maybe Str)))`, or a
fourth `SkReason` arm carries the nameless case. `keep-fams` filters on
`key-in? pois key`, so every membership test projects the pair, and
`arrow-key-eq` is threaded through a projection at each of `key-in?`'s
recursions. The argument for it is the substrate argument: a family is never
dropped without a reason, and a single list makes that structural rather than a
convention two lists have to keep.

**The measurement that kills it.** *That invariant is false at HEAD.*
`st-add-pois` has three call sites, and the third, inside `cwalk-app-head`
(`closconv.chiral:844`) at `closconv.chiral:851`, poisons
an unsaturated higher-order **variable**, keyed by `hty`. There is no global at
that site and no reason to state beyond the key itself. So the merged list
carries a `(none)` that every reader must handle and no reader can act on, and
the type system is reporting exactly that: the invariant the merge would enforce
is not the invariant that holds.

**And the merge does not remove the second list.** `pois` is keyed by `Core`,
`closconv`'s own vocabulary, and it never leaves the pass. `keep-fams` consumes
it inside `closconv-sig`. What crosses `CCOut` → `FR` → `back-program` is
`SkRec`, which is `Str`-keyed and belongs to `skip-diag`. The two are keyed by
different things and live in different vocabularies, so a merge relocates where
the `SkRec` is built and pays the projection at every membership test without
deleting a list. It buys nothing and costs `keep-fams`.

**Two lists, therefore, with the correspondence kept by construction.**
`st-pois-defunc` records a `SkRec` **only when the family was not already
poisoned**, mirroring `key-add`'s idempotence, so `dsk` holds at most one record
per family and the two lists cannot drift into reporting a cause twice for one
drop. That is the honest fraction of the invariant the merge was reaching for,
and it is enforceable inside one function.

⚑ **What that idempotence does not buy, stated so it is not a later surprise.**
It bounds `dsk` from above and leaves it unbounded from below. A family poisoned
FIRST at `closconv.chiral:851`, where there is no name and no record, and
reaching `st-add-gsite` afterwards under an `arrow-key-eq`-equal key, finds
`key-in?` already true and records no cause: that drop is reported by the
symptom alone. No shape in this tree reaches that order, because `:851` keys on a
`c-var` head's own type and `st-add-gsite` keys on a partial global
application's remainder. R5 and the suite are what catch it, and the repair if it
bites is a `key-in?` read off `dsk` in place of the one off `pois`.

⚑ **This is RESOLVED by measurement rather than by a settled document.** What
would reopen it: a fourth `st-add-pois` call site that carries a name, or a
ruling that the higher-order poison at `:851` should also state a reason. Either
makes the `(none)` disappear and the merge worth its price.

### 3.2 D2: the cause is a clause beside the chain

M-C measures two facts that together decide this. `blame-chain`'s `extern` arm
is a **leaf**, and the breaker's chain leafs at `compile-main`, so a record
keyed by `e188-plus` is never walked to. And `blame-chain` reads `skwhy-name`
and `skwhy-tag` and never `why`, so even a walked record renders as a bare name.

Three shapes were available.

- **Make `blame-chain` continue past an `extern` leaf when the op string names a
  global with a defunc record.** Rejected: it sniffs a formatted string for a
  name, which is the shape [[definitions/pattern-boundary-sums]] exists to
  forbid, and E97's comment at `skip-diag.chiral:3-6` pins the recursion's
  structure for an unrelated and still-live reason.
- **Rely on list order so `find-skip` returns the defunc record first.** Rejected
  by measurement: `lower-defs` PREPENDS its own `le-skip` records onto the
  accumulator (`compile-back.chiral:239`), so a seeded record sits at the
  accumulator's tail and the back's record for the same name wins. Relying on
  that order is a convention nothing checks.
- **Render the causes as a second clause.** TAKEN. A new `format-causes` filters
  the skip list for `defunc`-tagged records and renders each as
  `defunctionalization refused: <g>: <why>`, returning `""` when there are none.
  `compile-all` appends it after `format-blame`. `format-blame`'s output is then
  byte-identical on every program, which is what §5 row R5 gates and what keeps
  `tools/test/apply-spine.sh` R5's two greps passing.

⚑ **One hazard this leaves, stated so it is not a later surprise.** The seeded
record's `def-name` field is `g`, so `find-skip` can now match it while walking
a chain for `g`, and it precedes `fskips` and `pskips` records for the same name
in the assembled list. No live chain reaches that name today, because the breaker's
leafs first. A future program could. R5 and the suite are what catch it,
and the repair if it bites is a `def-name` that cannot collide.

### 3.3 D8: nothing is minted, and the band is now full

The example's §6 question 1 records the re-scope as taken partly because `E189`
stayed free. **Measured at `e04168f`: the author minted `E189` in parallel with
this run** (`op-mulhi` gets a surface extern, `docs/elements/catalog.md:505`,
owned by neither lane). Lane A's `E184-E189` band, shared with
[[arcs/diagnostics-arc]], now has **no free number**.

This SPEC therefore defers nothing to an unminted number, which is what
`docs/definitions/working-discipline.md`'s deferral rule requires, and §6's
residue is filed against existing homes or marked `UNASSIGNED`. **No sibling is
needed for this element to land.** §6 names two items of genuinely follow-on
work, the second discriminant's fixture and the `apply-spine.sh` R5 tightening
E188's own SPEC already left to the author. Each is small enough to ride an
existing gate or an existing row, and this run does not judge either into a
number it cannot allocate. The band being full is the author's call, and
`records/author-calls.md:29` is its standing row; this run does not edit it.

`status: draft`, not `blocked`: D8 blocks no step in §4.

## 4. Change plan (ordered, commit-sized)

Every step leaves the blob assembling and the compiler compiling. **The full
BUILD RULE runs once, at Step 8, before promotion.**
`docs/definitions/working-discipline.md` scopes it to `build-new → test →
promote`, not to each intermediate commit. Steps 1 to 6 are each verified with a
single `build-new` (`C1` only, non-empty checked) so a broken arity is caught at
the step that introduced it.

**Pathspec every commit.** The author works this tree in parallel.

### Step 1 — `skip-diag.chiral` gains the accessor and the formatter
- **Target:** `lib/lowering/skip-diag.chiral`, after `skwhy-tag` (`:28-29`) and
  before `lapp-skip` (`:32`).
- **Change:** four additions, no existing symbol touched.
  - `skwhy-detail (-> SkReason Str)`, the third accessor: `op` for `sk-extern`,
    `name` for `sk-callee`, **`why`** for `sk-defunc`. M-C: nothing reads `why`
    today.
  - `defunc-lines (-> (List SkRec) (List Str))` filters on
    `(str-eq (skwhy-tag (skrec-why s)) "defunc")` and renders each match as
    `defunctionalization refused: <skwhy-name w>: <skwhy-detail w>`. It uses the
    accessors only, honouring the ACCESSOR-FUNCTION PATTERN the module's header
    comment (`:3-6`) pins.
  - `join-semi (-> (List Str) Str)` is `join-arrows`' shape with `"; "`, because
    a cause list is not a chain and `" <- "` would read as one.
  - `format-causes (-> (List SkRec) Str)` answers `""` on an empty filter, else
    `" | "` joined onto `join-semi`. The empty case is what keeps every existing
    message byte-identical.
- **Size:** S. Nothing calls it yet.

### Step 2 — `CState` gains `dsk`, and `st-add-gsite` records the reason
- **Targets:** `lib/lowering/upper/closconv.chiral` and the one `cstate` pattern
  in `lib/lowering/upper/closconv-driver.chiral:281`. Both in one commit or the
  driver stops compiling.
- **Change:**
  - `(import "lowering/skip-diag")` at the top of `closconv.chiral`.
    `compile-back` and `typing/diag` already co-blob that module, so no new name
    collision is introduced (cf. E154), and `skip-diag` depends only on
    `prelude/prelude`, so the blob's order is unaffected.
  - `CState` (`:618`) gains a fourth field `(dsk (List SkRec))`. Rebuild it
    unchanged in `st-ensure-fam` (`:668-669`), `st-add-site` (`:670-672`),
    `st-add-ho` (`:673-675`), `st-add-pois` (`:676-678`); seed it `nil` in
    `collect` (`:959-961`).
  - New `st-pois-defunc (-> CState Core Str Str CState)`, placed beside
    `st-add-pois`. It poisons through `st-add-pois` and appends
    `(mk-skrec g (sk-defunc g why))` **only when `key-in?` on the old `pois` was
    false** (D1's idempotence).
  - `st-add-gsite` (`:700-706`): the `(none)` arm becomes
    `(st-pois-defunc st key g "no declared type")` and the `false` arm becomes
    `(st-pois-defunc st key g "family arity disagrees with the global's")`. Both
    strings are the discriminants `skip-diag.chiral:11-14` already names, and
    they are the SPEC's pinned strings.
  - `closconv-driver.chiral:281` destructures the fourth field and discards it
    at this step.
  - **D6, folded in:** two of the three `shape-eq` comments carry a span that
    drifted. `closconv.chiral:1153` and `closconv-driver.chiral:119` both cite
    `shape-eq` at `closconv.chiral:335-356`, where `closconv.chiral:340` is the
    definition and `closconv.chiral:356` the end. Repoint both.
- **Size:** M.

### Step 3 — `CCOut` gains `dsk`
- **Targets:** `lib/lowering/upper/closconv-driver.chiral`,
  `lib/lowering/compile-front.chiral`, `prog/e186-capture-fields.prog`. One
  commit; M-B says the prog stops compiling otherwise.
- **Change:** `CCOut` (`:142`) gains `(dsk (List SkRec))`. `closconv-sig`'s two
  constructors take it: the closure-free arm at `:283` becomes
  `(ccout s nil dsk)`. ⚑ **A refusal still reports when no family survives**,
  which is the arm that would otherwise drop every cause on a program whose only
  family was poisoned. The synth arm at `:286` passes `dsk` through.
  `bridge-sig` (`compile-front.chiral:340`) destructures the third field at
  `compile-front.chiral:342` and discards it at this step. `prog/e186-capture-fields.prog:287`'s `((ccout sig2 stated)`
  gains the third binder.
- **Size:** S.

### Step 4 — `fr-ok` gains `dsk`
- **Targets:** `lib/lowering/compile-front.chiral`,
  `lib/lowering/compile-all.chiral`, `prog/e185-apply-word.prog`,
  `prog/e188-apply-spine.prog`. One commit.
- **Change:** `FR`'s `fr-ok` (`compile-front.chiral:315-317`) gains a fifth
  field `(dsk (List SkRec))`; `fr-err` is untouched, because a poisoned family
  is a named skip at `keep-fams`' own granularity and not a whole-program error.
  `bridge-sig`'s `fr-ok` (`:348-349`) passes `dsk` through. The three pattern
  sites M-B found take the fifth binder: `compile-all.chiral:22`,
  `prog/e185-apply-word.prog:120`, `prog/e188-apply-spine.prog:62`.
  **D6, folded in:** repoint `shape-eq` to `:340-356` at
  `compile-front.chiral:194`.
- **Size:** S.

### Step 5 — `back-program` offers the seat `lower-defs` already has
- **Targets:** `lib/lowering/compile-back.chiral`,
  `lib/lowering/compile-all.chiral`. One commit.
- **Change:** `back-program` (`compile-back.chiral:297`) becomes
  `(-> (List NDef) (List NData) (List NPrim) (List SkRec) BR)` and passes the
  new parameter as `lower-defs`' last argument in place of the second `nil`.
  `compile-all.chiral:23` passes `dsk`.
- **Size:** S.

### Step 6 — the cause clause lands, and the observable with it
- **Target:** `lib/lowering/compile-all.chiral:36-39`, the `elf-err` arm.
- **Change:** the non-nil branch becomes
  `(ca-err (str-cat m (str-cat " | " (str-cat (format-blame entry skips) (format-causes skips)))))`.
  `format-causes` returns `""` when the list holds no defunc record, so every
  message this tree produces today is unchanged to the byte.
- **Size:** S. ⚑ **This is the step the deliverable is observable at**, and §5's
  base line goes green here.

### Step 7 — the gate, and one stale needle
- **Targets:** `tools/test/defunc-blame.sh` (new),
  `tools/test/apply-spine.sh`. Outside the blob, so no rebuild is owed.
- **Change:** §5's script, with its `# not-a-phase:` declaration and a non-blank
  reason. And ⚑ **`apply-spine.sh:336`'s M3 needle
  `(false (st-add-pois st key))` goes stale at Step 2**: `mutate` enforces the
  occurrence count at exactly 1 and would grade `bad`, taking that gate from
  `11 ok, 0 FAIL` to `10 ok, 1 FAIL`. Repoint it to the new
  `(false (st-pois-defunc st key g "family arity disagrees with the global's"))`
  with the same replacement, which leaves M3's pin unmoved because it still
  registers the mismatch instead of poisoning it. ⚑ **That needle cannot ride a
  single-quoted shell argument**: the pinned string carries an apostrophe in
  `global's`, and every `mutate` call in that script passes its needle in single
  quotes. Pass it double-quoted with the inner `"` escaped, and keep it spanning
  the WHOLE call. A needle cut short of the apostrophe leaves the tail behind,
  `sed` writes a tree that does not compile, and the row is graded on a build
  failure, which is GA-19 through a different door.
- **Size:** M.

### Step 8 — the BUILD RULE, then promotion
- **Target:** `bin/chirality-bin`, in its own commit.
- **Change:** the fixpoint, per `docs/definitions/working-discipline.md` as
  corrected at `76d3296`:

  ```
  . bin/chirality-resolve.sh
  chirality_blob_file "lib:prog" prog/compiler.prog > /tmp/blob.chiral
  (ulimit -s unlimited; bin/chirality-bin < /tmp/blob.chiral > /tmp/C1) && chmod +x /tmp/C1
  [ -s /tmp/C1 ] && (ulimit -s unlimited; /tmp/C1 < /tmp/blob.chiral > /tmp/C2) && chmod +x /tmp/C2
  [ -s /tmp/C2 ] && cmp /tmp/C1 /tmp/C2
  # differ: C3 from C2, cmp C2 C3; then C4 against C3.  STOP AFTER C4.
  ```

  ⚑ **Convergence is two consecutive generations agreeing, bounded at `C4`, and
  WHICH generation agrees first is measured here rather than predicted.**
  `docs/definitions/working-discipline.md` puts the first agreement at `C2 == C3`
  where the change reaches an EMITTING site the compiler's own blob executes,
  which is what E188 measured (`032681f`, its `arm-body` `(none)` arm reached
  twice), and at `C1 == C2` where the change leaves emission alone.
  ⚑ **The two readings are mutually exclusive with this SPEC's own byte-identity
  check, which makes the fixpoint's shape a second reading of that check.** The
  check below asserts the promoted binary emits byte-identically over `lib/` and
  `prog/`: no family here is poisoned, so `dsk` is `nil` at every root, and
  `format-causes` is reached only on the `elf-err` path a successful self-compile
  never takes. Where that holds, the tracked binary and `C1` emit alike on the
  same blob and the first agreement is `C1 == C2`. A measured `C1 != C2` says the
  change did move emission, and the byte-identity check is then what to read
  next. Either agreement is a correct build and neither is assumed. Non-empty is
  checked before every `cmp`; `(ulimit -s unlimited; …)` is on every build; a
  generation past `C4` that still differs is a defect. Report the sizes and the
  first differing char, and stop.
- ⚑ **Byte-identity check.** Recompile every root under `lib/` and `prog/` with
  the promoted binary and compare against the pre-change output. No family in
  this tree is poisoned (E188 measured a guard-off rebuild identical), so **no
  cause clause may appear anywhere in the self-compile**, and the emitted code
  must be byte-identical.
- **Size:** L in wall clock, S in diff.

## 5. Conformance gate

`tools/test/defunc-blame.sh`, over `tools/test/samples/e188_slot_break.prog`,
the fixture E188 already built, whose header carries both measured diagnostics.
No new fixture is needed and none is added.

⚑ **It takes no suite phase number** (decision D5). Its header carries one
declaration line with a non-blank reason, which is what `registration.sh` G4
checks and what keeps G2 green:

```
# not-a-phase: E187's number waits on the standing suite-phase-number call in
#   records/author-calls.md:30 -- four documents disagree about 21-23.
```

`registration.sh` reads **9 of 22** scripts outside the dispatch table at HEAD;
this makes it 10 of 23. (`records/author-calls.md:30` still says 8 of 21, one
generation stale since `apply-spine.sh` landed. That is a doc-tier repair and
not this element's.)

### 5.1 Six rows, ONE verdict line, and every mutant pins the line in FULL

`records/gate-audit.md` GA-21 and GA-22 both convict a gate that names one row
per mutant, because a mutant reddening a row outside its own pin is then
invisible.

⚑ **The rows are built on the symptom-versus-cause distinction, not on a refusal
happening.** M-A measures why that matters: the breaker is refused today, the
message already names `e188-plus`, and a row asserting either would be green
before any work is done. R1 exists so absence is a graded cell, and it is
explicitly not the deliverable; **R2, R3 and R4 are the deliverable and all three
are `bad` at HEAD.**

| row | asserts | judged by | at HEAD |
|---|---|---|---|
| **R1** | the compile is **refused**: no ELF is emitted | the presence of an ELF | `ok`. Present so absence is graded, and it carries the deliverable nowhere |
| **R2** | the message carries a **cause clause**: `defunctionalization refused:` | the stderr | **`bad`** |
| **R3** | the cause clause **names the global at the refused site**: `e188-plus` appears in the cause segment | the cause segment alone, never the whole stderr | **`bad`** |
| **R4** | the cause names the **right discriminant**: `family arity disagrees with the global's` is in the cause segment and `no declared type` is not | the cause segment alone | **`bad`** |
| **R5** | the **symptom clause is unchanged**: the stderr still carries `skip chain for compile-main: compile-main: extern does not lower: reference stays upper: e188-plus`, verbatim | the stderr | `ok`. The non-regression row, and what protects `apply-spine.sh` R5 |
| **R6** | the **pre-change** binary emits no cause clause on the same fixture and the promoted one does | two binaries, one fixture | **`bad`** (`nobase` until a baseline is set) |

⚑ **The cause segment is cut on the marker, and cutting it on the last pipe
separator is M-A's own trap.** At HEAD the message carries ONE `|`, so the text
after the last separator is the skip chain and `e188-plus` sits inside it: R3
read that way scores `ok` before any work, which is the cell M-A was measured to
protect. **The cut.** The cause segment is the text following the first
`defunctionalization refused: ` in the stderr, and it is the EMPTY string when a
refusal carries no such marker. A row asserting a substring of an empty segment
grades `bad`. `absent` is reserved for a run with no refusal to read, which is
M5's case alone.

**The seventh field is not a row.** `cause=<v>`, where `<v>` is the cause segment
with its leading `<name>: ` cut at the FIRST `: `, normalised to `[a-z0-9_]`
(spaces to `_`, everything else dropped), or `cause=absent` when the segment is
empty or there is no refusal. That cut is what `defunc-lines` writes, and M2, M3
and the base line are pinned against it. E188's own gate carries the same kind of field for
the same reason: **two mutants below redden the identical six cells and only the
measured value separates them.**

**A skipped or absent measurement grades `absent`, never `ok`.** It is the convention
`apply-word.sh` (`:60`, `:275`), `capture-fields.sh` (`:243`) and
`apply-spine.sh` all spell.

**R6's baseline binary** comes from git the way `apply-spine.sh`'s does.
`E187_BASE_REV` defaults to the Step 7 commit, the last one before promotion,
and `E187_BASE_CC` overrides it with a path. With neither, R6 scores `nobase`
and the script exits 1. An unscored control is not a passing one. The pin will
age, and a stale pin is repaired by a fresh `E187_BASE_REV`, never by widening
the comparison.

**Base line at HEAD, before any work:** `ok bad bad bad ok bad cause=absent`.
**Base line the element must produce:**
`ok ok ok ok ok ok cause=family_arity_disagrees_with_the_globals`.
The mutants are not run unless the base line is all-`ok`
(silent failure 4: a mutant graded against an already-red base measures nothing).

### 5.2 Five mutants, every one a SUBSTITUTION, every one BUILT AND RUN

GA-19: deleting an arm makes the module non-exhaustive, the compiler refuses the
mutated tree, and the row is graded on a compile refusal instead of on the
property it names. **Nothing below removes an arm or changes an arity.** Each
substitution declares its occurrence count, the count is enforced at exactly 1,
the mutated file is `cmp -s`'d against the base before it is built, and the
scratch `lib/` is checked not to be a symlink (the `pretty.sh` arc).

| mutant | substitution | reddens | pin |
|---|---|---|---|
| **M1** | Step 2's mismatch arm reverts to `(st-add-pois st key)`: the family is still poisoned and the reason goes unrecorded | **R2, R3, R4, R6** | `ok bad bad bad ok bad cause=absent` |
| **M2** | Step 2's two `why` strings are swapped, so the arity arm passes `"no declared type"` | **R4 alone** | `ok ok ok bad ok ok cause=no_declared_type` |
| **M3** | Step 2's record becomes `(sk-defunc why why)`: a cause with the right discriminant and no name | **R3 alone** | `ok ok bad ok ok ok cause=family_arity_disagrees_with_the_globals` |
| **M4** | Step 1's `defunc-lines` filters on `"extern"` instead of `"defunc"`: a cause clause exists and reports the wrong record | **R4 alone** | `ok ok ok bad ok ok cause=e188plus_reference_stays_upper_e188plus` |
| **M5** | Step 2's guard never fires: the mismatch branch calls `st-add-site` (`apply-spine.sh`'s own M3) | **R1, R5, R6**; R2–R4 grade `absent` | `bad absent absent absent bad bad cause=absent` |

⚑ **M1 is the element's own falsifier and it reproduces today's line exactly.**
That is the point: M1 restores the pre-change behaviour, so a green R2/R3/R4
cannot be inherited from anything already in the tree.

⚑ **M2 and M4 redden the identical six cells and the seventh field is what
separates them.** This is E188's M1/M4 problem in a new place, and the brief for
this run named it in advance. M2 reports the *wrong discriminant for the right
record*; M4 reports the *right discriminant's absence because the wrong record
was selected*. Both leave R2 and R3 green, because `defunctionalization refused:` is
present and `e188-plus` is inside the segment in both. Only the measured
`cause=` value tells them apart. A gate pinning six cells would grade them
identical and one of the two would be falsifying nothing.

⚑ **M4's seventh value is the least certain of the five.** `skwhy-name` and
`skwhy-detail` BOTH answer `op` on a `sk-extern` reason (`skip-diag.chiral:26`,
and Step 1's accessor), so M4's line renders the op twice and the cut above lands
inside it. The pin is what that derivation gives on a one-record filter; the
record count under M4's filter is unmeasured, and a second extern record would
lengthen the value through `join-semi`. The six cells hold either way, and the
value is corrected by measurement like every other pin.

⚑ **Every row is reddened by at least one mutant**, which is what GA-22
convicts a gate for lacking: R1 by M5, R2 by M1, R3 by M1 and M3, R4 by M1, M2
and M4, R5 by M5, R6 by M1 and M5.

⚑ **M5's R1 is `bad` by measurement, not by derivation.** `apply-spine.sh`'s M3
is the same substitution and its measured pin scores that gate's refusal row
`bad`, which its `blame_of` helper returns only when the breaker **emitted an
ELF**. So under M5 the fixture compiles, wrongly, and R1 catches it.

⚑ **NO PIN ABOVE IS EVIDENCE UNTIL ITS MUTANT HAS BEEN BUILT AND RUN.** EN-21
corrected E186's M5 for exactly that gap, `apply-word.sh:59-67` records the same
correction being forced on E185, and E188's own SPEC had two of five pins
corrected by measurement. The implementation run measures all five and records
every divergence at its mutant, in the script.

### 5.3 Why this gate is not satisfiable by today's tree

The suite is green and the fixpoint holds with `sk-defunc` unreached, so neither
instrument witnesses the gap. R2, R3 and R4 read a string that does not exist at
HEAD; R6 pins the pre-change binary's message explicitly, so a green R2 cannot
be inherited from a baseline drift. And R5 is a **non-regression** row rather
than a deliverable row: it is green today and must stay green, which is what
makes an implementation that rewrites `format-blame` instead of appending to it
fail this gate.

- **Green line:** the gating floor is `tools/test/run-tests.sh` and E187's gate
  is not a phase in it. The suite baseline is `373 passed, 0 failed, 90 roots,
  gate PASSED`; **nothing may rise and nothing may fall.** The root census stays
  at 90. No new `prog/` root is added, and the three existing roots M-B found
  (`e185-apply-word`, `e186-capture-fields`, `e188-apply-spine`) must still
  compile after their pattern lines widen. `tools/test/apply-spine.sh` stays at
  `11 ok, 0 FAIL` (Step 7's needle repoint is what keeps it there).
  `python3 tools/ledger-lint/ledger-lint.py` stays at exit 0.
- **Done when:** `tools/test/defunc-blame.sh` prints `11 ok, 0 FAIL`, six rows
  plus five mutants, with the base line
  `ok ok ok ok ok ok cause=family_arity_disagrees_with_the_globals`; the
  promoted binary at its byte fixpoint (`C2 == C3` expected, non-empty checked,
  bounded at `C4`); `lib/` and `prog/` recompiling byte-identically with no
  cause clause anywhere in the self-compile; and `run-tests.sh` at its baseline
  with `apply-spine.sh` still `11 ok, 0 FAIL`.

## 6. Residue & links

- **Deliberately unbuilt.**
  - **A fixture for the second discriminant, `"no declared type"`.** The `(none)`
    arm of `st-add-gsite` is reachable in principle, because `fv-own` and
    `fv-site` call it without pre-checking `arity` the way `cwalk-app-head`
    does. No
    source shape in this tree reaches it, and this run did not construct one. M2
    falsifies the discriminant through a mutant instead, which is honest about
    what is measured. **Home: this element's own gate**, as a seventh row added
    the day a fixture exists. Nothing is deferred to a number.
  - **Tightening `apply-spine.sh` R5 to read the `sk-defunc` tag.** E188's SPEC
    §5 left this to the author, explicitly, once the blame channel lands. It
    lands here. **Home: `records/author-calls.md`**, as an amendment to a row the
    author already holds; this run does not edit it.
  - **A nested sum in place of `why`'s `Str`** (D3). The STANDING DIRECTIVE one
    level deeper. Owed by nothing today: two discriminants, both named in the
    source, both `Str` like `SkReason`'s other arms. **Home: nobody's yet.**
  - **The `def-name` collision hazard** D2 states. No live chain reaches it.
    **Home: this element's R5 and the suite.**
  - **`records/author-calls.md:30`'s stale count** (8 of 21, measured 9 of 22).
    **Home: a `doc-audit` run.**
- **Follow-on.** None minted, and ⚑ **none mintable**: `E189` was spent by the
  author at `e04168f` and Lane A's `E184-E189` band has no free number.
  `records/author-calls.md:29` is the standing row for the band, and its "four
  numbers remain" is now zero. Every residue item above is filed against an
  existing home or against nobody, which is what the deferral rule requires.
- **Related:** [[E187-stated-invented-names]] · [[E185]] (built the `CCOut`
  channel this widens) · [[E186]] (ruled the capture fields `concrete`, which is
  what closed E187's minted subject) · [[E188]] (minted `sk-defunc`, built the
  guard, built the fixture, and left the caller unwritten) · [[E97]] (`SkReason`,
  `SkRec` and `format-blame`, the module M-C makes a target) ·
  [[decisions/decision-erased-word-level]] (why the struck clauses cannot be
  repaired) · [[definitions/working-discipline]] (the build rule as corrected at
  `76d3296`) · [[records/enforcement-arc]] EN-22 ·
  [[records/gate-audit]] GA-19, GA-21, GA-22 · [[arcs/enforcement-arc]]
