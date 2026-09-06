---
node: records-tooling-classification
layer: navigation
related: [records/README, records/gate-audit, goals/enforcement, arcs/enforcement-arc, arcs/independent-judgment-arc, arcs/text-tools-arc, arcs/zero-python-arc, goals/self-tooling, open-edges, status-ledger, index]
status: current
updated: 2026-09-04
---

# Tooling classification

Every call to a classic Unix tool in the shell and Python tooling surface, sorted
into buckets with a reason. **Classification only. Nothing was converted and
nothing outside this file was edited.**

This is enforcement requirement 5's first job. The goal is
[[goals/enforcement]]; the arc is [[arcs/enforcement-arc]] requirement 5; the
coverage table a bucket-2 claim rests on is [[arcs/text-tools-arc]]; the arc that
owns the independence criterion this classification needs is
[[arcs/independent-judgment-arc]], and it is not started.

Row format, states and the rules for adding, changing and retiring a row are in
[[records/README]]. Prefix is `TC`.

Measured 2026-09-04 against `dda00b9`, with `lib/`, `prog/`, `bin/` and `tools/`
clean in `git status`. `tools/test/run-tests.sh` was not run.

## Scope, and what a call site is

The corpus is every shell file under `tools/` and `bin/` plus every Python file
under `tools/`. A **call site** is one invocation of a classic tool in command
position: the first word of a command segment, after leading `VAR=value`
assignments and after `time`, `xargs`, `env` and `timeout`. Comments, single-
quoted spans, heredoc bodies and double-quoted text are excluded, and a `$(...)`
nested inside double quotes is scanned.

⚑ **This is not the number the goal tier carries.** The figures in
[[goals/enforcement]] and [[arcs/enforcement-arc]] are word-occurrence counts.
Reproduced here: `grep -ohE '\bgrep\b' tools/test/*.sh | wc -l` returns 149,
where the scan above finds **119** invocations in the same files. The gap is
comments, the scratch filenames `g5.awk` and `g9.awk`, and the word `awk` inside
prose describing the tool the native matcher replaces. TC-02 carries it.
⚑ *This sentence read 122 until 2026-09-04 and disagreed with this file's own
per-tool table by 3.* That table puts `grep` at 123 sites over the whole
surface, and the four sites outside the gate tier are `bin/chirality:171`,
`bin/chirality-resolve.sh:116` and `:139`, and
`tools/prose-lint/prose-lint.sh:206`, which leaves 119. TC-14.

The scanner was a session script and is not tracked. Its rule is stated above so
the count can be re-taken.

## The surface, measured

| tier | files | lines |
|---|---|---|
| gate tier, `tools/test/*.sh` | 18 | 6,915 |
| `tools/prose-lint/prose-lint.sh` | 1 | 223 |
| CLI and resolver, `bin/chirality` + `bin/chirality-resolve.sh` | 2 | 526 |
| Python under `tools/` | 9 | 4,786 |
| **outside the language** | **30** | **12,450** |
| native `.prog` tooling | 5 | **782** |

The 12,450 reproduces exactly. The 782 does not: the goal tier says **390**, and
390 counts `prog/test-runner.prog` at 134 and `prog/prose-lint.prog` at 256 while
omitting `prog/paren-audit.prog` at 244, `prog/resolve.prog` at 104 and
`prog/wield.prog` at 44. **782 is the authoritative figure.** TC-01 carries it.
`prog/compiler.prog` is the compiler's entry rather than tooling and is in
neither number.

Two framing corrections fall out of the same measurement. `bin/chirality` is
bash with no extension, so the shell surface is **21 files at 7,664 lines** where
a `*.sh` glob reports 20 at 7,444; the 12,450 already counts its 220 lines inside
the 526, so no arithmetic moves. And the Python tier is **nine** files where two
documents say seven (TC-11).

⚑ The library modules those five entries import are in neither figure.
`lib/text/matcher.chiral` is **602 lines** and exists to serve
`prog/prose-lint.prog`. On the same basis as 782 plus that one module, native
tooling reads **1,384**. TC-05 carries the line count. Seven documents recorded
it as 533; three were repointed at `8b65108` and four still carry the old
figure.

## The property, and the criterion that is owed

The property that matters is one sentence. **A judge must not be derived from the
artifact it judges.**

`lib/evidence/ddc.chiral` offers a criterion for it: `:30` defines `Prov` as
`(language, toolchain, author, epoch)` and `:68` defines `leg2-disjoint?`, which
demands that both the language and the toolchain differ. Read as a law, that
criterion says no chirality judge can ever be independent of chirality source,
and the whole gate tier is a permanent exemption.

⚑ **That reading is wrong, and the file says so itself.**
`lib/evidence/ddc.chiral:207-213` records that `leg2-disjoint?` is right for the
threat it was written against and wrong for this one: judgment cores are all
chirality-native so every quorum would come back `ddc-bad-quorum`, **`Prov` has
no FORMULATION axis**, the threat moved from a backdoored toolchain to a shared
mistake in how the rule set was encoded, and `ddc-fold` compares bytes where
different formulations agree on a verdict. `docs/definitions/open-edges.md:672`,
edge 21, carries the same three points at length and calls the repoint an open
edge with no element minted. `:701` adds that the module gates nothing today.

Language and toolchain are a **proxy** for the property, chosen because Wheeler's
threat is a backdoored compiler. Chirality is modular by design, and modularity
supplies real independence axes inside one language. Core-minimal is not the only
runtime.

### The axes, and what the tree already has for each

| axis | what it supplies | what is in the tree |
|---|---|---|
| **formulation** | the missing `Prov` field. A judge encoding the rule differently from the compiler | `lib/lowering/tal/eval.chiral`, 187 lines, **zero importers**: the reference tal interpreter, the Category-A oracle that defines what checked programs mean (`:1-2`). Its closure is `prelude/prelude` and `lowering/tal/ssa` only. `lib/typing/kernel-core.chiral`, 60 lines, **zero importers**, holds `JForm`, the judgment's own decomposition |
| **profile and port set** | a named module set over a frozen port set. A comparator under a minimal profile is not the compiler's runtime | [[banks/profile]] §1: a profile is a name, a manifest, a frozen port set and a target, and its validity is a type-checking question. `tools/test/profile-target.sh` gates the form at 31 rows |
| **runtime** | a process at system scale, changing as configured. There is no privileged runtime beneath everything | [[banks/runtime]] §1, quoting [[vocabulary]] |
| **import-closure disjointness** | the axis that mechanically stops a mutation in `lib/` from reaching the judge | already computed in bash: `tools/test/pretty.sh:552-573` walks a module's transitive imports and gates G13 on the result, with M17 as its run mutant |
| **building binary** | the promoted `bin/chirality-bin` against the artifact under test | `tools/test/mutant.sh:110-116` builds each mutant compiler with `$MUT_B1`, the promoted binary, so a judge compiled ahead of the matrix is not built by the mutant |

