---
element: E172
slug: file-kinds
title: Semantic file extensions, and the source tree by altitude
kind: BUILD-PROPER
reference_class: OURS/IMPL
ours_source: (none)
status: drafted
updated: 2026-08-30
---

# E172 — Semantic file extensions, and the source tree by altitude

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

**This example does not restate the catalog proposal. It tests it, and cuts it
in half.** The catalog proposed four extensions (`.chiral` / `.main` / `.port` /
`.prof`) carrying membrane-and-entry on one axis. Measurement says the extension
can carry **exactly one binary**, that binary is **entry-ness**, and that
membrane must stay where E161 already derives it. Sections 2 and 4 carry the
argument; §6 carries the disagreements with the catalog row.

## 1. Scope

- **Element:** E172 — give chirality source files a *kind* that is visible before
  the file is opened, and enforce it at the only stage that sees a filename.
- **Kind:** BUILD-PROPER (nothing here exists; the resolvers currently know one
  extension, `.chiral`, and nothing else).
- **Why chirality needs its own:** the tree already encodes three type-level facts
  in filenames — entry-ness (`-driver`), altitude (`tal-` / `-tal`), membrane
  (`ports/`) — and **nothing checks any of them.** That is the exact defect
  shape chirality exists to refuse: a fact that is real, load-bearing, and carried
  by convention. P4 (*invariants go in the substrate, not across a seam*) says
  the fix is not a lint but a carrier the toolchain must agree with.
  The measured urgency is the adoption gap: the declaration that was supposed
  to fix this (E160 → E161) is **BUILT with a 29-case gate and adopted in 13
  files of 402** (see §2, finding 1). A declaration must be hand-written 402
  times; an extension is carried by every file by construction.

## 2. Research

**Reference class:** `OURS` (the tree itself, measured 2026-08-30) plus `IMPL`
(OCaml, Ada/GNAT, Erlang, Go). Every number below is a command that was run,
not a recollection; three of the four figures in the catalog row came out
different (§6).

### Finding 1 — the declaration axis is adopted in 13 files, and its form has already changed once

```
git ls-files '*.chiral' | wc -l                                       -> 402
git ls-files '*.chiral' | xargs grep -lE '^\(module [a-z0-9_.-]+ \(cat ' | wc -l
                                                                     -> 13
git ls-files '*.chiral' | xargs grep -lE '\(kind [a-z0-9_-]+ [ABC] (upper|tal|metal)'
                                                                     -> 0
```

E160's `(kind ports C upper (crosses))` is declared in **zero** files: E161
deleted the claim facet and replaced the form with
`(module ports (cat C) (alt upper))` (`scaffold/tests/test-module-kind.sh:9-17`).
The live form is adopted in 13 files — 8 under `scaffold/lib/`, 5 under `TUI/` —
and **all 13 say `(alt upper)`.** Not one file in the repo declares `tal` or
`metal`, although nine files obviously live there. So the altitude axis, as a
*declared* fact, has never once varied. As a *basename* fact it varies fine —
which is the whole finding: the cheap carrier got used and the declared one did
not.

### Finding 2 — the import name is already extension-free; the basename is the resolver's key

```
git ls-files '*.chiral' | xargs grep -h '^(import' | wc -l            -> 1182
… | grep -c '\.chiral'                                                -> 1
```

Exactly one of 1182 import lines mentions `.chiral`, and it is inside a trailing
comment (`TUI/scriba/manas-runview.chiral:23`). **An extension change therefore
touches zero import sites.** The resolver appends the extension itself —
`lib/module/resolve.chiral:213` `(str-cat name ".chiral")`, and
`bin/chirality-resolve.sh:55-57` `"$parent/$name.chiral"` / `"$libdir/$name.chiral"`.

The corollary is the trap: because the *name* is the key, a **directory** move
is not free the way an extension change is. `tal-ir.chiral` → `tal/ir.chiral`
renames the module from `tal-ir` to `ir`, and E155's collision rule keys on the
**basename after the last slash** (`bin/chirality-resolve.sh:53`
`base="${name##*/}"`; `resolve.chiral:422-429`). Ten basenames are already
duplicated across the three trees (`prelude` ×4, `collections`, `ports`, `apc`,
`grid`, `render`, `session`, `utf8`, `vt-parser`, `t1_child_wiring`), legal only
because they never meet in one blob. Moving altitude out of the basename pushes
402 modules into a *shorter* name space that is already crowded.

