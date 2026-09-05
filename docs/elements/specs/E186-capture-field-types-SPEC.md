---
element: E186
slug: capture-field-types
title: "**The `$k<i>_<j>` capture constructor's field types: concrete, or the erased word**"
kind: BUILD-PROPER
example: examples/E186-capture-field-types.md
status: draft
updated: 2026-09-04
---

# E186 SPEC: **The `$k<i>_<j>` capture constructor's field types: concrete, or the erased word**

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** the ruling is **`concrete`** and it is written down where
  the fork was left open, and a gate exists that **separates the two answers**:
  `prog/e186-capture-fields.prog` computes `ctor-honest?` and the `$clo` field
  lowering from `closconv-sig`'s own output, `tools/test/samples/e186_capture_fields.prog`
  is the family that exercises both halves of the rule, and
  `tools/test/capture-fields.sh` judges four rows and runs five mutants, each of
  which reddens its named rows on a tree that builds. ⚑ **R2 is the row that
  separates the two answers**, because M1 rewrites a field's source `Term` and
  that field's lowering together and stays self-consistent under `ctor-honest?`.
  ⚑ **R4 carries a falsifier of its own**, on the fourth fixture site FLAG B
  bought: a site whose three ground captures no golden holds as a constant, one
  of which M5 sends to the word, reddening R4 alone. §5 measures both.

- **Non-goals.**
  - **No compiler source changes.** Nothing under `lib/` is edited, so the blob
    is byte-identical by construction and the build rule
    (`docs/definitions/working-discipline.md`) has no subject here.
  - **No stated channel for datas.** Extending `sp` to reach `datas->n` is the
    cost of the answer this ruling rejects, and it is E187's `$clo<i>` half.
  - **No phase number.** The gate declares itself out of the dispatch table with
    a reason, on the standing author call in `records/author-calls.md`.
  - **No close on the author's row.** E186 ships the ruling in
    `docs/decisions/decision-erased-word-level.md` and appends a pointer to the
    live row in `records/author-calls.md`. Closing that row is the author's edit
    (FLAG A, disposed 2026-09-04), and Steps 1, 2 and 6 are written to that one
    shape.
  - **No wrong-value repair.** E188 owns `arm-body`'s reached arm.
  - **No whole-blob `ck-prog` census.** §5 says what that target is worth and
    where its instrument lives.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none. E186 postdates the map snapshot and the
  pack reports no row, so the build state comes from the live tree below.

- **Live code, all built, none of it respecced here.**
  - `site-fields->term` (`lib/lowering/upper/closconv-driver.chiral:153-163`)
    writes one `$clo` ctor field per kept capture as
    `(field q "capN" (core->term fty))`, the capture's own source type at its
    own site. This **is** the ruling, already in the tree.
  - `term->ntalty` (`lib/lowering/compile-front.chiral:58-72`) maps `(t-var i)`
    and `(t-pi _ _ _ _)` to `(nt-word)`, recurses through `(t-refine base atoms)`
    into the base, and carries every other shape to its concrete `NTalTy`. This
    is [[banks/erasure]] shard **G**, measured built.
  - `field-tys->n` → `ctors->n` → `datas->n`
    (`lib/lowering/compile-front.chiral:238-261`) carries the fields into
    `NData`, dropping a whole data whose field fails to lower.
  - `field-erased?` / `kept-count` (`lib/lowering/upper/closconv.chiral:716-723`)
    is E100's type-kinded and `q=0` capture drop, [[banks/erasure]] shard **D**,
    built.
  - `shape-eq` (`lib/lowering/upper/closconv.chiral:340-356`) is the family
    merge, shard **E**, built. It is the pressure on the **dispatcher**, and it
    is why the two instances take different answers.
  - `apply-ptys` (`lib/lowering/upper/closconv-driver.chiral:131-133`) and the
    `CCOut` channel (`:142`) are E185, built and promoted at `1157028`.

- **True delta.** Zero lines of compiler source. The delta is three artifacts
  outside the blob and the doc rows that record the ruling:

  | new | what it is |
  |---|---|
  | `tools/test/samples/e186_capture_fields.prog` | one family, four sites: no capture, one arrow capture, two ground captures, three ground captures no golden pins |
  | `prog/e186-capture-fields.prog` | the probe: `ctor-honest?` over `closconv-sig`'s own output, printing one four-token line |
  | `tools/test/capture-fields.sh` | the driver: the base line, five mutants, every mutant pinning the full line |

  ⚑ **The probe is a new Phase 7 root.** Phase 7 discovers roots with
  `grep -rl '^(def compile-main' lib prog` (`tools/test/run-tests.sh:175`), so
  the root census moves by one, 88 to 89. The fixture goes to
  `tools/test/samples/` for the same reason E185's did: under `prog/` it would
  move the census twice.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled doc (cite it); genuinely novel
