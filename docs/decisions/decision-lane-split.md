---
node: decision-lane-split
layer: decision
status: DECIDED
decided: 2026-08-31
related: [decisions/decision-dispatch-cadence, decisions/decision-work-ids, arcs/README, arcs/diagnostics-arc, arcs/file-types-arc, arcs/enforcement-arc, arcs/transport-arc, arcs/text-tools-arc, arcs/zero-python-arc, arcs/unit-lane-arc, banks/unit, benchmarks/text-matcher-allocation, records/author-calls, elements/README, index]
updated: 2026-09-06
---

# Decision: two lanes, and what enforces the seam

**Decided 2026-08-31** so two sessions can run at once without colliding. Read
this before starting either lane.

> Moved from the repository root to `docs/decisions/` on 2026-09-01, unchanged.
> It was never a handoff: it settles a division of work and reserves element
> number bands, and 16 tracked files cite it for those bands. The root now holds
> the spine only. The chain both lanes serve is at the top of
`docs/arcs/diagnostics-arc.md` (was `HANDOFF-DIAGNOSTICS-ARC.md`, moved
2026-09-01); this file is only the *division*.

---

## The split

| | **Lane A — diagnostics & errors** | **Lane B — file types** |
|---|---|---|
| owns | `E181` pretty · `E182` arity evidence · `E176` `str-sub` · `E179` face registry · `E180` face redraw · adoption of `dg-doc` | `E146` value→source · `E163` `.manifest` · `E183` `.protocol` |
| lands in | `lib/typing/`, `lib/protocol/render*.chiral` | `lib/manifest/` (new), `lib/protocol/` codecs, `prog/` emitters |
| gate phases | **18, 19, 20** | **21, 22, 23** |
| element numbers | **E184–E189** | **E190–E195** |

`E189` is taken, 2026-09-05: the `op-mulhi` surface extern, minted for the AI lane's
fixed-point multiply-accumulate. `docs/arcs/native-protocol-arc.md`'s crypto
pipeline cites it as a route it refuses. Owned by neither arc. Lane A's band is now
spent, **and that no longer blocks anything**: see the ruling below.

## Bands may overlap, and they are advisory

**Ruled 2026-09-06 by the author: let overlap exist.** A band is where an arc's
numbers *start*. It owns nothing exclusively, and two arcs may be handed the
same range.

That dissolves the exhaustion problem rather than managing it. Lane A's
`E184-E189` is spent, and before this ruling [[arcs/enforcement-arc]] and
[[arcs/diagnostics-arc]] could mint nothing at all while twelve other arcs held
no band and carried 146 unminted rows between them. Under overlap none of that
blocks: an arc mints the next number free **tree-wide**, and a band only says
where to look first.

**A collision is stopped by the allocator and the roster.** A band stops none.
`pack.py <arc>/<id> --mint` reads both `docs/elements/catalog.md` and
`docs/elements/ledger.md`, takes the lowest number free in either, and writes
the roster row. The 2026-09-01 double-mint of `E173` happened because two
sessions hand-picked a number out of one range; a band cannot prevent that and
an allocator does. `ledger-lint` check AE fails an element present in one
document and absent from the other, which is the same collision seen from the
other side.

**An arc with no band still mints.** It takes the next free number and records
the range it landed in. [[decisions/decision-work-ids]] already gives its
rows citable ids until then.

**A third band, `E196-E239`, reserved 2026-09-05 for the unit lane.** 44 slots
against the 42 rows `.planning/AI-LANE-GAP.md` tables, two of headroom. The
unit lane is real work with a roster ([[banks/unit]], `.planning/AI-LANE-GAP.md`).
[[decisions/decision-work-ids]] allows arc-local ids only until a row needs
citing by a spec, and that is the gap this band closes: [[arcs/unit-lane-arc]]
carries the roster, and its 42 rows can now be cited once an element is
minted for one. Every row stays `unminted` until then.

Phases 1–7 and 13–17 are taken. 8–12 are names still owed to unported old-tree
phases — **do not reuse them**; a number that once meant something else is worse
than a fresh one.

---

## The shared seam: `Doc` and `pretty` — enforced, not agreed

