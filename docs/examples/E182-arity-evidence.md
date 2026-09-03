---
element: E182
slug: arity-evidence
title: **The arity judgments carry their arity**
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-09-02
---

# E182 — **The arity judgments carry their arity**

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E182. An arity refusal knows two integers at the moment it
  refuses, and today it throws both away and returns a nullary `Judg` tag. This
  element mints `r-arity (what Subject) (expected I64) (actual I64)` as a tenth
  `Reason` arm and repoints the detection sites at it.
- **Kind:** BUILD-PROPER. Nothing under `docs/banks/` supplies a shard of this;
  the evidence-bearing `Reason` sum is E157's and is built, and the gap is one
  missing arm on it plus the sites that feed it.
- **Why chirality needs its own:** E157's own taxonomy line is *one constructor
  per evidence shape, not per message*, and E157 shipped `Judg` as 38 nullary
  arms anyway, forced by a byte-identity golden on the pre-E157 strings. This is
  the first repayment of that debt, and the arity family is the cleanest place to
  take it because the discarded evidence is two `I64`s rather than a `Term`.

**⚑ The catalog premise is wrong in two of its three parts, and this example is
written against the measurement instead.** The row proposes retiring
`jg-tcon-arity` / `jg-ctor-arity` / `jg-ctor-arg-arity` and asserts all three
have "expected/actual counts live at the detection site and dropped". Measured:

| named arm | its only site | is it a comparison? | reachable? |
|---|---|---|---|
| `jg-tcon-arity` | `kernel.chiral:1050`, `check-tparams` | no, a structural-exhaustion arm | **no** |
| `jg-ctor-arity` | `kernel.chiral:1107`, `check-con-args` | no, a structural-exhaustion arm | **no** |
| `jg-ctor-arg-arity` | `kernel.chiral:1097`, `con-check` | **yes**, `(=i (llen Term args) (llen Field fields))` | yes |

And a fourth arm the row does not name is the second live comparison:
`jg-tparam-arity` at `kernel.chiral:1042` in `check-tcon`, guarding
`(=i (llen Term args) (llen Term (decl-params decl)))`. It renders
`(str-cat n " wrong number of type parameters")`, so it has no stub to give it
away, which is presumably why the stub-hunting that minted this row missed it.

So the honest element is **not** "retire three, mint one". It is **mint one arm
and repoint the two live comparisons at it**, one of which the row did not name,
while two of the three arms the row did name turn out to be dead code that a
separate decision must dispose of.

## 2. Research

- **Reference class:** `OURS`. The in-tree defect is E157's `Judg`
  (`lib/typing/diag.chiral:99-121`) and its four call sites in
  `lib/typing/kernel.chiral`. No external baseline; the comparison class in §3 is
  rustc's diagnostic structs, from knowledge.

**Finding 1 — two of the three arms are unreachable, proved by source and by
probe.** `check-tparams` has exactly one caller, `check-tcon:1043`, and that call
is gated at `:1041` on `(=i (llen Term args) (llen Term (decl-params decl)))`
being true. The recursion at `:1054` steps `params` and `args` together. So
`params` non-nil implies `args` non-nil, and the `(nil ... jg-tcon-arity)` arm at
`:1050` cannot fire. The same argument runs for `check-con-args`: its one caller
`con-check:1098` is gated at `:1096` on `(=i (llen Term args) (llen Field
fields))`, and `fts` comes from `ctor-field-types`, which emits exactly one
`pair` per `field` on its ok path (`:1020-1031`), so `llen fts == llen fields`.
The `(nil ... jg-ctor-arity)` arm at `:1107` cannot fire either.

Source-reading is not the evidence here; four probes are. Both directions of both
errors, compiled with the shipped binary:

| probe source | compiler said |
|---|---|
| `(the (Box I64 I64) (mk 1))`, `Box` has one param | `load: Box wrong number of type parameters` |
| `(the (Box2 I64) 0)`, `Box2` has two params | `load: Box2 wrong number of type parameters` |
| `(mk2 1)`, `mk2` has two fields | `load: mk2 wrong number of arguments` |
| `(mk3 1 2 3)`, `mk3` has two fields | `load: mk3 wrong number of arguments` |

Neither stub string appeared in any refusal. `"tcon arity"` and
`"constructor arity"` are strings the compiler cannot currently emit.

