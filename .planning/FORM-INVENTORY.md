# Form inventory

**Opened 2026-10-01.** The material for the author's review of what the surface
requires at every level. The author's words, the same day:

> "We need to go over elements and subelements that are required for different
> things so we can make syntax simpler and required fields straightforward,
> while using the structural knowledge to continue curbing possible syntax
> issues."

It feeds `surface-syntax/SY2`, the form-inventory row of
`docs/arcs/surface-syntax-arc.md`, whose requirement 2 (`:123-127`) asks for one
tracked row per form the recognizer admits. It is an extraction measured at
HEAD `3df3ae2`, whose code is byte-identical to `3a302d6` where the measuring
began, with the code as the authority, and it rules nothing. The ruling
it serves is the stage-4 fork, `records/author-calls.md:543`:
s-expressions stay as raw, and a coder surface is added that translates to raw
and back. `.planning/SYNTAX-REWORK.md` holds the discussion.
`.planning/FILE-KIND-STRUCTURES.md` §The template gives the four columns used
here, and its §`data` is the precedent table.

## How it was measured

- **Corpus.** 407 files: the 316 that `git ls-files lib prog` returns with
  `.chiral`, `.prog`, `.port` or `.manifest` (`.profile` returns none), and the
  91 `tools/**/*.prog`.
- **Counts.** A Python mirror of `lib/surface/sexp.chiral`, with the same four
  trivia bytes, delimiters, comment rule and escape rule, read all 407 files and
  counted list heads by position, so text inside comments and strings drops
  out. As the grep cross-check, `grep -hE '^\(def( |\)|$)'` over the same files
  gives 5,201 toplevel `def` lines against the mirror's 5,237 forms; the gap is
  files holding several forms on one line, as
  `prog/scriba/scriba-test-b1.prog:4` holds ten imports. An exemplar is the
  first occurrence in `git ls-files` order, at the line of its open paren.
- **Refusals.** 304 probe files in the session scratchpad, each opening with
  `(import "prelude/prelude")` and run through `bin/chirality check`: 194
  refused, 110 accepted. A probe whose acceptance mattered was also compiled and
  run. Every load refusal prints behind `load: `
  (`lib/lowering/compile-front.chiral:369`), and the tables drop that prefix.
- **Columns.** `position`, `becomes`, `layer` and `obligation` as the template
  defines them, then `required` and `refusal when wrong`. Count and exemplar,
  redundancy and hazard sit in a short list under each table.
- **Layers.** *reader* `lib/surface/sexp.chiral`. *parser*
  `lib/surface/parse.chiral`, Sexp to `Surf` and the toplevel loop. *elab*
  `lib/surface/surface.chiral`, `Surf` to `Core`. *loader*
  `lib/module/loader.chiral`, `Core` to `Term` and into `Sig`. *kernel*
  `lib/typing/kernel.chiral`. *emit* `lib/lowering/compile-front.chiral` and
  `compile-emit.chiral`. *provider* `bin/chirality-resolve.sh`.

## 1. Lexical level

The reader is pure and returns errors as values. It builds four node kinds,
`s-list`, `s-sym`, `s-i64` and `s-str` (`lib/surface/sexp.chiral:12-16`).

| token | bytes | becomes | layer | obligation | refusal when wrong |
|---|---|---|---|---|---|
| trivia | SP, TAB, CR, LF only (`:66-67`) | nothing | reader | none | none; every other byte, FF, VT and NUL included, is a symbol byte |
| comment | `;` to the next LF (`:81-87`, `:96-97`), any byte inside | nothing | reader | none | none |
| list | `(` items `)`; `(`, `)`, `"`, `;` and trivia end an atom (`:74-78`) | `s-list` | reader | balance | `unexpected ) at L:C depth=N` (`:228`); `unclosed ( at L:C depth=N` (`:240`); `unexpected end of input at L:C depth=N` (`:220`, reached by no probe) |
| string | `"` to the next unescaped `"`; raw LF, control bytes, bidi controls and zero-width characters all pass (`:191-200`) | `s-str`, then a `Str` literal | reader | termination | `unterminated string` (`:194`); `unterminated escape` (`:205`); neither carries a position |
| escape | `\n` is LF, `\t` is TAB, any other `\X` is the byte X (`:180-186`) | one byte | reader | none | none; `"a\qb"` reads as `aqb` |
| integer | exactly `-?[0-9]+` (`:117-124`), folded with no range check (`:129-133`) | `s-i64` | reader | none | none; overflow wraps |
| symbol | any other run of bytes up to a delimiter (`:168-176`) | `s-sym`, a `Str` compared by bytes | reader | none | none |

The two messages that carry a place compute line and column over the blob the
provider concatenated (`fmt-pos`, `:164-166`), and the relay drops the numeric
position of every reader error (`lib/surface/parse.chiral:1434`,
`lib/module/load-batch.chiral:99-100`). Each prints behind `parse: `
(`lib/typing/diag.chiral:516`).

- **Count / exemplar.** 178,676 symbol tokens, 10,713 integer tokens (141
  negative, 0 with a leading zero), 7,111 strings. Escapes used: `\n` 667, `\"`
  660, `\\` 17, `\t` 11, any other 0. The corpus symbol alphabet is 77 ASCII
  characters: ``!%'*+-/``, digits, `<=>?`, letters and `_`. 0 symbols hold a
  byte at or above 128, and no corpus file holds a TAB or a CR. 266 files hold
  non-ASCII bytes, on 2,580 comment lines and as 80 bytes in strings. The
  deepest nesting is 94 levels, at `lib/lowering/tal/bytes.chiral:757`.
- **Bounds.** `MAX-DEPTH` is 200 at `:44` and is read by nothing, as
  `prog/shape-census.prog:47` also records. A probe nested 20,000 deep was
  accepted in 0.1 s. Token length and file size carry no bound. The CLI runs
  the compiler under `ulimit -s unlimited` (`bin/chirality:124`, `:173`).