### The sorting rule this file uses

- **1a. Genuinely irreducible.** Something has to run first, or the judgment's
  subject sits inside every available judge's own closure, so no axis covers it.
- **1b. Convertible under a stated independence discipline.** The call is a
  judgment today and a named axis supplies the independence. Owed work with a
  named path.
- **2. HAS-A-COMPOSITION.** The call is not a judgment, and
  [[arcs/text-tools-arc]] records the composition as built.
- **3. NEEDS-A-COMPOSITION.** The call is not a judgment, and the primitive does
  not exist.

⚑ **1b is owed work with a named path, and that path is blocked in a chain.**
`docs/arcs/independent-judgment-arc.md:92` rows **J1**, the distinctness
criterion written down, as `not started`, and `:100` says J1 comes first because
requirement 2 cannot be judged without it. The `ddc` repoint is
`docs/definitions/open-edges.md` edge 21 with **no element minted**. And
`docs/arcs/independent-judgment-arc.md:107` records that the arc has **no
reserved element block, so nothing here can be minted**, which is a standing
author call. Nothing in 1b can honestly convert before J1 is written. TC-12.

## Burn-down

| bucket | sites | share |
|---|---|---|
| 1a irreducible | **15** | 3.0 % |
| 1b convertible under a stated discipline | **288** | 56.9 % |
| 2 has-a-composition | **145** | 28.7 % |
| 3 needs-a-composition | **58** | 11.5 % |
| total | **506** | |

Owed work is **491 of 506**, and only 15 sites are outside reach on any axis.

Split by tier:

| tier | sites | 1a | 1b | 2 | 3 |
|---|---|---|---|---|---|
| gate tier, `tools/test/` | 463 | 15 | 288 | 116 | 44 |
| resolver, CLI, `prose-lint` | 43 | 0 | 0 | 29 | 14 |

**Every call site outside the gate tier is owed work with a built composition or
a named missing one.** None of it is a judgment at all. The gate tier is 93 % of
the shell surface by line and 91 % of the call sites; 288 of its sites are
judgments waiting on a criterion nobody has written, and 15 are irreducible.

### Per file

| file | lines | sites | 1a | 1b | 2 | 3 |
|---|---|---|---|---|---|---|
| `bin/chirality-resolve.sh` | 306 | 9 | 0 | 0 | 6 | 3 |
| `bin/chirality` | 220 | 10 | 0 | 0 | 5 | 5 |
| `tools/prose-lint/prose-lint.sh` | 223 | 24 | 0 | 0 | 18 | 6 |
| `tools/test/pretty.sh` | 582 | 85 | 0 | 66 | 16 | 3 |
| `tools/test/row.sh` | 761 | 53 | 0 | 37 | 13 | 3 |
| `tools/test/doc.sh` | 478 | 48 | 0 | 37 | 7 | 4 |
| `tools/test/render-doc.sh` | 554 | 42 | 0 | 29 | 9 | 4 |
| `tools/test/face.sh` | 706 | 41 | 0 | 30 | 5 | 6 |
| `tools/test/diag.sh` | 319 | 40 | 0 | 36 | 2 | 2 |
| `tools/test/matcher.sh` | 565 | 32 | **15** | 0 | 11 | 6 |
| `tools/test/arity.sh` | 483 | 30 | 0 | 19 | 8 | 3 |
| `tools/test/run-tests.sh` | 373 | 15 | 0 | 4 | 9 | 2 |
| `tools/test/syscall-manifest.sh` | 169 | 14 | 0 | 4 | 9 | 1 |
| `tools/test/transport.sh` | 204 | 14 | 0 | 0 | 13 | 1 |
| `tools/test/crypto.sh` | 402 | 11 | 0 | 10 | 0 | 1 |
| `tools/test/tal-check.sh` | 474 | 11 | 0 | 9 | 1 | 1 |
| `tools/test/linear-mint.sh` | 368 | 9 | 0 | 2 | 6 | 1 |
| `tools/test/mutant.sh` | 257 | 7 | 0 | 3 | 2 | 2 |
| `tools/test/check-cli.sh` | 64 | 4 | 0 | 1 | 2 | 1 |
| `tools/test/profile-target.sh` | 125 | 4 | 0 | 1 | 2 | 1 |
| `tools/test/map-integrity.sh` | 31 | 3 | 0 | 0 | 1 | 2 |

### Per tool

| tool | sites | 1a+1b | 2 | 3 |
|---|---|---|---|---|
| `grep` | 123 | 111 | 12 | 0 |
| `sed` | 70 | 41 | 29 | 0 |
| `tr` | 50 | 13 | 37 | 0 |
| `awk` | 48 | 42 | 6 | 0 |
| `cat` | 41 | 19 | 3 | 19 |
| `wc` | 36 | 16 | 20 | 0 |
| `head` | 34 | 0 | 34 | 0 |
| `cmp` | 29 | 29 | 0 | 0 |
| `dirname` | 21 | 0 | 0 | 21 |
| `sort` | 18 | 16 | 2 | 0 |
| `diff` | 7 | 0 | 0 | 7 |
| `od` | 6 | 6 | 0 | 0 |
| `sha256sum` | 5 | 5 | 0 | 0 |
| `readlink` | 5 | 0 | 0 | 5 |
| `cut` | 4 | 3 | 1 | 0 |
| `find` | 4 | 0 | 0 | 4 |
| `tail` | 2 | 2 | 0 | 0 |
| `basename` | 2 | 0 | 0 | 2 |
| `paste` | 1 | 0 | 1 | 0 |

The four tools the arc names, `grep`, `sed`, `sort` and `awk`, total 259 sites:
210 are judgments (7 of them 1a) and **49 are owed with a built composition**.

## Bucket 1a: irreducible, 15 sites

All fifteen are in `tools/test/matcher.sh`, and the reason is one sentence: its
subject is `lib/text/matcher.chiral`, which is the module any matcher-based judge
would itself be built from.

| call | sites | which axis fails |
|---|---|---|
| `sed -i` mutating `lib/text/matcher.chiral` and `prog/prose-lint.prog`, with `cmp -s` as the stale-anchor guard (`:154`, `:156`, `:172`, `:174`) | 4 | closure disjointness. `lib/text/matcher.chiral` imports `prelude/prelude`, `prelude/list`, `prelude/ord`, `prelude/string` and nothing else, so a matcher-based mutation engine's closure contains the module it is mutating |
| the awk differential oracles `FENCE_AWK` and `awk_totals` (`:252`, `:433`, `:443`, `:495`) | 4 | formulation. [[arcs/text-tools-arc]] REQUIREMENT 4 is that each replacement is verified **against the tool it replaces on the same inputs**. Grading the matcher with the matcher compares it with itself |
| `fld`, the field extractor over the fixture's own output (`:181`) | 1 | closure disjointness, same module |
| the verdict compares `cmp -s` on G5, G9 and M11 (`:475`, `:498`, `:519`, `:520`) | 4 | closure disjointness, same module |
| the fixture heredoc and the mutant needle count (`:451`, `:543`) | 2 | closure disjointness, same module |

