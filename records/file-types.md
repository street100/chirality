---
node: records-file-types
layer: navigation
related: [records/README, arcs/file-types-arc, arcs/crypto-primitives-arc, records/author-calls, insp-unison, decisions/decision-work-ids, status-ledger, index]
status: current
updated: 2026-09-23
---

# File types arc

Every row is a claim [[arcs/file-types-arc]] makes, beside what was measured
against it. The prefix is `FT`. [[records/README]] fixes the six fields and the
rule that a row whose `checked:` date predates the last change to the files it
cites is unverified.

The file opens with `FT-01`. The arc was written 2026-09-04 and amended
2026-09-23 without ever carrying a record file, so the file is created by the
run that needed it. The precedent is [[records/runtime-loading]], opened the
same way on 2026-09-18.

## Caching

The four rows below were taken together on 2026-09-23, when the arc's own
constraints section gained the deferral they justify.

### FT-01 resolution already costs more than compilation, and the ruled join point adds to the resolving side

- state:    OPEN
- claim:    [[arcs/file-types-arc]] schedules kinds whose translation joins the pipeline as an optional parse stage in front of upper, ruled at [[records/author-calls]] the join-point ruling and carried into the arc at `docs/arcs/file-types-arc.md:28` as *"the join point is an optional `{parse ->}` stage in FRONT of upper, with `upper -> lower -> binary` always below"*. Six requirements and four roster rows state what each kind must declare and what gate it owes. None of them prices what a per-facet parse stage costs to run, and the arc names no budget anywhere.
- measured: `bin/chirality-resolve.sh:84-87` records, dated 2026-08-31, that resolving `prog/compiler.prog` cost **1657ms** against **744ms** to COMPILE the 732 KB blob it produces, and that a root with no imports at all cost **88ms** against **14ms**. The same comment draws its own conclusion at `:86-87`: *"The provider was the dominant cost of every gate in the tree, and none of it was compilation."* ⚑ **The bearing on this arc is a direction.** A stage in FRONT of upper runs on the resolving side of the pipeline, which is the side the 2026-08-31 figures put at 2.2x compilation on the compiler's own blob and 6.3x on an import-free root. Adding a parse stage per facet adds to the larger number. ⚑ **The arc proceeds without pricing it, and that is the workaround rather than a gap nobody saw.** The figures above are the whole of what the tree knows about resolution cost; no kind exists yet to measure a parse stage against, and the file that holds the measurement records at `:100-107` that the one alternative anybody tried, a pure-bash rewrite with no forks, was SLOWER. A budget written before the first kind exists would be a number with nothing behind it.
- evidence: bin/chirality-resolve.sh:84-87, :86-87, :100-107; docs/arcs/file-types-arc.md:28, :76-152, :154-172
- checked:  2026-09-23
- element:  `crypto-primitives/K2` then `crypto-primitives/K4`. **Deferred, with an exact trigger: when the sponge lands.** The remedy for a resolve cost that already exceeds the compile is a cache whose key is the content, and `FT-03` measures why one cannot be built first. `K4` at `docs/arcs/crypto-primitives-arc.md:165` owns the digest and reads `open`, and its own dependency `K2` at `:163` reads `open`, so the trigger is `K2` built then `K4` built. [[arcs/file-types-arc]] schedules neither and states the wait at its §Constraints this arc works under. Revisit this row when `K4` is built.
### FT-02 the only cache in the tree is per-process and dies with the shell

