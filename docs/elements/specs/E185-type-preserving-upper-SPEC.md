---
element: E185
slug: type-preserving-upper
title: **How the `$apply` dispatcher's erased domains are spelled at the lowering type level**
kind: BUILD-PROPER
example: examples/E185-type-preserving-upper.md
status: draft
updated: 2026-09-04
---

# E185 SPEC — **How the `$apply` dispatcher's erased domains are spelled at the lowering type level**

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `closconv-sig` returns the **lowering-level parameter
  types** of the `$apply<i>` dispatchers it synthesizes, the bridge in
  `lib/lowering/compile-front.chiral` uses those in place of the domains peeled
  off the dispatcher's `Core` type, and every `$apply<i>` reaches the emitted
  `TFn` with `tt-word` at each domain. The four dispatchers the EN-08 probe
  reports as rejects stop being rejects, and the emitted bytes of any program do
  not move.

- **Non-goals.**
  - The `$k<i>_<j>` capture constructor's field types. That is the EN-17 call and
    it is now **E186**.
  - `$clo<i>` declarations and the rest of `closconv`'s translation on the names
    it invents. That is **E187**.
  - Wiring `ck-prog` onto the shipping path. That is the arc's requirement 2, and
    E154's eleven colliding top-level names block it independently of this
    element ([[arcs/enforcement-arc]], Resume state).
  - Any change to `lib/lowering/tal/check.chiral`, to `tal-ty=?` or to `ck-prog`.
    The checker is correct and refuses correctly today.
  - Finer defunctionalization families. `lib/lowering/upper/closconv.chiral:359-363`
    rules them out: domains always erase, because a polymorphic `(-> K K ..)`
    parameter has to share a family with the concrete closures passed to it.
  - Any `Core` word spelling and any widening of the kernel's `conv` relation.
    Settled by [[decisions/decision-erased-word-level]].

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none. E185 postdates the map snapshot, so the
  build-state authority is silent and the element is treated as BUILD. The live
  build-state statement is [[status-ledger]]'s preserve-check row, which files
  the floor judgment as *built, unadopted*.

- **Live code this composes with, and does NOT respec.** Every one of these is a
  built shard in [[banks/erasure]] §2, and the refraction is the reason none of
  them is rebuilt here.

  | shard | what is already built | where |
  |---|---|---|
  | **E** | representation-shape erasure: every non-arrow domain is one word, so a family merges | `shape-eq`, `lib/lowering/upper/closconv.chiral:335-356`, with the design note at `:359-363` |
  | **F** | the uniform erased word at the lowering type level, and the relation over it | `tt-word`, `lib/lowering/tal/ssa.chiral:17-21`; `tal-ty=?`, `lib/lowering/tal/check.chiral:68-70`, whose first arm makes it match everything; the neutral twin `nt-word` at `lib/lowering/lowspec.chiral:30-34`, carried across by `ntalty->talty` at `lib/lowering/compile-back.chiral:25-29` |
  | **G** | kept-versus-erased domains at the peel | `ty-kept-doms`, `lib/lowering/compile-front.chiral:159-163`; `ty-erased`, `:166-170`; the arrow arm returning `(nt-word)` at `lib/lowering/compile-front.chiral:71` |
  | **D** | type-kinded captures become no closure field | `field-erased?` / `kept-count`, `lib/lowering/upper/closconv.chiral:716-722` |

  The transport is built as well. `NDef` and its `params` field are
  `lib/lowering/lowspec.chiral:52-57`, and the header there states the rule that
  prices the arity: an erased binder keeps its lambda position and takes a
  placeholder register. `lowspec` already co-loads with `closconv-driver` on every
  compile, because `lib/lowering/compile-front.chiral` imports
  `lowering/upper/specialize-singleton`, `lowering/upper/closconv-driver` and
  `lowering/lowspec` at `:20-22` and the namespace is flat with whole-file import.

