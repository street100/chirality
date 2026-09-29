---
row: enforcement/N12
arc: enforcement
title: the TFn census as a gate: fold `ck-prog` over every emitted TFn and report accept, reject and the four reject classes. Three record rows rest on this number. The instrument that still cannot be re-run is `ck-prog`, which has zero call sites anywhere under `lib/` or `prog/`, so the four reject classes stay un-taken. The `ck-fn` half does re-run: `prog/optimizer-census.prog` under `tools/test/opt-census.sh` reads `census tfns=1548 ok=1517 err=31`, measured 2026-09-08 at `38ecdba`. It reads 1582/1550/32 before that date, over a blob that still carried `check.chiral`; PRB-70's ruling took the module out of the compiler closure and the probe imports it directly now. ⚑ It became buildable when E154's eleven collisions were prefixed away: measured 2026-09-06, **zero** names in `lowering/tal/check` collide with any module under `lib/`, so a probe imports the real checker instead of keeping a copy
kind: tool
origin: connect
req: 2, 3
status: blocked
updated: 2026-09-29
---

# enforcement/N12: the TFn census as a gate

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** `ck-prog` gets a call site, over the program the compiler
  ships, and a gate reads its verdict on every suite run: accept, reject, and
  the reject classes by message.
- **Serves:** requirement 2 of [[arcs/enforcement-arc]], *"The typed-assembly
  floor runs on the shipping path"*, whose remaining half after PRB-70 is the
  census taken from outside the closure (`docs/arcs/enforcement-arc.md:89-100`).
  Also requirement 3, *"The check agrees with the compiler it checks"*
  (`:123`): an all-accept census over the shipped program is that agreement,
  measured.
- **Goal:** [[goals/enforcement]], condition 3 (`docs/goals/enforcement.md:33-34`).

## 2. What the tree holds

Measured 2026-09-29 at `ebe9757`, with the committed `bin/chirality-bin`
under `ulimit -s unlimited`.

- **Bank:** no bank names the typed-assembly checker or the census. The nearest
  are [[banks/verification]], whose shards are judgment cores that must agree,
  and [[banks/erasure]], which covers `lib/lowering/tal/erase.chiral`. Neither
  holds a shard for "a gate reads the floor checker's verdict over compiler
  output". The concept is one checker entry point and one instrument, both
  located below, so no bank is built for it: a bank refracts a concept that
  elsewhere is a monolith, and this row is a call site.

| what exists | where | rung | reached by |
|---|---|---|---|
| `ck-fn`, one TFn under a given `CEnv` | `lib/lowering/tal/check.chiral:289-291` | IMPLEMENTED | `prog/optimizer-census.prog:78` (`re-check`) |
| `prog-fns`, the signature table read off the program's own TFns | `lib/lowering/tal/check.chiral:293-298` | IMPLEMENTED | `ck-prog` alone |
| `ck-fns`, a fold that stops at the first refusing TFn | `lib/lowering/tal/check.chiral:299-305` | IMPLEMENTED | `ck-prog` alone |
| `ck-prog`, `(-> CEnv Prog TckR)`: replaces `cenv0`'s fns field with `prog-fns`, then `ck-fns` | `lib/lowering/tal/check.chiral:306-312` | SEEDED | nothing. `grep -rn ck-prog lib prog` outside `check.chiral` returns comments only (`lib/lowering/upper/lower.chiral:20`, `:115`, `lib/lowering/upper/optimize.chiral:22`, `lib/lowering/upper/closconv-driver.chiral:126`, `prog/e186-capture-fields.prog:28-30`) |
| fail-fast inside one TFn | `lib/lowering/tal/check.chiral:225-230` | IMPLEMENTED | PRB-73, FD-14 |
| the shipped pre-erase program: `lower-defs` folds each TFn (`opt-tfns`, `:246-250`), then `filter-erasable` and `prune-fix` at the `nil` arm | `lib/lowering/compile-back.chiral:252-274`, `:255-256` | ENFORCED | `back-program` (`:332-336`) on every compile |
| the census root: replicates `lower-defs`' per-def loop under the `def-sigs` `CEnv`, runs `ck-fn` folded and un-folded, prints `census`, `class` and `err` lines, asserts nothing | `prog/optimizer-census.prog:153-163`, `:204-225`; the no-judging rule at `:24-28` | IMPLEMENTED | `tools/test/opt-census.sh`; compiled as a Phase 7 root |
| the census gate: four rows R1 to R4 on exact pins, mutants M3 to M6 | `tools/test/opt-census.sh:143-149` pins, `:260-305` mutants, tally `:306` | SEEDED | nobody. `registration.sh` prints it `PEND` |

