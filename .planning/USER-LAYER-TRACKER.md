# The user layer — TRACKER

**The one place that says what is done, what is running, and what is next.**
Minted 2026-08-30.

Three companions, and this file does **not** restate them:
`.planning/USER-LAYER-GAP.md` — *what the gap is* (53 `U#` rows, the refraction,
the file-type roster) · `.planning/USER-LAYER-PIPELINE-PLAN.md` — *how each row gets
built* (tracks, research briefs, gates, the serial queue) · this file — **state**.

⚑ **Cadence: SERIAL. One stage at a time, one agent at a time.** Standing user
directive; it overrides `CLAUDE.md`'s "parallel waves" guidance for pre-runs, so
`--no-index` and orchestrator-appends-rows do **not** apply here — each run updates its
own INDEX row.

---

## §1 · NOW

| | |
|---|---|
| **Running** | — (nothing dispatched) |
| **Owed on the HOST** | `cd <host>/chirality && git push origin experimental` — 4 commits ready, guards green. ccbox has egress blocked, so the push cannot run from inside |
| **Just landed** | ✅ `P1a` — **D-U7 RESOLVED IN FAVOUR OF (b); it is expressible today.** My "captured closures don't lower" reading was wrong and is withdrawn |
| **Done** | ✅ `U0` — `chirality-pack` accepts `U#`/`S#`; E-lane byte-identical, lint clean, 3 mutants run (one caught a real hole and hardened the tool) · ✅ `P1` example drafted, 573 L, **D-U7 answered (b) — with the gap doc's own evidence overturned** |
| **Next after it** | re-run `P1 --audit example` with the FLAGs answered → `P1 --spec` → `P2` |
| **⚑ Open** | `P1 --audit example` returned **BLOCKED, 2 author-tier FLAGs**. Both were confirmed and the doc is patched; FLAG 1 (E7 scoped to direct fields) stands, FLAG 2's rule is now explained by `closconv.chiral:791` rather than the singleton pass. `--mark reviewed` NOT run — the example is still `drafted` and needs a re-audit carrying P1a's finding |
| **Blocked on the user** | **`D-U4`** — how a program acquires a `Clock`. Blocks all 12 rows of §7 and needs no run. **`D-U3`** — whether the KB mode replaces `bin/*.py` or keeps it as the lane's rank-2 oracle |
| **Stop condition armed** | the **additivity gate** — fires after P1 + P2 + the first document type. If adding the *second* type touches a shared sum, an exhaustive case, a `VimMode` variant or the loop, **D-U7 was answered wrongly and the plan stops** |

### The serial queue — position

```
   0.  U0    teach chirality-pack the U# lane                  ✅ DONE 2026-08-30
   1.  D-U4  author call: how a Clock is acquired          ← NEEDS THE USER (blocks §7 only)
   2.  P1    the typed document seam            → D-U7     ✅ example drafted
   2a. P1    --audit example (the pre-spec gate)             ⚑ BLOCKED — 2 FLAGs
   2b. P1a   does a CAPTURED-closure record lower at all?    ✅ YES — (b) stands
 ▶ 2c. P1    --audit example, re-run carrying P1a's finding   ← NEXT
   3.  P2    the family's surface syntax        → D-U2   (carries 2 types)
   4.  P3    outline/notes value
   5.  P5    table + column schema
   6.  P9    codepoint string view              (core VAL)
   7.  P4    sectioned doc + schemas            → D-U6 (with D-U3)
   8.  P6    graph + typed edges
   9.  P7    diagram rendering, tiered
  10.  P8    the derived lane
  11.  P10   fontification seam                 → D-U1
  12.  P11   KB port + note graph
  13.  P12   authority gradient as a value
  14.  P13   civil date/time                    (heaviest external research)
  15.  P14   told time as evidence              → D-U5
  16.  P15   agenda as a query
  17.  P16   TODO workflow as manifest
```

---

## §2 · State ledger — all 53 rows

**States:** `todo` · `example` (drafted) · `reviewed` (example audited, `--mark
reviewed`) · `specced` · `audited` (`--mark audited`) · `built` · `verified` (gates
green + mutant run + recorded) · `blocked` · `n/a`.