- **What is dishonest today, measured.** `apply-ty`
  (`lib/lowering/upper/closconv.chiral:1081-1083`) builds the dispatcher's Pi
  chain from `(peel-pi-doms key)`, and `ensure-fam` (`:653-655`) stores the first
  arrow type walked into the family. So the domains four dispatchers declare are
  one arbitrary member's concrete `Core` types, chosen by traversal order.
  `term->ntalty` then carries them through the peel as `nt-i64` / `nt-str` /
  `nt-data`, and `ck-prog` refuses. The measurement is
  [[records/enforcement-arc]] EN-15: `$apply4` register 2 carries `i64` against
  `(List Str)`, `$apply5` register 3 `i64` against `(List Word)`, `$apply6`
  register 1 `Mach` against `Op`, `$apply7` register 1 `(List Asm)` against
  `Str`.

- **What is already honest, and stays untouched.** `pi-effs` gives the per-arrow
  effect flags and `apply-ty` already threads them. `peel-pi-cod` gives the
  codomain, and `cod-key-eq` (`lib/lowering/upper/closconv.chiral:365-380`) keeps
  a ground codomain concrete on purpose, so two families returning different
  ground types never merge. Only the domains are copied across an erasure the key
  performed.

- **True delta.** A **stated-parameter channel** from the pass that invents a
  name to the bridge that peels it, populated for exactly one name family:
  `closconv-sig` returns `(name, (List NTalTy))` beside the rewritten `Sig`, and
  `peel-def` prefers a stated entry over the peeled domains. Two files change,
  plus one comment in a third. Nothing under `lib/lowering/tal/` moves.

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Candidate (a), an erased type binder per erased domain, or candidate (b), a coarse word type of the lower language | **RESOLVED: (b)** | Derived below, step by step, from settled documents. The author routed the level to [[records/author-calls]] and answered it; the same ruling routes the **spelling** to E185, so the pipeline is where it is decided |
| 2 | Under (a), how `$apply<i>`'s call sites get their type arguments, given that `build-emap` derives erased positions from the type | **RESOLVED, and it dissolves** | (b) adds no `q=0` binder, so `ty-erased` (`lib/lowering/compile-front.chiral:166-170`) still returns `nil` for a dispatcher, `build-emap` records no erased position, and `emap-get` / `tnc-keep` drop nothing. `rw-app-disp` is untouched. §5 R5 makes this a checked row rather than an assumption |
| 3 | Whether the nested-arrow domain erases its own domains, matching `shape-eq`'s recursion, or keeps them for a first cut | **RESOLVED, and it dissolves** | Under (b) there is no `Core` domain to rebuild. Every domain is one word, a nested arrow included: the arrow arm of `term->ntalty` already returns `(nt-word)` at `lib/lowering/compile-front.chiral:71`, commented *"arrow types (kept by `ty-kept-doms`) are pointer-sized"*. So `shape-eq`'s recursion and the stated params agree without a second recursion being written |
| 4 | Whether the gate is a chirality program on E168's test floor rather than another shell script | **RESOLVED, split** | The **judgment** is a chirality program (`prog/e185-apply-word.prog`), which is requirement 5's direction and what §5 specifies. The **driver** stays a short shell script, because `run_phase` (`tools/test/run-tests.sh:125`) takes a script name and every registered phase is one. Replacing the driver is requirement 5's work and not E185's |
| 5 | Which suite phase number the gate takes | **NEEDS-AUTHOR (non-blocking)** | Four documents disagree and this run assigns nothing. `tools/test/run-tests.sh:332` and `docs/decisions/decision-lane-split.md:30` reserve 21 through 23 for Lane B; `tools/test/tal-check.sh:5` claims 22 and leaves 21 to `crypto.sh`; `tools/test/crypto.sh:8` says 21 through 23 are free and is itself unregistered; `docs/definitions/testing-floors.md:69` asserts the `crypto.sh` precedent holds 21. Until the author settles it the gate runs by hand, exactly as `tal-check.sh` does. Carried out of this run and given a row in [[records/author-calls]] |
| 6 | The example's recommended three-way split, which the SPEC stage mints | **RESOLVED, and the merge is resolved with it** | **E186** is EN-17 turned into an element: the `$k<i>_<j>` capture constructor's field types. **E187** is `closconv` stating the lowering-level types of every name it invents. Under (b) E185 and E187 do not duplicate: **E185 builds the channel and populates it for one name**, E187 **extends the channel to the other two names** and states the pass's whole translation. E186 is a ruling E187 encodes once it exists. Ordering unchanged: E185, then E186, then E187 |