Both lanes print. That is the collision risk, and it is **already mechanical**.
Nothing below is etiquette; each rule names the thing that fails if it is broken.

### `Doc`'s algebra is CLOSED, and two gates prove it

`lib/prelude/doc.chiral` has six constructors and deliberately no seventh. That is
not a request to leave it alone — **adding an arm reddens two phases immediately,
in mutants that are actually run**:

- `tools/test/doc.sh` **M5 `add-seventh-constructor`** — adds an arm and nothing
  else, and asserts the compile is **refused**. Its failure text is the point:
  *"a 7th `Doc` arm compiled clean; the closed sum buys nothing."*
- `tools/test/render-doc.sh` **M10 `add-seventh-Doc-constructor`** — the same
  against `render-doc`'s coverage, because `rdc-best`/`rdc-tree` carry no `_` arm.

So a lane that adds a constructor does not "break an agreement" — it fails Phase 14
and Phase 17, in the other lane's gate, on the next run. **The invariant is in the
substrate.** (A `_` catch-all would defeat this, which is why neither gate has one
and why adding one is itself a mutation those rows catch.)

### The extension mechanism is CONVERSION, and it is already the decided pattern

A lane that needs something `Doc` cannot express does **not** add an arm. It builds
its own type and converts *into* `Doc`. This is not invented here — it is the call
E158 already made and gated: **`Doc` does not unify with `Rendering`; it
converts** (`doc->rendering`), because four of `Rendering`'s eight constructors
carry interaction state that has no meaning in a layout algebra. Same rule, same
reason: a shared closed sum stays small by *pushing difference into conversions*.

**If a lane genuinely needs a seventh arm, that is an ELEMENT** — a row, a
pre-run, an audit — because changing a closed sum that two lanes case over
exhaustively is design work with a measured blast radius, not a commit. The gates
above are what make that unavoidable rather than optional.

### `E181` (now `surface/pretty.chiral`) is Lane A's, and Lane B consumes it — **BUILT 2026-09-01**

Not seniority — Lane A has the forcing consumer already in the tree.
`diag.chiral:125`'s `r-mismatch` carries **two `Term`s** with no reachable `Term`
renderer, which is exactly why E158 had to ship `dg-term-tag` as a flat one-level
accessor instead of a real printer. Lane B's `E146` needs the same printer *later
in its own sequence*, so **Lane B starts on the half that does not need it** — the
declared form, the schema, the round-trip gate's shape, `.protocol`'s codec
derivation — and integrates when E181 lands.

**Lane B must not write its own term printer.** The enforcer here is a census, not
a promise: E158's **G6** greps `lib prog tools` for every `prelude/doc.chiral`
binding and fails on a duplicate definition, with **M6 `redefine-doc-fits`**
proving it can see one. A second printer defining the same names is caught the same
way. This is the duplicate-owner defect this repo has already fixed four times —
`str-cmp`, `list-sort`, `list-dedup-adj`, `Ord`.

## File ownership — explicit, so nobody has to guess

**Lane A may write:** `lib/typing/pretty.chiral` · `lib/typing/diag.chiral` ·
`lib/protocol/render.chiral` · `lib/protocol/render-doc.chiral` ·
`lib/prelude/string.chiral` (E176) · `tools/test/{face,render-doc}.sh` and new
Lane-A gates.

**Lane B may write:** `lib/manifest/**` (new) · `lib/protocol/{json,http,wire,apc,vt-parser}.chiral`
· `prog/` emitters · new Lane-B gates.