⚑ **`built` is claimed from `.planning/audit/CONFORMANCE-MAP.md`, never from this
file.** This column tracks the *pipeline*; the map is the build-state authority.

#### §4 · Text editor floor

| U# | Element | Track | Mint | State | Artifact | Last moved |
|---|---|---|---|---|---|---|
| U1 | codepoint-correct editing | P9 | MINT `VAL` | `todo` | — | — |
| U2 | display width (`wcwidth`) | S | T17-tier | `todo` | — | — |
| U3 | soft wrap + h-scroll | S | app | `todo` | — | — |
| U4 | multi-file search + result surface | S | E148 | `todo` | — | — |
| U5 | fontification from the real parse | P10 | app · D-U1 | `todo` | — | — |
| U6 | structural editing + indentation | X→S | app | `blocked` | — | — |
| U7 | completion-at-point | S | app | `todo` | — | — |
| U8 | diagnostics in the buffer as values | S | E157 | `todo` | — | — |
| U9 | file safety (atomic save, mtime, revert) | S | E148 + E149 | `todo` | — | — |
| U10 | jumplist + `.` repeat | S | app | `todo` | — | — |
| U11 | encoding + line-ending policy | S | app | `todo` | — | — |
| U12 | the honest scale bound | M | — | `todo` | — | — |

#### §5 · Document type family

| U# | Element | Track | Mint | State | Artifact | Last moved |
|---|---|---|---|---|---|---|
| U13 | renderer takes the **value**, not `Str` | P1 | app · D-U7 | `example` | `examples/U13-typed-document-seam.md` | 2026-08-30 |
| U14 | `Mode` grows — keymap + ops + views | P1 | app | `example` | covered by `U13-typed-document-seam.md` | 2026-08-30 |
| U15 | extension → document type, checked | P1 | app | `todo` | — | — |
| U16 | the block algebra | X | E158 | `blocked` | — | — |
| U17 | N views per type | P1 | app | `example` | covered by `U13-typed-document-seam.md` | 2026-08-30 |
| U18 | per-type surface reader | P2 | app · D-U2 | `todo` | — | — |
| U19 | `parse`/`print` round-trip, per type | P2 | app | `todo` | — | — |
| U20 | type 1 — outline / notes | P3 | MINT `VAL` | `todo` | — | — |
| U21 | type 2 — sectioned doc + schemas | P4 | MINT `VAL` · D-U6 | `todo` | — | — |
| U22 | type 3 — table + column schema | P5 | MINT `VAL` | `todo` | — | — |
| U23 | type 4 — graph + typed edges | P6 | MINT `VAL` | `todo` | — | — |
| U24 | type 5 — journal / datetree | S | `VAL` | `todo` | — | — |
| U25 | diagram rendering, tiered | P7 | app / TUI | `todo` | — | — |
| U26 | generalize the outline engine | S | app | `todo` | — | — |
| U27 | charts | S | E153 (partial) | `todo` | — | — |
| U28 | cross-type links + transclusion | S | app | `todo` | — | — |
| U51 | the derived lane | P8 | app | `todo` | — | — |
| U52 | the stream lane | X | S20b | `blocked` | — | — |
| U53 | the remote lane | X | S20b | `blocked` | — | — |

#### §6 · Knowledge base

| U# | Element | Track | Mint | State | Artifact | Last moved |
|---|---|---|---|---|---|---|
| U29 | KB as a port, read/write split | P11 | E148 + E149 | `todo` | — | — |
| U30 | note graph as a typed value | P11 | app | `todo` | — | — |
| U31 | link integrity as a property | S | E157 | `todo` | — | — |
| U32 | query + view surface | S | app | `todo` | — | — |
| U33 | citation checking against live files | S | S26 | `todo` | — | — |
| U34 | authority gradient as a value | P12 | app | `todo` | — | — |
| U35 | capture + routing | S | E149 | `todo` | — | — |
| U36 | staleness digests | S | E116 | `todo` | — | — |
| U37 | refile / archive / rename + link rewrite | S | E149 | `todo` | — | — |
| U38 | transclusion / block references | X→S | S26 + S27 | `blocked` | — | — |

#### §7 · Scheduling and agenda