### Finding 3 — the resolver runs strictly upstream of every derived fact

`prog/compiler.prog:9` — *"Read source from stdin (fd 0)"* — the
compiler never sees a path. The resolvers are the only filename-aware stage, and
they run **before** the blob exists, so they see nothing but a path and a byte
string. Anything the extension projects must be decidable from **surface syntax
alone**. This single constraint kills two of the four proposed extensions
(§4), because membrane-ness in chirality is *derived*, not written: E161 fills
`Sheet.crossings` from the call graph and there is *"NO surface production at
all, so they cannot be written and therefore cannot disagree"*
(`test-module-kind.sh:19-21`).

The proof that the derived fact and the syntactic fact differ is
`lib/lowering/tal/sys.chiral`:

```
grep -cE '^\(extern' lib/lowering/tal/sys.chiral                      -> 0
```

Zero externs, zero porttypes — and it is the *most* authority-bearing file in
the tree: *"crossings authored at the tal floor… The tal checker marks every
function here as sys-face (TalFn.sysface)… only this file, linked deliberately,
can cross"* (`sys-tal.chiral:1-7`). A `.port` extension keyed to
`^(extern|^(porttype` calls the membrane a plain module.

### Finding 4 — prior art splits on a *build-stage* fact, never on a type fact

Verified rather than recalled, and it does not support the catalog's reading:

- **OCaml `.mli`/`.ml`** is *not* one-file-one-kind. Both files share one
  basename and form one compilation unit, and **the `.mli` is optional** —
  "there is no requirement that every .ml file have a corresponding .mli file";
  with no `.mli`, `ocamlc` synthesises the `.cmi` from the `.ml`. So the pair
  splits *interface from implementation of the same module*, and the extension
  is not a checked projection of anything: its absence is legal.
- **Ada/GNAT `.ads`/`.adb`** is the strongest case — one compilation unit per
  file, spec and body, filename derived from the unit name. But it is
  *overridable* by `pragma Source_File_Name`, and again it is two halves of one
  module, not two kinds of module.
- **Erlang `.erl`/`.hrl`** is a **preprocessor** distinction: `.hrl` holds
  records and macros pulled in textually by `-include`. An `.hrl` is not a
  module at all. Build stage, not type.
- **Go `package main`** is the one that matches: a **declaration in the source**
  which the toolchain refuses to import — "you cannot import the main package…
  not intended to be imported by other packages", and the Go test harness's
  inability to import it is a well-known, *enforced* consequence. Rust
  (`main.rs`) and Haskell (`Main.hs`) mark the same fact by filename, unchecked.

**What the reference class actually teaches:** every language that splits by
extension splits **halves of one unit** (spec/body, header/module) — never
*kinds* of unit. The only genuine kind-distinction any of them makes is
`entry vs. importable`, and Go makes it by *declaration plus toolchain
refusal*. chirality has the declaration already (`(def compile-main …)`) and has the
refusal already, but at the wrong stage and with the wrong message: two entries
in one blob surface as `duplicate label` at link time. E172 is not "add
extensions like OCaml"; it is **move Go's refusal from link time to resolve
time, and put its answer in `ls`.**

## 3. Conventional (other-language) approach

The tree today, and the three conventions it runs on:

```
prog/compiler.prog     ; entry — "-driver" says so
prog/wield.prog         ; entry — nothing says so
prog/test-runner.prog        ; entry — nothing says so
lib/lowering/tal/ir.chiral             ; tal   — prefix
lib/lowering/tal/sys.chiral            ; tal   — suffix, opposite position
lib/ports/sock.port         ; membrane — directory
lib/prelude/prelude.chiral            ; membrane (32 externs) — nothing says so
prog/demo/profile-headless.chiral  ; profile — prefix
```

and the resolver that reads them, which knows one thing:

```bash
# bin/chirality-resolve.sh:55-57 — the shell provider, verbatim shape
if [ -n "$parent" ] && [ -f "$parent/$name.chiral" ]; then f="$parent/$name.chiral"
elif [ -f "$libdir/$name.chiral" ];                  then f="$libdir/$name.chiral"
fi
```

**Assumptions it bakes in:**

- **Kind is a hint to humans.** Only 4 files carry `-driver`; 177 define an
  entry. The convention describes 2% of the fact it names.
- **Position is free.** Altitude is a prefix in seven files and a suffix in two.
  A tool that wanted to sort by altitude would need both regexes and would still
  be guessing.
- **The blame arrives at the wrong stage.** Pull two entries into one blob and
  the failure is a linker `duplicate label`, hundreds of definitions downstream
  of the import that caused it. `resolve.chiral:401-406` records this happening:
  five `scaffold/lib/*.chiral` modules define `compile-main`, and
  `test-floor.chiral` importing two of them is exactly why `compile-main` was
  split out into its own leaf module on 2026-08-25.
- **The tree's own fix is unadopted.** 13 of 402 (finding 1) — this repo's
  fifth built-but-unadopted element.

## 4. The chirality idea

### The carrier count is forced, not chosen

There are **three orthogonal facts** (entry-ness, membrane, altitude+typeability)
and **three carriers** (extension, directory, declaration). The catalog assigns
membrane *and* entry to the extension. That cannot work, and the reason is not
aesthetic:

> **An extension is ONE slot. It can carry ONE binary.** Two independent binaries
> need four values, and a file that is both needs two extensions at once.

This is not hypothetical. Measured:

```
comm -12 <(… grep -l '^(def compile-main' …) <(… grep -l '^(porttype\|^(extern' …) | wc -l
                                                                     -> 9
```

Nine files are **already both** entry and membrane: `prog/wield.prog`
(`extern openat` at line 14, `compile-main` at line 34) and eight port-discipline
samples (`e106_drain_control`, `e123_porttype_carrier`, the four `e124_reject_*`,
`e42_supervisor_accept`, `e145_be_peek_roundtrip`). Under a four-extension set
each of these must be *arbitrarily* filed as one or the other — which reinstates
exactly the unchecked convention E172 exists to delete, one layer up. Under two
extensions the question does not arise: `.chiral` and `.main` partition on a
single binary, exhaustively and disjointly, by construction.

This is the same shape as E160/E161's own rule, and the catalog row states it:
the module *coordinate* is a coordinate, **one value per axis**. A single
extension slot is not a coordinate. It is one axis.

### Which axis wins the slot

Rank the three by (need-it-before-opening-the-file) × (decidable from surface
syntax by the resolver):

| fact | need before open | resolver-decidable | verdict |
|---|---|---|---|
| entry-ness | **yes** — it decides whether the file may be imported at all | **yes** — `^(def compile-main`, the exact grep that measured 177 | **extension** |
| membrane | useful | **no** — E161 *derives* `Sheet.crossings`; `sys-tal.chiral` has 0 externs (finding 3) | declaration + derivation |
| altitude | useful | no — it is a design fact about lowering | directory |
| typeability A/B/C | yes | **no** — "what does its correctness rest on" is not a token | declaration (E161) |

Entry-ness wins on both columns at once. It is also the only one of the four
whose violation is *already an error* — just a late and unreadable one.

### The revised assignment

- **entry-ness → the extension.** `.main` = defines `compile-main`; may be a
  root, may never be an import target. `.chiral` = everything else.
- **altitude → the directory.** `upper/` `tal/` `metal/`, the one axis that
  nests, per `axis-altitude`'s *lives as high as it can, drops only as far as
  it must*.
- **membrane + typeability → E161's `(module …)`, membrane derived.** The
  catalog's third carrier already exists and already fences: crossings non-empty
  ⇒ not `(cat A)`, refused by name (`test-module-kind.sh` check C). E172 does
  not add a carrier for the membrane. It makes the two carriers that *can* be
  free actually free, so the declaration is the only thing left to hand-write —
  which is the honest way to attack the 13-of-402 adoption gap.

### What chirality makes impossible here