**Neither writes these, and in each case something fails if they do:**
`lib/prelude/doc.chiral` — the two seventh-constructor mutants above ·
`bin/chirality-bin` — **⚑ clarified 2026-08-31, because as first written this
contradicted the very rule it cited.** What is forbidden is **hand-editing it, or
replacing it in place**. What is *required*, of a lane whose deliverable **enters
the compiler's closure**, is to promote it — build-new → test → promote, with the
fixpoint verified and `C` checked non-zero before every `cmp`. E181 is the first
element in this arc whose deliverable enters the blob, so E181 promotes; E174,
E175 and E158-c4 measured *outside* the closure and correctly did not.
**Two obligations come with promoting:** (a) a **precondition** — on the
unmodified tree, `B1(blob)` must already equal `bin/chirality-bin`, so a
staleness inherited from a merge is caught as a merge's and not blamed on the
element (this arc nearly convicted E181 of exactly that: the binary was two
generations stale, `C1 ≠ C2`, `C2 = C3`, and promoting `C1` would have installed
a binary that does not reproduce itself); and (b) **tell the other lane the moment
it lands** — any measurement they took against the old binary was taken against a
different compiler. A mismatched binary/blob pair produces the inverted "the
binary is stale" diagnosis this repo has already been caught by ·
**another lane's gate script** — every gate **sha256-pins its neighbours**, and
those pins are checked rows with their own `move-a-pinned-gate` mutants, so
touching one reddens the other lane's phase on the next run. Converging a pin
edit takes a fixpoint pass, because each gate pins the others.

---

## ⚑ Element numbers: the guard we did not have

`.planning/` is **untracked** by master's own decision, so the element catalog —
the file that makes a number unique — is exactly what git cannot help two sessions
agree on. **This already cost us one collision:** two sessions independently minted
`E173`, and it surfaced only because a merge happened to put both INDEX rows side
by side. Nothing detected it.

**The guard, and it is now structural rather than a convention.** Each lane mints
inside its own band (**A: E184–E189, B: E190–E195**), and a new element's row lands
in **two tracked files** in the same change that mints it:
`docs/examples/INDEX.md` and the arc's file under **`docs/arcs/`**. Those are the
only tracked homes, so they are the only collision detectors that exist — and unlike
`.planning/`, they do not fork per worktree. `.planning/` keeps the working detail
(change plans, decision tables, SPEC bodies), which may die with a worktree
without costing anything.

---


## ⚑ Cross-lane facts Lane B must have (2026-08-31)

Neither is gate-enforceable, so both live here, in the file both lanes read.

1. **The term printer moves to `surface/pretty`, not `typing/pretty`.** E181
   relocates it, decided against `MAP.md`: `Term` is `surface/syntax.chiral:18`
   and the output *is* chirality source, while `typing/` is *"every check on it"*
   and a printer checks nothing — it is `surface/parse`'s inverse. **E146 imports
   `surface/pretty`.** Root-relative keys make the directory the identity, so the
   two spellings are different modules; the move happens inside E181 precisely so
   E146 never takes a dependency on a key that then moves.
2. **E181 promotes `bin/chirality-bin`** (its deliverable enters the compiler's
   closure — the first in this arc that does). Any Lane-B measurement taken before
   that lands was taken against a **different compiler**. Measured in a probe:
   blob ~755,238 → ~764,000 B, binary 1,130,872 → ~1,147,000 B, fixpoint at
   generation one. **LANDED 2026-09-01, measured on the real file:** blob
   755,238 → **772,110 B** (57 → 58 `^(end-module "` markers), binary
   1,130,872 → **1,147,256 B**, `N1 == N2` at generation one, suite green under
   the new binary (303/0, 88 roots).

Also true and worth Lane B knowing, since `.manifest`'s round-trip depends on the
printed form: a `case` prints multi-line at **every** width, and it makes every
**enclosing** form multi-line too — `doc-fits` refuses a hard break anywhere inside
the group it measures (`doc.chiral:131`). That is accepted, not a defect: a `case`
is structurally multi-line. But a round-trip fixture that assumes single-line
output at a wide width will be surprised.

## Working rules (both lanes)

- **Separate worktree per lane**, off `/workspace/chirality`, living under
  `/workspace`. **Never `/tmp`** — this sandbox is fragile. Never work in
  `/workspace/chirality` itself.
- **Full pipeline per element**: example → audit → SPEC → audit → implement. It has
  earned it — it caught a wrong element premise, a 10× scope error, and nine gate
  rows that could not fail.
- **BUILD RULE:** the committed compiler compiles everything, Python compiles
  nothing. Build-new → test → promote; nothing replaces itself in place.