| U# | Element | Track | Mint | State | Artifact | Last moved |
|---|---|---|---|---|---|---|
| U39 | a program can acquire a `Clock` | M | D-U4 | `todo` | — | — |
| U40 | civil date/time | P13 | MINT `VAL` | `todo` | — | — |
| U41 | told time as evidence | P14 | MINT `SYS` | `todo` | — | — |
| U42 | timezones, tiered | M | D-U5 | `todo` | — | — |
| U43 | timestamps in the document value | S | U40 | `todo` | — | — |
| U44 | repeaters (`+1w`, `.+1d`) | S | U40 | `todo` | — | — |
| U45 | TODO state machines | P16 | E163 | `todo` | — | — |
| U46 | the agenda as a query | P15 | app | `todo` | — | — |
| U47 | priorities / tags / properties / effort | M | app | `todo` | — | — |
| U48 | clocking | S | U41 + `time-mono` | `todo` | — | — |
| U49 | the agenda daemon | X | E39 + S28/S29 | `blocked` | — | — |
| U50 | capture with a timestamp | M | U35 + U40 | `todo` | — | — |

---

## §3 · Decisions board

| # | Question | State | Blocks | Who |
|---|---|---|---|---|
| **D-U1** | the fontification seam — parse-driven or lexer-driven faces; behaviour on a broken buffer | `open` | P10, U6 | produced by the P10 run |
| **D-U2** | the family's surface syntax + how far the roster runs | `open` | P2, and every type after it | produced by the P2 run |
| **D-U3** | KB mode replaces `bin/*.py`, sits beside it, or **keeps it as the lane's rank-2 oracle** | `open` | P11, U35–U37 | **author — no run produces it** |
| **D-U4** | how a program acquires a `Clock` (profile-hands-caps vs an interim crossing on the `env-open` precedent) | `open` | **all 12 rows of §7** | **author — costs a paragraph** |
| **D-U5** | the told-time tier, and what a freshness divergence *does* in an editor | `open` | P14, U42 | tier is the author's; shape from P14 |
| **D-U6** | do typed documents retire `ledger-lint`'s schema checks | `open` | P4 | author, decide beside D-U3 |
| **D-U7** | where the heterogeneity is packed — closed sum / buffer-as-object / per-type registries / Str+memo | `open` | **P1, and the whole family** | produced by the P1 run; recommendation is buffer-as-object |

Inherited and already settled — **do not re-open:** `D-S1` (the user layer extends in
chirality, live) · `D-S2` (merged into D-S1; hooks are the observation half) · `D-S3` (chat
becomes an ordinary buffer).

---

## §4 · Run log — append only