- **What the reader leaves out.** Its one dispatch byte is `(`. It has no quote,
  quasiquote, `#` or bracket syntax, so `'x` and `#s` read as symbols, and it
  evaluates nothing at read time. `paren-fix` (`:289-315`) repairs one missing
  or extra close paren and is called by nothing. The `last-form` context
  threaded through `read-form*` and `read-list*` (`:216`, `:236`) appears in no
  message.
- **Probed spellings.** `007` reads as 7 and `-0` as 0.
  `99999999999999999999999` compiles and prints as `200376420520689663`, and
  `9223372036854775808` reads as a negative number. `+5`, `0x10` and `'x` read as
  symbols, each refused later as an unknown name, `unknown name +5` for the
  first. A form feed between `n` and `I64` makes one symbol, refused as
  `def body with no prior declare: n<FF>I64`, where `<FF>` marks the byte the
  message prints invisibly. `abc"def"` reads as two atoms. All
  of these are accepted: U+202E and U+2066 in a comment, U+202E in a string, a
  raw NUL or a raw newline in a string, a zero-width space inside a def name,
  bytes `FF FE` inside a def name, and two defs `vаl` (Cyrillic а) and `val`.
- **Hazard.** Symbols: PRB-102 and FD-68 on bidi, invisible and confusable
  characters; FD-66 files the homoglyph class as CWE-1007. Integers and
  escapes: FD-67's "refuse malformed input" and `.planning/SYNTAX-REWORK.md`
  reader rule 4 (explicit radix, a leading `0` refused); the reader repairs by
  wrapping and by dropping the backslash. Positions: PRB-103. Depth and size:
  FD-67's "bound depth, size and expansion", where the bound exists as a
  constant with no reader.

## 2. File kinds

`MAP.md:3-13` makes the extension the kind. The provider decides importability.
No code reads a file's content against its kind.

| ext | stated requirement (`MAP.md`) | what code checks it | lib / prog / tools |
|---|---|---|---|
| `.chiral` | module, importable computation; the default | the provider probes it first (`bin/chirality-resolve.sh:65`, `lib/module/resolve.chiral:221-245`) | 95 / 103 / 16 |
| `.prog` | program with an entry; defines the entry symbol | the provider never probes it, so `(import "compiler")` is refused `chirality-resolve: no module 'compiler'`. The entry is checked by `compile` and `run` only, for any extension (section 3) | 0 / 107 / 91 |
| `.port` | declarations only, zero lambdas, at least one extern or porttype | probed as importable; content unchecked | 9 / 0 / 0 |
| `.profile` | a named frozen port set: zero lambdas, zero externs, names a module set | nothing. No such file exists; the 6 `(profile ...)` forms sit in `.chiral` files under `prog/demo/` | 0 / 0 / 0 |
| `.manifest` | pure data, every `def` body a literal, "declared in the file and checked by the loader" (`MAP.md:32-40`) | probed as importable; the loader holds no such check | 1 / 1 / 0 |
| `.protocol`, `<name>.m.gram` | named in `.planning/FILE-KIND-STRUCTURES.md` §The kinds | nothing | 0 / 0 / 0 |

- **Measured content.** All 9 `.port` files hold 0 `def` and 0 `lam`, and each
  declares at least two externs. Both manifests hold 0 `lam`. The property
  holds by habit: a file holding `(def f (-> I64 I64) (lam (x) (+ x 1)))` passes
  `check` under each of `.port`, `.manifest`, `.profile` and `.prog`.
- **The one checked relation.** One key resolving under two importable
  extensions is the named error `module extension collision`, in the shell
  provider (`bin/chirality-resolve.sh:192-194`) and in the native one
  (`re-ext-collision`, `lib/module/resolve.chiral:123`).
- **Redundancy.** `.port` restates by extension what a module already shows by
  declaring an effectful `extern`; the module datasheet derives the same
  crossing list from the module's charges (`lib/module/loader.chiral:219-231`).
- **Hazard.** `.planning/FILE-KIND-STRUCTURES.md` §Where a separation can ride
  measures 5 of the 6 extensions as decoration. FD-67's "recognize the whole
  input before acting on it" reaches this level as a type each file inhabits.

## 3. Program purposes

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| a def named `compile-main` in the blob | the entry the driver compiles, `(compile-all src "compile-main")` (`prog/compiler.prog:18`) | emit | the name exists and the def lowers | for `compile` and `run` | `no such def: compile-main` (`lib/lowering/compile-front.chiral:348`); `the entry def does not lower: compile-main` (`:351`) |
| the entry's type | nothing | none | none | no | none |
| `--entry NAME` | an appended `(def compile-main (=> I64 I64) (lam (chirality-entry-arg) (NAME chirality-entry-arg)))` (`bin/chirality:93-95`) | CLI | NAME takes the one argument the alias passes | no | the alias's own type refusal |
| `(target name (require dname ty)...)` | a `TargetDef` in `Sig` (`lib/typing/kernel.chiral:59`) | kernel | each `ty` is a type | no | section 4, `target` |
| `(profile name clause...)` | a `Profile` in `Sig` (`kernel.chiral:60-61`) | emit, totality | section 4, `profile` | no | section 4, `profile` |

- **Count / exemplar.** All 198 `.prog` files define `compile-main`. Its types:
  `(=> I64 I64)` 132 (`prog/compiler.prog:15`), `(-> Unit I64)` 35,
  `(-> I64 I64)` 25, `(=> Unit I64)` 5, and `(-> I64)` 1
  (`prog/demo/_recurse-ceiling.prog:15`, refused at parse). 6 targets and 6
  profiles, all in `prog/demo/`, the first pair at
  `prog/demo/profile-duo.chiral:8` and `:13`.
- **What the entry's type admits.** `(def compile-main Str "x")` compiles.
  `(-> Str Str)` compiles and exits 0. `(-> I64 I64 I64)` compiles and exits 7.
  A `.chiral` file defining `compile-main` compiles as a program.
  `chirality check` appends a trivial entry when the text `(def compile-main`
  is absent from the blob (`bin/chirality:171-172`), so `check` passes a file
  that lacks an entry, and a comment holding that text turns `check` into
  `no such def: compile-main`.