**Finding 2 — the arm that cannot be retired is one of the dead ones.**
`tools/test/samples/e158_doc.prog:188-189` builds
`(r-judged (subj-ctor "Nope") (jg-ctor-arity))` and asserts the rendered doc
contains `"constructor arity"`. Removing that arm stops the fixture compiling.
Of the three arms the row names, the fixture pins exactly the one whose site is
dead, and leaves the one live site free.

**Finding 3 — a tenth `Reason` arm costs eight renderer arms and nothing else
breaks.** Every exhaustive `case` over `Reason` in the tree is in `diag.chiral`,
and there are eight, by their `def` lines: `dg-reason-tag:145`,
`dg-subject:193`, `dg-incumbent:209`, `dg-newcomer:223`, `dg-declared:259`,
`dg-observed:273`, `dg-msg:317`, `dg-doc:519`. `lib/module/loader.chiral`
constructs `Reason` values and never cases one. The comment above `dg-msg` states
the design intent this depends on:
*NO `_` arm, on purpose: a new Reason constructor must break every renderer
loudly.* Adding the arm is therefore a compile error at eight known places, which
is the desired failure mode.

**Finding 4 — rustc carries the counts as struct fields, not in the string.**
`E0061` (wrong number of function arguments) and `E0107` (wrong number of generic
arguments) are both backed by diagnostic structs holding `expected` and `found`
as integers, rendered late. That is the same move this element makes, arrived at
independently: the renderer formats, the checker reports.

## 3. Conventional (other-language) approach

Rust, in the shape most compilers reach for first, before the diagnostic gets
promoted to a struct:

```rust
// The counts are in hand. They are formatted, and then they are gone.
if args.len() != fields.len() {
    return Err(TypeError::new(format!(
        "{}: wrong number of arguments (expected {}, found {})",
        ctor_name, fields.len(), args.len()
    )));
}
```

- **Assumptions it bakes in:**
  - **Evidence lives in a string.** Anything downstream that wants the numbers
    back has to parse English out of the message, so nothing downstream ever
    does. A JSON emitter, an LSP frame, an autofix that inserts the missing
    argument: each re-derives or gives up.
  - **The message is the type.** Two errors with different evidence are the same
    Rust type, so the compiler cannot tell you that a renderer forgot one. The
    exhaustiveness check has nothing to check.
  - **A dead branch is invisible.** `TypeError::new` accepts any string, so an
    unreachable error path costs nothing to keep and nothing announces it. This
    is exactly how `jg-tcon-arity` and `jg-ctor-arity` survived.
  - **Partiality is available.** The conventional escape when the two counts are
    inconvenient to compute is to say less. Here that is not available: the
    function must return something total, and the something is a value.

## 4. The chirality idea

- **Chirality features in play:** closed sums with coverage-checked `case`
  (the boundary-sums standing directive), totality, the `->` membrane on the
  whole diagnostic path (no renderer crosses), `I64` as the only number.
- **The reframing.** The standing directive's test applies verbatim: *if
  information exists at point A and is re-derived or absent at point B, carry it
  as a field instead.* `con-check` holds `(llen Term args)` and
  `(llen Field fields)` on the line above the refusal (`kernel.chiral:1096-1097`)
  and hands neither of them on. `check-tcon` holds `(llen Term args)` and
  `(llen Term (decl-params decl))` at `:1041-1042` and does the same. So the fix
  is a field, and the field belongs on `Reason`, not on `Judg`: `Judg` is by
  construction the sum whose arms have no payload beyond their subject, and the
  comment above it says so.
- **The precedent is already in the tree, twice.** `r-mismatch` carries two
  `Term`s where `subsume` used to say only "type mismatch". `r-usage` carries
  both `Qty`s where `dg-usage-msg` collapses nine subjects into one sentence.
  `r-arity` is the same move over `I64` instead of `Term` or `Qty`, and it is the
  cheapest of the three because `I64` needs no pretty-printer.
- **What chirality makes impossible here:**
  - **A renderer that ignores the new arm.** Eight `case`s have no `_` arm, so
    the tenth constructor is eight compile errors, not eight silent fallbacks.
  - **An arity diagnostic that cannot say the numbers.** Once the field exists,
    constructing an `r-arity` without both counts is not expressible.
  - **A dead error path that reads as live.** Not by the type system, but by the
    thing that found it: the arm's payload obligation forces you to name where
    `expected` and `actual` come from, and at `:1050` and `:1107` there is no
    honest answer, because the lists were already proven equal. The payload turns
    an unreachable branch into a question you cannot skip.