### Decision 1, derived

Four steps, each resting on something already settled or already measured.

1. **(b) cannot be written in `Core`, which is the point rather than an
   objection.** A `(c-primty "Word")` or a `(c-tcon "$word" nil)` is a `Core`
   word spelling, and [[decisions/decision-erased-word-level]] refuses one. So
   (b) is not a `Core` type at all: it forces `closconv` to **state** the
   dispatcher's type at the lowering type level, which is the level the ruling
   names.

2. **(a) puts an unchecked claim at a level whose instrument never runs on it.**
   Under (a) the dispatcher's `Core` type becomes `(-> (0 a0 (type 0)) …
   $clo<i> a0 … cod)`, a universally quantified claim its own arms do not
   honour, because an arm applies a concrete function at a variable-typed
   argument. Pottier and Gauthier recover that step with a GADT equation
   (`.planning/RESEARCH-EN15-prior-art.md` §2) and this tree has no machinery for
   one. Nothing catches the gap: `closconv-sig` runs after the typecheck
   (`lib/lowering/compile-front.chiral:342`), which is reason 3 of the ruling
   itself. So (a) writes a stronger claim into the one place no instrument
   reads.

3. **(b) puts the claim where the instrument is.** [[banks/verification]]'s
   one-instrument-per-level rule is why the ruling refuses to let the kernel
   re-check post-closconv output, and it names `ck-prog` as the right instrument
   for lowered code. A statement in `NTalTy` is read by `ntalty->talty`
   (`lib/lowering/compile-back.chiral:25-29`) and lands in the `TFn` that
   `ck-prog` will judge the moment requirement 2 unblocks. Under (a) the honest
   part of the type is still only what `term->ntalty` recovers from it; under (b)
   the pass says it directly.

4. **Cost and failure mode, measured, and they point the same way.**

   | | (a) | (b) |
   |---|---|---|
   | new functions in the pass | four (`dom-ty`, `arrow-ty`, `erase-doms`, `quant-binders`) | two (`word-ptys`, `apply-ptys`) |
   | the dispatcher's lambda chain | `apply-body`'s `(mk-lams (+ 1 d) …)` (`lib/lowering/upper/closconv.chiral:1109-1111`) must become `(+ (+ 1 d) k)`, or `compile-fn` returns `le-skip "body is not a lambda chain"` (`lib/lowering/upper/lower.chiral:412-417`) and the dispatcher is **silently absent** from the emitted program | unchanged |
   | call sites | `build-emap` records `k` new erased positions, so `tnc-keep` drops the first `k` real arguments unless `rw-app-disp` passes type arguments at them. Missing it is a **miscompile**, and `ck-prog` is not wired to catch it | unchanged |
   | emitted bytes | move: `k` erased binders take placeholder registers and `nregs` grows | do not move. `erase-fn` keeps only the parameter **count** (`lib/lowering/tal/erase.chiral:270-276`), and the count is the same |
   | signature changes | none at the pass boundary | two: `closconv-sig`'s return, `peel-def`'s parameters |

   (a) is cheaper only if the two halves the audit priced are omitted, and each
   omission is silent. (b) costs a seam change and has no silent failure mode.

### The residue, either way

- **Under (b), which is what this SPEC builds:** the `Core` type `apply-ty`
  writes still spells the domains from one family member, and it is now read for
  its codomain and its erased vector only. A wrong annotation that nothing reads
  is still a wrong annotation, and it is the drift this tree refuses. Two things
  hold it: Step 4 writes the fact at `apply-ty` itself, so a reader meets it
  where the code is; and **E187** owns retiring the spelling, because retiring it
  means stating the pass's translation for every name it invents.
- **Under (a), which this SPEC does not build:** the residue is larger and has no
  home. `$apply<i>`'s `Core` type becomes a parametric claim its arms do not
  honour, at a level whose only instrument (the kernel) has already run. There is
  no element that would later check it, because [[decisions/decision-erased-word-level]]
  rules the kernel out of re-checking post-closconv output.

## 4. Change plan (ordered, commit-sized)

Steps 2, 3 and 4 change compiler source inside the blob, so the whole of §4 owes
the BUILD RULE in [[definitions/working-discipline]]: `build-new → test →
promote`, the fixpoint verified, the artifact checked non-empty before the `cmp`,
and `(ulimit -s unlimited; …)` on every compiler invocation.

### Step 0 — the Step-0 precondition (verification only, no commit)

Establish that the tree already fixpoints, so a mismatch after Step 2 is
attributable to Step 2 rather than to whatever landed before it.

```
. bin/chirality-resolve.sh