- **What reaches a consumer.** A profile's `ports` reach the emit gate:
  `E76 profile REFUSED emit: crossing trace (wrap-trace) is outside the declared profile port set`
  (`lib/lowering/compile-emit.chiral:357`). Its `(total)` reaches the totality
  gate (`lib/typing/totality-check.chiral:134`, `:161`). Its `target` is looked
  up once to exist (`lib/surface/parse.chiral:977-978`) and read by nothing
  after. Its `memory` is stored and read by nothing. A target's requirement list
  is read by nothing: a profile whose target holds
  `(require main (=> I64 I64))` compiles in a file that defines no `main`.
- **Conformance.** `docs/decisions/decision-profiles.md:79-85` states that a
  profile fits a target when its composite type satisfies the requirement
  type, and orders the check after the subtyping `modules-core` defers. No code
  performs it.
- **Redundancy.** The entry's name is fixed in three places,
  `prog/compiler.prog:18`, `bin/chirality:88-96` and the CLI help. A target
  requirement and the def it names state one type twice, and nothing joins
  them.
- **Hazard.** The entry is a name with no required type. FD-67's rule to
  recognize the whole input first applies to the program's kind as much as to
  its bytes.

## 4. Toplevel forms

`load-form` dispatches ten heads (`lib/surface/parse.chiral:1276-1303`). Loading
runs in three passes (`:1429-1466`, and its twin
`lib/module/load-batch.chiral:94-124`, which `compile-front` runs): every
`porttype` installs first, then every `data` form as one group, then every form
in source order, where `data` and `porttype` only charge their module
coordinate. A data or porttype name is visible everywhere; any other name is
visible to the forms after it.

Any other head gives `unsupported toplevel form frob` (`:1304`). A list in head
position gives `bad toplevel form (head not a symbol)` (`:1305`), `()` gives
`empty toplevel form` (`:1306`), and an atom gives
`bad toplevel form (not a list)` (`:1307`).

### `def`

`(def name ty body)` or `(def name body)`. The parser picks by the number of
items after the name (`:548-564`).

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `name` | a `Sig` global (`lib/module/loader.chiral:76-77`) and an `SEnv` global; charged `eh-def` | parser, loader | unique, checked at emit | yes | `def name must be a symbol`; `(def name ty body) or (def name body)`; a repeat gives `duplicate label (an object def collides with the linked runtime): f` (`compile-emit.chiral:362`) |
| `ty` | a `Term` inferred to be a universe (`loader.chiral:389-402`) | elab, kernel | a type | in the 4-item form | `definition type is not a type` |
| `body` | a `Term` checked against `ty`, with the name already in scope for self-recursion (`parse.chiral:574`) | elab, kernel | has the type | yes | kernel refusals, section 5 |
| `body` in the 3-item form | completes a prior `declare` (`loader.chiral:432-440`) | loader | a declare of the name comes first | a prior declare | `def body with no prior declare: f` |

- **Count / exemplar.** 5,237 (`lib/capability/lincoll.chiral:31`): 3,515 with
  four items, 1,722 with three. 4,302 bodies are a `lam`.
- **Redundancy.** A `lam` body names its parameters apart from their types:
  8,320 parameter names across those 4,302 defs, each typed only in the arrow.
  242 of the defs also name binders on the arrow, and 233 of those write the
  same names twice, as
  `(def sv-push (-> (1 s Sock) (1 v SockVec) SockVec) (lam (s v) ...))` does at
  `lib/capability/lincoll.chiral:31-32`. The parameter count is stated twice
  too, as the arrow's item count and the `lam`'s name count, and the two agree
  in 4,246 defs. Arrow names and `lam` names need not agree: swapping them is
  accepted.
- **Hazard.** The item count decides what the third item means: `(def f I64)`,
  a def missing its body, reads as body-only and is refused
  `def body with no prior declare: f`. A repeated def passes the loader and is
  refused at emit with a message about the runtime (PRB-104). `(def true I64 7)`
  is accepted and unreachable, because a constructor resolves before a global
  (`lib/surface/surface.chiral:118-132`); `(def + ...)` is accepted and hides
  the prelude extern. The name slot: PRB-102.

### `declare`

`(declare name ty)`, a forward declaration (`parse.chiral:606-625`).

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `name` | a `Sig` global with the placeholder body `(t-type 0)` (`loader.chiral:417-425`) | parser, loader | none | yes | `declare name must be a symbol`; `(declare name ty)` |
| `ty` | the global's type | elab, kernel | a type | yes | `declared type is not a type` |
| a fourth item | refused | parser | none | absent | `(declare name ty (measure ...)) -- measure attribute DEFERRED` |

- **Count / exemplar.** 1,731 (`lib/capability/lincoll.chiral:38`). 1,718 are
  completed by a three-item def in the same file, 1,022 of them by the next
  form. 12 have no def in their file; `prog/scriba/dispatch.chiral:54`, for
  one, declares a name that `prog/scriba/command-loop.chiral:2041` defines.
- **Redundancy.** Every declare writes its name a second time. Of the 1,719
  declares with a def in the same file, 359 are referenced by an earlier def,
  which is the forward reference a declaration exists for. The other 1,360 are
  referenced by nothing before their def: 782 are self-recursive, the other 578
  are non-recursive, and the four-item def covers both cases.
- **Hazard.** Nothing requires the def to follow, and nothing compares a later
  four-item def's type with the declared one. A declared, never-defined name
  passes `check`, and a program whose entry reaches it fails at `compile` as
  `call target not lowered: f`. Two
  declares of one name with different types are accepted.
  `(declare f (-> I64 I64))`, a caller `(f 3)`, then
  `(def f (-> Bytes I64) (lam (b) (blen b)))` compiles and segfaults: the caller
  was checked against the declared type and the body against the second one.
  One corpus file states a type twice this way, with equal types,
  `prog/demo/_recurse-ceiling.prog:8-9`.

### `data`

`(data Name (params) ctor...)`. Its slots are in section 6.

- **Count / exemplar.** 555 (`lib/capability/lincoll.chiral:26`).

### `extern`