**Reading 1. The committed gate is red at HEAD and nobody saw.**
`bash tools/test/opt-census.sh` exits 1 in 1.8 s:
`line bad bad ok ok census=1551/1520/31 cls=1`,
`opt-census: 2 passed, 2 failed, 4 mutants unmeasured`. R1 and R2 fail on
exact pins, `defs=1519` and `tfns=1549` against `defs=1521` and `tfns=1551`
today. R3 and R4 hold. The gate is held out of dispatch, so the drift between
2026-09-08 and today reddened nothing.

**Reading 2. The 31 refusals belong to the instrument's `CEnv`.** A scratch
probe (the census root plus four tallies, built from the tracked `lib/` and run
over the compiler's own blob of 851,722 B) reads:

| subject | `CEnv` fns | tfns | ok | err | classes |
|---|---|---|---|---|---|
| every folded TFn, pre-prune | `def-sigs` (what `opt-census` uses) | 1551 | 1520 | 31 | `call: unknown tal function` ×31, first `bput-u8` |
| every folded TFn, pre-prune | `prog-fns` (what `ck-prog` uses) | 1551 | 1549 | 2 | `call: unknown tal function` ×2, `$apply6` → `mach-galo`, `$apply5` → `mach-gbnw` |
| every un-folded TFn, pre-prune | `prog-fns` | 1551 | 1549 | 2 | same two |
| the shipped program, after `filter-erasable` and `prune-fix` | `prog-fns` | 1549 | 1549 | **0** | none |
| `ck-prog` over the shipped program | its own | | | | **`ok`** |

`prune-fix` removes exactly `$apply5` and `$apply6` (the name sets differ in
those two and no other), because their callees are among the ten skipped defs.
So `ck-prog` accepts all 1,549 TFns the compiler ships. The `<name>$0`
refusals `opt-census.sh` R3 pins exist because `def-sigs` never carries an
outlined block's signature, and `ck-prog` never consults `def-sigs`: it reads
every signature off the TFns themselves. The three TFns PRB-43 and PRB-73 name
as hidden behind that refusal, `$apply4`, `emit-code` and `emit-args-res`, are
in the shipped set and accept.

**Reading 3. The census reddens on a compiler defect.** The same probe built
from a scratch `lib/` carrying `opt-census.sh`'s M4 (`fold` annotates its
constant `(tt-str)`) reads, over the shipped program, `tfns=1549 ok=1535
err=14` in two classes, `argument arity or type mismatch` ×10 (first
`x-add-rsp`) and `ret: type does not match declared return` ×4 (first
`pow2-k`), and `ck-prog err argument arity or type mismatch`.

**Reading 4. Every root's program passes too.** The probe run
over all 99 `compile-main` roots `run-tests.sh:175-176` enumerates: 97 read
`err=0` and `ck-prog ok`, **38,333 TFns** in all; the two others are
`front-error` and are Phase 7's own `KNOWN_FAIL`
(`tools/test/run-tests.sh:173`). 23 s wall for 99 blob assemblies and four
tallies each.

**Reading 5. Cost against a self-compile.** Self-compile of the same blob:
0.81 s wall, 385 MB max RSS (the dispatch's 0.78 s and 394 MB reproduce within
noise). Building the census root: 0.45 s, 223 MB. Running it over the compiler
blob: 0.66 s and 215 MB with two tallies, 0.89 s and 341 MB with four.
`opt-census.sh` measured 7 s with four mutants at `38ecdba`
(`docs/arcs/enforcement-arc.md:310`).