⚑ **Nothing else in the tree is in this position, and it was checked rather than
assumed.** The mutation targets across all eighteen gate scripts are
`lib/protocol/render.chiral` 15, `lib/surface/pretty.chiral` 12,
`lib/typing/diag.chiral` 5, `lib/protocol/apc.chiral` 2, `lib/typing/qtt.chiral`
1, `lib/text/matcher.chiral` 1 and `lib/prelude/doc.chiral` 1. **No mutant
targets `lib/prelude/prelude.chiral`**, the one module every judge must import.
The three mutants that touch `lib/prelude/string.chiral`
(`tools/test/doc.sh:394`, `tools/test/pretty.sh:486`, `tools/test/row.sh:755`)
each **append** a colliding definition to test redeclare refusal and change no
existing behaviour, so a matcher-based judge importing `prelude/string` behaves
identically under them. Closure disjointness is the check that would say so
mechanically instead of by this paragraph.

### Irreducible, and outside the census

Two things are outside the language for reasons no axis touches, and neither
appears in the 506.

- **Process control.** Every gate row's core move is to run a binary, capture its
  stderr and read its exit code, under `(ulimit -s unlimited)`.
  `lib/ports/process.port` declares `exit`, `halt`, `mmap`, `mprotect`, `signal`
  and `heap-allocated` and **no spawn-and-wait**; the only spawn in the tree is
  `lib/ports/pty.port:47` `spawn-in-pty`, which is pty-specific. This is a
  missing crossing rather than a permanent exemption, and it is not classified
  here because it is shell syntax rather than a classic-tool call.
- **The bootstrap seed.** Something must produce the first binary. This binds the
  seed step only. The tree ships a promoted `bin/chirality-bin`, so steady state
  is not the seed.

## Bucket 1b: convertible under a stated independence discipline, 288 sites

Each group names the axis that supplies the independence and what has to exist
before the conversion is honest. **Every row is blocked behind J1.**

| group | sites | axis | composition | owed first |
|---|---|---|---|---|
| the source census that is a gate row: `grep -RIn`/`-c` over `lib/` and `prog/`, with `wc -l` and `sort -u` folding it | 111 `grep`, 16 `wc`, 16 `sort` | import-closure disjointness. A judge whose closure excludes the phase's mutation targets cannot be moved by them | `find-all` + `filter` + `length` + `list-sort`, built, E173 slice 1 and E152 | J1; a closure check run as a gate row, which `pretty.sh:554-573` already prototypes for one module |
| the refusal-message check, `grep -q -- "$want_msg"` on compiler stderr | inside the 111 above | building binary. A judge compiled by the promoted `bin/chirality-bin` before the matrix starts is not built by the mutant | `find-all` + `filter`, built | J1; and the judge's build pinned and recorded, which `mutant.sh:110-112` already does for the compiler under test |
| the reducers and extractors: `fld`, `blk`, `SGR_AWK`, `SCREEN_AWK`, `ARITY_AWK`, `judg_arms` | 42 `awk`, 6 `od`, 3 `cut`, 2 `tail` | formulation. A reducer over emitted bytes shares no rule encoding with the emitter | `find-all` over spans plus `foldl`, built; `od` wants a byte-render | J1; a byte-render composition |
| the mutation engine: `sed -i` applying a mutant, `cmp -s` refusing a stale anchor, `cmp -s` against a golden | 41 `sed`, 29 `cmp`, 13 `tr` | building binary plus closure disjointness. The engine is built ahead of the tree it mutates | literal search, occurrence count and replace are `find-all` + `length` + `str-replace`, all built. `cmp` is `bytes=?`, `lib/evidence/ddc.chiral:54` | J1; a file-write crossing for the mutated copy |
| the golden pins, `sha256sum` against a hex constant | 5 | building binary, plus a content hash whose closure excludes the pinned subject | **not built.** `lib/protocol/apc.chiral:126-130` is FNV-1a-64 and not cryptographic; BLAKE2s is N1 slice 3 | J1; N1 slice 3 |
| the fixture the compiler under test consumes, `cat` heredoc | 19 | building binary. A fixture writer built by a pinned binary is not the artifact under test | a file-write crossing | J1; a file-write crossing |

⚑ **`crypto.sh` is the clearest 1b case in the tree, and the axis is closure
disjointness.** `tools/test/crypto.sh:12-15` says every row compares bytes a
compiled fixture prints against RFC 8439 constants held in bash, so a mutant
cannot pass by rechecking its own arithmetic. Its two mutants target
`lib/crypto/chacha.chiral:297` and `lib/crypto/poly1305.chiral:380`. A comparator
holding the RFC vectors in a chirality module whose closure excludes `lib/crypto/`
is disjoint from its subject on the axis that matters, and it is a stronger
statement than "held in bash" because the disjointness is checkable rather than
asserted. Ten of its eleven sites are 1b.

⚑ **`mutant.sh`'s substitution has a built composition and contributes almost no
call sites, which is why it reads as harness.** `tools/test/mutant.sh:41-43` says
the search and replace is pure bash parameter expansion so the tool that audits
the gates does not reach for the floor the gates exist without, and
`:74-90` is that code: `mut_count` counts occurrences, `mut_sub` replaces them.
Neither invokes a classic tool, so the engine appears here only as one `cat`
(`:72`, `mut_slurp`) and two `cmp` (`:125` `mutant_differs`, `:146` the
fixpoint). The job itself is exactly the coverage table's `grep -c` row,
`find-all` + `length`, plus `str-replace` over spans, and
`lib/text/matcher.chiral` sits at ENFORCED in [[status-ledger]] with Phase 19
behind it. **So the parameter-expansion argument buys independence that a stated
discipline would buy better, and the composition is already built.** What is
owed beyond J1 is a file-write crossing and the engine's build pinned to
`bin/chirality-bin`.

## Bucket 2: HAS-A-COMPOSITION, 145 sites

Not a judgment. [[arcs/text-tools-arc]] records the composition as built.

| calls | sites | composition | state |
|---|---|---|---|
| `tr` byte and newline maps in FAIL and ok text | 37 | `map-list` over `Bytes` | built. The arc records that `tr` needs no primitive of its own |
| `head -c N` and `head -1` truncating a message | 34 | `ms-take` | built |
| `sed 's/^/  /'` indenting reported output, `sed -E` capture over an import line | 29 | `find-all` + `str-replace` over spans | built, E173 slice 1 |
| `wc -c` and `wc -l` in an informational line | 20 | `foldl` | built |
| `grep -c` and `grep -v` in a display body | 12 | `find-all` + `filter` | built, E173 slice 1 |
| `awk` in `prose-lint.sh`'s own scanner and reporter | 6 | `find-all` + `filter` + `foldl` | built, and `prog/prose-lint.prog` is the consumer that exists |
| `cat <<EOF` printing usage text | 3 | the entry's own stdout path | built |
| `sort -rn`, `sort -k2 -rn` over a display list | 2 | `list-sort` with the caller's comparator | built, E152 |
| `cut -d' ' -f1` splitting on a literal | 1 | `find-all` → spans → `str-sub` | built. Capture groups are E173 slice 2 and this call needs none |
| `paste` over a single file | 1 | `Doc` + `r-row` | built, E158/E174. The call is a passthrough |