`(extern name ty)`, a primitive bound at link time (`parse.chiral:659-680`,
`loader.chiral:464-491`).

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `name` | a `Sig` prim and an `SEnv` prim; charged `eh-extern` | parser, loader | unique among externs | yes | `extern name must be a symbol`; `(extern name ty)`; `extern redeclared: frob` |
| `ty` | the prim's type | elab, kernel | a type; a linear result needs a `=>` on the spine (E159); a `crossing-wraps` key needs `=>` (E204) | yes | `type of extern is not a type: frob`; ``extern mk returns the linear Gizmo through a pure `->` arrow: ...``; `extern declared pure routes to a crossing (use => not ->): put` |

- **Count / exemplar.** 131: 89 with a `=>` (`lib/capability/secret.chiral:36`),
  42 pure (`lib/prelude/prelude.chiral:59`).
- **Redundancy.** A profile's `(ports ...)` names the externs again.
- **Hazard.** An extern with no implementation passes the loader and is refused
  at compile as `extern does not lower: frob`. An extern and a def may share a
  name. Whether an extern crosses is read from its arrow, and for the 44
  `crossing-wraps` keys from a table too
  (`lib/lowering/tal/crossing-wraps.chiral:13-58`).

### `porttype`

`(porttype Name)` or `(porttype Name (n ty)...)` (`parse.chiral:688-710`).

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `Name` | a linear atom in `Sig` and an `SEnv` atom (`loader.chiral:497-506`) | loader | unique among atoms, and distinct from `I64`, `Str`, `Bytes` | yes | `porttype name must be a symbol`; `(porttype Name)`; `atom type redeclared: Gizmo` |
| `(n ty)...` | an empty data type with these index params, marked linear | loader | each `ty` is a type | no | `bad data parameter (want (P kind))` |

- **Count / exemplar.** 16: 15 bare (`lib/capability/secret.chiral:21`), 1
  indexed (`lib/ports/pool.port:13`).
- **Hazard.** A porttype and a data type may share a name. The parser's header
  calls the indexed form deferred (`parse.chiral:40-41`), and the handler at
  `:698-708` builds it.

### `target`

`(target name (require dname ty)...)` (`parse.chiral:783-849`).

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `name` | `TargetDef.name` | parser | unique among targets | yes | `(target name (require dname ty) ...)`; `target t redeclared` |
| `(require dname ty)` | one `(dname, Term)` pair in `TargetDef.reqs` | elab, kernel | `ty` is a type | at least one | `bad requirement (want (require name ty))`; `requirement main of target t is not a type` |

- **Count / exemplar.** 6 (`prog/demo/profile-duo.chiral:8`).
- **Hazard.** The requirements are read by nothing (section 3). Two requirements
  with one `dname` are accepted.

### `profile`

`(profile name clause...)`. Clauses are found by head, in any order
(`parse.chiral:855-1002`).

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `name` | `Profile.name` | parser | unique | yes | `(profile name (ports p...) (target t) [(memory d)])`; `profile p redeclared` |
| `(ports p...)` | `Profile.ports` | emit | each port is a declared extern that crosses | yes | `profile needs (ports p...)`; `profile port frob is not a declared extern`; `profile port + is pure; only crossings belong in the port set` |
| `(target t)` | `Profile.target` | parser | one symbol naming a declared target | yes | `profile needs (target name)`; `profile p names unknown target t` |
| `(memory d)` | `Profile.memory` | none | `d` is `linear` or `region` | no; default none | `profile p: unknown memory discipline heap (have linear, region)`; `profile memory clause is (memory discipline)` |
| `(total)` | `Profile.total` | totality | every def provably total | no; default false | `profile total clause is a bare (total)` |
| any other clause | refused | parser | none | absent | `unknown profile clause speed`; `bad profile clause` |

- **Count / exemplar.** 6 (`prog/demo/profile-duo.chiral:13`).
- **Redundancy.** The shape message leaves out the `(total)` clause it accepts.
- **Hazard.** A repeated clause keeps the last one silently (`:881-903`), so two
  `(ports ...)` clauses are accepted.

### `module`

`(module name (cat A|B|C) (alt upper|tal|metal))`, the module coordinate,
optional per file (`parse.chiral:1166-1222`).

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `name` | `ModKind.name` (`kernel.chiral:224-226`) | parser, loader | unique; equal to the provider's extent key; one per extent | yes | `module coordinate redeclared: m ...`; `module coordinate m is declared inside the extent of module n -- ...`; `module n declares a second coordinate inside one module extent ...` |
| `(cat X)` | a `KCat` (`kernel.chiral:101`) | loader | `(cat A)` refuses a module that binds an effectful extern (`loader.chiral:295-300`) | yes, second | `module m: unknown typeability category D (have A, B, C -- ...)`; `module m declared (cat A) -- correctness by proof -- but reaches the crossing frob ...` |
| `(alt X)` | a `KAlt` (`kernel.chiral:107`) | none | the value is in the closed list | yes, third | `module m: unknown altitude low (have upper, tal, metal)` |

A missing, reordered or malformed clause, or a string name, prints the whole
grammar: `(module <name> (cat A|B|C) (alt upper|tal|metal))`.

- **Count / exemplar.** 15 (`lib/crypto/chacha.chiral:15`): cat A 13, B 1, C 1;
  alt upper 14, tal 1.
- **Redundancy.** `alt` is read by nothing (`kernel.chiral:102-106`). The name
  repeats the file's path, which the provider already holds and checks it
  against.
- **Hazard.** The clauses are keyed and their order is fixed, so the key buys
  its name in the refusal and nothing in placement.

### `end-module`

`(end-module "key")`, written by the provider after each module
(`bin/chirality-resolve.sh:257`). It occurs 0 times in source.

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `"key"` | closes the open coordinate | loader | equals the open coordinate's name | yes | `(end-module "<module>")`; the extent-name refusal of `module` |

### `import`

`(import "key")`. The loader installs nothing for it (`parse.chiral:1303`), and
the providers read it.

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `"key"` | a dependency the provider resolves and concatenates ahead of the file | provider | the key resolves under `lib` or `prog` with one importable extension | yes | `chirality-resolve: no module 'no/such'`, followed by the roots and extensions searched |