**The "four reject classes" no longer exist.** PRB-38
(`records/lenses/problems.md:525`) re-measured on 2026-09-06 that `ret`,
`con`, `case on non-data register` and `argument arity` stopped reproducing
after `ddfbc27`, and PRB-73 (`:1024`) corrected the row's own claim on
2026-09-08. The three record rows resting on this number are PRB-38, PRB-43
(`:598`) and PRB-73, all `owner: enforcement/N12`; PRB-69 (`:968`) names the
row for its evidence census too.

**Siblings.** `enforcement/N11` (`docs/arcs/parts/enforcement-N11.md:200-202`)
owns a trace grammar, `trace base <row>:<ok|bad> …`; `opt-census.sh`'s
`measure` already prints the per-row vector that grammar would carry
(`tools/test/opt-census.sh:224`). `enforcement/N10` owns a native judge floor,
unbuilt and gated on its Q5 (`docs/arcs/parts/enforcement-N10.md:275`).
`enforcement/N23` and `N24` judge values under `tal-eval` and the emitted
instruction; this row judges target types under `ck-prog`, and none of the
four covers that. `enforcement/N8` (E18) names *"the call site `ck-prog` has
never had, PRB-15"* on the shipping path.

## 3. The delta

1. **`ck-prog` has no call site.** The committed census folds `ck-fn` under a
   `CEnv` the compiler never builds for checking, and it counts two TFns the
   compiler never ships.
2. **No gate runs.** `opt-census.sh` is held out and red on count pins.
3. **The pins measure the tree's size.** Exact `defs=` and `tfns=` pins redden
   on any added def (Reading 1). The property requirement 3 names is that the
   checker accepts what the compiler emits, and that is `err=0` with
   `ck-prog ok`, invariant under growth.
4. **The subject is one program.** Reading 4 shows every root's program
   passes today at a price a suite phase can pay.

Nothing in `lib/` is missing: `ck-prog`, `prog-fns`, `filter-erasable` and
`prune-fix` exist and a `prog/` root can call all four.

**Verdict:** a real delta, and it is `opt-census` finished. The fold, the root
and the gate stay; the `CEnv`, the subject set, the pins and the registration
change.

## 4. The shapes

### Shape A: finish `opt-census` in place
- **Form:** `prog/optimizer-census.prog` collects the folded TFns as
  `lower-defs` does, runs `filter-erasable` and `prune-fix`, builds its `CEnv`
  with `prog-fns` as `ck-prog` does, tallies `ck-fn` per TFn and class, runs
  un-folded beside it, and prints one `ck-prog ok|err <msg>` line.
  `tools/test/opt-census.sh` pins invariants: the census is non-empty,
  `err=0` with no class line, `ck-prog ok` agrees with the tally, and
  `unfolded-ok` equals `ok`. The base row runs over every root; mutants run
  over the compiler blob. It registers under the numbering rule.
- **Costs:** two files edited plus one dispatch line; about 25 s per suite run
  (Reading 4 over-counts, with four tallies). R3's `$0` assertion and M5 retire,
  since their subject is the instrument's `CEnv`.
- **Forbids:** a census that measures something the compiler does not ship. It
  keeps the replica of `lower-defs`' loop, so a change to that loop can leave
  the census behind.

### Shape B: Shape A reading a shared compiler function
- **Form:** `lower-defs` splits so its pre-erase program is a function
  `back-program` and the census both call.
- **Costs:** an edit to `lib/lowering/compile-back.chiral`, inside
  `prog/compiler.prog`'s closure (`lib/lowering/compile-all.chiral:14`), so the
  BUILD RULE: rebuild, fixpoint, promote.
- **Forbids:** replica drift, by construction.

### Shape C: a second root and gate beside `opt-census`
- **Form:** a new `ck-prog` root and gate; `opt-census` keeps its `def-sigs`
  census.
- **Costs:** two instruments over one TFn set, one of them red on pins and
  measuring an artifact of its own `CEnv`.
- **Forbids:** nothing A does not.

### Shape D: `ck-prog` on the shipping path
- **Form:** `back-program` calls `ck-prog` and refuses on `tck-err`.
- **Forbids itself:** PRB-70 ruled `lowering/tal/check` outside the compiler
  closure (`records/lenses/problems.md:986`), and `tools/test/tal-check.sh`
  G18 asserts it.