⚑ **A row here means the primitive exists.** It does not mean the tool exists. Reaching
these from a shell script needs an entry that reads a file and takes arguments.
`prog/prose-lint.prog` is the one entry that already does it, and it is the model.

The three files outside the gate tier hold 29 of these:
`tools/prose-lint/prose-lint.sh` 18, `bin/chirality-resolve.sh` 6,
`bin/chirality` 5.

⚑ **`bin/chirality-resolve.sh`'s six are the highest-value calls in the bucket.**
`:115-117` and `:138-140` are one `sed` stripping comments, one `grep -oE`
extracting `(import "…")`, and one `sed -E` taking the key out of the quotes.
That is the whole import scanner, it is three composition calls wide, and
`lib/module/resolve.chiral` already does the job in chirality.

## Bucket 3: NEEDS-A-COMPOSITION, 58 sites

Not a judgment, and the primitive does not exist.

| calls | sites | what must be built | state |
|---|---|---|---|
| `dirname`, `readlink -f`, `basename` for root detection | 28 | a path-split composition, plus `argv` to know the script's own path, plus a `realpath` crossing | `argv` is **E150**, example and SPEC exist, unbuilt; the capability is proven by a 15-line probe over `/proc/self/cmdline`. No port declares `realpath` |
| `cat FILE` writing a captured stream to stdout | 19 | a file-read-to-stdout composition | the file ports exist under `lib/ports/`. The composition does not |
| `diff` of two goldens in a FAIL body | 7 | an edit script over two sequences | **P3**, `unminted`. [[arcs/text-tools-arc]] rows it as needing a reserved element block from the author |
| `find -type f -name '*.md'` walking the corpus | 4 | a directory walk | **E148** `getdents64`, minted, `design`, no example and no SPEC. `flook.chiral` holds 264 inert lines waiting for it |

⚑ **The four `find` calls are the block on `prose-lint`.** Three are in
`tools/prose-lint/prose-lint.sh:73`, `:76`, `:77` and one is the corpus list in
`tools/test/matcher.sh:488`. `prog/prose-lint.prog` carries eight of the ten
checks already; what keeps the shell front end alive is the corpus walk, the
argument parsing and the baseline file, in that order.

### Where a native hash would land

Five `sha256sum` invocations across five scripts (`tools/test/doc.sh:444`,
`tools/test/face.sh:547`, `tools/test/row.sh:645`, `tools/test/pretty.sh:379`,
`tools/test/render-doc.sh:482`). Each compares a neighbouring gate script or
fixture against a hex constant held in bash. They are **1b** rather than bucket
3: the independence axis is the building binary, and what is missing is the hash
itself. Two corrections to the framing:

- **`lib/` is not hashless.** `lib/protocol/apc.chiral:122-130` defines
  `fnv1a-go`, `fnv1a` and `hex16`: FNV-1a-64 over `Bytes` rendered as 16 hex
  characters, used at `:141-147` as `block-id`, the content address every
  `r-section` and `r-hole` carries, and re-verified on decode at `:227` and
  `:244`. It is a content hash and it is not a cryptographic one.
- **The planned kernel is BLAKE2s, not SHA-256.**
  `docs/elements/specs/N01-crypto-kernels-SPEC.md:181` puts it at N1 slice 3, and
  `docs/arcs/native-protocol-arc.md:60` records slices 1 and 2 built and gated
  2026-09-03 with 3 and 4 open. Adopting it at a pin site changes every pinned
  constant, which is a scheduling fact rather than an objection.

## Order, by the OS rung

Rank is the rung. Line count does not decide it, and every classic tool that becomes a
composition is one fewer thing an operating system written in this language has
to trust, and a resolver and a text tool are needed long before a test harness
is.

| rank | subject | owed sites | why it outranks the one below |
|---|---|---|---|
| 1 | `bin/chirality-resolve.sh`, 306 L | 9 | the module resolver is on the build path of every compile in the tree. `prog/resolve.prog` already exists at 104 L and `lib/module/resolve.chiral` is its library. **No site here is a judgment**, so nothing waits on J1. Adoption is the whole of the work |
| 2 | `tools/prose-lint/prose-lint.sh`, 223 L | 24 | the text tool. `prog/prose-lint.prog` carries eight of ten checks and `lib/text/matcher.chiral` is ENFORCED at Phase 19. Blocked on E148 and E150, both minted, and on nothing else |
| 3 | `bin/chirality`, 220 L | 10 | the CLI front door. Five of its ten sites are `cat` and `readlink`, so it is the argument-and-process shape rather than text work. Same E150 block |
| 4 | `tools/paren-audit/paren-audit.py`, 154 L | 0 shell sites | `prog/paren-audit.prog` exists at 244 L. Zero classic-tool calls to convert; the work is a differential run and a retirement |
| 5 | the Python tier, 4,786 L over 9 files | 0 shell sites | no classic-tool call sites at all. See below |
| 6 | the gate tier, 6,915 L over 18 files | 448 | largest by far, last by rung, and 288 of its sites cannot honestly move until J1 is written |

The first three are 749 lines and 43 owed sites, none of them a judgment and none
blocked on the independence criterion. That is the whole argument for the
ordering: the rungs an operating system needs first are also the only ones not
waiting on an unstarted arc.

## The natives nothing calls

Four chirality modules are written, sit in the tree, and have no consumer. Two
are tools whose adoption is the cheapest win in the surface. Two are the
independence assets 1b needs.

**The tools.**

- **`prog/resolve.prog`, 104 lines, zero consumers.** Verified: no shell script,
  no gate phase and no `.prog` compiles or runs it. Every reference in the tree
  is prose (`lib/module/resolve.chiral:22`, `:406`, the catalog's E87 row,
  `docs/arcs/binary-split-arc.md:41`). Against that, **fifteen shell files**
  source `bin/chirality-resolve.sh`: `bin/chirality` and fourteen of the eighteen
  gate scripts. TC-03.
- **`prog/paren-audit.prog`, 244 lines, zero consumers.**
  `tools/paren-audit/paren-audit.py` is live at 154 lines and `tools/README.md:12`
  records the Python as not retired and not deletable because equivalence is
  unverified. `docs/goals/self-tooling.md:67-68` says the same. TC-04.

**The independence assets.**