- state:    OPEN
- claim:    `bin/chirality-resolve.sh:67` heads its cache section *"The two caches, and why they are sound"*, and argues the soundness at `:69-74`: *"Both memoize a PURE function of a static tree: a file's import list is a function of its bytes, and a key's resolution is a function of which files exist."*
- measured: the file declares **three** associative arrays at `:88-90`, `_CHIR_IMP`, `_CHIR_PROBE` and `_CHIR_SRC`, and each is read behind a `CHIRALITY_NO_CACHE` guard at `:110`, `:133`, `:158` and `:176`. Their scope is stated at `:76-77`: *"Scope is one shell process. `bin/chirality` sources this file per invocation, so `chirality check` gets a cold cache every time"*. The soundness argument holds only over a STATIC tree, and the file says so itself at `:80`: *"A tree mutated mid-process would be stale"*, which is why `tools/test/mutant.sh` resolves each mutated tree in its own subshell. ⚑ **So the tree has no cache that survives a process.** What the cache reaches is stated at `:77-79`, the callers that resolve many roots in one shell, and `run-tests.sh` Phase 7 at 38 roots over one overlapping closure is the named instance. A single `chirality check` gets none of it. ⚑ **The gap is kept deliberately and the workaround is the status quo.** No roster row in [[arcs/file-types-arc]] and none in any other arc owns a durable cache, so a facet's parse stage re-runs on every invocation, which is exactly what import resolution already does today. Nothing regresses, and nothing improves.
- evidence: bin/chirality-resolve.sh:67, :69-74, :76-79, :80-82, :88-90, :110, :133, :158, :176; tools/test/mutant.sh
- checked:  2026-09-23
- element:  `crypto-primitives/K2` then `crypto-primitives/K4`. **Deferred, with an exact trigger: when the sponge lands.** A durable cache is owned by no roster row in the tree today and cannot be, because its key needs a digest that does not exist (`FT-03`). The workaround costs nothing now: every parse re-runs, which is what import resolution already does per `bin/chirality-resolve.sh:76-77`. Revisit this row when `K4` is built.
### FT-03 no hash primitive exists, so a content-addressed cache is unconstructible today

- state:    OPEN
- claim:    [[insp-unison]] records the shape this tree says it wants, at `docs/definitions/insp-unison.md:12`: Unison stores definitions *"content-addressed by the hash of their typed syntax"* tree, so a definition once written never changes out from under a caller. A content-addressed cache is the standard remedy for `FT-02`, and it needs a digest over bytes.
- measured: `grep -nEi "blake|sha256|digest|hash"` over `lib/prelude/prelude.chiral` (183 lines) and every file in `lib/ports/` returns **zero** hits on 2026-09-23. The ports directory holds ten files, `clock`, `fd`, `file`, `pool`, `process`, `pty`, `sock`, `stdio` and `tty` as `.port` plus `ports.chiral`, and none of them declares a digest crossing. ⚑ **A hash IS rostered, in another arc, and it is unbuilt.** `docs/arcs/crypto-primitives-arc.md:165` carries `crypto-primitives/K4` as *"the sponge module: hash, XOF, MAC and KDF as configurations of `K2`, one machine"*, `state: open`, `element: unminted`, and its own dependency `K2` at `:163` is open and unminted too. ⚑ **So the deferral is cross-arc and it has a named owner.** [[arcs/file-types-arc]] defers caching to `crypto-primitives/K4` under `docs/decisions/decision-work-ids.md`, which gives an arc-local roster row the identity that makes a deferral citable, and `docs/definitions/working-discipline.md`'s deferral rule forbids naming an `E#` that does not exist. `K4` is a roster row and it is unminted, which is the form the rule permits.
- evidence: lib/prelude/prelude.chiral; lib/ports/; docs/definitions/insp-unison.md:12; docs/arcs/crypto-primitives-arc.md:163, :165; docs/decisions/decision-work-ids.md; docs/definitions/working-discipline.md
- checked:  2026-09-23
- element:  `crypto-primitives/K2` then `crypto-primitives/K4`. **Deferred, with an exact trigger: when the sponge lands.** `K4` at `docs/arcs/crypto-primitives-arc.md:165` owns the digest and reads `open`; its dependency `K2` at `:163` reads `open`. [[arcs/file-types-arc]] owns nothing here and waits. Revisit this row when `K4` is built.
### FT-04 the resolver's cache section says two and the file declares three

- state:    OPEN
- claim:    `bin/chirality-resolve.sh:67` heads the section *"The two caches, and why they are sound"* and closes it at `:81-82` with *"set CHIRALITY_NO_CACHE=1 to disable both if a caller ever needs to re-read a tree it just wrote"*. Both sentences count two.
- measured: three arrays are declared three lines below the heading, at `:88-90`: `_CHIR_IMP` for a file's import keys, `_CHIR_PROBE` for a root-and-key resolution, and `_CHIR_SRC` for a file's bytes. `_CHIR_SRC` has its own guard at `:158` and its own justification at `:149-155`, where the emit loop's fork count is priced, so the third cache is documented and only the count is stale. The environment variable at `:110`, `:133`, `:158` and `:176` disables all three, so the behaviour the sentence describes is correct and the word *both* is wrong. ⚑ **Nothing was done.** This row is a comment defect found while taking `FT-02` and it belongs to no arc, so it is recorded here beside the row that surfaced it.
- evidence: bin/chirality-resolve.sh:67, :81-82, :88-90, :110, :133, :149-155, :158, :176
- checked:  2026-09-23
- element:  none. A one-word comment correction in a file [[arcs/file-types-arc]] does not own, and Lane B's write list at `docs/arcs/file-types-arc.md` §Constraints this arc works under does not include `bin/`.