| Date | Stage | Outcome | Mutant run? | Commit |
|---|---|---|---|---|
| 2026-08-30 | mirror sync — `TUI/` + `scaffold/lib/manas` into the public repo | **DONE, committed `b822896` in `/workspace/chirality` (276 files, +38,609/−3,102); push owed on the host.** The mirror was **484 commits behind** and was shipping a **silently forked scriba** — `scaffold/lib/scriba` was a real directory frozen at Aug 10 while `TUI/` was not shipped at all (it is a symlink to `TUI/scriba` in private). ⚑ **The fixpoint guard then caught two more real defects:** (1) the mirror's `bin/chirality-resolve.sh` was **43 L against private's 164** — pre-E155, no symlink dedup — and `make-public.sh` never synced it, so the new symlink made the DFS resolve every shared module twice (*"a second coordinate inside one module extent"*); (2) the mirror's public-authored `build.sh` was missing the `compile-driver` root, so `compile-main` did not exist. Both fixed; mirror now self-hosts, `chirality-bin.new == bin/chirality-bin` byte-identical at 1,077,624 B | the guard **is** the mutant here — it refused twice and named both causes | `87338d7` (private), `b822896` (mirror) |
| 2026-08-30 | `P1a` — does a captured-closure record lower? | **YES — and my framing was wrong.** The k≥1 refusal has nothing to do with capture: a bare `(lam …)` in a **data-constructor argument position** is never registered as a closure-conversion site. `closconv.chiral:791`'s `c-con` arm passes `none` for expected types where `cwalk-app` (`:805-812`) threads `callee-doms`, so `lam-lit` (`:743-752`) rejects a bare `c-lam` but accepts `(c-ann (c-lam) arrow)`. The ctor field-type map **already exists** (`closconv-driver.chiral:84-91`) and is consumed only on the case-arm side. `E147` is BUILT and does not cover it — it fixed *consumption*, this is *registration*. **(b) demonstrated end to end**: buffer-as-object over a captured `Doc`, the additivity shape (two payload types in one `(List Buf)`, one loop), and an effectful `=>` field. Finding: `.planning/FINDING-captured-closures-2026-08-30.md` (393 L), 44 fixtures | **2 re-run by me, two-way falsification.** zero-capture bare lam in ctor position → **REFUSED**; capturing lam + `(the …)` → **lowered, ran exit 0**. Capture is irrelevant. Agent's 39 fixtures all fail their mutants (255) | — |
| 2026-08-30 | `P1 --audit example` — the pre-spec gate | **BLOCKED, 2 author-tier FLAGs**, both correct, both against claims I had already propagated into `USER-LAYER-GAP.md` §10. 14 FIXes applied in the example (line ranges, `Mach` 34→**37**, `ScribaOp` 32→**31**, a missing `()` param list, `$apply` keyed by *arrow signature* not arity). Checks 1–4 PASS; check 5 (internal consistency) is where both FLAGs landed. **FLAG 1:** E7 positivity is enforced *per declaration* — `walk` recurses through a `(t-tcon n as)` only into the arguments `as` and never resolves `n`, so a parameterless hop is invisible; the "object discipline by construction" claim is scoped to DIRECT fields. **FLAG 2:** the no-accessor-globals rule's stated mechanism is wrong — `find-con-global` matches only a global whose whole body is a bare `(t-con …)`, so the singleton pass is inert for a `Buf` built inside a `lam`, accessors or not | **5 falsifiers RUN by me, with B1.** (a) direct self-mentioning field → **REFUSED** `not strictly positive: op`. (b) one parameterless hop → **ACCEPTED, ran** — FLAG 1 confirmed. (c) k=0 named-global vocabulary record, 3 instances, inline `case` → **ACCEPTED, lowered, ran exit 0**. (d) k≥1 real capture, inline `case` → **REFUSED** `higher-order application`. (e) k≥1 capture + projector global → **REFUSED** `lambda stays upper`. ⚑ **(c) vs (d) is the finding: option (b) needs k≥1 capture by definition, and the live evidence for it (`RendererFn` ×3, `ScribaOp` ×31) is all k=0.** Fixtures kept in `scaffold/tests/samples/_wip/` | — |
| 2026-08-30 | `P1` — worked example, the typed document seam | **DRAFTED.** `examples/U13-typed-document-seam.md`, 573 L, six sections, real surface syntax; INDEX row appended `status: drafted`. **D-U7 answered: (b) buffer-as-object — and the gap doc's evidence for it was wrong.** Two shapes of fn-bearing record exist and the compiler treats them oppositely: **dictionary** (`Mach`, `Alloc`) reached through projector globals, handled by `specialize-singletons`, **capped at ONE instance per blob** (`:78-84`, and the `16d6d1a` count>=1 relaxation was *reverted as a silent miscompile*) — vs **vocabulary** (`RendererFn`, `ScribaOp`) consumed by inline `case`, routed by `closconv-sig`, **N instances fine**. I re-verified: `Mach`'s projector binds **37** fields (I had written 12); `ScribaOp` runs **31** live instances with an effectful `(=> (Puffer Str) (Puffer Str))` field. **Decisive new argument: E7 strict positivity** (`data.chiral:262-266`) refuses a recursive occurrence in a field arrow's *domain* and permits it in the *codomain* — verified — so `(op (=> Buf Key Buf))` is a type error and a self-returning closure field is not: **the checker enforces the object discipline by construction** | pending — falsifiers written into §6, run at spec/implement time | — |
| 2026-08-30 | `U0` — `chirality-pack` accepts `U#`/`S#` | **PASS.** `+219/−50`, `tools/pack/pack.py` only. A `SOURCES` adapter keyed on id prefix (path · table header · section→KIND · row regex · tick columns · declared baselines). Tags `U13-…`/`S19-…` so artifacts cannot collide. Independently re-verified: `E13`/`E148`/`E163` bundles **byte-identical** incl. stderr and rc (13,101 / 10,766 / 10,653 B), `E13 --audit example` (21,318 B) and `--kb` identical; all 53 `U#` + `S#` rows resolve; `ledger-lint` clean rc=0 | **3 run.** (1) wrong source path → dies clearly, E-lane unaffected. (2) bold-intolerant row regex → `U13 not found`. (3) **all four declared §6 baselines rotted → initially did NOT fail** — emitted a §3 headed "in-tree, 4 file(s)" containing four NOT-FOUND lines. Gate hardened: zero-resolving baselines now `die`, partial rot prints `N of M`. *A gate that misses its mutant is the case the contract exists to catch; recorded rather than smoothed over.* | — |