- **A silently-importable entry.** The resolver refuses `.main` as an import
  target *by name*, at the moment it probes the path, before the blob exists.
  `duplicate label` at link time stops being reachable from this cause.
- **A lying extension.** The projection is checked in both directions: a
  `.chiral` defining `compile-main` is refused, and a `.main` that does not is
  refused. There is no third state and no opt-out — unlike OCaml's optional
  `.mli` or GNAT's overridable `pragma Source_File_Name` (§2 finding 4).
- **Subject matter in a carrier.** `banks/module`: a module is individuated *by
  its type, not its subject… Not a file. Not a folder. Not a topic/subject.*
  So `.compiler` / `.stdlib` / `.editor` are illegitimate, and so is a
  `manas/` **kind** — the existing `scaffold/lib/manas/profile/` is a *role*
  directory holding 7 entries, which is legal, and it must not become a
  typeability claim.
- **Purity as a directory.** Purity is the empty effect row, written `->` in
  every signature in the tree — the single best-adopted notation chirality has.
  Giving it a directory would be a second truth about a fact already carried
  perfectly. Pure value modules go in `upper/` because they are *upper*; their
  purity stays in their arrows.
- 2026-09-04: the 2026-08-31 migration moved the tree out of scaffold/. The pre-migration paths kept here name no live directory.

### Answering `sys-tal.chiral` directly

It splits by **neither**. It becomes `tal/sys.chiral` (altitude → directory) and
stays a plain `.chiral` (it defines no `compile-main`). Its membrane-ness is
carried by the declaration it does not yet have and should:

```chirality
(module sys (cat C) (alt tal))
```

`(cat C)` is precisely *"a typed module over an untyped referent, governed by
evidence"* — which is `sys-tal.chiral:1-7` restated in the language's own terms.
The two axes only *appeared* to collide because the catalog gave membrane a
carrier it does not need.

## 5. Chirality example (fleshed)

Lands in `lib/module/resolve.chiral` (and mirrored in `bin/chirality-resolve.sh`).
Boundary-sums directive applies throughout: the classification is parsed **once**
at the path boundary and travels as a value.