- **Every gate row needs a named mutant that is actually RUN.** Nine toothless
  rows were found in one session — greps matching their own source, mutants paired
  with rows they cannot move, and once currying turning an arity check into a legal
  partial application. Reading a gate never tells you whether it can fail.
- **Probe before reasoning on anything renderer-shaped.** Source-reading produced a
  confidently wrong premise for E175 that a byte-exact probe refuted in one run.
- **Merge early.** Master moved 25 commits during one arc; the planning tier was
  untracked mid-flight. A long-lived branch pays for itself in conflicts.

---

## What "done" means for each lane

**Lane A:** diagnostics render through `Doc` end to end — a real consumer in
`prog/`, not just the arc's own modules — and the error-quality rows (E182, E176,
E179) are closed. Today `dg-doc` and `doc->rendering` are imported *only* by
`lib/`, which is the fifth "built but unadopted" instance in this repo.

**Lane B:** `.manifest` and `.protocol` exist as declared kinds with derived
codecs and round-trip gates — `parse(source(v)) ≡ v` against source, and against
**bytes** respectively. `MAP.md` gains `.protocol`.

**Both, together:** they are the prerequisites for the real destination —
**replacing the nine Python tools (4,140 lines) with chirality programs and
deleting `tools/`.** Neither lane does that; both exist so it can be done. Not
"no Python in the compile path" — that is already true. **Zero Python in the repo.**

---

## The four focuses, 2026-09-02

The two lanes above are two arcs of seven. The author settled the work into four
focuses so that scriba and prapanca can move forward. Those two are the destination.
Neither is the work.

| focus | arcs | element block |
|---|---|---|
| enforcement | [[arcs/enforcement-arc]] | `E184-E189`, shared with diagnostics |
| transport | [[arcs/transport-arc]] | none. Arc-local `T#` per [[decisions/decision-work-ids]] |
| readability | [[arcs/diagnostics-arc]], [[arcs/file-types-arc]] | `E184-E189` shared, and `E190-E195` |
| no-Python self-hosting | [[arcs/zero-python-arc]], [[arcs/text-tools-arc]] | none, and both are frozen |

Each arc file carries its own requirements, element list and resume state. This
section carries the division. [[arcs/README]] holds the goal relation, which has
been many to many since `39710ee`.

Two arcs spell their arc-local ids with the same letter. `zero-python` takes `T`
for tool and `transport` takes `T` for its rows, both under
[[decisions/decision-work-ids]]. The ids are arc-local, so the citation form
`<arc>/<id>` is what keeps `zero-python/T1` and `transport/T1` apart, and a bare
`T1` in a document that spans arcs is ambiguous.

## File ownership, measured 2026-09-02

Read off each arc's own element list and checked against the tree by grep. The
evidence column names what was read.

| arc | writes | evidence |
|---|---|---|
| transport | `prog/prapanca/`, `prog/shilpa/turn.chiral`, `prog/samples/e130_*.prog`, `e131_*.prog`, `stream-ollama.prog`, a new phase in `tools/test/run-tests.sh` | the nine importers of `protocol/http`. Rows `T2` to `T4` each owe a gated root and a phase that judges it |
| text-tools | `lib/text/` | one file, `matcher.chiral`. `prog/prose-lint.prog` is its only consumer |
| diagnostics | `lib/typing/diag.chiral`, `lib/surface/pretty.chiral`, `lib/protocol/render.chiral`, `lib/protocol/render-doc.chiral`, a consumer under `prog/` | `Judg` is `diag.chiral:99`, which E182 reshapes. `lookup-face` is in `render.chiral`, which E179 and E180 reach. The adoption row owes a consumer outside `lib/` |
| zero-python | `tools/`, plus one port root under `prog/` per tool | `prog/prose-lint.prog` and `prog/paren-audit.prog` are the two ports that exist |
| enforcement | `lib/lowering/` at top level (`compile-front`, `compile-back`, `compile-all`, `skip-diag`), `lib/lowering/upper/` (`lower`, `optimize`, `eff-lower`), `lib/lowering/tal/` (`ir`, `check`, `eval`), `bin/chirality` | E184's R3 to R7 name the four top-level files. E16, E17, E18 and E70 name the other six. E184's R7 owes a report exit `bin/chirality` does not have |
| file-types | `lib/manifest/**` (new), `lib/protocol/{json,http,wire,apc,vt-parser}.chiral`, emitters under `prog/`, `lib/module/loader.chiral` | the arc's own may-write list, plus requirement 1: `.manifest` is a property of term structure and is checked by the loader |