design goes to NEEDS-AUTHOR and is surfaced for the author to answer.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Does E186's SPEC produce a change plan, or a ruling and a gate row? | **RESOLVED: both, and neither touches the blob** | The example's own recommendation, taken with one correction. §4 is a change plan whose steps land in `docs/`, `records/`, `prog/` and `tools/test/`, and in no file under `lib/`. `docs/definitions/working-discipline.md:30-38` states the build rule for compiler source; with no compiler source touched there is nothing to build, test and promote, and saying so out loud is what the example asked the SPEC stage for. |
| 2 | Is the §5(c) predicate worth building before E187 lands? | **RESOLVED: yes, and it is built here** | See the measurement below. This is the decision the EXAMPLE audit routed to this stage. |
| 3 | What does the gate assert, given that today's tree already meets the non-regression target? | **RESOLVED: the field lowering itself, over a fixture with both halves** | `docs/definitions/working-discipline.md:69-72` names a check aimed at nothing as a gate that cannot fail. §5's four rows read the `$clo0` ctor field types that `datas->n` produced against the source `Term`s `site-fields->term` wrote, and five mutants redden them, every row with a falsifier of its own. |
| 4 | Which suite phase number does the new gate take? | **DEFERRED to the standing row** in `records/author-calls.md` (*Which suite phase number a new gate takes*) | No new author call is opened. Four documents disagree about 21 through 23 and 8 through 12 stay owed to unported old-tree phases. The gate takes the `crypto.sh` / `tal-check.sh` / `apply-word.sh` route: a `not-a-phase:` header with a reason, which keeps `tools/test/registration.sh` G2 and G4 green. ⚑ **The price, stated, re-measured at HEAD by the SPEC audit 2026-09-04:** `tools/test/registration.sh` reports **7 of 20** scripts outside the dispatch table, so this gate becomes the **eighth** `PEND`. Of those seven, only three wait on the contested *number* (`crypto.sh:6`, `tal-check.sh:11`, `apply-word.sh:5`); the other four declare out for structural reasons. So this gate is the **fourth** script waiting on one number at HEAD. `records/author-calls.md`'s display paragraph reads C1C2's as the fourth, and C1C2's script does not exist yet: whichever of the two lands first takes fourth and the other takes fifth. |
| 5 | Is the non-regression target vacuous? | **RESOLVED: no, and it certifies nothing E186 adds** | Both halves are true and both belong here. It holds up under `working-discipline.md`'s test: it asserts a partition (`1,482 of 1,484`, two `ret` rejects, none in the `con:` class) that E187 or E188 could genuinely break. It is also met identically under the opposite ruling, so what it grades is E185's repair. ⚑ **Its instrument is absent from the tree.** EN-08's whole-blob probe carries a name-prefixed copy of `check.chiral`, because E154's eleven colliding top-level names forbid importing it beside the compiler; it was built and reverted twice. Committing it is the whole-blob measurement E184 owns. §5 therefore records the target and does not gate on it. |
| 6 | The stale citations the pre-run found | **RESOLVED for E187's row, DEFERRED as recorded for E185's** | The EXAMPLE audit repaired three spans in E187's catalog and arc rows on the author's direction, verified at HEAD. E185's own catalog and arc rows still point `apply-ty` and its call site at pre-E185 line numbers, fifteen and thirty-one lines low of where `lib/lowering/upper/closconv.chiral:1096-1098` and `lib/lowering/upper/closconv-driver.chiral:206` sit at HEAD. `ledger-lint` check R does not catch that class. Left alone deliberately, and this SPEC does not propagate it. |

**The measurement behind decision 2.** The EXAMPLE audit's condition was whether
`ctor-honest?` can be built inside E186's boundary without reaching into E187's
channel through `datas->n` (`lib/lowering/compile-front.chiral:254-261`,
signature `(-> (List DataDecl) (List NData))`, no `sp` parameter, called from
`bridge-sig` at `:348`). **It can, and the `sp` channel is on none of its
inputs.** Both arguments come from `closconv-sig`'s own return value:

| argument | where it comes from |
|---|---|
| `srcs : (List Term)` | `(sig-datas sig)` off the `CCOut`, the `$clo<i>` `DataDecl`, each `(field q fn fty)`'s `fty` |
| `ftys : (List NTalTy)` | `(datas->n (sig-datas sig))`, the matching `(ndctor cn ftys)` |