- **Count / exemplar.** 1,263 (`lib/capability/lincoll.chiral:20`).
- **Hazard.** The loader accepts `(import)`, `(import 5)` and
  `(import prelude/string)` as no-ops. The shell provider finds imports with the
  regex `\(import "[^"]+"\)` after deleting whole-line comments
  (`bin/chirality-resolve.sh:115-116`), so `(import  "ports/ports")` with two
  spaces and `(import "ports/ports" x)` import nothing, and
  `(def f I64 1) ; (import "no/such")` imports from a comment. The native
  provider reads the file with the reader, takes an import with exactly one
  string argument, and treats an unreadable file as importing nothing
  (`lib/module/resolve.chiral:70-106`). By that code it imports the two-space
  spelling and ignores the comment, so the two providers disagree on two of the
  four probed spellings. Each silent case surfaces later as `unknown name put`
  or `unknown name str-split`. FD-67 names two parsers of one language that
  disagree as the differential class.

## 5. Expression and type forms

The parser dispatches ten heads at `lib/surface/parse.chiral:181-190` and reads
anything else as an application. Heads are contextual: `(lam (lam) lam)` is
accepted, and a local named `case` cannot be called. Each form becomes one of
the 13 `Surf` constructors (`lib/surface/surface.chiral:28-41`), which `elab`
lowers to `Core` (`:50-66`) and the loader to the de Bruijn `Term`
(`lib/module/loader.chiral:32-50`, `lib/surface/syntax.chiral:18-34`).

### Atoms

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| integer | `s-lit-i`, then `t-lit-i` of type `I64` | parser | none | n/a | none |
| string | `s-lit-s`, then `t-lit-s` of type `Str` | parser | none | n/a | none |
| symbol | `s-var`, resolved in the order local, primitive type, constructor, data type, global, prim (`surface.chiral:118-132`) | elab | the name resolves | n/a | `unknown name lenght` |

- **Count.** 98,874 symbols, 10,054 integers and 7,111 strings sit in
  expression and type positions.
- **Hazard.** The resolution order lets one namespace hide another without a
  word: a local hides a constructor (`(lam (none) none)` is accepted), and a
  constructor hides a global. `unknown name` names the symbol and says nothing
  of where it lives (PRB-104).

### Application `(head arg...)`

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `head` | a constructor or data-type head takes all the arguments at once (`c-con`, `c-tcon`); any other head is curried `c-app` (`surface.chiral:183-196`) | elab, kernel | a function, constructor or type former | yes | `empty ()`; `cannot apply a non-function` |
| `arg...` | positional arguments | kernel | each checks against its parameter | per arity | `type mismatch`; for a constructor `c wrong number of arguments (expected 2, actual 1)`; for a type `List wrong number of type parameters (expected 1, actual 2)` |

- **Count / exemplar.** 42,655 (`lib/capability/lincoll.chiral:32`).
- **Redundancy.** A polymorphic function takes its type argument by hand: 81
  globals open with `(0 A (type 0))`, and their 555 call sites in def bodies
  pass the type as the first argument, as `(reverse Sexp acc)` does at
  `lib/surface/sexp.chiral:245`. Leaving it out gives `type mismatch`. A
  constructor's type parameters are inferred from its fields
  (`lib/surface/data.chiral:174-178`).
- **Hazard.** Arguments are positional and unnamed. A wrong count and a wrong
  type read alike for a function, `type mismatch`
  (`lib/typing/diag.chiral:361`), with neither type (PRB-104).

### `(type n)`

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `n` | `s-type`, then `t-type n` | parser | an integer literal | yes | `(type level)` |

- **Count / exemplar.** 127, every one `(type 0)`
  (`lib/lowering/tal/erase.chiral:34`).
- **Hazard.** `(type -1)` is accepted.

### Arrows `(-> item... cod)` and `(=> item... cod)`

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `item` | a binder `(q name ty)` when it has three elements, a quantity token first and a symbol second (`parse.chiral:61-80`); otherwise a bare type at quantity `w` named `_` (`:437-441`) | parser, kernel | the domain is a type | at least one | `arrow needs at least a domain and codomain`; `pi domain is not a type` |
| `cod` | the innermost codomain; the head's effect bit lands on the innermost `Pi` only (`surface.chiral:100-106`) | kernel | a type; a `->` body performs no crossing | yes | `pi codomain is not a type`; `effectful application at a pure seat (use => not ->)` |

- **Count / exemplar.** 3,908 `->` and 803 `=>`
  (`lib/capability/lincoll.chiral:31`). Items: 8,536 bare, 378 binders (`0`
  164, `1` 211, `w` 3).
- **Redundancy.** `(=> A B C)` means `(-> A (=> B C))`: the effect belongs to
  the last arrow and is written at the head of the first.
- **Hazard.** An item's role is read from its shape. `(x I64)` without a
  quantity reads as the application of `x` and is refused `unknown name x`;
  `(2 x I64)` and `(W x I64)` give the same refusal, which mentions the
  quantity nowhere. A type former named `w` reads as a binder: with `(data w ...)`
  declared, `(-> (w I64 Str) I64)` is refused `pi codomain is not a type`.

### Binders `(q name ty)`

The one slot keyed by shape, shared by arrow items, `let` bindings and data
fields.

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `q` | `0`, `1` or `w`, read as 0, 1, 2 (`parse.chiral:50-56`), then a `Qty` (`kernel.chiral:1018-1019`) | kernel, `typing/qtt` | the binder is used that many times | no; omitted, `w` | `linear binder usage mismatch`; `function parameter of a linear type at quantity omega -- a linear parameter must be declared (1 x T)` |
| `name` | a binder name, erased in `Term`, used for dependent reference inside the arrow | elab | a symbol | yes | the item reads as a type |
| `ty` | the domain | kernel | a type | yes | `pi domain is not a type` |