## 5. Chirality example (fleshed)

```chirality
; ---------------------------------------------------------------- diag.chiral
; The tenth Reason arm. Both counts are I64 because the floor is I64, and
; `expected` comes first to match r-mismatch's (expected, actual) field order.
(data Reason ()
  ; … the nine arms E157 shipped …
  ; an arity disagreement, both counts as the integers the site had in hand
  (r-arity      (what Subject) (expected I64) (actual I64)))

; Two accessors, so a consumer reads the counts off the reason rather than the
; text. Named for the fields, following dg-declared / dg-observed.
(declare dg-expected (-> Reason I64))
(declare dg-actual   (-> Reason I64))
; Every OTHER arm answers 0. That is a real answer: "this reason has no arity".
; … eight sibling arms elided, one line each …

; The eight existing cases each gain one arm. Two are load-bearing:
(def dg-reason-tag
  (lam (r)
    (case r
      ; … nine arms …
      ((r-arity w e a) "arity"))))

(def dg-subject
  (lam (r)
    (case r
      ; … nine arms …
      ((r-arity w e a) w))))

; The flat exit. i64->str is the prelude extern (prelude.chiral:84); diag.chiral
; already uses it at :670 for dg-dd-arity, so this is not a new dependency.
; ⚑ THE WORDING BELOW IS THE SKETCH AND THE TREE DOES NOT CARRY IT. The SPEC's
; decision 4 settled on the existing sentence as a prefix with the counts
; appended: "<name> wrong number of <noun> (expected N, actual M)", which is
; what §1, G2, G5 and G6 pin and what shipped at 65bec90. This example is the
; design rationale and keeps its own draft.
(declare dg-arity-msg (-> Subject I64 I64 Str))
(def dg-arity-msg
  (lam (w e a)
    (str-cat (dg-subject-name w)
      (str-cat " expected " (str-cat (i64->str e)
        (str-cat " argument(s), got " (i64->str a)))))))

; The Doc exit. Head is the sentence; the two counts are their own laid-out
; lines, so a narrow width breaks between them instead of inside one.
; Mirrors the r-usage arm at diag.chiral:564 field for field.
(def dg-doc
  (lam (r)
    (case r
      ; … nine arms …
      ((r-arity w e a)
        (d-group
          (d-cat
            (d-tag "diag-head"
              (doc-concat (cons (d-text (dg-arity-msg w e a))
                          (cons (d-text " (")
                          (cons (d-text (dg-subject-tag w))
                          (cons (d-text ")") nil))))))
            (d-nest 2
              (doc-concat
                (cons (d-line (brk-space))
                (cons (d-text "expected ")
                (cons (d-text (i64->str e))
                (cons (d-line (brk-space))
                (cons (d-text "actual ")
                (cons (d-text (i64->str a)) nil))))))))))))))

; -------------------------------------------------------------- kernel.chiral
; SITE 1 (:1096-1097). The comparison whose operands were discarded. Nothing
; moves except the reason that is built: the two llen calls already exist on the
; line above, so this is a re-use, not a recomputation.
(def con-check
  (lam (sig c dn cn args targs fields)
    (case (ctor-field-types sig (rev-vals targs) fields)
      ((ft-err m) (tc-err m))
      ((ft-ok fts)
        (case (=i (llen Term args) (llen Field fields))
          (false (tc-err (r-arity (subj-ctor cn)
                                  (llen Field fields)      ; expected
                                  (llen Term args))))      ; actual
          (true  ; … unchanged, verbatim from :1098-1100 …
                 (case (check-con-args sig c args fts (uzero (ctx-len c)))
                   ((u-err m) (tc-err m))
                   ((u-ok u)  (tc-ok (v-tcon dn targs) u)))))))))

; SITE 2 (:1041-1042). The one the catalog row did not name. Same shape.
; This retires `jg-tparam-arity`, which the row does not mention, and NOT
; `jg-tcon-arity`, which the row does.
(def check-tcon
  (lam (sig c dn args expected)
    (case (sig-data sig dn)
      (none (tc-err (r-unbound (subj-data dn))))
      ((some decl)
        (case (=i (llen Term args) (llen Term (decl-params decl)))
          (false (tc-err (r-arity (subj-data dn)
                                  (llen Term (decl-params decl))
                                  (llen Term args))))
          (true  (check-tparams sig c (decl-params decl) args nil expected dn)))))))

; SITES 3 and 4 (:1050, :1107) are UNCHANGED by this snippet, on purpose.
; They are the two unreachable arms. They stay exactly as they are, because
; `jg-ctor-arity` is pinned by a fixture this element may not edit, and because
; removing an unreachable branch is a totality question, not an evidence one.
```