Measured 2026-09-04 by a scratch probe built outside `lib/` and `prog/` and
deleted, compiled by `bin/chirality-bin` and run on a three-site fixture. It
imports `lowering/compile-front`, calls
`(closconv-sig (specialize-singletons sig))` itself, and reads both sides off the
`ccout`. Output:

```
  $clo0/$k0_0  honest=ok    src: (none)                      low: (none)
  $clo0/$k0_1  honest=ok    src: t-pi                        low: nt-word
  $clo0/$k0_2  honest=ok    src: t-primty:I64  t-tcon:List    low: nt-i64  (nt-data List [nt-str])
```

Concrete where a concrete source type exists, the word at exactly the one source
shape that has no ground spelling. `peel-def` and `peel-globals` consult `sp` for
globals, and nothing on this path calls either. **E187's channel is required only
by the answer this element rejects**, which is the asymmetry the example's §4
table states, so the standing disposition holds without being forced.

⚑ **That reading is the three-site fixture, taken before FLAG B bought the
fourth site** (noted 2026-09-04 by this revision). The fourth site captures
`Bytes`, `Str` and `I64`, three `t-primty` shapes on arms `term->ntalty` already
carries (`lib/lowering/compile-front.chiral:63-65`), reachable in a plain fixture
through `str->bytes` (`lib/prelude/prelude.chiral:88`) and `blen` (`:93`). It
adds one `DataDecl` ctor to `datas->n`'s input and no demand on `sp`, so
decision 2's measurement holds unchanged at four sites.

## 4. Change plan (ordered, commit-sized)

### Step 1: the ruling, written where the fork was left open
- **Target:** `docs/decisions/decision-erased-word-level.md`, the section
  *The `$kI_J` capture constructor's field types* (`:97-111`).
- **Change:** replace the closing sentence, which says the question stays
  unsettled and that a row in `records/author-calls.md` holds it, with the
  ruling: **the capture constructor's field types stay at the capture's own
  source type**, on three converging grounds. The prior art keeps constructor
  fields concrete in both published shapes (`.planning/RESEARCH-EN15-prior-art.md`
  §7, tracked since 2026-09-01 per `docs/decisions/decision-ai-tier.md`). The
  constructor is applied at one site, so no merge pressure exists to erase it,
  while `shape-eq` puts the dispatcher's argument position under the whole
  family at once. And the tree already spells it that way. State the asymmetry
  in cost: `Field` carries a `Term`, `Core` gains no word spelling by this same
  decision, so the erased-field answer is unwritable in the pass's own output
  without a second stated channel. Name E187 as that channel's owner.
  ⚑ **The closing sentence points at `records/author-calls.md`, and the pointer
  survives redirected** (FLAG A, disposed 2026-09-04). The replacement states
  which document is live: the ruling is here, the author's row stays open until
  the author closes it, and no work in the tree waits on it. Without the redirect
  the two files point at each other with neither one carrying the answer, which
  is the shape the SPEC audit found.
- **Size:** S.

### Step 2: the record, appended and not rewound
- **Target:** `records/enforcement-arc.md`, EN-17 plus one new row EN-21.
- **Change:** append a **RULED 2026-09-04** note to EN-17 pointing at the
  decision doc. ⚑ **The word is RULED, per FLAG A's disposition.** EN-15 reads
  ANSWERED because the author closed its call; EN-17's call stays open in
  `records/author-calls.md`, so this note records where the ruling landed and
  leaves EN-17 at `state: OPEN`, in the shape EN-17's own element field already
  uses, "the author call stands and the element carries the pipeline after it".
  Add **EN-21**, the measurement this SPEC's decision 2 rests on: `ctor-honest?`
  computed from `closconv-sig`'s output alone, the fixture reading, and the five
  mutant verdicts §5 pins, each carried across with the measured-or-derived mark
  §5 gives it. `records/` gets appendices only, so EN-17's original text stands.
- **Size:** M.