- **Hazard.** A `0` binder used at run time is refused
  `linear binder usage mismatch`, naming linearity for an erased binder.
  `docs/definitions/syntax-evolution.md:31` reserves this slot for the grade
  vector, and `:80` says the implicit-argument marker lands in it too.

### `(lam (x...) body)`

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `(x...)` | one `c-lam` per name (`surface.chiral:218-221`); names only, with type and quantity taken from the expected `Pi` | parser | symbols | yes | `(lam (x ...) body)`; `expected a symbol` |
| `body` | the innermost body | kernel | checks against the expected `Pi` | yes | `cannot infer an un-annotated lambda`; `lambda checked against a non-function type`; `type mismatch` |

- **Count / exemplar.** 4,455 (`lib/capability/lincoll.chiral:32`); 2,194 take
  one parameter.
- **Redundancy.** Under a def each name is written here and its type and
  quantity in the arrow (section 4, `def`).
- **Hazard.** `(lam (x x) x)` is accepted. `(lam () 1)` is refused
  `type mismatch`. A typed parameter, `(lam ((x I64)) x)`, is refused
  `expected a symbol`.

### `(let binding body)`

`(let (x v) body)`, `(let (q x v) body)` or `(let ((x v)...) body)`. The parser
tells them apart by whether the first element is a list
(`parse.chiral:251-270`).

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| binding name | a `c-let`; bindings are sequential, each value seeing the names before it (`surface.chiral:224-240`) | elab | a symbol | yes | `bad let binding` |
| binding `q` | the let's quantity, by the QTT let rule | kernel | usage matches | no; omitted, `w` | `let binder usage mismatch`; `let binds a linear value at quantity omega -- a linear value must be bound at 1` |
| binding value | the bound term | kernel | inferable | yes | kernel refusals |
| `body` | the let body | kernel | one expression | yes | `(let binding body)` |

- **Count / exemplar.** 1,574: 817 single (`lib/capability/session.chiral:33`),
  755 list (`lib/crypto/chacha.chiral:52`). Bindings: 1,754 without a quantity,
  14 at `1` (`prog/demo/duo.chiral:11`), 0 at `0`.
- **Redundancy.** One binding has two spellings, `(let (x v) b)` and
  `(let ((x v)) b)`; 684 list forms hold a single binding.
- **Hazard.** The binding has no type slot: `(let (x I64 1) x)` is refused
  `bad let binding`. A binding is non-recursive, and `(let (x x) 1)` gives
  `unknown name x`.

### `(case scrut arm...)` and its patterns

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `scrut` | the `c-case` scrutinee | kernel | of a data type | yes | `(case scrut branch...)`; `case scrutinee has a non-data type` |
| arm `(pat body)` | one `carm`, or the default | parser | two elements | none at parse | `bad case branch (want (pattern body))` |
| `pat` as `_` | the default branch (`parse.chiral:318`) | kernel | none | no | none |
| `pat` as `C` or `(C)` | a nullary arm | kernel | `C` is a constructor of the scrutinee's type, matched once | n/a | `branch names a non-constructor`; `duplicate case branch` |
| `pat` as `(C v...)` | an arm binding names by position | kernel | the name count equals the field count (`kernel.chiral:1276-1288`) | n/a | `branch binds the wrong number of names`; `expected a symbol` for a nested pattern; `bad case pattern` for an integer |
| coverage | written nowhere | kernel | every constructor covered, or a default | n/a | `non-exhaustive case` (`kernel.chiral:1332`) |

- **Count / exemplar.** 7,388 (`lib/capability/lincoll.chiral:41`). Patterns:
  7,374 lists, 6,557 bare symbols, 615 `_`
  (`lib/evidence/test-floor.chiral:112`), 688 nullary in parens
  (`lib/capability/session.chiral:39`). 2,033 cases match on `true` and
  `false`.
- **Redundancy.** A nullary pattern has two spellings, `none` and `(none)`.
  Pattern names rebind fields by position, and the field names the data
  declaration states play no part.
- **Hazard.** `_` may come first or twice, and the last one wins
  (`parse.chiral:319-320`); a `_` after full coverage is accepted. A variable
  pattern, `(x 1)`, reads as a constructor named `x`.
  `prog/scriba/window.chiral` writes nested patterns (`:72`, `:158`) and
  integer ones (`:218`), is imported by nothing, and is refused
  `expected a symbol`. `lib/surface/data.chiral:39` computes the missing
  constructor (`cov-missing`); the shipping path uses the kernel's own check
  and prints none (PRB-104).

### `(do step... result)` and `(<- x e)`

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `(<- x e)` (`parse.chiral:100-121`) | `c-let 1 x e` (`surface.chiral:270-276`) | elab, kernel | `x` used exactly once | no | `let binder usage mismatch`; `a do-bind (<- x e) cannot be the last step of a do` |
| plain step | `c-let 1 #u e`, then a case on `unit` (`:277-284`) | elab, kernel | the step's type has the one constructor `unit` | no | `case scrutinee has a non-data type` |
| `result` | the last step | kernel | one expression | yes | `(do e1 ... result)` |

- **Count / exemplar.** 444 (`lib/capability/secret.chiral:55`): 928 plain
  steps, 2 binds.
- **Redundancy.** `do` with `<-` overlaps `let` at quantity 1.
- **Hazard.** PRB-105: every bind is linear, every plain step must return
  `Unit`, and the refusals name a `let` and a `case` the writer never wrote. A
  malformed bind, `(<- x)`, falls through to application and is refused
  `unknown name x`.

### `(cond (test body)... (else body))`

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| clause `(test body)` | a nested `case` on `true` and `false` (`surface.chiral:291-304`) | elab, kernel | `test` is a `Bool` | at least one clause | `bad cond clause`; `case scrutinee has a non-data type` |
| `(else body)` | the last `false` branch (`parse.chiral:368`) | elab | present, and last | yes | `(cond): last clause must be (else body) for exhaustiveness`; `(cond): else must be the last clause`; `(cond) needs at least one clause` |

- **Count / exemplar.** 78 (`lib/crypto/chacha.chiral:33`), with 233 test
  clauses and 78 `else`.