chirality_blob_file "lib:prog" prog/compiler.prog > /tmp/blob0.chiral

(ulimit -s unlimited; bin/chirality-bin < /tmp/blob0.chiral > /tmp/P1) && chmod +x /tmp/P1

[ -s /tmp/P1 ] && (ulimit -s unlimited; /tmp/P1 < /tmp/blob0.chiral > /tmp/P2) && cmp /tmp/P1 /tmp/P2
```

Record the blob and binary byte figures. Without the non-empty guard two empty
files compare equal and the precondition passes on a build that produced nothing.

### Step 1 — the gate, written first and RED

- **Target:** `prog/samples/e185_apply_word.prog` (fixture),
  `prog/e185-apply-word.prog` (probe), `tools/test/apply-word.sh` (driver).
- **Change:** the fixture holds a defunctionalization family whose members
  disagree on the domain: two closures of the same word arity, one taking a
  ground `I64` and one taking a `(List Str)`, both reaching one higher-order
  parameter so `arrow-key-eq` merges them, plus a ground codomain so
  `cod-key-eq` has something to keep. The probe imports `lowering/compile-front`
  and **nothing from `lowering/tal/`**, so E154's eleven collisions are not
  touched: it reads the blob on stdin, calls `compile-front`, finds the
  `$apply0` `NDef` and judges the six rows of §5. The driver builds the fixture
  blob with `chirality_blob_file`, builds and runs the probe, and reports.
- **Expected now:** rows R2 and R6 red, because `$apply0`'s params carry one
  member's concrete spelling today.
- **Size:** M.

### Step 2 — the stated-parameter channel

- **Target:** `lib/lowering/upper/closconv-driver.chiral` — a new
  `(import "lowering/lowspec")`, new `word-ptys` and `apply-ptys`, and the
  threading through `synth-apply`, `synth-applies` and `closconv-sig`.
- **Change:**

```chirality
(import "lowering/lowspec")     ; NTalTy / nt-word / nt-data: the stated-type transport

; The dispatcher's lowering-level parameter types, COMPUTED from the family and
; never copied off a member.  shape-eq (closconv.chiral:335-356) makes every
; non-arrow domain one word, and a nested-arrow domain is pointer-sized
; (compile-front.chiral:71), so every domain is nt-word.  The leading $clo
; argument keeps its data name, because the arm case is a case on it.
(declare word-ptys (-> I64 (List NTalTy)))
(def word-ptys
  (lam (n) (case (<=i n 0) (true nil) (false (cons (nt-word) (word-ptys (- n 1)))))))

(declare apply-ptys (-> I64 (List Core) (List NTalTy)))
(def apply-ptys
  (lam (i doms) (cons (nt-data (clo-name i) nil) (word-ptys (cc-llen doms)))))

; the synth accumulator carries the stated types beside the globals it builds
(data SynA () (syna (globs (List (Pair Str (Pair Term Term))))
                    (stated (List (Pair Str (List NTalTy))))))