- **`lib/lowering/tal/eval.chiral`, 187 lines, zero importers.** The reference tal
  interpreter, described at `:1-2` as the Category-A oracle that defines what
  checked programs mean, with a strictly decreasing fuel making the meaning
  function total. Its imports are `prelude/prelude` and `lowering/tal/ssa`.
  **This is the strongest formulation-axis asset the tree owns and nothing uses
  it.** TC-13.
- **`lib/typing/kernel-core.chiral`, 60 lines, zero importers.** `JForm`, the
  judgment's own decomposition. `docs/arcs/independent-judgment-arc.md:41` and
  `:93` already row it. ⚑ Its imports are `typing/kernel` and `typing/diag`, so
  it is **not** closure-disjoint from the compiler's typing modules, and it
  serves the formulation axis less well than `eval.chiral` does.

⚑ **The resolver has two consumers with opposite requirements, and that is the
shape of its adoption.** `tools/test/mutant.sh:110-116` runs
`. "$tree/bin/chirality-resolve.sh"` from the mutated tree. A chirality resolver
there would itself be built from the mutated `lib/`, so a mutant in
`lib/module/resolve.chiral` could produce a resolver that hides the mutation.
Closure disjointness names that failure exactly, and the fix is the same shape as
everywhere else in 1b: build the resolver ahead of the matrix with the promoted
binary. The build path does not wait on any of it.

## The Python tier

Nine files, 4,786 lines, and **zero classic-tool invocations**. The only
subprocess calls are to `git` (`tools/ledger-lint/ledger-lint.py:1038`, `:1047`,
`:1588`; `tools/frontier/frontier.py:254`) and to `sys.executable` re-entering
another tool in this tree (`tools/doc/doc.py:204`,
`tools/capture/capture.py:225`, `:444`).

The classic-tool work is done in process. Census, measured 2026-09-04:

| job | occurrences | the composition it wants |
|---|---|---|
| `re.compile/search/match/findall/finditer/sub/split` | 172 | `find-all` + `filter` + `str-replace`, built, E173 slice 1 |
| `sorted(...)` and `.sort(...)` | 60 | `list-sort`, built, E152 |
| `glob.glob`, `os.walk`, `os.listdir`, `os.scandir` | 15 | E148 `getdents64`, unbuilt |
| `hashlib` / `sha256` | 9 | N1 slice 3, unbuilt |

`tools/ledger-lint/ledger-lint.py` alone holds 87 of the 172 regex operations and
27 of the 60 sorts. This tier has no 1a and no 1b: none of it runs inside a gate,
so none of it judges a chirality artifact under a mutated compiler. A per-tool
port is the only shape available, because there are no call sites to convert one
at a time. TC-10.

## The three gate scripts nothing invokes

Recorded as measurement. Nothing was registered.

`ls tools/test/*.sh` lists eighteen files. `grep -n '^run_phase' tools/test/run-tests.sh`
returns thirteen dispatch lines and none names `crypto.sh`, `tal-check.sh`,
`map-integrity.sh` or `mutant.sh`. All three of the first were read:

| script | lines | its own claim | measured |
|---|---|---|---|
| `tools/test/crypto.sh` | 402 | `:6-8` NOT YET REGISTERED, the `run_phase` line owed to the suite-owning session, and "21-23 are free at this writing" | it claims **no phase number of its own**, anywhere in the file |
| `tools/test/tal-check.sh` | 474 | `:3` "The Phase 22 gate", `:5-9` PHASE 22 with 21 left to `crypto.sh`, `:11-15` not yet registered | claims 22 explicitly |
| `tools/test/map-integrity.sh` | 31 | `:7-8` "Not a suite phase: the map lives under `.planning/`, which is not tracked, so a fresh checkout has no map to check" | the reason is **false**. `git ls-files .planning` returns 147 and includes `.planning/MIGRATION-MAP.tsv` |

`records/gate-audit.md` GA-10 holds the five-outside-the-dispatch count and left
`crypto.sh` and `tal-check.sh` unmeasured. This pass measures them. TC-07, TC-09.

⚑ **Gate phases 21 and 22 are allocated twice, and this is an open question for
the author.** TC-08.

## Findings

### TC-01 the goal tier's native line count omits three of the five entries

- state:    FIXED
- claim:    `docs/goals/enforcement.md:32` and `docs/arcs/enforcement-arc.md:74-75` read "12,450 lines outside the language against 390 native", and the arc names `prog/test-runner.prog` 134 and `prog/prose-lint.prog` 256 as the whole of it.
- measured: `wc -l prog/*.prog` returns `paren-audit` 244, `prose-lint` 256, `test-runner` 134, `resolve` 104, `wield` 44 and `compiler` 20. Tooling is the five, and the sum is **782**. The 390 is 134 + 256 and omits `paren-audit`, `resolve` and `wield`, which together are 392, so the figure is short by more than it contains. The 12,450 reproduces exactly: 6,915 + 223 + 4,786 + 526.
  Re-measured at `67d3d54`: `wc -l prog/*.prog` returns the same six figures and
  the same 782. **Repointed at `56348b9`**, in both documents. The documents now
  also record what the correction costs: `test-runner` and `prose-lint` are the
  only two entries `grep -rIn` over `tools/` and `bin/` finds any consumer for,
  and they are exactly the 390, so the 392 lines the correction adds are all
  SEEDED and the ratio reads worse rather than better.
- evidence: `docs/goals/enforcement.md:32-45`; `docs/arcs/enforcement-arc.md:74-85`; `prog/paren-audit.prog`, `prog/resolve.prog`, `prog/wield.prog`
- checked:  2026-09-04
- element:  none

### TC-02 the 352-call figure is a word count, and the invocation count is 240

- state:    FIXED
- claim:    `docs/arcs/enforcement-arc.md:79-82` and `docs/goals/enforcement.md:35-38` read that within the gate tier alone there are **352 calls to `grep`, `sed`, `sort` and `awk` where `docs/arcs/text-tools-arc.md` records a built chirality composition**.
- measured: 352 reproduces as a word-occurrence count. `for t in grep sed awk sort; do grep -ohE "\b$t\b" tools/test/*.sh | wc -l; done` returns 149, 100, 81 and 22, summing to exactly 352. Those occurrences include comments, the scratch filenames `g5.awk` and `g9.awk`, and the prose in `tools/test/matcher.sh` naming the awk tool the native matcher is graded against. Counting invocations in command position gives **240** for the same four tools in the same files. Of those 240, **210 are judgments** and **30 are owed work with a built composition**. Over the whole surface the four total 259 invocations, 210 judgments and 49 owed.
  Re-measured at `67d3d54` with an independently written scanner following the
  rule stated above: **240 exactly** for the four tools in `tools/test/*.sh`,
  agreeing site for site. The word count reads 353 at `67d3d54` rather than 352,
  one `awk` occurrence added by the concurrent gate pass; 352 still reproduces
  at `acc70d6`. ⚑ **The stale half was the number. The false half was the claim
  attached to it.** Both documents read that a built chirality composition stood
  behind all 352. It stands behind **30**: 49 of the four tools' 259 sites are
  bucket 2 across the whole surface, and 19 of those 49 sit outside the gate
  tier, which the per-tier table already fixes. **Repointed at `100137a`**, with
  the other 210 named as judgments waiting on J1.