- **Redundancy.** `cond` is `case` on `Bool`, which the corpus writes 2,033
  times against 78.
- **Hazard.** A non-`Bool` test names a `case` the writer never wrote, the
  shape PRB-105 records for `do`.

### `(the ty e)`

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `ty` | the `c-ann` type (`surface.chiral:164-168`) | kernel | a type | yes | `(the ty e)`; `annotation is not a type` |
| `e` | the annotated term | kernel | has the type | yes | `type mismatch` |

- **Count / exemplar.** 200 (`lib/evidence/ddc.chiral:116`); 119 annotate
  `nil`.
- **Hazard.** `(the 1 I64)`, the order swapped, gives
  `annotation is not a type`. The type-first order follows Common Lisp and was
  kept on review (`docs/definitions/syntax-evolution.md:118-122`).

### `(refine base (op operand)...)`

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `base` | the `t-refine` base | kernel | `I64` | yes | `(refine base atoms)`; `scaffold refinements are over I64 only` |
| `op` | a `SymOp`: `>=`, `>`, `<=`, `<`, and every other symbol becomes `!=` (`loader.chiral:21-25`) | loader, kernel | none | yes | none |
| `operand` | a `Term` | kernel | an `I64` literal or a bare variable | yes | `bad refinement atom (want (op operand))`; `bad refinement atom`; `refinement operand must be a constant or a bare variable` |
| the atoms together | a conjunction each caller proves | kernel | provable at each call | zero or more | `cannot prove refinement` |

- **Count / exemplar.** 11 forms, 16 atoms (`>` 7, `<` 5, `>=` 4), at
  `lib/memory/mem-linear.chiral:27` and `lib/ports/sock.port:69`.
- **Hazard.** The operator slot turns every unknown spelling into `!=`.
  `(refine I64 (= 0))` accepts 5 and refuses 0, the opposite of how it reads,
  and `(frob 0)` is accepted the same way. That is FD-66's CWE-480, the
  incorrect operator, made by the loader. `(refine I64)` with no atoms is
  accepted.

### Ruled 2026-10-01 and built nowhere

Both rulings sit in `records/author-calls.md:538`, the row for `checker-core/CK20`
and `enforcement/N25`. The parser has no slot for either, and each probe is
refused at elab.

| form | ruled shape | today |
|---|---|---|
| effect row | a leading `(row ...)` item of an arrow, `row` reserved only there, kind `Row`: `(=> (row put (st s) e) (1 h (Buf s)) I64)` | `unknown name row` |
| linear arrow | `->1` and `=>1`, the quantity on the arrow head: `(=>1 (row put) (1 h Fd) I64)` | `unknown name ->1`; `unknown name =>1` |

## 6. Data declarations

`(data Name (params) ctor...)`, elaborated by `elab-data-decl`
(`lib/surface/parse.chiral:1357-1376`) and installed by `load-data-group`
(`lib/module/loader.chiral:601-608`).

| position | becomes | layer | obligation | required | refusal when wrong |
|---|---|---|---|---|---|
| `Name` | a `t-tcon` former and a `DataDecl` in `Sig` (`lib/surface/data.chiral:33`) | elab, loader | unique among data | yes | `data name must be a symbol`; `(data Name ...)`; `data redeclared: D` |
| `(params)` | a list | parser | a list | yes, may be `()` | `(data Name (params) ctors)` |
| param `(P kind)` | a kind `Term`; `P` becomes a de Bruijn position in field types | loader | `kind` is a type (`loader.chiral:518-527`) | per param | `bad data parameter (want (P kind))`; `data parameter is not a type` |
| ctor `(cname field...)` | a `Ctor`, a `t-con` former, and an `SEnv` entry pointing at its home type | parser | a symbol head | zero or more | `bad constructor`; `empty constructor`; `constructor needs a name` |
| field `(name ty)` or `(q name ty)` | a `Field` (`data.chiral:31`) | parser | two or three elements | per field | `bad field (want (name ty) or (q name ty))` |
| field `ty` | the field's `Term` type | loader, kernel | a type, strictly positive in `Name` (`data.chiral:258-294`) | yes | `unknown name Foo`; `field type is not a type`; `not strictly positive: x` |
| field `q` | `0`, `1` or `w`; default `w` | kernel | a field of linear type has `q` = 1 (`loader.chiral:541-542`) | no | `linear field declared non-1: s` |
| coverage, positivity, linearity | written nowhere | kernel | on each later `case` and each field | n/a | section 5 |

Every data refusal from the parser prints behind `data-group: `, because data
elaborates before the linear pass (`lib/typing/diag.chiral:515`).

**What `ctor-fields` gives.** `ctor-fields decl cn`
(`lib/typing/kernel.chiral:1026`) returns the constructor's `(List Field)`,
each `(field q fname fty)` in declared order, or none for an unknown name. Its
two consumers read the length and the types: constructor checking (`:1080-1087`)
and case-branch arity (`:1276-1288`). Field names reach diagnostics only
(`kernel.chiral:1041`, `loader.chiral:539`, `:542`). Construction and patterns
are positional.

- **Count / exemplar.** 555 data (`lib/capability/lincoll.chiral:26`): 531 with
  `()` params, 20 with one, 4 with two (`lib/prelude/map.chiral:19`). Of 28
  params, 19 are `(type 0)` and 9 are value-indexed
  (`lib/memory/mem-region.chiral:23`). 1,295 constructors, 321 nullary. 1,975
  fields: 1,860 without a quantity, 115 at `1`
  (`lib/capability/lincoll.chiral:28`), 0 at `0` or `w`.
- **Redundancy.** Field names are written and read by messages alone; each
  `case` arm renames the fields by position. 19 of 28 params write `(type 0)`,
  the kind every type parameter in the corpus has.
- **Hazard.** Each of these is accepted: two constructors of one name in one
  type (the second is unreachable, and one arm covers both); two fields of one
  name; a constructor name another type already uses, after which the later
  type owns the name everywhere, so `(data D () (some (x I64)))` makes
  `(some 1)` at `(Maybe I64)` fail far away as
  `some checked against a different data type`; a data type and a def or a
  porttype of one name; a type with no constructors. A type named like its own
  constructor, `(data c () (c))`, makes `c` in a type slot resolve to the
  constructor: `definition type is not a type`. The name slots: PRB-102.