- **Knobs to modify:**
  - The `dg-arity-msg` wording. It is a new string, so no golden constrains it,
    but E157 owns `dg-msg` byte-identity for the nine arms that existed, and a
    tenth arm's message should be settled once here rather than drifted later.
  - Whether `dg-expected` / `dg-actual` return `0` or a `(Maybe I64)` for the
    other nine arms. `0` matches how `dg-declared` answers `(qw)` for arms with
    no quantity; `Maybe` is more honest and costs a sum at every call site.
  - Field order. `(expected, actual)` follows `r-mismatch`; `(actual, expected)`
    would follow nothing.
  - Whether `subj-ctor` / `subj-data` stay the subjects, or a new `Subject` arm
    distinguishes "type parameters" from "constructor arguments" so the message
    can say which. Today the sentence would have to carry that distinction.

- **Deliberately omitted:**
  - Retiring any `Judg` arm. See §6; two of them cannot be removed and the third
    is a separate question.
  - Any change to `dg-msg`'s nine existing strings. E157 pins those.
  - The other 34 nullary `Judg` arms. This element repays one family.
  - `lib/prelude/doc.chiral`. The snippet uses six existing `Doc` constructors and
    adds none.

## 6. Use / modify notes

- **Lands in:** `lib/typing/diag.chiral` (the arm, two accessors, eight `case`
  arms, `dg-arity-msg`) and `lib/typing/kernel.chiral` (two detection sites).
  Both are inside `prog/compiler.prog`'s closure.

- **Conformance target:** the four probe refusals in §2 finding 1 keep their
  meaning and gain their numbers. `load: mk2 wrong number of arguments` becomes a
  sentence carrying `expected 2` and `actual 1`, and `dg-doc` lays both out on
  their own lines. Everything E157 pins byte-for-byte stays byte-identical,
  because none of the nine arms it pins is touched.

### The build rule, and the precondition FD-08 accepted

`lib/typing/{diag,kernel}.chiral` are compiler sources, so **E182 owes
`build-new → test → promote` and a promotion of `bin/chirality-bin`.** It was
measured before any edit, on the unmodified tree, and the precondition does not
hold:

```
. bin/chirality-resolve.sh
chirality_blob_file "lib:prog" prog/compiler.prog > blob.chiral   # 804,277 B
(ulimit -s unlimited; bin/chirality-bin < blob.chiral > B1)       # 1,184,120 B
cmp B1 bin/chirality-bin        # DIFFER at char 98 (shipped is 1,147,256 B)
chmod +x B1; (ulimit -s unlimited; ./B1 < blob.chiral > B2)       # 1,184,120 B
cmp B1 B2                       # DIFFER at char 1,180,606, 14 bytes
chmod +x B2; (ulimit -s unlimited; ./B2 < blob.chiral > B3)
cmp B2 B3                       # EQUAL
```

Every artifact was checked non-empty first. The B1 build is deterministic
(rebuilt and byte-identical). The 14 bytes are zeros in B1 and a function body in
B2:

```
48 8b 35 ..   mov rsi, [rip+..]
48 8b 05 ..   mov rax, [rip+..]
48 29 f0      sub rax, rsi
c3            ret
```

Two globals subtracted, which reads as the arena counter from
`7341ddf ports/process: heap-allocated, the arena counter a program can read`.
`bin/chirality-bin` was last promoted at `58603c3` (E181, 2026-09-01) and
**thirteen commits have touched `lib/` or `prog/` since**, including that one,
E11's `(total)`, and all five of E173's matcher slices. The shipped binary trails
its sources by one generation, and `B1 != B2` with `B2 == B3` is the ordinary
two-generation bootstrap: `7341ddf` changed emitted code, so the shipped binary
omits that body where `B1` emits it, and the tree reaches its fixpoint at
generation two.