- evidence: `docs/arcs/enforcement-arc.md:74-100`; `docs/goals/enforcement.md:46-61`; `tools/test/matcher.sh:14`, `:49`, `:474`, `:497`
- checked:  2026-09-04
- element:  none

### TC-03 `prog/resolve.prog` has no consumer and fifteen shell files use the bash resolver

- state:    RETIRED
- claim:    `docs/elements/catalog.md:117` (E87) reads that two providers are "pinned against each other and both live": `bin/chirality-resolve.sh`, the one the build rule uses, and `lib/module/resolve.chiral`, imported by `prog/resolve.prog` and `lib/evidence/test-floor.chiral`.
- measured: MOVED to PRB-59 in records/lenses/problems.md (2026-09-05): the lens row carries the live state, this row is the history.  the chirality provider is live as a library and dead as a tool. `grep -rIn 'resolve\.prog'` over the tree returns seven hits and every one is prose: two comments in `lib/module/resolve.chiral` (`:22`, `:406`), the E87 catalog row, `docs/examples/E172-NAME-MAP.md:141`, `docs/decisions/decision-lane-split.md:256`, `docs/arcs/binary-split-arc.md:41` and two size rows in `records/baseline-alignment.md`. No shell script, no gate phase and no `.prog` compiles or runs it. Against that, `grep -rIln 'chirality-resolve' tools bin` names **fifteen shell files**: `bin/chirality` and fourteen of the eighteen gate scripts. The four that do not are `check-cli.sh`, `linear-mint.sh`, `map-integrity.sh` and `profile-target.sh`. None of the resolver's nine classic-tool sites is a judgment, so its adoption on the build path waits on nothing in `arcs/independent-judgment-arc`.
- evidence: `prog/resolve.prog:1-20`; `docs/elements/catalog.md:117`; `bin/chirality-resolve.sh:115-117`, `:138-140`, `:273-276`, `:304`
- checked:  2026-09-04
- element:  UNASSIGNED

### TC-04 `prog/paren-audit.prog` has no consumer and the Python it replaces is live

- state:    RETIRED
- claim:    `prog/paren-audit.prog:10` reads that it is a port of `tools/paren-audit/paren-audit.py` (154 LOC), wave 0 of the zero-python arc.
- measured: MOVED to PRB-60 in records/lenses/problems.md (2026-09-05): the lens row carries the live state, this row is the history.  `prog/paren-audit.prog` is 244 lines and nothing invokes it. `tools/paren-audit/paren-audit.py` is 154 lines and still on disk. `tools/README.md:12` records the Python as running unchanged with equivalence against the chirality replacement **unverified**, so it is not retired and not deletable. `docs/goals/self-tooling.md:67-68` and `docs/arcs/zero-python-arc.md:97-99` carry the same. Its usage line, `prog/paren-audit.prog:7`, needs a directory walk it does not have: `find lib prog -name '*.chiral' | chirality run prog/paren-audit.prog`. The differential run that would retire the Python has never been taken.
- evidence: `prog/paren-audit.prog:1-10`; `tools/paren-audit/paren-audit.py:1-12`; `tools/README.md:12`; `docs/arcs/zero-python-arc.md:97-99`
- checked:  2026-09-04
- element:  UNASSIGNED

### TC-05 `lib/text/matcher.chiral` is 602 lines and three documents say 533

- state:    RETIRED
- claim:    `docs/arcs/text-tools-arc.md:87`, `docs/definitions/status-ledger.md:165` and `docs/goals/local-ai.md:103` each record `lib/text/matcher.chiral` at **533 lines**.
- measured: MOVED to PRB-61 in records/lenses/problems.md (2026-09-05): the lens row carries the live state, this row is the history. `wc -l lib/text/matcher.chiral` returns **602**. The file grew after those rows were written: `git log --follow` puts the last change at `9f46c6c`, "matcher: the two constructions scan-go built and threw away", and the figure was taken at the E173 slice-1 landing on 2026-09-01. The consumer count is unchanged and correct: `grep -rIn 'import "text/matcher"' lib prog` returns exactly one shipping consumer, `prog/prose-lint.prog:43`, plus the gate fixture `tools/test/samples/e173_matcher.prog:37`. Its own imports are `prelude/prelude`, `prelude/list`, `prelude/ord` and `prelude/string`, which is what makes its closure small enough to be a judge everywhere except over itself.
  ⚑ **This row named three documents and there are seven.** `grep -rln` for the
  figure over `docs/` returns `docs/definitions/status-ledger.md:165`,
  `docs/elements/catalog.md:499`, `docs/elements/ledger.md:321`,
  `docs/banks/text.md:50`, `docs/examples/INDEX.md:164`,
  `docs/goals/local-ai.md:103` and `docs/arcs/text-tools-arc.md:87`, where the
  last wraps the number onto the following line. **Three repointed at
  `8b65108`**: `status-ledger`, `catalog`, `ledger`. The other four stay owed;
  `docs/banks/text.md` was held by a concurrent bank pass at the time and was
  not opened.
- evidence: `docs/arcs/text-tools-arc.md:87`; `docs/banks/text.md:50`; `docs/examples/INDEX.md:164`; `docs/goals/local-ai.md:103`; `lib/text/matcher.chiral:10-13`; `prog/prose-lint.prog:43`
- checked:  2026-09-04
- element:  none

### TC-06 `lib/` has a content hash, and the planned kernel is BLAKE2s

- state:    RETIRED
- claim:    the dispatch for this pass read that there is no hash anywhere in `lib/`, and that a native hash would replace the gate tier's `sha256sum` calls.
- measured: MOVED to PRB-62 in records/lenses/problems.md (2026-09-05): the lens row carries the live state, this row is the history. both halves need correcting. `lib/protocol/apc.chiral:122-130` defines `fnv1a-go`, `fnv1a` and `hex16`, an FNV-1a-64 content hash rendered as 16 hex characters, and `:141-147` uses it as `block-id`, the content address on every `r-section` and `r-hole`; `:227` and `:244` re-verify it on decode. It is a content hash and it is not cryptographic, which is the distinction the claim wanted. Separately, the planned cryptographic kernel is **BLAKE2s** rather than SHA-256: `docs/elements/specs/N01-crypto-kernels-SPEC.md:181` is "Step 3: BLAKE2s (slice 3)" and `docs/arcs/native-protocol-arc.md:60` records slices 1 and 2 built and gated with 3 and 4 open. The five pin sites are 1b rather than bucket 3, because the independence axis is the building binary and only the hash is missing.
- evidence: `lib/protocol/apc.chiral:122-147`, `:227`, `:244`; `docs/elements/specs/N01-crypto-kernels-SPEC.md:181`; `docs/arcs/native-protocol-arc.md:60`
- checked:  2026-09-04
- element:  none