```chirality
; ── E172: the file-kind projection ────────────────────────────────────────
; resolve.chiral owns this because it is the ONLY stage that sees a filename:
; compile-driver.chiral:9 reads the blob from stdin, so the compiler is
; filename-blind. The extension is a CHECKED PROJECTION of a surface-syntactic
; fact, never a parallel truth.

; The axis the extension carries. Exactly TWO values, because the extension is
; ONE slot and entry-ness is ONE binary. Membrane and typeability are NOT here:
; E161 derives Sheet.crossings from the call graph, and this code runs before
; any call graph exists.
(data FileKind ()
  (fk-module)                  ; ".chiral" — importable computation
  (fk-entry))                  ; ".main"  — defines compile-main; never imported

; What the FILENAME claims. An unrecognised extension is not an error: the probe
; simply misses it, exactly as today. (Manifests are E163's; do NOT mint a third
; value here.)
(data ExtClaim ()
  (ec-module)
  (ec-entry)
  (ec-none))

; What the SOURCE is. ONE surface-syntactic predicate — the same one that
; measured 177 of 402 — and deliberately nothing derived.
(declare line-starts? (-> Str Str Bool))          ; some line begins with prefix
(declare src-kind (-> Str FileKind))
(def src-kind
  (lam (src)
    (case (line-starts? src "(def compile-main")
      (true  (fk-entry))
      (false (fk-module)))))

; The refusal, as a closed sum: the reason is a VALUE with the blame attached,
; never a string assembled at the throw site (the SkReason precedent, E97).
(data KindErr ()
  (ke-entry-in-module (path Str))                 ; a .chiral that defines an entry
  (ke-module-in-entry (path Str))                 ; a .main that does not
  (ke-entry-imported  (path Str) (importer Str))) ; a .main reached by an import

(data KindR ()
  (kr-ok  (k FileKind))
  (kr-err (e KindErr)))

; The whole gate. `root?` is true only for the name the driver was handed;
; every other probe is an import, and an import may not land on an entry.
(declare check-file-kind (-> Str ExtClaim Str Bool Str KindR))
(def check-file-kind
  (lam (path claim src root? importer)
    (let (actual (src-kind src))
      (case claim
        ((ec-module)
          (case actual
            ((fk-entry)  (kr-err (ke-entry-in-module path)))
            ((fk-module) (kr-ok  (fk-module)))))
        ((ec-entry)
          (case actual
            ((fk-module) (kr-err (ke-module-in-entry path)))
            ((fk-entry)
              (case root?
                (true  (kr-ok  (fk-entry)))
                (false (kr-err (ke-entry-imported path importer)))))))
        ; no extension we recognise -> no claim to check, resolve as before
        ((ec-none) (kr-ok (fk-module)))))))

; Messages: one arm per constructor, so a new reason cannot ship without one.
(declare k-msg (-> KindErr Str))
(def k-msg
  (lam (e)
    (case e
      ((ke-entry-in-module p)
        (str-cat "resolve: " (str-cat p
          ".chiral defines compile-main — an entry must be named .main\n")))
      ((ke-module-in-entry p)
        (str-cat "resolve: " (str-cat p
          ".main defines no compile-main — rename it .chiral\n")))
      ((ke-entry-imported p by)
        (str-cat "resolve: " (str-cat p
          (str-cat ".main is an entry and cannot be imported (from "
            (str-cat by ")\n"))))))))

; ── The probe, and the migration it makes possible ────────────────────────
; Mirrors the existing open-at-root (resolve.chiral:210-226). Probing BOTH
; extensions is what lets ~210 files be renamed in waves instead of a flag day:
; accept both -> rename -> refuse the old. `strict?` is the one bit that flips
; at the end; until it flips, k-msg goes to trace instead of aborting.
(declare openat-str (=> Str I64))
(declare open-at-root (=> Str Str Str I64))
(def open-at-root
  (lam (root subdir name)
    (let (stem (str-cat root (str-cat "/" (str-cat subdir (str-cat "/" name)))))
      (let (fd (openat-str (str-cat stem ".main")))
        (case (<=i 0 fd)
          (true  fd)
          (false (openat-str (str-cat stem ".chiral"))))))))
; …  try-roots probes each -L root IN ORDER, unchanged; only the leaf differs.
```

The altitude carrier is a tree, not code — it is the same 48 import names moved:

```
lib/lowering/tal/ir.chiral      tal/check.chiral  tal/ssa.chiral  tal/erase.chiral
lib/lowering/tal/eval.chiral    tal/reify.chiral  tal/spec.chiral
lib/lowering/tal/bytes.chiral   tal/sys.chiral            ; the two -tal suffixes
lib/lowering/x64/emit.chiral   metal/mach-x64.chiral
lib/lowering/mach/asm-reloc.chiral  metal/elf.chiral
scaffold/lib/upper/…                                    ; everything else
```
2026-09-04: pre-migration scaffold/ path.

- **Knobs to modify:** the entry symbol (`"(def compile-main"`) if the entry
  convention ever changes; `strict?`'s flip point; the probe order in
  `open-at-root` (`.main` first is deliberate — the new extension wins ties so
  a half-renamed tree resolves to the renamed file); the `-L` root list, which
  is what makes `upper/` `tal/` `metal/` reachable without a resolver change.