**`records/findings.md` FD-08 records exactly this measurement, state ACCEPTED,
and nothing here is broken.** It is inherited, it is pre-existing, and it is
E182's to report rather than E182's to fix. The one consequence that survives is
attribution: an element promoting from this base reports blob and binary deltas
carrying thirteen commits of other arcs' work.

### The promotion choice, which FD-08 hands to the SPEC

FD-08 names E182 as the next element to promote from this base, and it leaves
that element two honest ways to report. Either promote once from the unmodified
tree beforehand, so the element's own deltas are its own, or promote in one step
and report the inherited delta and the element's delta separately. **The SPEC
disposes of this.** Re-filing it as a defect would re-argue an ACCEPTED finding.

### FLAG (ownership, record only)

`docs/decisions/decision-lane-split.md` enumerates Lane A's writable files at
`:94-97` and the diagnostics arc's measured write set at `:245`.
**`lib/typing/kernel.chiral` is on neither list.** The same document's prose at
`:260` says "`lib/typing/` belongs to diagnostics. The enforcement arc names no
path under it", which covers it at directory granularity. So E182's detection
sites are permitted by the prose and unlisted by both enumerations. Not resolved
here, and the decision document is not edited here.

### FLAG (scope, author-tier: raised by the EXAMPLE audit 2026-09-02)

The catalog row proposed retiring three arms. The measurement in §1 leaves one
arm actually retired (`jg-tparam-arity`), with two dead arms staying in place and
one of them unretirable behind a sha256 pin. The element shrank under its own
research, so the question the row's rationale no longer answers is:

> Does `r-arity` carrying `(what Subject) (expected I64) (actual I64)` still pay
> for a tenth `Reason` arm and the eight renderer arms that arm costs, when it
> repoints two call sites?

**Not resolved here.** Two facts already settled elsewhere bear on it and are
recorded rather than weighed: the boundary-sums standing directive's test is met
verbatim at both sites (both counts exist at the comparison and are absent at the
renderer), and `docs/decisions/decision-lane-split.md` makes closing E182 part of
Lane A's definition of done. What neither settles is whether the shrunken version
is the version the author wants, and correcting the catalog row's three-arm
premise is an author's write into a file this audit may not touch.

### The traps, measured

1. **The `e158_doc.prog` pin is worse than framed.** The expected string
   `"constructor arity"` lives in the **fixture** (`:189`), not in the bash;
   `doc.sh` only names the path (`:51`) and reports an exit code (`:99`). But the
   fixture **is** sha256-pinned, in three places:
   `face.sh:545,556` and `row.sh:644,654` both hold
   `DOC_FX_SHA=56292ca8dfd175eb3bd1e7b79aa1b1e0b6971cde8478632790906a995fada584`,
   and `pretty.sh:371` carries the same literal. That is the file's live sha.
   So editing the fixture reddens Phases 16, 15 and 18 as well as 14.
   **`jg-ctor-arity` cannot be retired by this element at all.** The design in §5
   keeps it, which costs nothing, because the arm is dead anyway.
2. **The comment at `e158_doc.prog:190-194` guards a different row.** It sits on
   row 14, the `dg-usage` control, and anticipates someone "fixing" `dg-msg` to
   carry the two quantities. E182 touches neither `dg-usage-msg` nor any pinned
   string, so **E182 is not that reconciliation**. It is the same class of hazard
   one row earlier: row 13 pins `jg-ctor-arity` with no such comment on it. The
   anticipation was written and then attached to the wrong neighbour.
3. **The `diag.sh:288` census does not move.** It builds a name set from
   `diag.chiral` and asserts that **none of those names is redefined anywhere
   else in `lib/` or `prog/`** (`:303-305`). `$nnames` is interpolated into the
   pass message and never compared to a literal. `r-arity` currently appears
   nowhere in `lib/` or `prog/`, so the set grows by one, shrinks by nothing in
   the §5 design, and no assertion moves.