### Step 3: the fixture
- **Target:** `tools/test/samples/e186_capture_fields.prog` (new).
- **Change:** one defunctionalization family with four sites, so that both
  halves of the rule have a subject, no row is vacuous, and R4 holds a subject
  no golden pins: a captureless global; a site capturing one arrow, whose source
  `Term` is `t-pi` and whose honest lowering is `nt-word`; a site capturing an
  `I64` and a `(List Str)`, whose honest lowering is `nt-i64` and
  `(nt-data "List" ((nt-str)))`; and a site capturing a `Bytes`, a `Str` and an
  `I64`, whose honest lowering is `nt-bytes`, `nt-str` and `nt-i64`. Every site's
  lambda keeps one family key, so all four ctors land in `$clo0`. It must also
  **run correctly**, so a miscompile shows as a non-zero exit and not only as a
  type reading. Header states why it lives under `samples/` and not `prog/`.
  ⚑ **The fourth site is FLAG B's disposition and it is R4's own subject**
  (2026-09-04). R2 holds `nt-i64` and `(nt-data "List" ((nt-str)))` as constants
  and R3 holds `nt-word` against `t-pi`; `nt-bytes` appears in neither, so R4's
  clause on that field follows from neither golden and M5 reddens R4 alone.
  ⚑ **Three captures rather than one, for the identifier.** Step 4 names ctors by
  field arity, so the fourth site takes arity 3 and the four arities stay
  distinct at 0, 1, 2 and 3. A second one-field ctor would leave R3's subject
  ambiguous, and a tie-break on the field's own lowering or source `Term` would
  read the property R3 asserts. `Str` and `I64` ride along for the arity; `Bytes`
  is the field that carries R4.
- **Size:** S.

### Step 4: the probe
- **Target:** `prog/e186-capture-fields.prog` (new).
- **Change:** read the fixture's blob on fd 0; `load-source-batched`, then
  `specialize-singletons`, then `closconv-sig`; take `(sig-datas sig)` and
  `(datas->n (sig-datas sig))` off the same `CCOut`; keep the `$clo<i>` datas by
  matching `clo-name` over a bounded index range. Carry the example §5(c)
  predicates verbatim in shape: `word?`, `no-ground-spelling?` with its
  `t-var` / `t-pi` arms **and the `t-refine` recursion the example's knob note
  names**, and `ctor-honest?`. Identify the three graded ctors by **field arity
  within `$clo0`**, which Step 3's fixture keeps distinct at 0, 1, 2 and 3. The
  index is unstable, because `$k0_<j>` numbering follows `build-sites`' site
  order. Print one four-token line
  `==E186== <R1> <R2> <R3> <R4>` then the measured detail behind it.
  ⚑ **It asserts nothing and always exits 0.** Every comparison lives in bash
  against a string constant in the driver, which is the `pretty.sh` /
  `tal-check.sh` / `apply-word.sh` rule: a gate that re-derives its own verdict
  stays green under any mutant that changes what the verdict says.
  ⚑ **It imports nothing under `lowering/tal/`**, for E154's eleven collisions,
  which is also why no row here reads `ck-prog`.
- **Size:** M.

### Step 5: the driver
- **Target:** `tools/test/capture-fields.sh` (new).
- **Change:** the `apply-word.sh` harness, four rows and five mutants, laid out
  in §5. Header carries a `not-a-phase:` declaration with the reason from
  decision 4, so `registration.sh` G2 and G4 stay green. Every mutant is a
  **substitution** whose occurrence count is asserted at 1 and whose mutated
  file is `cmp -s`'d against the base before it is built (GA-18), and none of
  them removes an arm or changes an arity (GA-19). The scratch `lib/` is a real
  directory from `cp -a`, checked not to be a symlink. Every mutant pins the
  **whole four-token line** (GA-21, GA-22). Zero Python; wall clock printed and
  setting no bar.
- **Size:** M.

### Step 6: the rows
- **Target:** `docs/elements/catalog.md`, `docs/elements/ledger.md`,
  `docs/examples/INDEX.md`, `docs/arcs/enforcement-arc.md` (E186's two mirrored
  rows), `records/author-calls.md`.
- **Change:** flip E186 to built with its evidence commits and the gate's
  verdict line; INDEX to `implemented`. In `records/author-calls.md`, append to
  the **existing** *Which suite phase number a new gate takes* row's note that
  E186's gate is the eighth `PEND` and its place in the waiting-on-a-number
  count as decision 4 states it, in the shape the display-calculus arc's
  paragraph already uses. **Do not open a new row.**
  All rows land in the same change, per the deferral rule.
  ⚑ **A second row in that file is the one E186 answers, and it was missing
  from this list** (added by the SPEC audit 2026-09-04). `records/author-calls.md`
  carries a live blocking row *The `$kI_J` capture constructor's field types*,
  whose closing clause reads that the call "stays open on its own question:
  whether the capture constructor's fields should erase too", and
  `docs/decisions/decision-erased-word-level.md`'s closing sentence — the one
  Step 1 replaces — points at that row as the holder. Step 1 without this leaves
  the decision doc ruled and the author's own file open, pointing at each other.
  ⚑ **FLAG A, disposed 2026-09-04: the row stays open and this run appends a
  pointer to it.** Recording an outcome is one act and making the author's call
  is another, and an implementation run owns only the first. The precedent sits
  in the same file at `b4a2688`, where a run **narrowed** this very row instead
  of closing it and marked the narrowing "⚑ **Narrowed and given an element
  2026-09-04**". Append a clause in that shape, **⚑ Ruled 2026-09-04 by E186**,
  carrying three things: the ruling is `concrete`; it is written in
  `docs/decisions/decision-erased-word-level.md`; and no work in the tree waits
  on this row any longer, so closing it is the author's edit whenever the author
  wants it. Do not write ANSWERED, do not move the row to *Closed since the
  hoist*, and do not open a new row. `records/` is appended, never rewound.
  ⚑ **Step 1's redirect and this pointer are one statement read from two ends.**
  The decision doc is live and says so; the row is the author's bookkeeping and
  says where the answer is. Neither leaves the other holding an open fork.