; closconv-sig's output: the rewritten Sig, plus what the pass STATED about the
; names it invented.  Sig alone cannot carry it -- a Sig global holds a Term.
(data CCOut () (ccout (sig Sig) (stated (List (Pair Str (List NTalTy))))))
```

  `synth-apply` keeps computing `aty` and `abody` exactly as it does now and adds
  `(pair (apply-name i) (apply-ptys i doms))` to the `stated` list.
  `synth-applies` folds the `SynA`. `closconv-sig` returns a `CCOut`.
- **Size:** M. Compiler source: BUILD RULE.

### Step 3 — the bridge prefers the stated params

- **Target:** `lib/lowering/compile-front.chiral` — a new `sp-get`, and
  `peel-def` (`:193-201`), `peel-globals` (`:204-210`) and `bridge-sig`
  (`:314-322`) rethreaded.
- **Change:** `peel-def` takes the stated list. On a hit it uses the stated
  `(List NTalTy)` as `params`; on a miss it peels as it does today. The codomain
  still comes from `ty-cod` plus `term->ntalty`, because `cod-key-eq` already
  keeps it honest, and `erased` still comes from `ty-erased`, which returns `nil`
  for a dispatcher. `bridge-sig` becomes `(-> CCOut Str FR)` and pulls the `Sig`
  and the stated list out of the `ccout`. The call inside `compile-front`
  (`lib/lowering/compile-front.chiral:335-342`) is textually unchanged.
- **Size:** M. Compiler source: BUILD RULE.

### Step 4 — say it where `apply-ty` is read

- **Target:** `lib/lowering/upper/closconv.chiral`, the comment above `apply-ty`
  at `:1079-1083`.
- **Change:** record that the dispatcher's **parameter** types are stated by
  `closconv-driver` and that this `Core` chain is read for its codomain and its
  erased vector only. Without it the next reader takes `apply-ty` for the
  authority on the dispatcher's type, which is the drift the residue names.
- **Size:** S. A comment-only edit to compiler source still owes the rebuild; it
  rides Step 2 and Step 3's.

### Step 5 — build-new, test, promote

Run the BUILD RULE end to end over the changed blob, verify `C1 == C2` at
non-empty, promote generation two, and run `tools/test/run-tests.sh`. Record the
blob and binary byte figures beside Step 0's.

### Step 6 — the record

- **Target:** `records/enforcement-arc.md` (a new EN-18 row carrying the re-run
  EN-08 probe figures), `docs/arcs/enforcement-arc.md` (requirement 2 and the
  Resume state), `docs/elements/ledger.md` and `docs/examples/INDEX.md` (E185 to
  `built`), [[status-ledger]]'s preserve-check row.
- **Change:** the EN-08 probe is rebuilt against the promoted binary, its figures
  recorded, and the probe reverted, exactly as EN-08 and EN-14 did. A probe that
  is reverted is the honest instrument here, because a committed one would have
  to import `lowering/tal/check` beside the compiler and that is E154's fifth
  instance.
- **Size:** M.

## 5. Conformance gate

- **Golden behavior.** For a source holding one defunctionalization family whose
  members disagree on the domain, the `NDef` the front produces for `$apply0`
  carries `nt-word` at every domain, `(nt-data "$clo0" nil)` at the leading
  argument, the family's ground codomain at `ret`, and an empty `erased` vector.
  The emitted bytes for that source do not move.

- **Rows, judged by `prog/e185-apply-word.prog` and reported by
  `tools/test/apply-word.sh`.**

  | row | assertion | what it guards |
  |---|---|---|
  | R1 | `$apply0` is present in `compile-front`'s `NDef` list | the dispatcher still lowers; the `le-skip "body is not a lambda chain"` failure mode (`lib/lowering/upper/lower.chiral:412-417`) is silent otherwise |
  | R2 | every domain param of `$apply0` is `nt-word` | the deliverable |
  | R3 | the leading param of `$apply0` is `(nt-data "$clo0" nil)` | the one param that must stay concrete. `ck-scrut-dn` would recover the data name from the first arm anyway, so no other instrument catches this |
  | R4 | `$apply0`'s `ret` is the family's ground codomain and is not `nt-word` | `cod-key-eq` (`lib/lowering/upper/closconv.chiral:365-380`): two families returning different ground types must not merge |
  | R5 | `$apply0`'s `erased` vector is empty | decision 2. No `q=0` binder is introduced, so `emap-get` and `tnc-keep` drop nothing at a call site |
  | R6 | the fixture's emitted ELF is byte-identical under the pre-change binary and the promoted one | the ⚑ that has stood since EN-15: nothing here is a miscompile. `erase-fn` keeps only the parameter count (`lib/lowering/tal/erase.chiral:270-276`), so a parameter retyping must move no byte |

- **Mutants, and all three are RUN, then reverted, with the measured failure
  recorded.** Required by [[definitions/testing-floors]]'s run-the-mutant rule
  and by requirement 6 of [[arcs/enforcement-arc]].

  | mutant | the edit | expected |
  |---|---|---|
  | M1 | delete the stated-params arm in `peel-def`, so the domains peel as they do today | R2 red, reporting `nt-i64` where `nt-word` is expected |
  | M2 | `word-ptys` emits one fewer word | R1 red. The stated list is short, so `compile-fn`'s `total` shrinks, `strip-lams` fails and the dispatcher leaves the program. This is the arity rule `lib/lowering/lowspec.chiral:52-57` states |
  | M3 | `apply-ptys` returns `(nt-word)` for the leading `$clo` argument too | R3 red |

- **Green line.** No phase number is assigned: decision 5 is NEEDS-AUTHOR and
  four documents disagree. The gate runs by hand, as `tools/test/tal-check.sh`
  does, and its six rows are reported on their own line. The suite's recorded
  figure is `339 passed, 0 failed, 87 roots` ([[definitions/testing-floors]],
  measured 2026-09-04); the probe is a new root, so the root count is expected at
  **88** and the implementation run re-measures both. `ledger-lint` counts must
  not rise.

- **Conformance target, whole-blob.** The EN-08 probe reads **1,477 of 1,481**
  today and the four `$apply` dispatchers are the whole of the remainder
  ([[records/enforcement-arc]] EN-14, EN-15). After this change **every
  dispatcher accepts and the reject count is zero**. ⚑ The **denominator moves**,
  because the change is compiler source inside the blob and the promoted binary
  emits a different number of `TFn`s. So the target is *zero rejects*, and
  `N of N` is re-measured rather than predicted. Stating it as `1,481 of 1,481`
  would be a figure no compile produces.

- **Done when:** the six rows pass under the promoted binary, all three mutants
  have been run and reverted with their failures recorded, the BUILD RULE reaches
  `C1 == C2` at non-empty, the suite is green at its re-measured count, and the
  re-run EN-08 probe reports zero `$apply` rejects.

## 6. Residue & links

- **Deliberately unbuilt, each with its home.**
  - `apply-ty`'s `Core` domains still spell one member's types, now read for the
    codomain and the erased vector only. **Home: E187**, which retires the
    spelling by stating the translation for every name the pass invents. Step 4
    keeps it visible at the code until then.
  - The `$k<i>_<j>` capture constructor's field types. **Home: E186**, and the
    ruling behind it is still the author's ([[records/author-calls]]).
  - `$clo<i>` declarations, and the 1,820 lines of live rewriting in
    `lib/lowering/upper/` that state nothing at the lowering type level.
    **Home: E187.**
  - E154's eleven colliding top-level names, which keep `lowering/tal/check`
    unimportable beside the compiler and keep the whole-blob measurement a
    reverted probe. **Home: [[arcs/enforcement-arc]]** requirement 2, and it is
    independent of this element.
  - The gate's suite phase number. **Home: the author**, decision 5, with a row
    in [[records/author-calls]].
  - Whether the parameter retyping is invisible to register allocation and to
    `emit-core`. Argued from `lib/lowering/tal/erase.chiral:270-276` and **made a
    checked row** as R6 rather than left as an argument.

- **Follow-on, both minted in the same change as this SPEC.**
  - **E186** — the `$k<i>_<j>` capture constructor's field types: concrete, or
    the erased word. EN-17 as an element.
  - **E187** — `closconv` states the lowering-level type of every name it
    invents.

- **What this unblocks.** [[arcs/enforcement-arc]] requirement 2, jointly with
  E186 and with E154's collisions. E185 removes one of the three things standing
  in front of a live `ck-prog` refusal.

- **Related:** [[E185-type-preserving-upper]] · [[decisions/decision-erased-word-level]] ·
  [[banks/erasure]] · [[banks/verification]] · [[records/enforcement-arc]] ·
  [[records/author-calls]] · [[arcs/enforcement-arc]] · [[definitions/working-discipline]] ·
  [[definitions/testing-floors]] · [[status-ledger]] · [[E16]] · [[E18]] · [[E70]] ·
  [[E154]] · [[E168]] · [[E186]] · [[E187]]