---

### Open follow-ups from completed stages

| From | Finding | State |
|---|---|---|
| U0 | **The `U#` legend is ~14 KB.** The adapter reuses the catalog's rule — *everything above the first table header is the legend* — which for `USER-LAYER-GAP.md` means §0–§3 plus the §4 header. Measured: U bundles **22–28 KB** vs E's **10–13 KB**, ~2× the context per run. Not wrong — §3 (the refraction check, 5.7 KB) is exactly the anti-phantom material a U example needs, and §0 carries the state vocabulary — but §1 (dated baseline) and §2 (the floor) are indiscriminate. **Recommended trim: legend = §0 + §3 only.** Cheap; not blocking; `U0b`. | `open` |
| P1a | ⚑ **`closconv.chiral:791` is a real compiler defect with a named fix** — thread the existing ctor field-type map through the `c-con` arm. Until then every vocabulary record needs `(the …)` at each construction site. **Not minted** — no consumer has asked for the compiler fix yet; the annotation workaround is total. Mint if the SPEC decides the annotation is unacceptable. | `open` |
| P1a | **The `Flow` corroboration was refuted at source** (`flow.chiral:71-73`: codec totality, not lowering) — but its real reason **bites `Buf` too** the moment a buffer list needs a codec or structural checker. Carry into the SPEC as a known constraint on (b). | `recorded` |
| U0c | **The pack copies the gap-doc cell verbatim into the YAML `title:`**, so a bolded row emitted `title: **The renderer takes…**` — a leading `*` is a YAML alias indicator and every other example's title is plain text. Worked around by hand in the artifact. **Fix: strip markdown emphasis when minting a U-row title.** | `open` |
| U0 | **No `U#` row names a `.py` baseline** — the four `bin/*.py` names live in §6's *prose*, not in rows, and §5's prose names `ledger-lint.py` as something it **retires**, not as its baseline. So the adapter **declares** §6's baselines rather than discovering them. A declaration can rot silently; mutant 3 exists for exactly that and is why the tool now dies on it. **Consequence to carry: the §6 baseline list is a maintained fact, not a derived one.** | `recorded` |

## §5 · Doc-sync obligations

Every state change owes an update somewhere else. This is the list; a row that moves
without its sync has rotted the tree.

| When a row moves to | Update |
|---|---|
| `example` | `examples/INDEX.md` (the pack appends it) · this tracker |
| `reviewed` | `--mark reviewed` flips INDEX · this tracker |
| `specced` | `.planning/specs/` gains the SPEC; INDEX flips · this tracker |
| `audited` | `--mark audited` flips INDEX + SPEC frontmatter · this tracker |
| `built` | **`.planning/audit/CONFORMANCE-MAP.md`** (the authority) · `USER-LAYER-GAP.md`'s row cell · this tracker |
| `verified` | the run log's **mutant** column, with its *measured* failure · this tracker |
| any mint | `.planning/SELF-IMPLEMENT-CATALOG.md` **+** `.planning/LEDGER.md` in the **same change** (the no-phantom-dep rule) |
| any sequencing change | `.planning/BUILD-ORDER.md` — it owns cross-lane order, not this file |
| any row touching a ledger/INDEX/bank | `tools/ledger-lint/ledger-lint.py` clean before the commit |

⚑ **Standing rot risks, checked at each stage:**
- `USER-LAYER-GAP.md` §1's baseline is measured at 2026-08-30 — **re-measure before
  quoting it in a SPEC**.
