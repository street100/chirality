---
row: lowering-and-emit/LE25
arc: lowering-and-emit
title: name lookup through an ordered map
kind: law
origin: connect
req: 7
status: draft
updated: 2026-09-29
---

# lowering-and-emit/LE25: name lookup through an ordered map

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** every name environment the profile measured scanning a list is
  an ordered map under `str-cmp`, looked up in `O(log n)` compares, and no
  emitted byte moves.
- **Serves:** requirement 7 of [[arcs/lowering-and-emit-arc]], its first limb:
  *"every name environment that profile names is an ordered map"*
  (`docs/arcs/lowering-and-emit-arc.md:220-221`).
- **Goal:** [[goals/self-hosting]], condition 5, through this arc; the figure
  reads toward [[goals/emitted-speed]] condition 4 and sets no bar
  (`docs/arcs/lowering-and-emit-arc.md:229-232`).
- **The question this run settles**, from FD-57 section 5 in
  [[records/findings]]: whether a per-pass `Map Str` is proper, or an interim
  that interned ids would later replace, which `.planning/protocol/reconcile.md:117-124`
  refuses as an improper split.

## 2. What the tree holds

Measured 2026-09-29 at HEAD `97f1683`.

- **Bank:** none names name lookup, the ordered map or interning. A grep of
  `docs/banks/*.md` for `E27`, `ordered map`, `intern` and `name lookup`
  returns no line on the concept. The concept is one built element, `E27`
  (`docs/elements/ledger.md:169`, `built`), and this row is its adoption at
  the scan sites, so no bank is owed before §3.
- **The self-compile today:** `bin/chirality-bin` on a regenerated blob of
  851,880 B, three runs: 0.711 / 0.700 / 0.704 s wall, 330 MiB peak RSS,
  output `cmp` equal to `bin/chirality-bin`.
- **The profile:** measured at HEAD `96f40ee`. Callers of `nb-beq`, the
  byte compare under `str-eq`: `assoc-core` 21.5%, `dctor-index` 17.9%,
  `assoc` 8.4%, `lits-mem` 7.7%, `emap-get` 6.7%, `sig-assoc` 6.5%,
  `sv-ctor-fields` 5.9%, `in?` 5.4%, `find-ddata` 4.1%
  (`.planning/LANGUAGE-PROFILE-2026-09.md:15`). The 56% is grouped by cause
  at `:16`, and it includes `dctor-index` and `find-ddata`, which are
  `ctor-tag`'s walk and `LE26`'s.

The scan sites, each a head-first walk comparing keys with `str-eq`:

| scan | where | environment and its type | built at | read at |
|---|---|---|---|---|
| `in?` | `lib/surface/surface.chiral:88-89` | `SEnv`'s atoms, datas, globals, prims, each `List Str` (`:75-85`) | `lib/surface/parse.chiral:452-465`, one cons per form | `surface.chiral:122`, `:126`, `:128`, `:130` |
| `assoc` | `surface.chiral:90-93` | `SEnv`'s ctors, `List (Pair Str Str)` (`:82`) | `parse.chiral:458-459` | `surface.chiral:124` |
| `assoc-core` | `lib/lowering/upper/closconv.chiral:470-477` | `SigV`'s tys and defs, `List (Pair Str Core)` (`:464`) | `lib/lowering/upper/closconv-driver.chiral:92` | `sv-type` and `sv-def` (`closconv.chiral:479-482`), called at `:493`, `:509`, `:540`, `:585`, `:588` and `closconv-driver.chiral:260` |
| `sv-ctor-fields` | `closconv.chiral:815`, `:949-954` | `SigV`'s ctors, `List (Pair Str (List Core))` (`:464`) | `closconv-driver.chiral:86-92` | `closconv.chiral:962` |
| `emap-get` | `lib/lowering/compile-front.chiral:92-93` | `List (Pair Str (List I64))` | `build-emap` and `emap-app` (`:171-184`), joined at `:349` | `:121-122` |
| `sig-assoc` | `lib/lowering/upper/lower.chiral:163-164` | `CEnv`'s prims and fns, `List (Pair Str TalSig)` (`lib/lowering/tal/ssa.chiral:50`), and `St`'s fns seeded from `ce-fns` (`lower.chiral:124`, `:413`) | `compile-back.chiral:258` | `lower.chiral:245`, `:277`, `:280` |
| `lits-mem` | `lib/lowering/compile-back.chiral:90-91` | prune's `avail`, `List Str` of prim and function names | `prune-fix` (`:213`), rebuilt each iteration | `cb-all-in` (`:169`) and `first-missing` (`:197`) |