## What the extraction shows

Observations for the review. The author decides what changes.

1. **Slots are positional.** The tables hold 64 slots a writer fills: 23 in the
   toplevel forms, 8 in `data`, 33 in expression and type forms. 10 are found
   by a keyword: the four profile clauses, `cat` and `alt`, `require`, `<-`,
   `else` and `_`. 3 are found by shape: the binder quantity in arrows, lets and
   fields. The other 51 are found by position alone, among them every name,
   type and body slot of `def`, `declare`, `data`, `extern`, `lam`, `let`,
   `case`, `the`, `refine` and application. `def` takes the meaning of its third
   item from its item count. `module` is the one form whose header records the
   measured cost of a positional slot (`lib/surface/parse.chiral:1014-1024`).
2. **Refusals name little.** Of 194 probe refusals, 58 name the offending token
   or declaration, 66 print the expected shape or name the slot, and 70 name
   neither. 14 of the 58 name the wrong cause: a missing quantity reported as
   `unknown name x`, a repeated def as a collision with the runtime, a missing
   body as a missing declare, a malformed import as `unknown name put`. 101
   refusals were raised inside a def's type or body; 0 of them name the def and
   0 carry a position, and 13 are the bare `type mismatch`. Reader errors carry
   a position in the blob or none.
3. **Five places accept a wrong form silently.** The refine operator maps
   every unknown symbol to `!=`. A declare and a later four-item def may
   disagree on the type, and the program crashes. An integer literal wraps. An
   import written with a symbol, two spaces or an extra item is dropped. A
   constructor name reused by a later type moves to that type. The import cases
   are the shell provider's, the one `bin/chirality` runs. Each is accepted
   where it is written and fails somewhere else, or never.
4. **Information is written twice.** 8,320 `lam` parameter names sit apart from
   their types in the arrow, and 233 defs write the names in both places. The
   parameter count appears in both. 1,731 declares restate their def's name,
   and 1,360 of them precede a def that nothing references earlier. 555 call
   sites pass a type argument by hand. 119 `the` forms annotate `nil`. 19 data
   params write `(type 0)`. 1,975 field names are written and read by messages
   alone.
5. **Forms overlap.** `cond` and `case` on `Bool`, 78 against 2,033. `do` with
   `<-` and `let` at quantity 1, with 2 binds in the corpus. `(def name ty body)`
   and `declare` plus `(def name body)`. A single `let` binding in two
   spellings, 817 and 684. A nullary pattern as `none` and as `(none)`. `the`
   and a def's own type as the two places an annotation goes.
6. **Most slots carry no type.** Every name slot is a symbol compared by bytes:
   def, declare, data, constructor, field, parameter, pattern variable, `let`
   and `<-` names, extern and porttype names, target, profile and requirement
   names, and ports. The refine operator is a symbol with a fallback. The
   `import` key is a string the loader never reads, and the `end-module` key is
   compared with the open coordinate's name. The
   closed-list values `cat`, `alt` and `memory` are checked against their lists,
   and `cat` and `alt` become typed sums (`kernel.chiral:101`, `:107`). The
   entry's type and a target's requirements are types checked against nothing.
7. **Required fields are already declared the way `data` does it, in four
   places.** The 13 `Surf` constructors and their six sub-records
   (`lib/surface/surface.chiral:28-47`) declare every expression form as a
   record with named fields, `(s-lam (params (List Str)) (body Surf))` among
   them, and `parse.chiral:163-441` is a hand-written reader for each.
   `TargetDef`, `Profile` and `ModKind` (`kernel.chiral:59-61`, `:224-226`) are
   the records `target`, `profile` and `module` build, and their readers are
   hand-written beside the closed error sums `MfErr` (18 arms) and `KErr` (7
   arms). `data` is the one user-facing form whose fields are written
   `(name Type)`. `lib/lowering/tal/target-linux.manifest` is a file whose
   content is one value of the declared type `SysReg`. For every form the record
   exists and the reader is written by hand, which is the gap
   `.planning/SYNTAX-REWORK.md` §The requirements structure names:
   "declaration to reader is total for a record".
8. **Kinds and purposes go unchecked above the form.** 0 of 5 extensions have
   their content checked, and a `lam` passes under each. The entry is a name
   with no type, and `(def compile-main Str "x")` compiles. Of the four profile
   clauses, `ports` and `total` have consumers, `target` is looked up once, and
   `memory` is read by nothing. Target requirements, `module`'s `alt` and
   `MAX-DEPTH` are stored and read by nothing.
9. **The binder and the arrow head carry every pending change.** The binder
   quantity `(q x T)` is reserved for the grade vector and for implicit
   arguments (`docs/definitions/syntax-evolution.md:31`, `:80`). The arrow head
   carries the effect bit today, and the 2026-10-01 rulings put `->1` and `=>1`
   on it and a `(row ...)` item after it. The grade vector, the implicit
   marker, `->1`/`=>1` and the row item are all unbuilt. The
   quantity token `w` is also a legal symbol, so the binder shape and a
   two-argument type application overlap.

## What the extraction left open

- The 555 explicit type arguments are counted by call head: a call counts when
  its head names one of the 81 globals whose type opens with `(0 A (type 0))`,
  and local shadowing is ignored.
- `unexpected end of input` was reached by no probe; through `read-all` it may
  be unreachable.
- The search for grammar overlaps stopped at the probed ones: the `w` binder,
  the `let` binding shapes and the arrow items.
- How many corpus files compile today is unmeasured.
  `prog/scriba/window.chiral` and `prog/demo/_recurse-ceiling.prog` are refused.
- Which provider a given caller runs: `bin/chirality` sources the shell one, and
  the native one is imported by `lib/evidence/test-floor.chiral` and
  `prog/resolve.prog`. The native provider's reading of the four import
  spellings comes from its code; the probes ran the shell one only.
