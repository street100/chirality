# BUILD-ORDER — the live cross-lane sequence (2026-08-21)

`ROADMAP.md` is the **design spine** and says so explicitly: *"The stage numbers below
are the design spine, not the build order … for sequencing, the lane plan is
authoritative."* It then points at `.planning/HANDOFF.md`, which was last touched
**2026-08-03 — two days before the rung-1 fixpoint landed**. That arc closed; nothing
took over sequencing. **This file is that owner.**

Scope: everything currently open across the three lanes — core (`E#`), terminal
(`T#`), scriba (`S#`) — in the order it should actually be built, with the reason each
item sits where it does.

**⚡ LIVE WORKSET: `.planning/HANDOFF-VERIFICATION-ARC.md`** — the verification arc
(E166/E167/E168/E169, the oracle retirement). It was reachable only from the CLOSED
`HARNESS-REFACTOR-CHECKLIST.md` until 2026-08-24, which is the same altitude error §A4
catalogues: a live handoff findable only through a dead checklist. Named here and in
`CLAUDE.md` so a fresh session reaches it without knowing to look.

⚑ **Since 2026-08-26 that file opens with THE PLAN OF THE PLAN — five lanes and
their gates — which replaces its old single "one next action".** Sequencing lives
here, but the arc's internal order does not: a linear next-action list could not
express the dependency that section exists to fix (**Lane E gates Lane B**, and
looked orthogonal until the weak-statement floor was named). Read the lane graph
there before scheduling any verification work. The three stances D1 conversion /
D2 derivations / D3 structural-only are RESOLVED in it, with the reasoning; the
one irreversible step in the whole arc is Lane D's corpus deletion, gated on
Lane C mechanically rather than by intention.