4. **A tenth `Reason` arm does not redden `e157_diag.prog`, it silently weakens
   it.** The fixture never `case`s over `Reason`. It builds nine values and joins
   their tags (`:50-63`), and case 19 asserts the join equals
   `"redeclared,mismatch,usage,linear,arrow,unbound,skipped,judged,relayed,"`.
   Adding `r-arity` leaves that string untouched, so the row still passes while
   its own comment, *one value of EVERY Reason arm, so the exhaustiveness row is
   real*, becomes false. `doc.sh:230` repeats the claim. Both files are
   sha256-pinned (`doc.sh:442-443`, `DIAG_FX_SHA=713fe84d…`) and cannot be
   corrected. **The exhaustiveness row degrades from ten-of-ten to nine-of-ten
   and nothing goes red.** E182 must bring its own row asserting the tenth tag,
   on its own fixture, or the guarantee quietly shrinks.

### The gate E182 owes

**⚑ Phase 19 is taken.** `tools/test/run-tests.sh:301` runs
`run_phase 19 "the total matcher (E173 pd + norm)" matcher.sh`. **The next free
phase is 20.** A gate that assumed 19 would collide.

Three rows, each with a mutant that is run:

| row | asserts | mutant | must |
|---|---|---|---|
| G1 tenth-arm exhaustiveness | a new fixture joins **ten** tags and gets `…,judged,relayed,arity,` | drop the `r-arity` arm from `dg-reason-tag` | not compile (no `_` arm) |
| G2 evidence survival | `dg-doc` of `(r-arity (subj-ctor "mk2") 2 1)` contains both `"2"` and `"1"`; `dg-msg` of the same contains both too | `dg-arity-msg` stops calling `i64->str e` | G2 fails on the missing `"2"` |
| G3 the site actually reports | compile a two-field ctor applied to one arg, assert stderr contains `expected 2` and `actual 1` | revert `con-check` to `(r-judged … (jg-ctor-arg-arity))` | G3 fails |

G3 is the row that matters, and it is the one the eleven toothless rows found
across this arc did not have: it drives a real refusal through a real compile
rather than grepping the source that would satisfy it. **G2's mutant must corrupt
`dg-arity-msg`, not the `Reason` arm** — corrupting the arm makes the fixture
fail to compile, which convicts G1 and leaves G2 unexercised.

### Residue, carried as arc-local ids

Two pieces of work fall out of the measurement, and `E184-E189` is contended with
the enforcement arc, so both took arc-local ids under
[[decisions/decision-work-ids]] instead of an `E#`. Their rows are in
[[arcs/diagnostics-arc]] under Numbering, named 2026-09-02 by this pre-run. An id
claims identification and nothing else, so a citation made now survives the
number arriving.

- **`diagnostics/D1`, the two provably unreachable `Judg` arms get a
  disposition.** `jg-tcon-arity` at `kernel.chiral:1050` and `jg-ctor-arity` at
  `:1107` are dead branches kept for totality, and one of them is spelled by a
  sha256-pinned fixture. Whether such an arm should be removed, kept with the
  proof written beside it, or refused by a totality gate is a real question and
  it belongs to `diagnostics/D1` rather than to E182.
- **`diagnostics/D2`, the `Reason` exhaustiveness claim becomes checkable.**
  `e157_diag.prog:50` and `doc.sh:230` will both assert something false the
  moment a tenth `Reason` arm lands, and both are sha256-pinned. Repairing them
  is a change to E157's and E158's gates and belongs to whoever owns those.

### Open questions for the SPEC

- Which of the four sites the SPEC actually repoints. §5 argues two (the live
  comparisons). Repointing all four would require inventing `expected` and
  `actual` at two places where the lists were already proven equal.
- Whether `jg-tparam-arity` is removed once `check-tcon` stops building it. It
  has no other site, so it would become a fourth dead arm, and it is not named by
  the catalog row, so removing it is a scope widening the SPEC must state.
- The `dg-expected` / `dg-actual` return shape (see §5 knobs).

- **Related:** [[E157-typed-diagnostics]] (the `Reason` sum, the nine pinned
  goldens, the 38-arm `Judg` this repays), [[E158-doc-formatter]] (`dg-doc`, the
  fixture that pins `jg-ctor-arity`, and the audit FLAG B that minted this row),
  E159 (`r-linear` / `r-arrow`, the payload-carrying precedent; no example file
  in `docs/examples/`),
  [[E181-pretty-term-doc]] (Phase 18, and the promotion FD-08 measures this base
  against).