## 5. The call

- **Chosen:** Shape A. It gives `ck-prog` its call site with no edit inside the
  closure, and the replica precedent is the tree's own
  (`prog/optimizer-census.prog:5-7`). Shape B's guard against drift is listed
  as needed and unrostered below. C duplicates A's subject. D is ruled out.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Which `CEnv` the census uses | **RESOLVED → `ck-prog`'s own, `prog-fns` over the shipped program** | the row names `ck-prog`, and `check.chiral:306-312` defines it that way. Reading 2 |
| 2 | Which TFns are the subject | **RESOLVED → the program after `filter-erasable` and `prune-fix`** | the list erasure receives (§2, the `nil` arm); the pre-prune set holds two TFns that never ship |
| 3 | The four reject classes | **RESOLVED → a class histogram by message, whatever classes appear** | PRB-38 measured the four gone; PRB-73 corrected the claim |
| 4 | Fail-fast inside a TFn (PRB-73) | **DEFERRED → PRB-73** | at `err=0` there is no first refusal to hide behind; the fork returns when one does |
| 5 | Where the check runs | **RESOLVED → a gate outside the closure** | PRB-70 (`records/lenses/problems.md:986`) |
| 6 | Phase number | **RESOLVED → the first free at build time** | `tools/test/run-tests.sh:347-351`, ruled 2026-09-06 |
| 7 | The judge | **RESOLVED → bash over the root's printed lines** | the root asserts nothing (`prog/optimizer-census.prog:24-28`); N10's judge floor is unbuilt and not claimed |
| 8 | Pins: the invariant (`err=0`, `ck-prog ok`, counts printed) or the counts whole | **NEEDS-AUTHOR** | exact pins went red unseen (Reading 1). `tools/test/shape-census.sh:3` holds E201 out on the same axis, *"until the author rules on R2, which pins all fourteen readings whole"*, and no row in `records/author-calls.md` carries that call. Recommended: invariants, counts printed |
| 9 | Does this gate discharge `N8`'s *"call site `ck-prog` has never had"* | **NEEDS-AUTHOR** | `N8` and goal condition 3 (`docs/goals/enforcement.md:33-34`) place the call site in the shipping compile; PRB-70 places the checker outside the closure. `records/author-calls.md:116` holds the same fork for `N23`'s value check, and this is its twin for type checking |

Mutants, each pinned on the whole row vector plus the class-name set, with
counts printed and unpinned: M3 `call-lookup-in-prims` (reject > 0), M4
`fold-const-mistyped` (Reading 3; R4 red), M6 `strip-lams-off-by-one` (empty
census), and a new `prune-off` (`prune-fix` returns its input; the two
`$apply` refusals enter the shipped set). A mutant making `ck-fn` accept
everything belongs to Phase 22's REJECT rows (`tools/test/tal-check.sh`) and is
not repeated here.

## 6. The mint packet

- **Elements:** one. The root and the gate constrain each other: the root
  prints what the gate pins, and the mutants grade both.
- **Band:** `E184-E189` is spent (`docs/decisions/decision-lane-split.md:31-35`)
  and bands are advisory since 2026-09-06 (`:40`). The next free number
  tree-wide, which `pack.py --mint` computes.
- **Catalog row:**
  `| E<NN> | **The TFn census as a gate: `ck-prog` over the program the compiler ships, every TFn tallied under its own signature table, accept and reject and the class histogram, on every suite run.** `prog/optimizer-census.prog` collects the folded TFns, runs `filter-erasable` and `prune-fix`, builds the `CEnv` with `prog-fns` as `ck-prog` does, and prints the tally and `ck-prog`'s verdict; `tools/test/opt-census.sh` pins `err=0`, `ck-prog ok`, their agreement and `unfolded-ok = ok` over every root, with four mutants over the compiler blob, and registers. Measured 2026-09-29: 1,549 of 1,549 accept on the compiler, 38,333 TFns over 97 roots, all accept; the 31 refusals `opt-census` pinned were its own `def-sigs` `CEnv` | Not built. No lib/ file changes | OURS (prog/optimizer-census.prog, tools/test/opt-census.sh); TAL program typing (PAPER, FD-14) | SH |`