What the tree already holds for the replacement:

| what exists | where | rung | reached by |
|---|---|---|---|
| AVL `Map` with `m-lookup`, `m-insert` (last write wins), `m-insert-new` (a collision is `none`) | `lib/prelude/map.chiral:19-21`, `:86-127` | built, `E27` | the compiler blob |
| `str-cmp`, a total byte-order comparator | `lib/prelude/string.chiral:91-92` | built | `compile-back.chiral:20`, `asm-reloc.chiral:11` |
| a label table converted from list to `Map Str I64`, the returned table left a list | `lib/lowering/mach/asm-reloc.chiral:64-75` | built | every emit |
| literal dedup by tree-set membership, first-occurrence order kept, *"so emitted bytes are too"* | `compile-back.chiral:114-125` | built | `program-lits` |

The second pair is the precedent this row repeats: lookup moves to a map, and
every list whose order reaches emitted bytes stays a list.

**Where names cross passes.** A name is a `Str` payload in every IR the
compiler threads: `t-global`, `t-prim` and `t-con` in `Term`
(`lib/surface/syntax.chiral:27-31`); `c-con`, `c-global` and `c-prim` in `Core`
(`surface.chiral:60-64`); `nc-global`, `nc-prim` and `nc-con` in `NCore`
(`lib/lowering/lowspec.chiral:40-46`); `lc-global` and `lc-prim` in `LCore`
(`lower.chiral:117-118`); `i-call` and `tfn` (`ssa.chiral:29`, `:40`); the
kernel's signature, scanned by `assoc-tt` and `assoc-t`
(`lib/typing/kernel.chiral:374-385`); and the emitted labels
(`asm-reloc.chiral:68`). Two passes mint names mid-pipeline:
`(str-cat (str-cat name "$") (i64->str ncase))` in lowering
(`lower.chiral:319`) and `(str-cat name "#spec")` in the optimizer
(`lib/lowering/upper/optimize.chiral:256`). The ELF carries no symbol table
(`.planning/LANGUAGE-PROFILE-2026-09.md:7`), so no name reaches emitted bytes
as text.

## 3. The delta

Seven scans are maps nowhere: every site in the table above. `E27` and
`str-cmp` are built and two sites already made the move, so the delta is
adoption, with four facts §2 adds to the row as written:

1. **`sv-ctor-fields` is a profile-named scan the row omits**, 5.9% of
   `nb-beq`'s callers, in the same `SigV` record as `assoc-core`. It is in
   scope.
2. **One environment type crosses a module boundary.** `CEnv`
   (`ssa.chiral:50`) is built in `compile-back.chiral:258` and in
   `lib/lowering/tal/check.chiral:311-312` and `prog/optimizer-census.prog:211`,
   and read by lowering and by `tck-sig-assoc` (`check.chiral:101-105`,
   called at `:207` and `:211`). Seeding a map per function from a list
   `CEnv` at `lower.chiral:413` costs `O(n log n)` per function, more than the
   scan it replaces, so `CEnv`'s prims and fns become maps and its readers
   follow. The row's *"no type that crosses a pass boundary changes"* holds for
   the IRs and fails for this one record.
3. **`lits-mem` no longer touches literals.** Literal dedup is already a tree
   set (`compile-back.chiral:114-125`); `lits-mem`'s callers are prune's
   `avail` checks alone.
4. **The share is smaller than 56%.** The seven scans' share, estimated from
   `.planning/LANGUAGE-PROFILE-2026-09.md:15`: 62.1% of `nb-beq`'s callers
   times `nb-beq` plus `nb-beq-go` (32.5% of self time) is 20.2%, plus the
   scans' own self time (9.5%), about 30% of self time. The pass shares at
   `:51-59` give the same: closure conversion 13.8, load forms 7.6, peel 3.9,
   prune 4.0 and lowering about 2.6 points of samples, about 32%. At today's
   0.70 s that is about 0.21 s, estimated. The rest of the 56% is `LE26`'s
   14% and callers the profile does not break out.

**Verdict:** a real delta, adoption at seven sites across nine files.

## 4. The shapes

The build rule's test: the codebase does not settle whether keys stay `Str`
or become interned ids. FD-57 section 5 raises the question and leaves it to
this stage. Two shapes are real; a third fell at step 1.

### Shape A: an ordered `Map Str` per environment

- **Form:** each environment in §2's table becomes a `Map Str V` under
  `str-cmp`, or a set as `Map Str Unit` where the scan is membership, built
  where the list is built today. `SEnv`'s five fields and `SigV`'s three
  change type; `CEnv`'s prims and fns change type with their three builders
  and two readers. Every list whose order reaches output stays: the literal
  table, the def order, the `TFn` order, the offsets list.