- The `e106-linear-caps-utf8` branch carries in-flight UTF-8 work. **P9 must reconcile
  with it, not spec around it.**
- `SCRIBA-PRIMITIVE-CHECKLIST` §1 claims the buffer is "a typed lens on a port"; measured
  152 `(Puffer Str)` vs 7 `(Puffer A)`. **FLAGGED, not fixed** — owed to a `doc-audit`
  run, not to this lane.

---

## §5b · NEXT PHASE — scoped, NOT started

Named by the user 2026-08-30. **Nothing here has been begun**; this section exists so
the next session does not have to re-derive the scope.

### A · The public repo's target structure (author, 2026-08-30)

**Not started.** The shape is the author's; the notes under it are constraints
measured this session, not amendments.

```
<root>/
  <source>/          the language itself
  <harness>/         build + test machinery
  docs/
    examples/        one entry per code example
    definitions/     one entry per named concept + a dictionary map
    elements/        one entry per element: status, relationships, explanation
```

**Per-folder schema.** Each folder is a *sectioned document type with a declared
schema* — which is `U21` exactly, one tier up. Same machinery, and
`tools/doc/doc.py new-bank` is the precedent for a scaffolder that emits a
schema-conformant page.

| Folder | Entry carries |
|---|---|
| `examples/` | a succinct explanation · **a citation to the reference code when borrowed from another open-source project** · the chirality code used |
| `definitions/` | the term, the **level** it sits at, what it IS and IS-NOT, its links — plus a **dictionary map** (term → entry) as the index |
| `elements/` | the id, **status in implementation**, relationships, explanation |

**Four constraints, in the order they bite:**

1. **⚑ Element status must be DERIVED, never written.** Build-state is
   authoritative from `.planning/audit/CONFORMANCE-MAP.md`. ~171 hand-maintained
   status lines across `E#`/`T#`/`S#`/`U#` is guaranteed rot — it is the exact
   failure `ledger-lint`'s bank-claim-vs-MAP checks already exist to catch. So an
   element page is **emitted** from catalog + map with its hand-written prose
   preserved across regeneration. This is the one decision that determines whether
   the folder is an asset or a liability.
2. **`examples/` already has its citation taxonomy.** The repo's
   `OURS` / `PAPER` / `IMPL` / `SPEC` reference-class convention is that field;
   reuse it rather than mint a second one. Note the existing top-level `examples/`
   (53 shipped, 118 private) are **pipeline artifacts**, not reader examples —
   raw material for this folder, not its contents.
3. **"Every level of concept" needs the levels named first**, or `definitions/`
   has no spine. Candidate ladder already implicit in the tree: principle → axis →
   concept (the banks) → module → element. `docs/glossary.md` + `docs/vocabulary.md`
   + the 10 banks' §1 (*IS / IS-NOT*) are the raw material; a bank's §1 is the
   public face, the rest of the bank is not.
4. **`scaffold/` is a legacy name for "the language source"** — it dates from the
   Python-hosted era. If the tree is moving anyway, that name should not survive
   the move.

**Debris to clear in the same pass** (measured 2026-08-30): `CONTENTS.md` tells the
reader to read `.planning/PERSONA.md`, which is not in the public repo · `sys-tal.chiral`
exists at the root **and** at `scaffold/lib/sys-tal.chiral` · `E91-host-scale.sh`
is a one-off stress script at the root · the mirror's `bin/` carries five ~1 MB
`chirality-bin.*` binaries · `scaffold/lib/agent/` is an empty named home.

**Two questions that block the first move, both author-tier:**

- **Does manas leave the repo, or stay in-tree and stop being mirrored?** These
  diverge immediately — leaving needs its own repo and a dependency story; staying
  is a few lines in `make-public.sh`. ⚑ Either way the cut is already drawn by
  `S20b` on authority grounds: the editor's network port set is empty, the
  orchestrator holds `Backend`, and `docs/live-environment.md` decides that case by
  name. The repo-level separation and the process-level split are **the same line**.