- **Deliberately omitted:** `.port` and `.prof` (argued away in §4);
  manifests (E163 owns that choice — do not encode one here); the E161
  `(module …)` back-fill from 13 files toward 402, which is a separate,
  purely-additive campaign; the actual `git mv`s; anything that reads a
  *derived* fact, since the resolver cannot.

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/resolve.chiral` (the native provider — the logic is
  **one line**, `:213` `(str-cat name ".chiral")`, plus the two message strings at
  `:427-429`) and `bin/chirality-resolve.sh:55-57` (the shell provider, two
  conditionals). Both, together, or neither.
- **Conformance target:** `scaffold/tests/test-resolver-collision.sh` already
  exercises **both** providers, so it is the natural home for the new cases.
  Golden behaviour: (a) `B1 < blob` is unchanged — the compiler stays
  filename-blind; (b) an `import` naming a `.main` fails at *resolve* with
  `ke-entry-imported`, not at link with `duplicate label`; (c) the mutant —
  `git mv x.main x.chiral` — is refused with `ke-entry-in-module`; (d) the
  inverse mutant, a `.main` with the entry deleted, is refused with
  `ke-module-in-entry`; (e) the fixpoint still reproduces byte-identically.
- **Open questions (a spec must settle these; none is settled here):**
  1. **E155's collision key vs. the altitude directory.** `tal-ir` → `tal/ir`
     renames the *module*, and the collision key is the post-slash basename
     (`chirality-resolve.sh:53`; `resolve.chiral:422-429`). No collision exists today
     for the 13 proposed moves (checked), but 10 basenames are *already*
     duplicated tree-wide. Either the key becomes the root-relative name, or
     the altitude directory is a slow-motion collision generator. This is the
     one genuinely open dependency and the spec must pick — not defer.
  2. `scaffold/lib/scriba/prelude.chiral` is a **symlink** to
     `scaffold/lib/prelude.chiral` (`resolve.chiral:26-27`). Any rename wave has
     to move link and target coherently.
  3. Does `.main` change how `chirality test` discovers the 137 fixture entries in
     `samples/`, or is `samples/` still the discovery key? (§4 says role →
     directory, so probably the latter — but the runner is not read here.)
- **Related:** [[E160-module-coordinate]] · [[E161-module-datasheet]] ·
  [[E155-basename-collision]] · [[E163-manifest]] (owns the manifest choice —
  untouched here) · [[axis-altitude]] · [[banks/module]] ·
  [[pattern-boundary-sums]] · [[U15]] (`TUI/scriba/file-io.chiral:99`
  `mode-from-path` — the same extension→kind binding, one tier down, already
  shipped).

### Corrections to the E172 catalog row (report, do not patch)

The catalog is outside this run's write surface. Five claims came out different:

1. **"E160's coordinate is declared in 6 files of 402, all scriba."** Measured:
   E160's `(kind …)` form is declared in **0** files — E161 replaced it. The
   live form `(module N (cat X) (alt Y))` is in **13**, of which 8 are
   `scaffold/lib/` and 5 are `TUI/`. The "6, all scriba" figure matches a loose
   `grep '(kind '`, whose six hits are the *identifier* `kind` (a `lam` binder
   in `command-loop.chiral:208`, a `Str` field in `flow.chiral:108`, …) and are
   3 scriba + 3 manas. The argument survives — 13/402 is still built-but-
   unadopted — but the number and the form are both wrong.
2. **"28 declare a `porttype`/`extern`."** Measured **31**
   (`^(porttype` → 13, `^(extern` → 31, union 31; 36 if indented `(extern` is
   counted). More importantly the predicate is the wrong one: `sys-tal.chiral`
   has **zero** and *is* the membrane.
3. **"`scaffold/lib/resolve.chiral` (18 sites)."** 18 lines *mention* `.chiral`;
   **one** is logic (`:213`), two are message strings (`:427`, `:429`), fifteen
   are comments. The change surface is far smaller than the row implies.
4. **"~250 test path literals."** Measured **615** `*.chiral` literals across
   tracked `*.sh` + `*.py` (177 in `scaffold/tests/*.sh` alone). Larger, not
   smaller — but §2 finding 2 offsets it: **0 of 1182 import sites change**, so
   the churn is entirely in tooling paths, which is `sed`-able and testable.
5. **"the 132 fixtures stay entries."** Measured **137** entry files under
   `samples/` dirs (56 `scaffold/samples` + 51 `scaffold/tests/samples` + 30
   `scaffold/tests/samples/_wip`), of 177 total.

And one design disagreement, argued in §4 rather than measured: the row's
four-extension set and its "membrane + entry → extension" assignment are
**refuted by the 9 files that are already both**, and by `sys-tal.chiral`, which
the resolver cannot classify because the fact is derived. The example proposes
two extensions and leaves the membrane where E161 already put it.

**Suggested next element:** E163 (manifest form) — it is the only remaining open
choice adjacent to this one, and it must not be answered by an extension.