### TC-07 three written gate scripts have no dispatch line

- state:    RETIRED
- claim:    `tools/test/crypto.sh:6-8` and `tools/test/tal-check.sh:11-15` each read NOT YET REGISTERED, with the `run_phase` line owed to the suite-owning session. `tools/test/map-integrity.sh:7-8` reads that it is not a suite phase.
- measured: MOVED to PRB-63 in records/lenses/problems.md (2026-09-05): the lens row carries the live state, this row is the history. `grep -n '^run_phase' tools/test/run-tests.sh` returns thirteen dispatch lines at `:144-147`, `:216`, `:225`, `:236`, `:252`, `:268`, `:284`, `:303`, `:326` and `:345`, and none names any of the three. `crypto.sh` is 402 lines and gates the two RFC 8439 kernels; `tal-check.sh` is 474 lines and gates the typed-assembly floor checker after the EN-09 and EN-11 repairs; `map-integrity.sh` is 31 lines. So 907 lines of gate script are written and outside `bin/chirality test`. `records/gate-audit.md` GA-10 holds the five-outside-the-dispatch count and left `crypto.sh` and `tal-check.sh` unmeasured; this row measures them. Nothing was registered by this pass.
- evidence: `tools/test/run-tests.sh:144-147`, `:345`; `tools/test/crypto.sh:6-8`; `tools/test/tal-check.sh:3`, `:5-9`, `:11-15`; `records/gate-audit.md` GA-10
- checked:  2026-09-04
- element:  UNASSIGNED

### TC-08 gate phases 21 and 22 are allocated twice

- state:    RETIRED
- claim:    `docs/decisions/decision-lane-split.md:30` reserves gate phases **21, 22, 23** for Lane B, which owns E146, E163 and E183. `tools/test/run-tests.sh:332` repeats it: "21-23 are Lane B's".
- measured: MOVED to PRB-64 in records/lenses/problems.md (2026-09-05): the lens row carries the live state, this row is the history. two scripts that are not Lane B elements sit in that block. `tools/test/tal-check.sh:3` reads "The Phase 22 gate" and `:5-9` takes 22 explicitly, leaving 21 to `crypto.sh` "which was written first and whose registration is already owed". `docs/definitions/testing-floors.md:69` records tal-check.sh as Phase 22 and describes "the `crypto.sh` precedent holding phase 21". Reading `crypto.sh` in full, it claims **no phase number**: `:6-8` says only that registration is owed and that "21-23 are free at this writing". So three documents place phase 21 with a script that has never asked for it, and phase 22 with EN-09/EN-11 work rather than with Lane B's E163 or E183. Recorded as an open allocation question. No number was assigned by this pass.
  Re-read at `67d3d54`: `crypto.sh:8` still claims no number and still records
  21 through 23 as free. **`docs/definitions/testing-floors.md:69` repointed at
  `096ba33`**: it no longer asserts the precedent, and it names all four
  positions with the author call beside them. **No number was assigned.** The
  allocation stays open, and `records/author-calls.md:30` holds it.
- evidence: `docs/decisions/decision-lane-split.md:30`; `tools/test/run-tests.sh:332`; `tools/test/tal-check.sh:3`, `:5-9`; `tools/test/crypto.sh:6-8`; `docs/definitions/testing-floors.md:69`; `records/author-calls.md:30`
- checked:  2026-09-04
- element:  UNASSIGNED

### TC-09 map-integrity.sh's stated reason for exclusion has been false since 2026-09-01

- state:    RETIRED
- claim:    `tools/test/map-integrity.sh:7-8` reads "Not a suite phase: the map lives under `.planning/`, which is not tracked, so a fresh checkout has no map to check."
- measured: MOVED to PRB-65 in records/lenses/problems.md (2026-09-05): the lens row carries the live state, this row is the history. `.planning/` has been tracked since 2026-09-01 by `docs/decisions/decision-ai-tier.md`. `git ls-files .planning | wc -l` returns **147**, and `git ls-files .planning/MIGRATION-MAP.tsv` returns the map itself, so a fresh checkout does have a map to check. This is the same false claim `ledger-lint` check Z drives to zero in the doc tier; Z scans `docs/` and `.claude/skills/` and reports 5 live instances, and it does not scan `tools/`, so this one is invisible to the lint. The exclusion may still be right for another reason. The reason written down is not.
- evidence: `tools/test/map-integrity.sh:7-8`; `docs/decisions/decision-ai-tier.md`; `tools/ledger-lint/ledger-lint.py:1586-1590`
- checked:  2026-09-04
- element:  UNASSIGNED

### TC-10 the Python tier makes no classic-tool call

- state:    RETIRED
- claim:    [[arcs/zero-python-arc]] treats the Python tier as tooling to be replaced, and enforcement requirement 5 counts its 4,786 lines in the 12,450 outside the language.
- measured: MOVED to LIM-15 in records/lenses/limits.md (2026-09-05): ACCEPTED was a limit at `accepted`, per decision-four-lenses. the count is right and the shape is different from the shell's. Nine `.py` files under `tools/` make **zero** invocations of a classic Unix tool. Every `subprocess` call is to `git` (`tools/ledger-lint/ledger-lint.py:1038`, `:1047`, `:1588`; `tools/frontier/frontier.py:254`) or to `sys.executable` re-entering a tool in this tree (`tools/doc/doc.py:204`; `tools/capture/capture.py:225`, `:444`). The classic-tool jobs are done in process: 172 `re` operations, 60 sorts, 15 directory walks and 9 `hashlib` uses, of which `ledger-lint.py` holds 87 regex operations and 27 sorts. None of it runs inside a gate, so this tier has no 1a and no 1b, and a per-tool port is the only shape available. Accepted as a measurement rather than a defect.
- evidence: `tools/ledger-lint/ledger-lint.py:1034-1048`, `:1586-1590`; `tools/frontier/frontier.py:250-254`; `tools/doc/doc.py:204`; `tools/capture/capture.py:225`, `:444`
- checked:  2026-09-04
- element:  none

### TC-11 the Python tier is nine files, and two documents say seven

- state:    FIXED
- claim:    `docs/goals/enforcement.md:34` and `docs/arcs/enforcement-arc.md:78` both read "seven Python tools are 4,786".
- measured: `find tools -name '*.py' | wc -l` returns **9** and their lines sum to exactly 4,786, so the line figure is right and the file count is not. `tools/README.md` lists nine Python folders: `paren-audit`, `syscall-map`, `ledger-lint`, `pack`, `frontier`, `capture`, `doc`, `scriba-edit-smoke`, `scriba-run-smoke`. Excluding the two smoke tests, which is the only reading that gives seven, leaves 4,604 lines rather than 4,786.
  Re-measured at `67d3d54`: 9 files, 4,786 lines. **Repointed at `5f84af8`**.