- **What happens to the 86-file reasoning corpus** — 14 `decision-*`, 7 `insp-*`,
  8 `modules-*`, 5 `view-*`, the axes, the banks? The target has three doc folders
  and none of them is "the notebook". Either it ships under a name that says what
  it is, or it goes private. It should not keep being called `docs/`.

### A2 · Tools compartmented, one folder each (author, 2026-08-30)

**Not started.** Every chirality tool gets its own folder, held apart from the language
source.

```
<root>/
  <source>/          the language
  <harness>/         build + run machinery -- NOT tools
  tools/<one folder per tool>/
  docs/{examples,definitions,elements}/
```

⚑ **CORRECTED 2026-08-30, same day.** The first draft of this row said
`bin/chirality-resolve.sh` and `bin/chirality` are *"harness, not tools, and moving them breaks
the build."* Both halves were wrong. The breakage is **8 hardcoded path references**
(`build.sh`, `bin/chirality`, `run-native.sh` ×2, `test-resolver-collision.sh`, three
Python tests) — a same-commit fix, not a principle; a category claim was put over a
mechanical fact.

**And the category itself is wrong, which matters more.** There are **two resolvers**,
maintained as a deliberate matched pair (`test-resolver-collision.sh` tests the
collision rule in *both providers*):
- `bin/chirality-resolve.sh` (164 L, shell) — the **cold path**, for when no chirality program
  is running yet: `build.sh`, the `bin/chirality` CLI, the native test phases.