Three shapes a path glob gets wrong here, each with something that fails.

- **`lib/prelude/doc.chiral` is written by no arc.** The seventh-constructor
  section above names the two mutants that refuse it. Diagnostics consumes it and
  does not own it.
- **`prog/*.prog` is six roots and only two of them port a Python tool.**
  `prog/compiler.prog` is the compiler's own root. `prog/resolve.prog`,
  `prog/test-runner.prog` and `prog/wield.prog` port nothing under `tools/`. Sweeping
  them into zero-python's scope would put the compiler root in an arc whose
  requirement 2 is that `tools/` is deleted.
- **`lib/typing/` belongs to diagnostics.** The enforcement arc names no path
  under it. Enforcement's whole footprint is `lib/lowering/` plus
  `bin/chirality`, and `lib/typing/diag.chiral` carries `Judg` for E182.

## What contends, and what does not

No two arcs' measured write sets share a file. Three couplings survive that.

| coupling | between | what it forces |
|---|---|---|
| one band | enforcement and diagnostics | `E184-E189` is five numbers and `E184` is spent. Two focuses cannot mint from it concurrently |
| one module, read against written | transport and file-types | `lib/protocol/http.chiral` holds `http-request` at `:437` and `chat-open` at `:773`, which transport's gates run against, and it is one of the five hand-written codecs file-types derives. A sequencing constraint. No arc is excluded by it |
| one consumer | text-tools and zero-python | `prog/prose-lint.prog` is the matcher's only consumer and is also a tool port. Both arcs are frozen, so nothing contends today |

So the four focuses run concurrently as far as files decide it. What sequences
enforcement against diagnostics is the shared band, and that is an author call.

### Two ownership lines stay unmeasured

- **E176's repair site.** `str-sub` is an extern at
  `lib/prelude/prelude.chiral:83`, mapped to `nb-bslice` at
  `lib/lowering/tal/erase.chiral:114`. Whether the fix is a guard in
  `lib/prelude/string.chiral` or a change under `lib/lowering/` decides whether
  diagnostics reaches enforcement's tree. The element has no SPEC and nothing
  settles it. `FD-01` in `records/findings.md` holds the measurement.
- **file-types' emitters under `prog/`.** The arc's may-write list carries the
  phrase and names no file. This pass did not locate E146's five emitters.

## The allocation gap belongs to no arc

Measured 2026-09-02 in [[benchmarks/text-matcher-allocation]], on the tree at
`c23947e`, host `claude-sandbox`, `MemTotal` 4,033,056 kB and `SwapTotal` 0.

| fact | figure |
|---|---|
| arena per input byte, `prog/prose-lint.prog` over 81 files and 609,872 B | ~1,747 B |
| reclamation on any path a compiled program takes | none. `x-galo` advances `heapptr` and `nb-arena-grow` doubles the commit. Peak RSS is therefore total bytes ever allocated |
| `lib/memory/` modules with zero importers | four of six: `alloc-fixed`, `arena`, `mem-linear`, `mem-region`. `mem-region` is the only reclamation discipline in the tree |
| default-scope projection, itemised over 545 files and 8,142,676 B | 14.12 GB against 3.85 GB with no swap. The kill is arithmetic |
| what `9f46c6c` cut, min-of-3 under a 2 GB cgroup | peak 1,111,728,128 to 466,821,120 B, 58.0%. The matching term 67.1% |
| the same projection with those per-term deltas applied | ~6.3 GB. Projected. The default scope has never been run |

This blocks prapanca and scriba from running once transport lands, and no arc holds
it. Enforcement is one candidate, because a bound the machine ignores is an
enforcement failure. Its own arc is another. The call is a row in
[[records/author-calls]] and this section decides nothing.