- **Ledger row:**
  `| E<NN> | tfn-census | design | **`ck-prog`'s first call site: the census gate over the shipped program.** `opt-census` finished: `prog-fns` `CEnv`, post-prune subject, invariant pins, every root, registered. Answers PRB-38's instrument half and the residue PRB-43 carries | `enforcement/N12`, PRB-38, PRB-43, PRB-73 | SH |`
- **Size and closure.** Basis: the current root is 225 lines and the gate 307;
  the scratch probe that took Readings 2 to 4 added about 60 lines to the root.

  | file | change | lines | inside `prog/compiler.prog`'s closure |
  |---|---|---|---|
  | `prog/optimizer-census.prog` | collect, prune, `prog-fns` `CEnv`, `ck-prog` line; `cen-defs` replaced | +50, -20 | no, a root nothing imports |
  | `tools/test/opt-census.sh` | rows to invariants, roots loop, M5 out, `prune-off` in, `not-a-phase:` header out | +70, -60 | no |
  | `tools/test/run-tests.sh` | one `run_phase` line and its comment | +4 | no |

  No BUILD RULE step. The gate keeps printing `opt-census: N passed, M
  failed`, the form `tools/test/run-tests.sh:134-138` parses, on both exits.
- **Related:** [[arcs/enforcement-arc]] `N8`, `N11`, `N13`, `N23`; PRB-15,
  PRB-38, PRB-43, PRB-69, PRB-70, PRB-73; FD-14; EN-24, EN-25, EN-26.

## Residue

### Needed and unrostered

Grepped 2026-09-29 over every `docs/arcs/*-arc.md` roster row for
`optimizer-census`, `opt-census`, `prune-fix`, `def-sigs`, `pre-erase` and
`replica`; the hits are `enforcement/N12`, `N23`, `emitted-speed/X9`,
`substrate-floor/SU8` and `lowering-and-emit/LE4`, none of which holds either
item. Read `.planning/DISPATCH-QUEUE.md:67` (E4): its N11 item *"the three
held-out gates' mutants reach a run"* covers `opt-census.sh`'s registration,
which this element absorbs; this table leaves it out.

| needed | evidence | arc it belongs to |
|---|---|---|
| one compiler function returning the shipped pre-erase program, called by `back-program` and by every census root, so a census cannot measure a stale copy of the loop | `prog/optimizer-census.prog:153-163` copies `lib/lowering/compile-back.chiral:252-274` and already omits `:255-256`, counting two TFns that never ship (Reading 2) | lowering-and-emit; inside the closure, BUILD RULE |
| each TFn's own signature, which `prog-fns` trusts, checked equal to the source-declared signature `def-sigs` holds for the same name. Unmeasured | `lib/lowering/tal/check.chiral:293-298`; `def-sigs` at `lib/lowering/compile-back.chiral:78` | enforcement, requirement 2 |

### Drift against the brief, the row and the tree

- `opt-census.sh` is red at HEAD, `2 passed, 2 failed` (Reading 1). The roster
  row's `1548/1517/31` already disagreed with the gate's own pins `1549/1518/31`
  (`tools/test/opt-census.sh:145-147`).
- `docs/arcs/enforcement-arc.md:99-100` reads that the `CEnv`-plumbing gap
  *"is still what stands between here and `ck-prog`"*. Measured, `ck-prog`
  accepts the shipped program; the gap is the census's `CEnv`, and the call
  site it lived at was cut at `b613a8f`.
- PRB-43's live residue is that same gap and dissolves with it. PRB-73's cost,
  three hidden TFns, reads zero: all three accept.
- `docs/elements/ledger.md:134` (E17) still reads *"Wired 2026-09-05"* with
  `re-check` in `lower-defs`, cut at `b613a8f`.
- `tools/test/run-tests.sh:356-360` says `tal-check.sh` stays out red on G18;
  G18 is green since 2026-09-08 (`docs/arcs/enforcement-arc.md:171-177`) and
  registration's reason is now the 21-23 band.
- `docs/goals/enforcement.md:33-34` still wants the re-check *"running in the
  shipping compile"*, which PRB-70 rules out for `ck-prog`. Question 9.