- **`scaffold/lib/resolve.chiral` (429 L, native)** — `collect-imports` walks the Sexp
  forms and `openat` reads by computed path, so it does the import DFS in chirality.
  `resolve-driver.chiral` was split out of it **2026-08-25 precisely so the resolver
  could be IMPORTED as a library** (`test-floor.chiral`'s `observe` must resolve a
  root's imports before compiling it).

So **a chirality program can already resolve and compile another chirality program's imports,
natively, today** — and it needs no `E148`, because the DFS follows *imports*, which
name modules, and never enumerates a directory. The real three-way split:

| | what it is | who uses it |
|---|---|---|
| **toolchain** | `B1` + `resolve.chiral`/`resolve-driver.chiral` **as an importable library** | chirality programs, incl. every tool |
| **tools** | chirality programs that import the toolchain | `docgen`, then the rest as ported |
| **shell entry** | `bin/chirality-resolve.sh` + `bin/chirality` | the cold path only |

`chirality-resolve.sh` is a **bootstrap artifact whose native successor exists and is
already library-shaped**. Where it lives matters less than the first draft implied,
because tools written in chirality route around it. The genuine tools:

| Tool | Now | Lane |
|---|---|---|
| `ledger-lint` | `tools/ledger-lint/ledger-lint.py` 1033 L | doc tier |
| `chirality-pack` | `tools/pack/pack.py` 805 L | element pipeline |
| `chirality-frontier` | `bin/chirality-frontier.py` 650 L | orientation |
| `chirality-capture` | `bin/chirality-capture.py` 619 L | growth |
| `chirality-doc` | `tools/doc/doc.py` 313 L | doc tier |
| `syscall-map` | `bin/syscall-map.py` 238 L | language |
| `paren-audit` | `bin/paren-audit.py` 154 L | language |
| `make-public` | `bin/make-public.sh` 146 L | release |
| `scriba-edit-smoke` / `scriba-run-smoke` | 126 + 40 L | scriba (app) |
| **`docgen`** | **does not exist — build it in chirality** | doc tier |

Also to fold in: `scaffold/tools` (8 files), `scaffold/bin` (1), `scaffold/bench` (14),
`scaffold/mock` (12).

### A3 · The new tool — `docgen`, written in chirality

Emits `docs/elements/` (and the scaffolds for `definitions/` / `examples/`) from the
catalog + `CONFORMANCE-MAP.md`, with **status derived, never written** (§5b·A
constraint 1).

**⚑ Measured 2026-08-30: v1 is buildable TODAY, with zero new crossings.** The tool is
a pure transform from *known paths* to *computed paths*:
- read known files — `open-rw` + `read` (`ports/file.chiral`, `ports/fd.chiral`): HAVE
- write to a computed path — `open-create` (`openat O_RDWR|O_CREAT|O_TRUNC`, NUL-term
  path → fd, `ports/file.chiral:15`) + `write-fd`: HAVE
- sort — `E152` BUILT · string ordering — `E151a` landed
- **precedent: `lib/test-runner.chiral`** is already a native chirality tool that reads a
  *manifest* rather than enumerating, and `harness.chiral`/`test-floor.chiral` sit under
  it. `docgen` follows that shape exactly.

**What it cannot do until E148/E149:**
- **`E148` (`getdents64` + `stat`)** — the *reverse* direction only: orphan detection,
  "every element has a page", coverage over `docs/`. That is the lint half, not the
  emit half. Emit does not need it.
- **`E149` (`mkdir`)** — creating `docs/elements/` if absent. Workaround: commit the
  directories. Not a blocker.

**Gate provenance (`testing-floors.md` ranks).** `docgen` has no Python counterpart, so
it has no rank-2 differential the way the KB rows do — **except** the one that matters:
`CONFORMANCE-MAP.md` is authored independently of the generator, so *"the emitted status
equals the map"* is a genuine **rank 2** check against a fixed committed artifact. Say
that in the SPEC rather than defaulting to a rank-4 golden capture of its own output.

**⚑ This does not answer `D-U3`, and should not be recorded as if it did.** The author's
direction is that **new** tooling is native chirality. The fate of the existing 3,251 L
Python tier is still open — and §6.2 of the pipeline plan is the reason to be careful:
that tier is the user layer's *only* rank-2 instrument.

**Mint owed:** `docgen` needs a catalog + ledger row before any SPEC cites it. Consumer
is named and real (this structure), so it earns one. Category: it holds file crossings,
so `SYS`-adjacent app tooling rather than `VAL`.

### B · Slow, careful audit and alignment of the docs

The doc tier is **doc-keyed and separate from the element pipeline** — the
`doc-audit` skill, `tools/ledger-lint/ledger-lint.py` (checks A–S) as the mechanical pre-sorted
worklist, `tools/doc/doc.py audit <node>` for the semantic residue, fixes running
**toward the authority gradient** (code > map/INDEX > decisions > bank > thin note),
disagreement above the doc = FLAG, never pick.

Known debts this session created or uncovered, to be worked there and **not** patched
ad hoc before it:
- `SCRIBA-PRIMITIVE-CHECKLIST` §1 claims the buffer is *"a typed lens on a port,
  richer than emacs's"*; measured **152 `(Puffer Str)` vs 7 `(Puffer A)`** — the
  parameter has never been cashed. **FLAGGED, deliberately not fixed by this lane.**
- `examples/U13-typed-document-seam.md` is still `status: drafted` and now **behind**
  P1a's finding; it needs a re-audit, not a hand-patch.
- `USER-LAYER-GAP.md` §10 D-U7 has been rewritten three times in one day. It is
  correct now and it is also the least-settled prose in the lane.
- Four new docs (`GAP`, `PIPELINE-PLAN`, `TRACKER`, `FINDING-captured-closures`) have
  never been through `ledger-lint` as *subjects* — only as bystanders.
- `.planning/HANDOFF.md` opens with a **2026-08-03** status banner and is three arcs
  stale; `HANDOFF-VERIFICATION-ARC.md` is live. Two files named handoff, one live.

## §6 · Invariants that must not drift

1. **B1 compiles everything; Python compiles nothing.** Tooling changes (`U0`) are not
   the build path and do not touch this.
2. **A test outside the gating floor is not a gate** — U-row tests land as native-suite
   samples, not side scripts.
3. **Rank 4 unlabelled is a finding** — every gate names its expectation provenance.
4. **Name a mutant and RUN it.** A mutant the gate *misses* is also a measurement and
   gets recorded.
5. **No defer without a cataloged dep.** Naming a follow-on mints its row in the same
   change.
6. **No new phantom** — nothing ships naming a chirality gap a bank already refracts.

---

## §7 · Anchors

`.planning/USER-LAYER-GAP.md` · `.planning/USER-LAYER-PIPELINE-PLAN.md` ·
`.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` · `.planning/BUILD-ORDER.md` ·
`.planning/audit/CONFORMANCE-MAP.md` (build-state authority) ·
`docs/testing-floors.md` + `docs/banks/verification.md` (the gate contract).