**Lane docs (detail lives there, not here):**
`.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` (S18–S32) ·
`.planning/USER-LAYER-GAP.md` (**U#** — a fourth lane, minted 2026-08-30: the
editor/document/KB/agenda user layer above the S# floor; outline tier, no rows
specced yet; run plan `.planning/USER-LAYER-PIPELINE-PLAN.md`, live state
`.planning/USER-LAYER-TRACKER.md`) ·
`.planning/LANGUAGE-INVENTORY.md` (the language floor) ·
`.planning/LEDGER.md` (E# category map) · `TUI/CATALOG.md` (T1–T19) ·
`.planning/SCRIBA-STATE.md` (what is already built).

---

## §1 · Altitude findings — why the order is what it is

The repo's own altitude axis (`docs/axis-altitude.md`) is about **lowering**:
upper → tal → metal, with the rule *"a feature lives as high as it can and drops only
as far as it must,"* and the note that *"the check this wants is mechanical … but it is
unbuilt: today the invariant is discipline enforced by review."* That axis is healthy.

The altitude errors we actually made are on **four other axes** the doc doesn't cover.
All four are the same shape — *a thing living below the level of generality that owns
it* — and all four were found by measurement, not by reading.

### A1 · Definition altitude — shared helpers homed inside consumers
A generic helper written wherever it was first needed, because there was no shelf.
- **Five ad-hoc string comparators; three share the bare name.** `ty-cmp.chiral:34` and
  `row-infer.chiral:35` define `str-cmp`; `asm-reloc.chiral:79` and `compile-back.chiral:128`
  define `ar-str-cmp`/`cb-str-cmp` — **already prefix-renamed to dodge the flat
  emitted-label namespace**, i.e. A2 visible in the source. `string-utils.chiral:80` is
  the canonical one E151a added. *(Corrected 2026-08-22: written as "4×", which
  conflated "definitions of the exact name" with "ad-hoc comparators" and was stale
  either way. The `ledger-lint` check L baseline was slack by one as a result — it
  recorded 4 where the exact-name count is 3, so a new duplicate would have passed.)*
- `str-lower` lives in `manas/chatter/router.chiral:46`; `str-trim` in
  `manas/core/flow.chiral:430` — **text primitives homed inside the orchestration app.**
- ~12 generic prefixed clones (`puf-length`, `puf-reverse`, `se-length`, `se-reverse`,
  `list-nth`×2, `rnd-append-list`, `rules-append`, …).
- The only sort in 88 lib modules is an insertion sort private to `row-infer.chiral:106`.
  **⚑ CORRECTED 2026-08-23 (E156 example audit): NOT the only one.** `closconv.chiral:39` defines `ins-uniq`, the same private fused sorted-unique insertion over `(List I64)` — verified by reading both. There were **two** private sorted-insertion helpers before E152, not one, and a third private de-duplicator (`compile-back.chiral:116`'s tree-set `dedup-str`) besides. The live lines are `row-infer.chiral:93` (`ins-sorted`) and `:104` (`sort-dedup`), not `:106,117`.
→ **Fix: E151 (string stdlib), E152 (sort), and the new `VAL` ledger category** — a
shelf that did not exist until 2026-08-21, which is *why* the leak happened.

### A2 · Mechanism altitude — a codegen defect forcing app-level duplication
A1 is not carelessness. Two co-blobbed modules **cannot** define the same internal
name: emitted labels share one flat namespace. Hand-patched three times
(`gate-contains` E140 · `agent-ok2xx` S15 · `cmd-types.chiral:2` inlining
`lookup-scribaop` "to avoid B1 label issue"). If a shared name can't be defined twice
safely, a module writes a prefixed clone instead of importing.
→ **Fix: E154** (per-module label mangling at emit).
→ **Not the phantom** `docs/banks/module.md` §4 refutes — that correction is about the
*design* tier and is right. This is the *emit* tier. The bank now carries the caveat
(§5 item 6) so it can't be cited as evidence the collision doesn't exist.

### A3 · Source-tree altitude — the foundation reachable by several paths
`resolve.chiral` takes **one** `CHIRALITY_LIBDIR`, so every independently-buildable subtree
needs the foundation visible under its own path. `TUI/` carries 9 such paths —
`prelude`×3, `grid`×2, `collections`, `utf8`, `vt-parser`, `session`, `render`,
`ports`, `apc`. Second half, and the part that matters: basename dedup is *"first
occurrence wins"* (`resolve.chiral:15`), so two same-named modules on the path silently
drop one — a P1 hole, a thing that happens with no name for the event.
→ **Fix: E155** (multi-root search path, named collision error, retire the extra paths).

**⚑ A3 — CORRECTED TWICE; this is the final version (2026-08-22).** **they are SYMLINKS — 9 real files behind 12 shared paths, links running BOTH directions** (`TUI`→`lib` for prelude×3/collections/ports/samples-grid; `lib`→`TUI` for grid/vt-parser/utf8/apc/render/session, plus the `scriba` and `agent` directory links). **There is no duplication at all.** Settled by `ls -l` 2026-08-22, after two wrong calls — first "independent copies, drift risk" (from `stat` inodes), then "hardlinks, proved by mutation". The lesson recorded on purpose: check the simplest direct observation before reasoning from indirect evidence.

Sequence of my errors, kept because the pattern is the point: (1) "9 independent copies,
nothing prevents drift", cited to differing inodes — wrong, `stat` is unreliable here;
(2) "hardlinks, proved by mutation" — right conclusion, wrong mechanism; (3) actual:
symlinks, both directions, no duplication. Each time I reasoned from indirect evidence
when `ls -l` answered it outright.

**What survives for E155:** `resolve.chiral` takes ONE `CHIRALITY_LIBDIR`, which is *why* the
symlink web exists — it is a workaround, and a working one. **"Delete the 9 copies" is NOT
a deliverable — they are not copies.**

**⚑ E155 BUILT 2026-08-22 (`cc9604d`) — and my dedup claim above was WRONG, a third
error in this same section.** I wrote that `resolve.chiral:15`'s *"first occurrence wins"*
dedup silently drops a module. That line is a **COMMENT**; the code keyed on the import
string as written (`seen-insert seen root-name`), so `(import "ports/proc")` and
`(import "proc")` were *different* keys and **both** were emitted — a duplicate-definition
hole, not a drop. The drop only fired through the importer-dir fallback. I cited a comment
as if it were code — the same A5 error as the `tools/` one, and the same shape as A3's own
first two: reasoning from an indirect artifact when the direct one was one command away.

What actually landed: a basename collision between two DIFFERENT modules is now a named
error naming both paths, with **no blob emitted** (fails closed), in both providers;
re-importing the SAME module still dedups (the DFS relies on it). Identity is canonical
path-then-bytes (shell) / source text (chirality), **not** the path string — because
`scaffold/lib/scriba/{prelude,ports}.chiral` are symlinks to the lib-root files and
`scaffold/lib/render.chiral` symlinks into `TUI/scriba/`, so a path-keyed check would have
refused the scriba build outright. Multi-root landed in `resolve.chiral` (`-L <dir>` on
stdin, first hit wins). Verified: the real `ports/proc` vs `proc.chiral` case refused;
compiler blob byte-identical; fixpoint holds; native suite green; 19/19 in the new
`scaffold/tests/test-resolver-collision.sh`.

### A4 · Catalog altitude — elements filed in the wrong lane
- `E88` (mark+region) and `E92` (dispatch) are scriba-app work carrying **core E#
  numbers**. The ledger has flagged them "pending migration to S#" for months.
  → **Fixed 2026-08-21:** rehomed to **S31/S32**; the E-rows are cite stubs.
- `E88`'s build-state read `design` in the ledger and `Not built` in the catalog while
  the code has shipped since **2026-08-14** and is live in the blob.
  → **Fixed:** both corrected with citation.

### A5 · Claim altitude — docs asserting what the code contradicts
Three found, all corrected 2026-08-21:
- `TUI/PRIMITIVE-AUDIT.md` lists `shr`/`sar` and `bput-u16-le` as open WANTs. Both
  **shipped** — `E108` and `E109`, ledger state `built`; `shr`/`sar` are prelude
  externs at `prelude.chiral:60–61`. Live WANT count was 5, is 3.
- `.planning/SCRIBA-SLICES.md` "chirality needs #3" says `alist-get` still can't be called
  with 2 type params + a fn param. **E147 fixed exactly that on 2026-08-16** — its
  runtime gate is literally `(alist-get Str Str str-eqf)`. So the workaround at
  `puffer.chiral:8` is **obsolete and still in the tree**.
- `docs/banks/module.md` §4 — see A2.

### A6 · Principle audit (2026-08-22) — findings against PRINCIPLES.md

Run after the author asked for one. Three findings changed rows; the rest are noted
so they are not re-derived.

- **P3 · scriba holds network authority (measured).** The blob carries 87
  network references and the editor opens `(backend-open rv-endpoint)` inline at
  `command-loop.chiral:1327,1439,1473`. P3 governs the ports, and
  `docs/live-environment.md` decides this exact case: *"an AI-orchestrator earns its
  own node… a fontifier does not (empty port set)."* → **new `S20b`**, and the
  original `S20` shrinks to empty-port-set view state. This is the audit's biggest
  finding: the conventional fix (buffer-local slot) would have entrenched the
  violation. **Stated at the right level** (corrected same day, after a first draft
  over-collapsed it): conversation *content* leaves the editor but a re-attach
  *handle* stays; the network-authority removal is unqualified; `S28` changes shape
  rather than dissolving — the loop must still poll two sources, it just is no longer
  blocked inside a crossing it makes. And S20b inherits a real hard edge — a port is
  linear, and `command-loop.chiral:1735` records that holding anything linear across a
  keystroke is precisely what CHAT had to avoid — so S20b is **not** a strictly
  cheaper S20; that question is its design content.
- **P4 · the S18 record's gradient points the wrong way.** One central record makes
  "add to global state" cheap and "make it a node" expensive — the slope that built
  Emacs's single image, which `live-environment.md` inverts. S18 still lands, now
  with an explicit constraint: editor's own state only, nothing holding a port.
- **P1 · E154/E155 are correctly motivated but were not cited as such.** The
  resolver's silent *"first occurrence wins"* dedup is precisely P1's seccomp
  example one level down: a module can vanish with no name for the event. That is
  the argument for E155's named collision error, and it should be the argument in
  the row.
- **Global principle 6 (abstractions must constrain or they're overhead) · the A1–A5
  taxonomy is descriptive, not enforcing.** Until the two one-command checks in §3
  are actual `ledger-lint` rows, this taxonomy is policy, not physics — which is what
  P4 rejects. Owed, not done.
- **Process · the E# pipeline was bypassed.** `CLAUDE.md` requires
  example → audit → spec → audit → implement before implementing any catalog `E#`.
  E151a was dispatched straight to implementation with no worked example and no SPEC.
  Precedent exists (E145 and E147 have neither) but the rule carries no carve-out, so
  this is a violation, not an exception. Either follow it for E151b/E152/E150, or
  amend the rule on purpose — `PRINCIPLES.md` itself says a contradicted principle
  gets changed deliberately, not quietly.
**⚑ CORRECTED 2026-08-22: E42 is BUILT, not designed-unbuilt.** `LEDGER.md:99` reads `built` — *Runtime supervisor v1: supervised event loop + alarm-as-crossing*, `scaffold/lib/supervisor.chiral` (139 L), multiplexing fd-readiness + fired alarms through one blocking primitive, dispatching exactly one unit of work per tick, threading the linear `SockVec` + `Clock` cap on every arm. Rung-2 halves + typed alarm (E26) are named residue. I propagated *designed, unbuilt* from `TUI/PRIMITIVE-AUDIT.md` (2026-08-11), which the ledger corrected on 2026-08-12 — an A5 claim-altitude error, mine, from trusting the lower-authority doc. **Nothing imports it yet**, which is why it read as unbuilt: built-but-unadopted, exactly like `string-utils` before E151b. So `S29` is gated on *adoption*, not on construction.
- **P5 · not engaged, correctly.** Nothing here is in the unprovable region.

**The through-line:** every one of these is a thing sitting lower than the level that
owns it — a helper below its generality, a duplicate below its source, an element
below its lane, a claim below its authority. The lowering axis has a `preserve-check`;
these four have nothing, which is why they rotted silently. `tools/ledger-lint/ledger-lint.py`
already covers the catalog axis (checks J/K caught two of my own mistakes while
writing this). The other three are candidates for the same treatment.

---

## §2 · The order

Serial within a wave unless noted. Each item: build → B1 rebuild → verify → commit
before the next. **Async is last on purpose and gates nothing.**

> **⚑ Concurrency note (2026-08-22).** A second session is committing in this repo with
> a sweep-everything staging step: the W0-1 source edit below was captured into its
> commit `9b7d216` ("feat(research): R1 …") before it could be committed with its own
> message. The change and its verification are correct and recorded here; only the
> commit attribution is wrong. **Check `git log -- <file>` before assuming an edit is
> uncommitted, and prefer committing a finished unit immediately.**

### Wave 0 · Truth — no code, hours   ✅ COMPLETE 2026-08-22
Do this first because everything downstream reads these docs.

```
[x] A4  rehome E88/E92 → S31/S32; correct both stale build-states
[x] A5  correct PRIMITIVE-AUDIT (shr/sar, bput-u16-le), SCRIBA-SLICES #3, banks/module §4
[x] D-S3 decided: chat becomes an ordinary buffer
[x] W0-1 DONE 2026-08-22 — the three helpers were DEAD (zero external callers),
         so this was a deletion, not an import restoration. ELF same size,
         ~180K bytes differ (per-def index renumbering); behaviour verified by a
         control-vs-subject PTY smoke + 4 unit tests exit 0.
[x] D-S1 DONE 2026-08-22 — docs/decision-user-layer-extensibility.md. NOT a fork:
         the user layer extends in chirality, live; E45 freezes the KERNEL, and the user
         layer is above that line. S11 stays an init-file loader, blocked on E132;
         no throwaway data-config format. The registries S18/S21 build are the seam.
[x] D-S2 MERGED into D-S1 2026-08-22 — minting it separately was a FALSE SPLIT:
         a hook IS extensibility, reaching the same effect by another feature.
         One decision. Advice dissolves into re-registration; a hook adds only
         plurality, so it is a handler list + a closed event sum, not a mechanism.
         S25 is the observation half of the one model. S29's event half decided;
         only scheduling stays gated on E42.
```

> **⚑ SUPERSEDED 2026-08-23 — resume from `.planning/HARNESS-REFACTOR-CHECKLIST.md`'s
> RESUME POINT banner, not from here.** That arc closed (H1–H11, C1–C4, E155, E159,
> E160, E76's remainder, E2's `profile`/`target` slice; `run-native.sh` 2 → 8 gating
> phases). The live work is the **E161** pipeline, blocked one step short of
> implement. The banner below is kept for provenance only.
>
> **⚑ SESSION STATE 2026-08-22 (context exhausted; resume here).**
> **Done:** compiler+blob PROMOTED 2026-08-22 (see the ✅ section below — 20/20
> samples) · W0 complete · **E151 BUILT** (full pipeline; six gated commits; `str-cmp`,
> `str-contains`, `str-lower`, `str-trim`, `str-pad` each have exactly one owner, ratchet
> at 1) · **E152 BUILT** (`list-sort`, stability gate with teeth) · **E150 example reviewed;
> SPEC audit FAILED/BLOCKED** — status reverted `audited` → `specced` (a `--mark audited`
> had been run prematurely).
> **⚑ NEXT ACTION is an AUTHOR CALL, not code — decision 2, `openat`/`close`'s home.**
> The SPEC says `lib/argv.chiral` declares them locally, citing four precedents. Measured
> refutation: all four are *roots* (nothing imports them, so their duplicates never meet),
> but `argv` is a **library** that meets all of them — and **`term.chiral:137` declares
> `(extern close (=> I64 Unit))`**, with `term` in **scriba's** import graph, while
> `scriba <file>` is this element's stated first consumer. A duplicate extern is a hard
> load error (`load: extern redeclared: close`, measured). **Either** promote
> `openat`/`close` into `ports.chiral` and delete six local declarations across five files
> (also unifying `close`'s type — tree says `(=> I64 Unit)`, the example says
> `(=> I64 I64)`), **or** keep them local and record "never compose `argv` with
> `term`/`resolve`/`self-wield`/`test-runner`" as a live hazard. Either answer changes
> Phase A's "Done when". Then re-audit; the rest of the SPEC is clean.
> **B0 is RESOLVED, by measurement, not argument:** the probe was *run* — a `ti-call`
> does reach an `x-fin` asm label (exit 77, with a negative control giving
> `asm: unknown label`). Phase B needs no new `TInstr` and no op-set widening. My
> "deadlock" framing was also wrong on its own terms: decision 1 rejected `ti-peek` (a
> general computed-address load); decision 7's fallback was `ti-argv` (narrow,
> fixed-source) — different ops, different widening.
> **Then:** E156 (`row-infer` adopts the sort owner) → S18 → S20b.
> **Parked, own chat:** `.planning/TEXT-AND-DIAGNOSTICS-ARC.md` (E157/E158).
> **Orientation:** `.planning/NOVELTY-INVENTORY.md`.

### ✅ DONE 2026-08-22 — the compiler is promoted

Was: `scaffold/build/B1` stale at 1,020,280 B (predating E151b and E152), with
`blob.chiral` staler still. Now both are at HEAD, promoted **together**.

| artifact | was | now |
|---|---|---|
| `scaffold/build/B1` | 1,020,280 B (Aug 16) | **1,024,376 B** — the size this doc predicted |
| `scaffold/build/blob.chiral` | 600,140 B (Aug 16) | **613,000 B** |

Gates actually run, in order: fixpoint `C1 == C2` **byte-identical** · E151 string gate
**exit 0** · E152 sort gate **exit 0** · promoted-pair reconfirm `B1(blob) == B1` ·
`run-native.sh` green. Local artifacts only — `scaffold/build/` is gitignored, so this
is not a commit.

**⚑ Finding 1 — `run-native.sh` green meant less than it looked.** Phase 2 runs
`scaffold/build/test-runner`, a binary dated **Aug 6** — 16 days and ~5 compiler
generations stale, which promoting B1 does not touch. Its manifest is hardcoded to the
**6 oldest samples**; `scaffold/tests/samples/` holds **20**. So "ALL PASS" was a stale
binary over trivial cases. Already cataloged — the E148 ledger row names *"retires
`test-runner`'s bundled manifest (`test-runner.chiral:7`)"*, so no new element is needed.
Two residues NOT in that row, recorded so they are not rediscovered. First, the binary
is stale *independent* of discovery. Second — and this is the one that matters — its
builder **runs on the Python floor**: `scaffold/tools/build_test_runner.py` (142 L)
"interpreted-compile[s] with the named entry", i.e. it drives the CPython interpreter
over the compiler source. So the native test-runner can only be rebuilt by the floor
that is being retired, which is exactly why it has sat at Aug 6 while B1 moved five
generations. *(Corrected 2026-08-22: first written as "its build path is **lost** —
`tools/` does not exist". Wrong — I ran `ls tools/` from the repo root; the path in
`run-native.sh:70` is relative to `scaffold/`, and `scaffold/tools/` is fully present.
Same error shape as A3: an indirect check where a direct one was available.)*
The fix is small and removes a Python dependency from the test path: B1 can build it
today, since `lib/test-runner.chiral`'s entry is `test-main` while B1's entry is
`compile-main` — which is precisely why the old `test-runner-blob.chiral` carries a
**hand-appended tail** with a `compile-main` shim (and its own `manifest`, hardcoding
`(=i passed 6)`, superseding the module's own `manifest`/`test-main`).

**⚑ Finding 2 — so the promoted compiler was verified against all 20 instead.**
Each sample declares its own imports, so blob-per-sample is generic. Result: **20/20**,
including `e104_pty` (the real `/dev/ptmx` acquisition dance) and `e120_pool_roundtrip`
(memfd + ftruncate + mmap). Note for whoever automates this: **13 exit 0 and 7 exit 42**,
and 42 is the documented SUCCESS code in those seven headers — a naive `[ $? -eq 0 ]`
harness reports them as failures. Same shape as the two traps below.

### The procedure (reusable — run it whenever compiler sources change)

```
cd /workspace/chirality
ulimit -s unlimited
. bin/chirality-resolve.sh

# 1. regenerate the blob from HEAD sources (pure shell, post-order DFS, no Python)
chirality_blob scaffold/lib sys-linkage compile-front compile-back compile-emit compile-all compile-driver > /tmp/blob.new

# 2. build the new compiler with the OLD one, then prove it reproduces itself
./scaffold/build/B1 < /tmp/blob.new > /tmp/C1 && chmod +x /tmp/C1
/tmp/C1 < /tmp/blob.new > /tmp/C2 && cmp /tmp/C1 /tmp/C2      # MUST be byte-identical

# 3. BEHAVIOURAL gates — the fixpoint above is NOT a correctness check
chirality_blob scaffold/lib string-utils > /tmp/g.chiral
cat scaffold/tests/samples/e151_string_stdlib.chiral >> /tmp/g.chiral
/tmp/C1 < /tmp/g.chiral > /tmp/g.elf && chmod +x /tmp/g.elf && /tmp/g.elf   # exit 0
chirality_blob scaffold/lib collections > /tmp/h.chiral
cat scaffold/tests/samples/e152_list_sort.chiral >> /tmp/h.chiral
/tmp/C1 < /tmp/h.chiral > /tmp/h.elf && chmod +x /tmp/h.elf && /tmp/h.elf   # exit 0

# 4. promote both artifacts together — a new B1 beside a stale blob is the trap
#    that made me report "B1 is one generation stale" when the blob was the stale one
cp /tmp/C1 scaffold/build/B1 && chmod +x scaffold/build/B1
cp /tmp/blob.new scaffold/build/blob.chiral

# 5. confirm from the promoted pair, and re-run the suite against the NEW compiler
./scaffold/build/B1 < scaffold/build/blob.chiral > /tmp/V && cmp /tmp/V scaffold/build/B1
bash scaffold/tests/run-native.sh
```

**Do not skip step 3.** A reversed-but-total comparator passes the fixpoint at identical
byte size, passes the 42-test, and passes a cross-compiler differential — only the
behavioural samples catch it. That was measured, deliberately, this session.

**⚑ The root list was STALE and is corrected 2026-08-23 — `compile-driver` is
required.** H4 moved the `compile-main` entry out of `compile-all` (a library) into
`compile-driver` (a leaf), so the old list ending at `compile-all` now resolves a blob
with **no entry**: B1 exits 1 with `no such def: compile-main` and leaves a **0-byte**
`/tmp/C1`. The next line then "passes" — `cmp` of two empty files succeeds — so the
stale list fails the build and **passes the fixpoint check**, which is the fixpoint
trap this file already warns about, wearing a third hat. Measured 2026-08-23 while
setting up the E161 baseline. `scaffold/tests/test-syscall-manifest.sh:71` already
carried the correct list; this procedure, the `run-native.sh:84` hint and
`SCRIBA-PRIMITIVE-CHECKLIST.md` did not. Historical records that quote the old list
(`BUGS-AND-GAPS.md:59`, the E108/E144/E151 specs) are left alone: they were true when
written.

**Do not promote B1 without the blob.** Promoting one and not the other is exactly what
produced my inverted "the binary is stale" diagnosis, which cost three documents a
correction.

### ⚑ AUDIT 2026-08-25 — the local pair is one source generation behind HEAD

> **Partly CLOSED 2026-08-25** — the promotion and the orphaned gate are DONE; see
> *RESOLUTION* at the end of this section for the numbers. Still **OPEN**: the mirror's
> `build.sh` root list, `make-public.sh:101` blessing a non-fixpoint mirror, and
> `test-runner`'s structural blindness to `lib/`. Each open item is tagged inline.

Measured at `7a5746b`, read-only: nothing was promoted, nothing in `scaffold/build/`
was written. Every number below is from a command whose output is quoted in the
session that produced this section.

**The fixpoint holds, and the local binary is not the one HEAD builds.** A fresh blob
(`chirality_blob scaffold/lib sys-linkage compile-front compile-back compile-emit
compile-all compile-driver`) is **708,039 B**; `B1 < fresh > C1` and `C1 < fresh > C2`
both give **1,077,624 B** and `cmp C1 C2` passes — non-zero size asserted first, so
this is not the empty-file trap. But `cmp C1 scaffold/build/B1` **fails at byte
40,121**, with **79,713 of 1,077,624 bytes differing** at identical total size. The
committed pair is internally consistent on its own terms — `B1 < scaffold/build/blob.chiral`
reproduces `B1` byte-for-byte — so what we have is two self-consistent generations,
not a corrupt one.

**The blob delta is only E166 Step 0, and that is shown, not assumed.** Splitting both
blobs on `(end-module "…")` gives 52 modules committed and 53 fresh; the only new one
is `alloc-growing`. Of the 52 shared modules, exactly **two** differ: `alloc` loses the
`alloc-growing` def and the `mach-x64` import (−215 B) and `emit-x64` gains
`(import "alloc-growing")` (+25 B). −215 + 25 + 1104 = **+914**, which is exactly
708,039 − 707,125. Nothing else has landed in the compiler blob: `mach-c`,
`c-assemble` and `ddc-legc` are new modules outside its root set (⚑ `mach-c` and
`c-assemble` were **deleted 2026-09-01** with the C backend, `d8bcec5`; this
measurement is left as it was taken), and `row-infer`,
`collections` and `emit-core` have newer mtimes than the blob with byte-identical
content in it.

**The stale binary is stale-but-harmless, and that too is measured.** `C1` and `B1`
have **identical string sets** (`strings -n 6 | sort -u`, 383 lines each, zero
difference either way), and they compile identical output: the E151 string blob and
the E152 sort blob each come out byte-identical from both compilers, and both run to
exit 0 under `C1`. Step 3's behavioural gates pass. So a promotion is **owed for
hygiene** — the tree that built the local binary is no longer the tree — and the risk
of deferring it is that every gate below silently reports on the pre-relocation
compiler. **Promotion is the author's call; this audit did not take it.**
**→ CLOSED 2026-08-25: the promotion was taken. See RESOLUTION below.**

**The gate that would have caught it is not wired to anything.** **→ CLOSED
2026-08-25: it is `run-native.sh` Phase 11. See RESOLUTION below.**
`scaffold/tests/test-resolver-collision.sh:267` resolves the compiler blob and `cmp`s
it against `scaffold/build/blob.chiral`, printing *"compiler blob resolves but differs
from the committed `scaffold/build/blob.chiral`"* on mismatch — it would fail today.
`run-native.sh` never invokes that script; it is a standalone gate nobody runs.

**Phase 2 is evidence about a frozen binary, not about HEAD.** **→ half CLOSED
2026-08-25: `test-runner` was rebuilt against the promoted `B1`, so it is no longer a
generation behind. Its structural blindness to `lib/` is unchanged and stays OPEN —
E148.**
`scaffold/build/test-runner` (1,081,720 B, dated 2026-08-23 07:29:44) embeds its own
`compile-all`; `run-native.sh:90` executes it and `$CHIRALITY_BIN` never touches it. It reads
six sample *paths* off disk (`test-runner.chiral:50-55`) — the same six cases Phase 1
already checks inline — so a regression in `scaffold/samples/` is visible to it and a
regression anywhere in `scaffold/lib` is not. Its generation is now datable: its string
set is `B1`'s minus `compile-main` plus its own ten runner strings, so it carries the
E161 module-coordinate refusals and is **the same source generation as `B1`**, not the
Aug-6 binary the 2026-08-22 finding above describes. That finding is history now; the
binary is one generation stale rather than five, and it still cannot see `lib/`.

**Everything else the gates execute is built fresh.** `scaffold/build/B1` (every gate's
`$CHIRALITY_BIN`, via the `bin/chirality-bin` → `scaffold/build/B1` fallback — `bin/chirality-bin` does not
exist in this repo), `scaffold/build/test-runner` (Phase 2) and
`scaffold/build/blob.chiral` (the collision gate's baseline) are the complete set of
prebuilt artifacts any script under `scaffold/tests/` or `bin/` reads. The resolver
binary both `test-resolver-collision.sh:56` and `test-module-kind.sh:503` exercise is
compiled from source by `$CHIRALITY_BIN` inside the run, so the stray `scaffold/build/resolve`
is dead weight; `bin/chirality:44` assigns `TEST_RUNNER` and never uses it.

**The public mirror cannot currently be synced, and it fails closed.** **→ OPEN.
Untouched 2026-08-25 — the mirror is a separate repo and syncing it is an outward-facing
action nobody has authorized. Both hazards below stand.**
`bin/make-public.sh:85` ships the private `scaffold/build/B1` as the mirror's
`bin/chirality-bin` — so a sync today would publish the pre-relocation compiler beside
post-relocation `lib/` sources. It does not get that far: the guard runs the mirror's
own `build.sh`, which is public-authored and therefore never synced, and that script
still carries the **retired root list ending at `compile-all`**. Resolved here, that
list yields a 707,018 B blob with **zero** `(def compile-main)`; `B1` exits 1 with
`no such def: compile-main` and writes 0 bytes, and `set -euo pipefail` aborts
`build.sh` before it prints `built:`, so `make-public.sh` exits 1 without committing.
The mirror at `/workspace/chirality` is meanwhile pinned at private `b312dd7`
(2026-08-14) with a 1,012,088 B `bin/chirality-bin`, **396 commits** behind. Fixing this means
editing `build.sh` in the mirror repo, not here. Note the second-order hazard for
whoever does: once the root list is fixed, a stale `bin/chirality-bin` compiling current `lib/`
produces a binary that differs from the shipped one, and `make-public.sh:101`'s
`^built:` branch **accepts** that — the mirror would ship a compiler that is not the
fixpoint of the sources beside it, with the guard reporting OK.

#### RESOLUTION 2026-08-25 — promoted, and the gate now runs

Done at `5a5e94a`, in the order the procedure above prescribes: **build, TEST, promote.**
`scaffold/build/` is gitignored (`.gitignore:8`), so none of these artifacts are in git —
what follows is the local build state, and the commit carries only the two source/doc
changes.

**Build.** Fresh blob from the six canonical roots: **708,039 B**, one `(def compile-main)`.
`B1 < fresh > C1` = **1,077,624 B**; `C1 < fresh > C2` = 1,077,624 B; both sizes asserted
non-zero *before* the compare, then `cmp C1 C2` rc=0. `cmp C1 scaffold/build/B1` differed
at byte 40,121 — the generation gap this audit measured, reproduced exactly.

**Test, before promoting.** `CHIRALITY_BIN=/…/C1 bash scaffold/tests/run-native.sh` →
**144 ok, 0 FAIL, 82 roots compiled, exit 0**, matching the number `docs/testing-floors.md`
records for HEAD. Phase 10 ran the whole C leg under the candidate (`--no-admission`,
9 gates), including G4's byte-identity at 1,077,624 B. This ordering is the point: a
candidate that fails here never reaches `scaffold/build/`.

**Preserve, then promote both together.** The outgoing artifacts were kept under the
`.pre-e166` names beside `B1.pre-e137` and friends — `B1.pre-e166` (1,077,624 B, Aug 23),
`blob.chiral.pre-e166` (707,125 B), and `test-runner.pre-e166` (1,081,720 B) — so the
promotion is reversible by three `cp`s. Then `C1` → `B1` and the fresh blob →
`blob.chiral`, in one step. Confirmed from the promoted pair:
`./scaffold/build/B1 < scaffold/build/blob.chiral > V` gives 1,077,624 B (asserted
non-zero) and `cmp V scaffold/build/B1` rc=0.

**`test-runner` rebuilt** with the promoted `B1` from the seven-root list
(`sys-linkage compile-front compile-back compile-emit compile-all test-runner` — **no**
`compile-driver`; it supplies its own entry): blob 710,027 B → 1,081,720 B, differing
from the outgoing binary at byte 42,524 at identical size. Runs 6/6 PASS, exit 0.

**The orphaned gate is wired in as Phase 11**, and it found a second defect on the way.
`test-resolver-collision.sh` is now `run-native.sh`'s last phase, **19 assertions**. It
was placed LAST, not inserted: phase numbers are cited as identifiers outside the script
(E156 = Phase 9, E166 = Phase 10, in `SELF-IMPLEMENT-CATALOG.md`, `LEDGER.md`,
`CONFORMANCE-MAP.md`, two SPECs and `docs/testing-floors.md`), and no phase
short-circuits the run — `fail` only accumulates — so an earlier slot would rot those
citations to buy nothing. ⚑ **The gate had itself rotted red while orphaned**: its
`build_native_resolver` concatenates a hand-listed module set with a plain `cat`, which
predates E161's `(end-module "<key>")` extent markers, so it died with *"module
collections declares a second coordinate inside one module extent"* and **11 of its 19
assertions — the entire native half — had not run since E161**. Fixed in the same change.
That is the orphaning's real cost: not one dark assertion but eleven, plus the staleness
this audit had to find by hand.

**The suite at HEAD is now 163 `ok`, 0 FAIL, 82 roots, exit 0** — 144 + 19. Its
wall clock, and where that clock goes, is the next section.

### The suite's wall clock: a measured RANGE, and the retirement of a budget nobody measured

⚑ **THERE IS NO ~4-MINUTE BUDGET, AND THERE NEVER WAS ONE.** That figure was asserted
in conversation on 2026-08-25, propagated into three rows here and in `LEDGER.md`,
`SELF-IMPLEMENT-CATALOG.md` and `HANDOFF-VERIFICATION-ARC.md` as a threshold the suite
"is supposed to hold", and was never measured against anything. Nothing in the tree
enforces it, no run ever established it, and it was invented twice — once as the budget
and once as the finding that the budget was breached. It is retired here, and the
replacement is a range with its variance named, not another threshold. A number a run
can be compared against has to come from runs.

**Measured 2026-08-25 at `8db4af0`, three serial runs, nothing else on the box**
(`ulimit -s unlimited; time bash scaffold/tests/run-native.sh`, default compiler
selection, i.e. CompCert; `MemAvailable` checked between each at 3.0–3.3 GB of 3.85 GB
with no swap):

| run | `real` | `user` | `sys` | `real` − (`user`+`sys`) | result |
|---|---|---|---|---|---|
| 1 | **5m24.523s** | 2m39.258s | 1m28.459s | 1m16.8s | 163 `ok`, 0 FAIL, 82 roots, exit 0 |
| 2 | **5m25.725s** | 2m38.110s | 1m28.447s | 1m19.2s | 163 `ok`, 0 FAIL, exit 0 |
| 3 | **5m21.253s** | 2m35.862s | 1m28.151s | 1m17.2s | 163 `ok`, 0 FAIL, exit 0 |

**The figure to quote is `5m07s–5m36s` on this host** — seven runs now. Five on
2026-08-25 at `8db4af0` (the three tabled above plus 5m26.139s under ccomp and
5m26.160s under gcc) clustered inside 4.9 s ≈ 1.5 %; two more at `568699e`, serial on
an otherwise idle box, ran **5m07.711s** and **5m36.444s**.

⚑ **That 1.5 % was a property of those five runs, not of the suite.** Two back-to-back
runs differ by 28.7 s ≈ 9.3 %, and one phase moved further than the whole published
spread: **Phase 8 does identical work every time** (44 assertions in both runs, 1.2 s of
its 35 s spent off-CPU, so nothing about it should be load-sensitive) and measured
**23.15s** inside the first run against **35.04s** inside the second and **35.379s /
34.732s / 35.488s** standalone. Five of six measurements cluster at 34.7–35.5 s. The
23.15 s is not explained. A suite whose fixed-work phase varies 1.5× on the same box in
the same hour does not have a ±1.5 % wall clock, and the range is all these numbers
license — never a threshold.

### Where the time goes — the eleven phases, measured

**One instrumented run at `568699e`**: `$EPOCHREALTIME` stamped onto every output line
gives each phase's wall clock, and bash's `times` builtin read at each phase banner gives
cumulative `user`+`sys`, so `real − CPU` is attributable *per phase* rather than only in
aggregate. Total 5m36.444s = `user` 2m41.699s + `sys` 1m33.415s + **1m21.3s off-CPU**.

| # | phase | wall | share | CPU | off-CPU |
|---|---|---|---|---|---|
| 1 | inline behavioral | 0.30s | 0.1% | 0.18s | 0.13s |
| 2 | native test-runner | 0.07s | 0.0% | 0.05s | 0.02s |
| 3 | `chirality check` CLI | 3.20s | 1.0% | 1.83s | 1.38s |
| 4 | composition manifest | 6.73s | 2.0% | 3.47s | 3.26s |
| 5 | syscall manifest enforced | 12.26s | 3.6% | 9.93s | 2.32s |
| 6 | linear mint (E159) | 2.01s | 0.6% | 1.20s | 0.81s |
| **7** | **downstream roots compile** | **151.37s** | **45.0%** | 99.87s | **51.50s** |
| 8 | module datasheet (E161) | 35.04s | 10.4% | 33.88s | 1.16s |
| 9 | sort adoption (E156) | 12.31s | 3.7% | 12.22s | 0.09s |
| **10** | **external-compiler leg (E166)** | **102.51s** | **30.5%** | 85.80s | 16.72s |
| 11 | resolver + build state (E155) | 10.63s | 3.2% | 6.68s | 3.94s |

**Phases 7 and 10 are 75.5 % of the suite.** Everything else together is 82 s.

⚑ **Phase 7 is not a compile cost. It is `bin/chirality-resolve.sh`.** Re-running its exact
loop with the two legs timed separately (88 roots after the six `*_reject_*` skips,
**2,017 module resolutions**, `144.747s` total):

| leg | time | share of Phase 7 |
|---|---|---|
| `chirality_blob_file` — the **shell** source provider | **118.556s** | **81.9 %** |
| `B1` — actually compiling the 88 blobs | 22.305s | 15.4 % |
| the loop itself (`mktemp`, `rm`, the `end-module` count) | ~3.9s | 2.7 % |

The provider forks ~7 external processes **per module per root** — `readlink -f`,
`dirname`, and `chirality_imports`'s `sed | grep | sed`, then a `cat` per module in the emit
loop. Resolving one large root's 53 modules that way costs `real 3.367s` (`user` 1.338 +
`sys` 1.072, so 0.96 s of it off-CPU); the same 53 files read by bash with no fork at all
cost **0.028s** — a **120× ratio**. That is also the answer to "where is the off-CPU
time": 51.5 s of the suite's 81.3 s off-CPU seconds are in this one phase, and they are
process creation and image lookup on a virtiofs-backed root, not the compiler waiting on
anything. **~35 % of the entire suite's wall clock is bash spawning helpers.** The native
provider that would replace it already exists — `scaffold/lib/resolve.chiral`, which
Phase 11 builds and pins against this one — so this is an observation about the shell
leg, not a missing capability.

⚑ **Phase 10's cost is the differential and the C compile, not the gate.** From the same
instrumented run:

| step | time |
|---|---|
| G0b blob A composition (674,612 B, 51 modules) | 2.97s |
| G1 `B1 < blobA` → `chirality-bin-emit-c` (1,007,992 B) | 1.47s |
| the shim's 51 hand-derived checks over `chirality-rt.c` | 0.38s |
| G2 exit-42 program end to end through the leg | 0.77s |
| **F3 behavioural differential, 25 samples, both legs** | **64.61s** |
| **building `chirality-bin-c`: 2,171,314 B of C → `ccomp`** | **25.01s** |
| G4 conviction, byte-identity at 1,077,624 B | 6.95s |
| G5 quorum, `prov-disjoint?`, 36 cases | 0.23s |

So the ddc gate's growth from 13 to 36 cases — a named suspect — costs **0.23 s** and is
not a suspect at all.

⚑ **The 2m52s and 3m35s at `70ee90f` are FALSIFIED, and no bisect was needed.** Both
were written the same day for the same commit and the same 163 assertions, they disagree
with each other by 43 s, and both are below the measured cost of phases whose workload
that commit and HEAD share exactly:

* Phase 7 sweeps **94** files defining `compile-main` at `70ee90f` and **94** at HEAD
  (`git grep -l '^(def compile-main' <rev> -- scaffold/lib TUI agent scaffold/samples`),
  against a `scaffold/lib` of 31,373 lines then and 31,429 now — **+0.18 %**.
* Phase 10's F3 differential walks **25** samples at both revisions
  (`git ls-tree -r --name-only <rev> -- scaffold/tests/samples`).
* Phase 7's dominant leg, the 118.6 s shell resolver, does not invoke the compiler at
  all, so it is **independent of which `B1` was promoted** — and `scaffold/build/` being
  gitignored is exactly why that matters.

163 `ok` also *requires* Phase 10: the counts are 6+0+7+31+12+21+0+44+14+**9**+19, so a
run reporting 163 ran the C leg's nine gates, F3 and the `chirality-bin-c` build included. That
leaves **2m52s = 172 s** to cover a 118.6 s fork-bound resolver plus a 35 s Phase 8 plus
a 25 s C compile of 2.17 MB — 179 s before counting eight other phases. **3m35s = 215 s**
fails the same way against Phase 8 + Phase 10 alone (137 s) on top of the resolver.

**What is honest to say:** at HEAD, on this host, the suite is 5m07s–5m36s, and 75 % of
that is Phase 7's shell resolver and Phase 10's C leg. Neither prior figure can be a
complete 163-`ok` run here; what they actually measured is not recoverable from the tree,
because neither was recorded with a method. A historical run was **not attempted and
would not have settled it**: `scaffold/build/` is gitignored, so a worktree at `70ee90f`
has no `B1` and a run there would be that tree's tests against *this* tree's compiler —
a comparison across two binaries, which is not a comparison. The arithmetic above needs
no such run, because its dominant term never touches the compiler.

⚑ **Still unexplained, and left that way rather than guessed:** what the 2m52s and 3m35s
figures were taken over, and Phase 8's single 23.15 s reading against five clustered at
34.7–35.5 s.

### ⚑ 2026-08-26 — the baseline IS reproducible, once the WORKLOAD is held fixed

E170 W0 read Phase 10 at **6m0.541s**, re-ran the *unchanged* pre-W0 tree
(`576963e`, in a worktree against the same `B1`) at **4m18.478s** against this
page's recorded **2m21s**, and concluded *"the machine is ~1.8× slower today"*.
**That inference is falsified, and the correction is worth more than the number:
the two sides were not the same workload.** Every baseline figure above — 2m21s,
1m41s, the per-phase table, the 5m07s–5m36s range — was taken when F3 swept
**25** samples. Counted with
`git ls-tree -r --name-only <rev> -- scaffold/tests/samples`:

| rev | date | `.chiral` samples | of which test-floor fixtures |
|---|---|---|---|
| `e426a30` · `70ee90f` · `8db4af0` · `568699e` | 08-24 → 08-25 | **25** | 0 |
| `576963e` — *"the unchanged pre-W0 tree"* | 08-25 | **36** | 11 |
| `880e0e0` — HEAD at W0 | 08-25 | **39** | 14 |

**Measured 2026-08-26** — two back-to-back
`ulimit -s unlimited; time bash scaffold/tests/ddc-c-leg.sh --no-admission` runs,
otherwise idle box, same `B1`, `gcc 12.2.0` both, the only difference being F3's
marker column:

| F3 sweep | `real` | `user` | `sys` |
|---|---|---|---|
| 39 samples | **5m14.614s** | 4m13.359s | 0m30.355s |
| 25 samples | **1m41.358s** | 1m12.555s | 0m12.747s |

The 25 swept today are identically the 25 the baselines were taken over (the 14
now tabled `floor` are exactly the files added after `568699e`). **1m41.358s
reproduces the recorded 1m41.6s / 1m41.2s and sits inside the recorded gcc band
1m40.1s–1m51.7s.** The arithmetic closes on the other side too: 101.4 s + 11 floor
fixtures × 15.2 s = **269 s ≈ 4m29s**, against the 4m18.478s measured at
`576963e`. The corpus grew; the box did not slow down, and no machine-speed term
is needed to account for a second of it.

**The method, named so the next wave repeats it instead of re-deriving it:**
compare Phase 10 only against a Phase 10 measured over the SAME SAMPLE COUNT, and
take that count from `git ls-tree`, not from a document. A suite wall clock is not
comparable across revisions that touched `scaffold/tests/samples/` — which is now
every wave of E170. `ddc-c-leg.sh` prints its swept and floor-judged counts on the
`ok` line for exactly this reason.

⚑ **AND THE TOOLCHAIN IS NOT THE ONE THIS PAGE RECORDS.** `/opt/compcert` **does
not exist in this container** (`ls /opt/compcert/bin` → *No such file or
directory*, 2026-08-26), so `ddc-c-leg.sh`'s preference order falls through to
**gcc 12.2.0** and every figure in this section is a gcc figure. The fallback is
REPORTED, not silent — `ddc-c-leg: C compiler gcc (Debian 12.2.0-14+deb12u1)
12.2.0` is printed on every run, which is how this was noticed — but *"Phase 10
now defaults to CompCert `ccomp 3.17`, which is built and installed at
`/opt/compcert`"* is a claim about a **machine state that did not survive**, and
`/opt` is not on the `/workspace` bind mount. The build recipe below stands
unchanged; what does not stand is reading a run's provenance off this page instead
of off the banner.

**The suite at HEAD after the marker landed, measured the same day, same method**
(`ulimit -s unlimited; time bash scaffold/tests/run-native.sh`):
**12 phases / 178 `ok` / 0 FAIL / 82 roots compiled / exit 0 in 3m22.359s**
(`user` 1m58.291s, `sys` 0m45.410s), with Phase 10 reporting *"25 samples SWEPT:
both legs agree AND match the documented exit code (14 more judged by the floor,
Phase 12)"* and Phase 12 15 passed / 0 failed. **The assertion count is unchanged
at 178** — F3 is one assertion whether it sweeps 39 samples or 25, which is the
point: coverage moved home, the accounting did not.

**Re-measured 2026-08-26 after E170 lane C landed** (same command, same box):
**12 phases / 187 `ok` / 0 FAIL / 82 roots compiled / exit 0 in 3m07.828s**
(`user` 1m53.228s, `sys` 0m39.082s), Phase 10 now *"25 samples SWEPT … (17 more
judged by the floor, Phase 12)"* and Phase 12 24 passed / 0 failed. **+9
assertions and +18.2 s, both in Phase 12**, measured directly by running that
phase alone on either side of the change (**23.555 s → 41.786 s**) rather than
inferred from the suite total, which moved the other way inside its own spread.
The nine are three re-founded judgment rules and their six harness-run mutants;
the mutants are two thirds of the cost and are the half that makes the other
third mean anything.

⚑ **Do NOT read 11m18.589s → 3m22.359s as this change's effect.** **213.3 s** of
it is F3's and is measured directly, back-to-back, in the table above; the rest is
the run-to-run spread this section already documents (Phase 8 has been measured at
23.15 s and at 35.04 s for identical work), and charging it to a marker column
would be the very mistake the subsection above corrects.

**Why the number lives here and not in `docs/testing-floors.md`.** That file is the
*contract* — which floors gate, which are advisory, what expectation provenance a row
carries — and its native-behavioral row cites a wall clock only as orientation. This
file owns sequencing and the measurements that inform it. The floors table now points
here rather than carrying a rival figure, so there is one home for the number.

⚑ **TOOLCHAIN ACQUISITION — READ BEFORE INSTALLING ANYTHING, and do NOT reach for
opam.** Phase 10 now defaults to **CompCert `ccomp 3.17`**, which is built and
installed at `/opt/compcert`. It was obtained *without opam*, which matters
because the standing note used to say "CompCert installs via opam" and opam is the
one route that exhausted this box's fd table **twice**. Debian ships no `compcert`
package in any suite — and does not need to: CompCert bundles Flocq and MenhirLib,
and every other prerequisite is in bookworm `main`, the only component this box
has (`coq 8.16.1`, `ocaml 4.13.1`, `menhir 20220210`, `libmenhir-ocaml-dev`).

```
apt-get install -y --no-install-recommends coq menhir ocaml-findlib libmenhir-ocaml-dev
curl -sSL -o v3.17.tar.gz https://github.com/AbsInt/CompCert/archive/refs/tags/v3.17.tar.gz
./configure x86_64-linux -prefix /opt/compcert && make -j2 all && make install
```

`make -j2 all` (259 Coq proof files re-checked, then OCaml extraction) returned
RC=0 with a floor of **1,369,324 kB MemAvailable** — it fits this microVM
comfortably, in ~20 minutes unattended. Recorded in three places on purpose:
here (sequencing), `.planning/HANDOFF-VERIFICATION-ARC.md` (the live workset a
new chat opens), and `docs/banks/verification.md` §5 item 6 (the durable depth
tier that outlives the arc's handoff). ⚑ **Never distribute a CompCert-built
artifact** — INRIA's licence restricts *use* of CompCert and carries no output
restriction, a one-off comparison is evaluation, and `ddc-c-leg.sh` discards
every artifact it builds on exit.

⚑ **One thing measured and not fixed in this change — FIXED IMMEDIATELY AFTER, at
`ce593c4`.** `CHIRALITY_BIN` was honoured by `run-native.sh`'s own inline phases only. Five of
the sub-scripts it drives — `test-syscall-manifest.sh`, `test-linear-mint.sh`,
`test-e156-dedup.sh`, `test-module-kind.sh` and `test-resolver-collision.sh` — each
re-derived `CHIRALITY_BIN` from `bin/chirality-bin` → `scaffold/build/B1` and ignored the override, and
two more (`test-check-cli.sh`, `test-profile-target.sh`) went through `bin/chirality`, which had
its own resolution. So E166's admission run, which sets `CHIRALITY_BIN=chirality-bin-c` to run this
suite "under chirality-bin-c", actually ran **Phases 3, 4, 5, 6, 8, 9 and 11 under `B1`** — of the
135 assertions it reported, **6** (Phase 1) were genuine C-leg coverage and **129** were
not. Phase 7's 82 root compiles were genuine, that phase being inline.

All seven now resolve `CHIRALITY_BIN` first, `bin/chirality` included (its `_compiler()` honours the
same variable — the two front-door phases are cleanly coverable, since resolution decides
only which binary gets exec'd). Measured both ways before and after:
`CHIRALITY_BIN=/bin/false bash scaffold/tests/test-linear-mint.sh` → **7 passed, 14 failed**
(was 21/0, ignoring the override), and unset → 21/0 unchanged.
**Admission re-run under a total override: 154 `ok`, 0 FAIL, 82 roots, exit 0** — 148
assertions that had never once run under the C-built compiler, **none of them divergent**.
`ledger-lint` **check P** (added `e579106`) now fails any `scaffold/tests/*.sh` that names
`scaffold/build/B1` without consulting `CHIRALITY_BIN`, so the convention cannot rot back one
new test script at a time — which is how it got here.

### Wave 1 · The shelf — small, unblocks everything above it
The stdlib is *upstream* of the editor floor: S18–S24 will want sort, string ordering,
and argv, and writing them locally again is how A1 happened the first time.

```
[x] E151a DONE — string module, ADDITIVE half — canonical str-cmp/lower/upper/trim/
         replace into scaffold/lib/string-utils.chiral + a samples gate.
         DISPATCHED 2026-08-22.
[x] E151b DONE 2026-08-22 — RETIRED the duplicates — make ty-cmp / row-infer / asm-reloc /
         compile-back import the shelf and delete their local str-cmp; same for
         router.chiral's str-lower and flow.chiral's str-trim.
         ⚑ COMPILER SOURCES => needs the self-hosting fixpoint check.

         Why the split (found 2026-08-22, not in the original catalog row):
         `string-utils.chiral` is imported by exactly ONE module today —
         `render-str.chiral`, itself an orphan — so the shelf is DEAD in every
         shipping blob. That makes E151a zero-link-risk (nothing can break) and
         means all the risk, and all the actual altitude payoff, sits in E151b.
         It also means the shelf existing was never enough: A1 happened because
         nothing IMPORTED it, not because it was missing.

         ⚑ E154 bites here concretely: E151b co-blobs string-utils with
         ty-cmp.chiral, which defines `cmp-bytes`. E151a's internal helpers are
         `su-`-prefixed for exactly that reason — a live instance of the flat
         label namespace forcing a naming workaround.
[x] E152 DONE 2026-08-22 — polymorphic comparator-passed STABLE merge sort:
    `list-sort` in collections.chiral + the e152_list_sort.chiral runtime gate (exit 0).
[ ] E150 own argv — unblocks `scriba <file>` and any real CLI
```

### Wave 2 · The editor state floor — the gate
```
[ ] S18  Scriba editor-state record         ← 74 signatures, 436 arg sites, mechanical
[ ] S21  : commands as a registry           ← before S19: buffer commands register INTO it
[ ] S19  buffer list + switching            ← chat retires here (D-S3)
[ ] S20  buffer-local slot — EMPTY-PORT-SET state only (Outline, Catalog, scroll)
[ ] S20b split the orchestrator into its own node    ← P3. Moves conversation
         content out of the editor (a re-attach HANDLE stays), removes network
         authority from the editor process, and changes S28's shape without
         removing it. ⚑ Inherits a known hard edge: a port is linear, and
         command-loop.chiral:1735 records that holding anything linear across a
         keystroke is what CHAT had to avoid. That question IS S20b's design
         content. See §1 A6.
```

### Wave 3 · Wire the 986 written-but-inert lines
```
[ ] S22  describe-key / apropos / generated :help      (help.chiral, 249 L, written)
[ ] S23  window tree wiring                            (window.chiral, 400 L, written)
[ ] E148 directory READ: getdents64 + stat             (CORE)
[ ] E149 fs MUTATION: unlink + rename + mkdir          (CORE, split from read)
[ ] S24  flook wiring                                  (flook.chiral, 264 L, written)
```

### Wave 4 · Mechanism — pay down A2/A3   (E155 DONE; E154 open)
> **⚑ 2026-08-22 — a whole arc landed off this path.** The harness/auth refactor ran
> as its own checklist, `.planning/HARNESS-REFACTOR-CHECKLIST.md`, and closed: the
> compiler promotion, the entry-symbol squat (H4), `chirality check` off Python (H5), the
> four interpreted-compile tools (H4b), **E155** (H10), the **ports split into nine
> registries** (H11), **`profile`/`target` in the native front end** (H6, E2's deferred
> slice), **E76 ENFORCED** (H7/H8), and **E159** the linear-mint hole (H9). `run-native.sh`
> went from 2 gating phases to **six**. Read that checklist before re-planning these waves.
Deliberately *after* Wave 1–3: E151/E152 already remove much of the duplication E154
would make safe, and doing the shelf first tells us how much of E154 is really needed.

```
[x] E155 DONE 2026-08-22 (cc9604d) — named collision error (fails closed, no blob
         emitted) + multi-root via `-L <dir>`. "DELETE the 9 copies" was never a
         deliverable — they are symlinks. Identity is bytes/canonical path, NOT the
         path string, because the scriba symlink web would otherwise be refused.
[ ] E154 per-module label namespace at lowering (compiler-source change →
         rebuild + promote + self-hosting fixpoint check)
```

### Wave 5 · The decided rows
```
[ ] S25  hooks / extension points        (needs D-S2)
[ ] S26  edit-stable markers
[ ] S11  init-file load                  (needs D-S1 + E132)
[ ] S27  overlays / text properties
[ ] S30  keyboard macros
```

### Wave 6 · Numeric
```
[ ] E153 F64 float tower — DESIGN PASS FIRST. Touches type system, reader, TAL,
         codegen; orthogonal to the NumProfile width decision but shares its home.
         Nothing above depends on it; everything measurable does.
```

### Wave 7 · Async — its own arc
```
[ ] S28  interruptible run — poll stdin beside the backend socket (poll.chiral exists, unused)
[ ] S29  background work + completion events            (gated on E42)
```

**Parked, deliberately off this path:** the **text & diagnostics arc** (E157 typed
diagnostics + E158 `Doc`) — handoff at `.planning/TEXT-AND-DIAGNOSTICS-ARC.md`, to be
run by a dedicated agent in its own chat. Surfaced while working E150/E151; do not
interleave.

**Not on this path, correctly:** the `CRY` ladder (E114–E119, already slotted), TLS/DNS,
the T# terminal waves (T5–T19), rung-2. They have their own docs and no dependency on
the above.

---

## §3 · Acceptance for the whole sequence

- **After Wave 2:** adding a user-layer surface costs one registry row and one module —
  zero `command-loop-inner` arms, zero `VimMode` variants, zero threaded params.
- **After Wave 4:** `grep -c '(def [a-z]*-str-cmp'` returns 1, and `TUI/` carries zero
  copies of `scaffold/lib/` modules. Both are one-command checks — make them lint rows.
- **Throughout:** no new helper is written inside a consumer when a shelf exists for it.
  That is the altitude rule, restated for the pure tier.

---

> **SPLIT 2026-09-01. Two halves of this file are now TRACKED; this file is not.**
>
> - **§1's A1-A6 altitude taxonomy** -> `docs/definitions/altitude-errors.md`,
>   with every instance re-measured against the migrated tree. About half of them
>   are fixed and the original citations are `scaffold/`/`TUI/` paths that no
>   longer exist.
> - **The suite wall-clock sections** (the retired "~4-minute budget", the
>   5m07s-5m36s range, the eleven-phase breakdown, the same-workload comparison
>   method, the gcc-not-CompCert caveat, the CHIRALITY_BIN defect) ->
>   `docs/benchmarks/test-suite-wall-clock.md`. `docs/definitions/testing-floors.md`
>   used to name THIS file as the owner of that figure, which pointed the tree's
>   contract for its primary correctness gate at a gitignored document. It now
>   points at the benchmark note.
>
> **This file is NOT archived and must not be moved.** Fifteen tracked documents
> cite it by path and by line, including `docs/banks/verification.md:117`, which
> names it as the home of the build ceremony, and five `docs/elements/specs/`
> files that cite `:285-320` and `:304-313` for that ceremony. Moving it breaks
> all of them. The remaining live content is:
>
> - **the build ceremony** at `:285-335`, the thing those citations want. It is
>   the strongest candidate for the next hoist, and `CLAUDE.md`'s BUILD RULE
>   already carries a condensed form.
> - **§2's waves and §3's acceptance**, superseded for the two live lanes by
>   `docs/decisions/decision-lane-split.md` (Lane A diagnostics, Lane B file
>   types) but still the only record of the S# and U# ordering.