## Cross-kind use

### FT-05 an import statement names a key and carries no kind, and cross-kind import already works

- state:    ACCEPTED
- claim:    `MAP.md:18-30` §Importability states that `.chiral`, `.port` and `.manifest` are import targets and that *"the resolver probes three extensions, not five"*. [[records/author-calls]] the module-key call asks whether `<name>.m.conf` and `<name>.m.check` are one module key with facets or two keys, which is a question about what an import statement has to spell.
- measured: an import spells a key and never an extension, checked 2026-09-23 in both directions. A `.chiral` importing a `.port`: `lib/ports/ports.chiral:32` reads `(import "ports/fd")` and the target on disk is `lib/ports/fd.port`, with eight more of the same shape at `:33-40`, and `lib/runtime/poll.chiral:9` reads `(import "ports/sock")` against `lib/ports/sock.port`. A `.manifest` importing a `.chiral`: `lib/lowering/tal/target-linux.manifest:9` reads `(import "lowering/tal/sys-check")` and the target is `lib/lowering/tal/sys-check.chiral`. The extension is supplied by the resolver's probe order, declared at `bin/chirality-resolve.sh:65` as `CHIRALITY_EXTS=(.chiral .port .manifest)` and executed at `:174-199`. ⚑ **So the property holds today by construction and the arc's job is to keep it.** Two importable kinds under one key is already a NAMED ERROR, `module extension collision`, raised at `:190-197`, whose first line at `:192` prints `module extension collision`, and mirrored by the native provider at `lib/module/resolve.chiral`, which is what stops the probe from silently picking. A facet scheme that put the kind into the import statement would reverse a property nothing in the tree currently pays for.
- evidence: MAP.md:18-30; lib/ports/ports.chiral:32-40; lib/runtime/poll.chiral:9; lib/lowering/tal/target-linux.manifest:9; lib/lowering/tal/sys-check.chiral; bin/chirality-resolve.sh:65, :174-199, :192; lib/module/resolve.chiral
- checked:  2026-09-23
- element:  `file-types/K1`. [[records/author-calls]] the module-key call blocks it, and this row is the measurement that call is decided against.

## The derivation substrate

Two rows taken 2026-09-23 against the arc's own law, a declared form and a
derived codec. [[records/checker-core]] `CK-03` is the same absence measured from
the checker's side and carries the call-site census.

### FT-06 the schema a derived codec would read is built, the deriving is named `new`, and three rows assume it

- state:    OPEN
- claim:    [[arcs/file-types-arc]] states the law at `docs/arcs/file-types-arc.md:63` as *"One law, two carriers. A declared form, a derived codec, a round-trip gate"*, and requirement 3 at `:97-99` asks that *"Codecs are derived from the declared form"* rather than hand-written, observed by *"the five hand-written codecs losing their framing code and the 1,891-line total falling"*. `.planning/MANIFEST-DESIGN-MAP.md:18-20` states the same law from the design side: *"a configuration's reader is derived from the type declaration, so there is no second implementation to audit."*
- measured: the declaration side is built and the deriving side is one table cell. `.planning/MANIFEST-DESIGN-MAP.md:238` lists *"Schema-consulting printer over `Sig`"* as `new`, beside `:237` listing *"Type-directed elaboration"* as `new` and `:240` listing *"Sub-form positions"* as `new`. What those would read is in the tree: `sig-data : (-> Sig Str (Maybe DataDecl))` at `lib/typing/kernel.chiral:401` and `ctor-fields : (-> DataDecl Str (Maybe (List Field)))` declared at `:460` and defined at `:1013`. ⚑ **Their seven call sites all judge.** Five are the kernel's own checking (`:1038`, `:1069`, `:1072`, `:1263`, `:1306`) and two are redeclaration tests in `lib/module/loader.chiral` at `:550` and `:571`. No caller builds a traversal, so nothing in the tree turns a `DataDecl` into a reader or a printer. ⚑ **Three of the arc's four rows assume the thing that is absent.** `file-types/K1`, `K2` and `K3` each read `3` in the `req` column of the roster at `docs/arcs/file-types-arc.md:169-172` or carry a derived reader in their prose, `docs/arcs/parts/file-types-K3.md:105` stating that what `K3` adds over `K1` *"is exactly the notation plus its derived reader"*. The roster's `element` cells are `E163`, `E183` and `E190`, each a kind. **No row in this arc or in any other owns the mechanism the three would derive through**, verified 2026-09-23 by reading the four roster rows and the `Coverage` section, which attaches requirement 3 to `K1` and `K2` as a property they carry rather than to a row that builds it.
- evidence: docs/arcs/file-types-arc.md:63, :97-99, :169-172, §Coverage; docs/arcs/parts/file-types-K3.md:105; .planning/MANIFEST-DESIGN-MAP.md:18-20, :237, :238, :240; lib/typing/kernel.chiral:401, :460, :1013, :1038, :1069, :1072, :1263, :1306; lib/module/loader.chiral:550, :571
- checked:  2026-09-23
- element:  none. `GAP-04` in `records/lenses/gaps.md` is the enumerated gap for requirement 3 and reads `open` with `owner: none`; this row is the substrate measurement behind it and the gap row was amended 2026-09-23 to carry it. Whether the mechanism takes a roster row of its own or lands inside `K1` is a design question no run has asked.