- evidence: `docs/goals/enforcement.md:34`; `docs/arcs/enforcement-arc.md:88-89`; `tools/README.md:11-21`
- checked:  2026-09-04
- element:  none

### TC-12 288 gate-tier calls are blocked on a criterion nobody has written

- state:    RETIRED
- claim:    `docs/goals/enforcement.md:41-45` and `docs/arcs/enforcement-arc.md:84-88` read that some of the tooling surface is correct and stays, because a comparator holding constants cannot be fooled by a mutated compiler, and that over-claiming that bucket replaces a safety property with a dependency.
- measured: MOVED to PRB-66 in records/lenses/problems.md (2026-09-05): the lens row carries the live state, this row is the history. the caution is right and the bucket is much smaller than "the gate tier". **15 of 506** call sites are irreducible, all in `tools/test/matcher.sh`, whose subject is the module a matcher-based judge would itself be built from. The other **288** are judgments for which this tree already owns an independence axis: formulation (`lib/lowering/tal/eval.chiral`, 187 lines, zero importers), profile and frozen port set ([[banks/profile]] §1), runtime ([[banks/runtime]] §1), import-closure disjointness (already computed in bash at `tools/test/pretty.sh:552-573` and gated as G13 with M17 as its mutant), and the building binary (`tools/test/mutant.sh:110-116` builds every mutant with the promoted `$MUT_B1`). `lib/evidence/ddc.chiral:207-213` and `docs/definitions/open-edges.md:672` both record that `leg2-disjoint?` is the wrong criterion for this threat, that `Prov` has no formulation axis and that `ddc-fold` compares bytes where formulations agree on verdicts. **The independence is already in the tree. What is missing is the criterion.** `docs/arcs/independent-judgment-arc.md:92` rows J1, the distinctness criterion written down, as `not started`; the `ddc` repoint is open edge 21 with no element minted; and `:107` records that the arc has no reserved element block, so nothing there can be minted at all. Nothing in the 288 can honestly convert until J1 lands, and every one of them stays owed work meanwhile.
- evidence: `lib/evidence/ddc.chiral:207-213`; `docs/definitions/open-edges.md:672`, `:687-699`, `:701`; `docs/arcs/independent-judgment-arc.md:92`, `:100`, `:107`; `tools/test/pretty.sh:552-573`; `tools/test/mutant.sh:110-116`
- checked:  2026-09-04
- element:  UNASSIGNED

### TC-13 the reference tal interpreter is the tree's strongest formulation asset and no arc rows it

- state:    RETIRED
- claim:    `docs/arcs/independent-judgment-arc.md:38-42` lists what is in the tree already for the independence axes: `lib/evidence/ddc.chiral` at 213 lines with 1 importer, `lib/typing/kernel-core.chiral` at 60 lines with 0, and `lib/typing/reflect-floor.chiral` at 54 lines with 0.
- measured: MOVED to PRB-67 in records/lenses/problems.md (2026-09-05): the lens row carries the live state, this row is the history. the table omits the strongest member. `lib/lowering/tal/eval.chiral` is **187 lines with zero importers**, and `:1-2` describes it as the reference tal interpreter, the Category-A oracle that defines what checked programs mean, ported from `TalMachine.call`. Its register file and byte store are explicit and threaded so evaluation is replayable by construction, and a strictly decreasing fuel makes the meaning function total, with "out of fuel" a constructor rather than a hang. Its imports are `prelude/prelude` and `lowering/tal/ssa` only, so its closure excludes `typing/`, `surface/`, `lowering/compile-*` and `lowering/tal/check` entirely. That makes it disjoint from the compiler on both the formulation axis and the closure axis. By contrast `kernel-core.chiral` imports `typing/kernel` and `typing/diag` (`:23-24`) and is **not** closure-disjoint from the modules it would judge. `lib/typing/reflect-floor.chiral` was confirmed at 54 lines with zero importers. Three written modules, 301 lines, and nothing reaches any of them.
- evidence: `lib/lowering/tal/eval.chiral:1-20`; `lib/typing/kernel-core.chiral:23-24`; `docs/arcs/independent-judgment-arc.md:38-42`, `:93`
- checked:  2026-09-04
- element:  UNASSIGNED

### TC-14 the surface figures started drifting the day they were taken

- state:    RETIRED
- claim:    the table above and both goal-tier documents read a gate tier of **6,915** lines and **12,450** lines outside the language, measured 2026-09-04 against `dda00b9`. This file's scope paragraph read **122** gate-tier `grep` invocations.
- measured: MOVED to PRB-68 in records/lenses/problems.md (2026-09-05): the lens row carries the live state, this row is the history. three separate drifts, none of them a defect in the original count. **One.** Four commits after `acc70d6` (`ebec76a`, `d3ab4d3`, `3a71658`, `f7caf96`, all falsifier work on `tools/test/*.sh`) took the gate tier to **7,136** lines, so the surface outside the language reads **12,671** at `67d3d54` and the 12,450 is already behind. Neither figure was repointed: `tools/test/` was held by a concurrent gate pass and the target moves under it. **Two.** The same four commits added no classic-tool call site, so **506 stands as 504** under an independently written scanner following this file's stated rule, with `tools/test/doc.sh` at 47 against 48 and `tools/prose-lint/prose-lint.sh` at 23 against 24, one `sort` and one `wc` this pass could not place. Every other file and 17 of the 19 tools agree exactly, and the gate-tier four-tool count reproduces at **240** site for site. **Three.** The 122 above disagreed with this file's own per-tool table and is corrected to 119 in the same commit as this row.
- evidence: `records/tooling-classification.md:36-46`; `docs/goals/enforcement.md:32-33`; `docs/arcs/enforcement-arc.md:74`, `:87-90`, `:130`; `git log acc70d6..67d3d54 -- tools/test/`
- checked:  2026-09-04
- element:  none

## What this pass did not do

- Nothing was converted. No file outside `records/` was edited.
- Nothing was registered, and no phase number was assigned.
- `tools/test/run-tests.sh` was not run, by instruction. Every count here comes
  from reading files.
- The scanner is a session script and is not tracked. Its rule is written above
  and the count can be re-taken from it.
- `docs/goals/enforcement.md` and `docs/arcs/enforcement-arc.md` carried the
  390, the 352 and the seven when this file was written. A later pass repointed
  all three (`56348b9`, `5f84af8`, `100137a`), repointed three of the seven
  documents carrying 533 (`8b65108`), and repointed
  `docs/definitions/testing-floors.md:69` off the phase-21 precedent
  (`096ba33`). TC-01, TC-02 and TC-11 are `FIXED`. TC-05 and TC-08 stay `OPEN`
  and TC-14 records what has drifted since.
- J1 was not written. This file states which axis covers each 1b group and does
  **not** claim that a criterion exists.