- **Size:** M.

⚑ **Nothing in this plan touches `lib/` or `prog/compiler.prog`.** No
`build-new → test → promote`, no byte-compare, no fixpoint: there is no compiler
source in the change. Pathspec every commit.

## 5. Conformance gate

- **Golden behavior.** For the fixture's one family, the `$clo0` constructor
  field types that reach `datas->n` are **concrete wherever the capture's source
  type has a ground spelling, and the erased word only where it has none**, and
  that partition is asserted from both sides at once.

- **The four rows.** All four are judged by `prog/e186-capture-fields.prog` on
  `tools/test/samples/e186_capture_fields.prog`. Every one reads what a compile
  produced.

  | row | asserts |
  |---|---|
  | **R1** | `$clo0` reaches `datas->n`'s output with four ctors, of field arities 0, 1, 2 and 3 |
  | **R2** | the two-field ctor's fields are `nt-i64` then `(nt-data "List" ((nt-str)))`, and neither is `nt-word`. **The ruling** |
  | **R3** | the one-field ctor's field is `nt-word` and its source `Term` is `t-pi`. The word is still reached where the source has no ground spelling |
  | **R4** | `ctor-honest?` holds over every `$clo` ctor: no field lowered to the word whose source `Term` has a ground spelling. **The row the fourth site makes falsifiable** |

  R2 and R3 are the two directions of the same partition, and both are needed:
  R2 alone permits a tree that never reaches the word, R3 alone permits a tree
  that reaches it everywhere. R4 is the only row that reaches `$k0_3`, whose
  three fields no golden holds as a constant, and that is what gives it a
  falsifier of its own.

- **Baseline → expected.** Base verdict `ok ok ok ok`. The three-site reading is
  **measured** 2026-09-04 on the scratch probe at HEAD. The fourth site's
  contribution is **derived**: its three fields are `t-primty` shapes on arms
  `term->ntalty` already carries, so each lowers to a ground `NTalTy` and
  `ctor-honest?` holds on all three.