### FT-07 requirement 5 asks for five emitters, and with no mechanism that is five hand-written walks nothing gates

- state:    OPEN
- claim:    [[arcs/file-types-arc]] requirement 5 at `docs/arcs/file-types-arc.md:119-121` reads *"The five emitters return `Doc`, gated at widths 1, 40 and 10^6. E146"*, served by `file-types/E1` at `:172`, *"value to source: the five emitters return `Doc`. Imports `surface/pretty`, which E181 landed"*. The same file's §Constraints opens with the rule that guards it: *"Lane B must not write its own term printer. E158's G6 greps `lib prog tools` for every `prelude/doc.chiral` binding and fails on a duplicate definition, with M6 proving it can see one. This is the duplicate-owner defect this repo has already fixed four times: `str-cmp`, `list-sort`, `list-dedup-adj`, `Ord`."*
- measured: the five are five distinct declared types, read 2026-09-23 at `prog/prapanca/core/types.chiral`: `GateRule` at `:14`, `Binding` at `:28`, `Config` at `:36`, `Expert` at `:66` and `Pipeline` at `:82`, **21 fields over five constructors**, with `Pipeline` reaching two further closed sums, `Order` at `:52` and `StopPolicy` at `:57`. `docs/elements/catalog.md:466` names the file that would hold them, `prog/prapanca/contract/emit.chiral`, and records *"the emit module does not exist"*, which holds on 2026-09-23. ⚑ **The hand-written shape is already in the tree once, as a pair.** `prog/prapanca/contract/manifest.chiral` is 334 lines carrying `manifest-from-json` at `:135` and its inverse `manifest-to-json` from `:182`, whose own header calls it *"The PURE serializer -- the byte-for-byte inverse of manifest-from-json above"* over *"Same 15 top-level keys, same 9 ExpertCall keys"*, so the two halves agree by hand and by reading. `.planning/MANIFEST-DESIGN-MAP.md:140-142` prices that file as *"334 L of hand-written field-diggers"* whose `run-id` against `run_id` mismatch is the knob the derived route avoids. ⚑ **G6 cannot see this class.** Read at `tools/test/doc.sh:509-545`, it reads every `^(def|data|declare` name out of `lib/prelude/doc.chiral`, then greps `lib prog tools` for a second **defining** occurrence of each, with `M6` appending a second `(def doc-fits ...)` to `lib/prelude/string.chiral` to prove the census sees one. Five emitters over five different types define five different names, so the census returns clean on a tree carrying five independent walks of one shape. **The duplication requirement 5 risks is structural and the gate that exists is nominal.**
- evidence: docs/arcs/file-types-arc.md:119-121, :172, §Constraints this arc works under; prog/prapanca/core/types.chiral:14, :28, :36, :52, :57, :66, :82; prog/prapanca/contract/manifest.chiral:135, :182; docs/elements/catalog.md:466; .planning/MANIFEST-DESIGN-MAP.md:140-142; tools/test/doc.sh:509-545
- checked:  2026-09-23
- element:  `file-types/E1`, which carries `E146` and is the one row [[arcs/file-types-arc]] §Resume state names as startable. **This row schedules nothing and adds no row.** It bears on the design stage for `E1`: `FT-06` measures the mechanism absent, so an `E1` design that writes five walks and an `E1` design that derives them are different elements, and which one the row means has never been decided.