- **Costs:** `O(log n)` calls of `str-cmp` per lookup, about 13 at the
  compiler's 7,640 labels (`.planning/LANGUAGE-PROFILE-2026-09.md:10`);
  `O(n log n)` per build. Each builder keeps the scan's winner: a head-first
  scan returns the first match, so a map built from a list in order keeps the
  first key it meets (`m-insert-new`, collision kept), and `SEnv`'s cons per
  form becomes `m-insert` per form, whose last write is the scan's head.
- **Forbids:** nothing wanted. Iteration order is `str-cmp`'s, and no map
  here is iterated into output.

### Shape B: names interned once at load, id-keyed maps in every pass

- **Form:** each name resolved at load to an `I64` through one ordered lookup
  per occurrence, as FD-57 section 5 describes, after which every map compares
  ids in one instruction.
- **Costs:** the `Str` payload in `Term`, `Core`, `NCore`, `LCore`, `i-call`
  and `tfn` becomes an id: six IR types across the reader, the elaborator, the
  kernel's signature (checker-core's code), closure conversion, the peel,
  lowering, erase and the emitter. The names minted mid-pipeline
  (`lower.chiral:319`, `optimize.chiral:256`) need fresh ids, so an intern
  table threads through passes that are pure `->` transforms today, and every
  diagnostic that prints a name reads the table back. The environments are
  still ordered maps: no indexed array exists to key by a dense id
  (`memory-discipline/M4` is unbuilt, per FD-57 section 5), so the bound stays
  `O(log n)` and Shape A's map conversion sits inside Shape B with a different
  key type.
- **What it buys over A:** each lookup after load compares ids where A runs
  `str-cmp`. The profile puts a map lookup at under 2% of the compile
  (`.planning/LANGUAGE-PROFILE-2026-09.md:167`), so B's margin over A is
  bounded by that 2%, estimated, and FD-57 section 4's word-wide compare cuts
  `str-cmp`'s constant without B.
- **Forbids:** reading a name off an IR node without the table.

### Refused at step 1: a per-pass `Map Str` scheduled to give way to interning

Shape A scheduled as an interim is the improper split
`.planning/protocol/reconcile.md:119-124` names. It does not enter the list.
Shape A stands only if nothing replaces it, which §5 settles.

## 5. The call

- **Chosen:** Shape A. Interning falls outside this row, for three
  reasons the tree states.
  1. **Requirement 7 names the map.** Its limb is *"every name environment
     that profile names is an ordered map"*
     (`docs/arcs/lowering-and-emit-arc.md:220-221`), and A discharges it whole.
  2. **B contains A.** With no indexed array, B's environments are A's maps
     keyed by an id. If B were ever built, each of A's builders and lookups
     changes its key type and comparator, and the conversion from list to map,
     the threading and the first-match rule all stand. Nothing of A is thrown
     away, so A is proper and smaller in the sense of
     `.planning/protocol/reconcile.md:117`: complete, correct, and replaced by
     nothing.
  3. **Nothing owes B.** Its margin over A is bounded by an estimated 2% of a
     self-compile, no goal condition holds the compiler's own time
     (`docs/arcs/enforcement-arc.md:503-504`), and B rewrites six IR types
     including the kernel's. It is out of scope: not at all, stated here, with
     no row opened.
- **`direct`:** yes. The form is settled by the two precedents in §2
  (`compile-back.chiral:114-125`, `asm-reloc.chiral:64-75`), and this section
  pins every choice a SPEC would carry.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | `Map Str` per environment, or interned ids | RESOLVED: `Map Str` | requirement 7 at `docs/arcs/lowering-and-emit-arc.md:220-221`; §4 shows B contains A; no goal holds compiler time (`docs/arcs/enforcement-arc.md:503-504`) |