- **The five mutants.** ⚑ **Measured and derived are separated, and the fourth
  site moved the line** (header corrected by the SPEC audit 2026-09-04, extended
  by this revision).

  What is **measured** for M1 to M4, on the **three-site** fixture Step 3
  originally specced: every needle was counted at **exactly 1** occurrence in the
  file it mutates and at **exactly 1** across `lib/` at HEAD, every mutated tree
  built its probe under `bin/chirality-bin`, every probe ran, and each printed
  the `src`/`low` detail the notes below quote. None scores `nobuild`.

  What is **measured** for M5, added by this revision: its needle is counted at
  **exactly 1** in `lib/lowering/compile-front.chiral` and at **exactly 1** across
  `lib/` at HEAD. Its build and its run are **not measured**, because the fourth
  fixture site does not exist yet. Its `nobuild` risk is M2's risk exactly: the
  same arm chain of the same function, `(some (nt-word))` written over
  `(some (nt-bytes))` where M2 writes it over `(some (nt-i64))`, type-preserving
  in the same way, and M2 was measured built.
  ⚑ **The analogy is checked rather than asserted** (SPEC audit 2026-09-04).
  `nt-i64`, `nt-bytes` and `nt-word` are three nullary `NTalTy` constructors on
  two adjacent lines (`lib/lowering/lowspec.chiral:31-32`), so both substitutions
  are the same nullary-for-nullary swap and neither can move the typecheck. The
  one consumer downstream is `ntalty->talty`
  (`lib/lowering/compile-back.chiral:27-28`), a total one-to-one map, and
  `tal-ty=?`'s first arm makes `tt-word` match everything
  (`lib/lowering/tal/check.chiral:70`), so a widened signature type only makes the
  tal check more accepting. **The one arm where `tt-bytes` and `tt-word` genuinely
  diverge is unreachable**, which is the step the analogy alone leaves out:
  `erase-instr`'s `i-const` case erases `tt-bytes` to `n-lit` and `tt-word` to
  `n-const` (`lib/lowering/tal/erase.chiral:184-188`), while `tt-i64` erases to
  `n-const` beside `tt-word` and M2 therefore moves nothing there. No `i-const`
  in the tree carries `tt-bytes`: every emitter in `lower.chiral` hard-codes
  `tt-i64`, `tt-str` or `tt-word` (`:240`, `:244`, `:257`, `:339`, `:405`), which
  is what `erase.chiral:182-183`'s own comment already states. So M5 reaches no
  codegen `tt-bytes` and its build risk is bounded by M2's, over a far smaller
  set of values.
  ⚑ **An unbuilt M5 fails loudly.** `run_mutant` scores a mutant that does not
  assemble, build or run as `bad` with `BUILD:fail ... UNBUILT measures nothing`
  (`tools/test/apply-word.sh:230-237`), and `bad` increments the failure counter
  (`:99`). A `nobuild` is never a pass, so if this argument is wrong the gate
  reddens instead of certifying R4 on a mutant that never ran, which is
  [[records/gate-audit]] GA-19's rule. The implementer builds M5 first and
  reports what it did.

  What is **derived**: every pinned four-token line in the table, for two
  reasons. The four rows and `tools/test/capture-fields.sh` do not exist, so no
  row has been observed red. And every pin below is re-derived against the
  **four-site** fixture, which no probe has run. The implementer re-measures
  every pin against the rows as built and corrects this table from the run rather
  than reproducing it.
  ⚑ **`lib/` is the scope of the needle count, and it is the scope that matters.**
  `mutate` copies `lib/` alone and greps the one file it mutates
  (`tools/test/apply-word.sh:208-216`, the `cp -a "$REPO/lib"` and the
  single-file `grep -cF`). M1's, M2's and M5's needle strings also
  appear under `docs/`, in this SPEC and in two worked examples, and the harness
  never sees them.

  | mutant | substitution | pinned line | reddens |
  |---|---|---|---|
  | **M1** | `closconv-driver.chiral`, `site-fields->term`: `(str-cat "cap" (i64->str n)) (core->term fty)` → `… (t-var 0)`. Every kept field is spelled as an erased variable, which is the opposite ruling as closely as `Core` can express it | `ok bad bad ok` | **R2**, **R3** |
  | **M2** | `compile-front.chiral`, `term->ntalty`: `(str-eq n "I64") (true (some (nt-i64)))` → `… (true (some (nt-word)))`. A ground source spelling lowers to the word | `ok bad ok bad` | **R2**, **R4** |
  | **M3** | `compile-front.chiral`, `term->ntalty`: `((t-pi _ _ _ _) (some (nt-word)))` → `((t-pi _ _ _ _) (some (nt-i64)))`. The word is no longer reached where the source has no ground spelling | `ok ok bad ok` | **R3** |
  | **M4** | `compile-front.chiral`, `term->ntalty`: the whole `t-tcon` arm → `((t-tcon dn args) (none))`. `field-tys->n` fails, `datas->n` drops `$clo0`, the subject never arrives | `bad absent absent absent` | **R1** |
  | **M5** | `compile-front.chiral`, `term->ntalty`: `(str-eq n "Bytes") (true (some (nt-bytes)))` → `… (true (some (nt-word)))`. The fourth site's `Bytes` capture lowers to the word, and no golden holds that field | `ok ok ok bad` | **R4**, alone |

  ⚑ **Every pin re-derived against the fourth site, and four of the five are
  unchanged.** M1 rewrites every kept field's source `Term`, `$k0_3`'s three with
  the rest, so `ctor-honest?` still reads the word against `t-var` and holds:
  `ok bad bad ok` stands. M2 and M3 hit arms the `Bytes` field never reaches, and
  M2's `I64` arm reaches `$k0_3`'s third field as well as `$k0_2`'s first, which
  adds a second dishonest field to a row already pinned `bad`: `ok bad ok bad` and
  `ok ok bad ok` stand. **M4 keeps its shape.** `ctors->n`
  (`lib/lowering/compile-front.chiral:246-253`) returns `(none)` if any one ctor's
  `field-tys->n` fails, and `datas->n` drops the whole `DataDecl` on that
  `(none)`, so `$k0_2`'s `(List Str)` field still takes all four ctors down
  together and the subject is absent whole: `bad absent absent absent` stands at
  four sites.

  ⚑ **M1 is the reason R2 exists, and it is a measured limit on `ctor-honest?`.**
  Under M1 the probe reads `src: t-var:0 t-var:0` against `low: nt-word nt-word`
  and `ctor-honest?` returns **true**: the predicate compares a field's lowering
  against the field's own declared `Term`, so a driver that replaces the source
  type with a variable is consistent with itself and invisible to R4. R2 catches
  it, against the two lowered types this driver holds as constants. Stating this
  is the point: R4 alone does not separate `concrete` from `word`, at three sites
  or at four.

  ⚑ **M1's pin was `ok bad ok ok` and it is wrong; the audit corrected it to
  `ok bad bad ok`** (2026-09-04, from the SPEC's own quoted detail). R3 asserts
  two things about the one-field ctor, that its lowering is `nt-word` **and that
  its source `Term` is `t-pi`**. M1 rewrites every kept field's source `Term` to
  `(t-var 0)`, the arrow capture with the rest, so R3's second conjunct is false
  under M1 and R3 reddens beside R2. A mutant reddening a row outside its own pin
  is [[records/gate-audit]] GA-22's exact shape, which is why the whole line is
  pinned. R2 stays M1's headline row; the attribution column now names both.

  ⚑ **FLAG B disposed 2026-09-04: the fourth site is spent, and R4 has
  independent falsifying power.** The SPEC audit's proof is correct and it is
  correct **about the three-site fixture**. Over those three ctors: `$k0_0` has
  no fields, so `ctor-honest?` holds on it vacuously; `$k0_2` is pinned whole by
  R2 at `nt-i64` and `(nt-data "List" ((nt-str)))`, neither of which is the word,
  so R4's clause holds on both its fields whenever R2 holds; `$k0_1` is pinned
  whole by R3 at `nt-word` with source `t-pi`, which has no ground spelling, so
  R4's clause holds on it whenever R3 holds. Every field of every `$clo0` ctor
  was golden-pinned by R2 or R3, so **R2 ∧ R3 ⟹ R4** and no mutant in the
  four-mutant table reddened R4 alone. **`$k0_3` is pinned by neither golden.**
  R2 names `nt-i64` and `(nt-data "List" ((nt-str)))` and R3 names `nt-word`
  against `t-pi`, and both goldens are pinned to a **named** ctor, R2 to the
  two-field one and R3 to the one-field one. **No golden pins any field of
  `$k0_3`.** The types themselves recur, `nt-str` inside R2's own constant and
  `nt-i64` as its first, and that is the point: a golden on `$k0_2` says nothing
  about `$k0_3` carrying the same type, so R4's clause on the fourth site's three
  fields is not entailed by R2 ∧ R3 and the implication fails there. M5 is the witness:
  `Bytes` lowers to the word while its source `Term` is `(t-primty "Bytes")`,
  which `no-ground-spelling?` does not admit, so `ctor-honest?` is
  false on `$k0_3` while `$clo0` still carries four ctors (R1 green), `$k0_2`'s
  two fields are untouched (R2 green) and `$k0_1`'s field and source are
  untouched (R3 green). The pin is `ok ok ok bad`, R4 is the sole red, and the
  row the EXAMPLE audit demanded ships live rather than inert. ⚑ **Growth is
  still the second thing R4 buys**, unchanged: it is the only row quantified over
  every `$clo` ctor rather than pinned to a named one, so a later fixture site or
  a third erasing arm in `term->ntalty` is caught without a new golden. What
  changed is that the row no longer rests on that alone, which is what
  [[records/gate-audit]] GA-19 and `docs/definitions/working-discipline.md`
  require of it.

  ⚑ **No row reads `ck-prog`.** EN-20 measured a live miscompile that `ck-prog`
  accepts in silence whenever the family codomain is ground, so nothing here
  leans on it catching anything.

- **Green line.** No suite phase is claimed, by decision 4:
  `tools/test/capture-fields.sh` declares itself out with a reason and runs by
  hand, as `apply-word.sh` and `tal-check.sh` do. What `tools/test/run-tests.sh`
  witnesses of E186 is **one thing**: Phase 7's root census moves **88 → 89**,
  because `prog/e186-capture-fields.prog` is a new root and must build. The
  suite's pass total is otherwise unchanged, and `ledger-lint` stays at exit 0
  with every check zero.

- **Done when:** `bash tools/test/capture-fields.sh` prints a base line of
  `ok ok ok ok` and `9 ok, 0 FAIL` with all five mutants matching their pinned
  lines (four rows plus five mutant lines, the `apply-word.sh` accounting), Phase
  7 reports 89 roots built and 0 failed,
  `docs/decisions/decision-erased-word-level.md` carries the ruling in place of
  the open call, and `records/author-calls.md`'s row carries the pointer and
  stays open, which is what FLAG A disposes deliberately.

- **The non-regression target, carried and not gated.** The example's stated
  target is that the reject set does not move: `1,482 of 1,484` accepting, the
  two rejects `$apply5` and `$apply6` in the `ret` class, none in the `con:`
  class. It is **not vacuous** in `working-discipline.md`'s sense, because that
  partition is a real assertion E187 or E188 could break. It **certifies nothing
  E186 adds**, because the same partition holds under the opposite ruling and it
  grades E185's repair. Its instrument is also absent from the tree: EN-08's probe
  needs a name-prefixed copy of `check.chiral` for E154's collisions and was
  reverted twice. E184 owns committing it. E186 changes no compiler source, so
  the blob and the byte fixpoint are untouched by construction.

## 6. Residue & links

- **Deliberately unbuilt.**
  - **The stated channel for datas.** `sp` reaches globals only, through
    `peel-def` and `peel-globals`. Carrying it to `datas->n` is one job with one
    shape. **Home: [[E187]]**, whose row already names it as its `$clo<i>` half
    in those words.
  - **A quantified row over `site-fields->term`, the ruling's own producer.**
    Found by the SPEC audit 2026-09-04. E186 rules on what `site-fields->term`
    writes, and the gate's only assertion over it is R2, a golden holding two
    lowered types as constants in the driver. `ctor-honest?` cannot supply the
    quantified form, because it reads each field's lowering against that field's
    **own** declared `Term`, both of which `site-fields->term` wrote: it is
    `term->ntalty`'s honesty, and it is self-consistent under any rewriting of
    the source type, which is what M1 measures. The quantified statement — every
    kept capture's declared field `Term` is the capture's own source type — needs
    the pre-`closconv` `Csite` capture list beside the emitted `Field`, and the
    probe reads only the `CCOut`. **Home: [[E187]]**, which rewrites
    `site-fields->term`'s side of the channel and holds both sides at once. That
    is the example's open question 2 recommendation, declined here for
    `ctor-honest?` and taken here for this.
  - **`no-ground-spelling?`'s exact preimage.** Two arms plus the `t-refine`
    recursion are the honest reading of what the compiler's own fields hold
    today. A future shard that adds a third erasing arm to `term->ntalty` has to
    widen both together, and R4 reddening on correct output is how that is
    noticed. **Home: whoever adds that arm**, and the knob is named in the
    probe's header.
  - **The whole-blob `ck-prog` census as a committed instrument.** **Home:
    [[E184]]**, blocked behind E154's eleven colliding top-level names.
  - **The suite phase number.** **Home: the standing row in
    `records/author-calls.md`.** The gate runs by hand until it is settled.
  - **The `∃`-packed alternative.** `NTalTy` has no arrow former and no
    quantifier, so MMH's existential environment has nowhere to live. Considered
    and unreachable, recorded in the example §5.
  - **E185's own stale spans.** Its catalog and arc rows point `apply-ty` and
    the call site at pre-E185 line numbers, fifteen and thirty-one lines low of
    `lib/lowering/upper/closconv.chiral:1096-1098` and
    `lib/lowering/upper/closconv-driver.chiral:206` at HEAD. Check R does not
    catch the class. **Home: a `doc-audit` pass.** Reported here, repaired
    nowhere, and propagated nowhere.

- **Follow-on.** [[E187]] takes the residue and needs no mint: its row already
  carries both halves. **Nothing is minted by this SPEC.** `E189` stays the last
  free number in Lane A's reserved band, shared with the diagnostics arc.

- **Related:** [[E186-capture-field-types]] · [[E185]] · [[E187]] · [[E188]] ·
  [[E100]] · [[E184]] · [[decisions/decision-erased-word-level]] ·
  [[decisions/decision-scope]] · [[decisions/decision-lane-split]] ·
  [[banks/erasure]] · [[banks/verification]] · [[arcs/enforcement-arc]] ·
  [[records/enforcement-arc]] EN-08, EN-15, EN-17, EN-18, EN-19, EN-20 ·
  [[records/gate-audit]] GA-18, GA-19, GA-21, GA-22, GA-24 ·
  [[records/author-calls]] · [[definitions/working-discipline]]