| 2 | one element or one per pass | RESOLVED: one | the sites share one builder rule and one check, and a per-pass element would mint five catalog rows for about 150 lines; the SPEC-less build lands one commit per pass, each passing the BUILD RULE |
| 3 | `CEnv` seeds lowering's map per function, or carries the map | RESOLVED: `CEnv`'s prims and fns become `Map Str TalSig` | a per-function seed at `lower.chiral:413` costs more than the scan; `check.chiral` and `optimizer-census.prog` follow |
| 4 | which key a built map keeps on a duplicate | RESOLVED: the key the scan found first | the build rule demands `C1 == C2` with no emitted byte moved (`docs/definitions/working-discipline.md:23-41`); `SEnv` inserts per form with `m-insert`, every other builder folds its list in order with `m-insert-new` and keeps the first |
| 5 | does a byte move, bringing `docs/arcs/enforcement-arc.md` requirement 7 in | RESOLVED: no | only lookups change; every order that reaches output stays a list, and enforcement requirement 7 covers optimizer rewrites of emitted code (`docs/arcs/enforcement-arc.md:471-480`), which this is not. The check converges at `C1 == C2` and `C2` on HEAD's blob reproduces `bin/chirality-bin` |
| 6 | the kernel's `assoc-tt` and `assoc-t`, `tck-sig-assoc`'s own list, `find-data` and `l-find-ctor` (`lower.chiral:167-170`), `str-assoc` (`lib/lowering/tal/erase.chiral:41-43`) | RESOLVED: `tck-sig-assoc` is in, forced by #3; the rest are out | the profile names none of the rest among `nb-beq`'s callers (`.planning/LANGUAGE-PROFILE-2026-09.md:15`); the residue lists them |

## 6. The mint packet

- **Elements:** one. Seven scans under one rule and one check; `CEnv` couples
  lowering to the TAL checker, and the builder rule of §5 #4 is shared.
- **Band:** `UNASSIGNED`. The arc holds no reserved block
  (`docs/arcs/lowering-and-emit-arc.md:34`).
- **Catalog row:**
  ```
  | E<NN> | **Name lookup through an ordered map**: every name environment `.planning/LANGUAGE-PROFILE-2026-09.md` measured scanning a list is an `E27` `Map Str` under `str-cmp`: `SEnv`'s five fields, `SigV`'s three, the peel's erased-position map, `CEnv`'s prims and fns, and prune's `avail` as a set; each builder keeps the key the scan found first, and every list whose order reaches output stays a list | Not built. `lib/surface/{surface,parse}.chiral`, `lib/lowering/upper/{closconv,closconv-driver,lower}.chiral`, `lib/lowering/{compile-front,compile-back}.chiral`, `lib/lowering/tal/{ssa,check}.chiral`, `prog/optimizer-census.prog` | `lowering-and-emit/LE25`, the arc's G7 row, `docs/arcs/lowering-and-emit-arc.md:267` | SH |
  ```
- **Ledger row:**
  ```
  | E<NN> | compile-front | design | Name lookup through an ordered map: seven scans become `Map Str` lookups, first match kept, no output order changed. Check: BUILD RULE `C1 == C2`, `C2` reproduces `bin/chirality-bin`, then the suite | `lowering-and-emit/LE25` | SH |
  ```
- **Size:** nine `lib/` files and one `prog/` file. About 150 lines touched:
  eight scan functions become `m-lookup` calls at 21 call sites, three record
  types (`SEnv`, `SigV`, `CEnv`), about ten builders (`parse.chiral:452-465`,
  `closconv-driver.chiral:86-92`, `compile-front.chiral:171-184`,
  `compile-back.chiral:213` and `:258`, `check.chiral:312`,
  `optimizer-census.prog:211`), and one keep-first builder added to
  `lib/prelude/map.chiral`. Basis: the sites in §2, one to eight lines each.
- **Check, as the build runs it:** blob regenerated, `C1` and `C2` built from
  it, each non-empty before `cmp`, `C1 == C2`; `C2` compiling the blob
  reproduces the prior `bin/chirality-bin`; the suite on `C2` before promotion.
  A sampled self-compile re-reads requirement 7's figure against today's
  0.70 s and 330 MiB and gates nothing.
- **Related:** [[arcs/lowering-and-emit-arc]], [[records/findings]] FD-57,
  `lowering-and-emit/LE26`.

### Residue

**Needed and unrostered.**

| need | why | where it would go |
|---|---|---|
| amend the row's cited share and savings: about 30% of self time and about 0.21 s, estimated, where the row reads 56% and 0.35 to 0.45 s | §3 fact 4: the 56% includes `LE26`'s walk and unattributed callers | clerical, at the mint's roster update of `docs/arcs/lowering-and-emit-arc.md:267` |
| add `sv-ctor-fields` to the row and drop *"no type that crosses a pass boundary changes"* for `CEnv` | §3 facts 1 and 2 | the same roster update |
| measure the unattributed rest of the 56%, including the kernel's `assoc-tt` and `assoc-t` and the dup check's `nb-beq` (`.planning/LANGUAGE-PROFILE-2026-09.md:61`) | the profile breaks out callers above 4.1% only; the kernel is checker-core's code | a sampled self-compile after this element lands; a row in [[arcs/checker-core-arc]] if the kernel's scan is material |

No row is opened for interning: §5 disposes of it as out of scope.
