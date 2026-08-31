# HARNESS REFACTOR — THE checklist for this arc

> ## ⚑ THIS ARC IS CLOSED — the live workset moved out, 2026-08-23
>
> **→ `.planning/HANDOFF-VERIFICATION-ARC.md`** is the handoff for the live work
> (the verification arc: oracle repair → retirement, the C/CompCert legs,
> E166–E169). It used to be a resume banner grafted here, which was the wrong
> home: this arc is closed and that one is not.
>
> What is below is this arc's own record (H1–H11 and the E161 pipeline that ran
> out of it) and stays for provenance.
>
> ### Traps that already cost time — do not re-learn these
> - ~~**Pack defect:** `--spec` / `--audit spec` resolved the example as
>   `sorted(glob(...))[0]` and picked `E161-REQUIREMENTS.md`.~~ **FIXED** — the
>   pipeline artifact is now taken from the file the `examples/INDEX.md` row
>   links, glob only as fallback (`examples_for`, `tools/pack/pack.py`).
> - **A shipped E160 defect is recorded on its ledger row** — a def-less coordinate
>   is never closed, so `(kind ports C upper)` owns the **345 defs** that follow it
>   in the compiler blob. Latent only because that façade carries no claim.
>   **E161 Step 1 fixes it at the root**; don't patch it separately.
> - **Trust order: code > requirements > example > prompt.** Every framing handed
>   to this element has been wrong at least once, mine included. See §7 below.
> - **Comparing against the pre-session compiler is CONFOUNDED** — it does not know
>   the `kind` form and fails on that first. Strip `(kind …)` lines before any
>   old-vs-new comparison.
>
> ### Minted, no pipeline run yet
> **E162** manifest-custody · **E163** manifest-kind · **E164** profile-ergonomics.
> Each was minted with the open choice that makes it pipeline-worthy. E164's row
> carries the evidence it is real: the port-set gate works and the tree contains
> **zero** `(profile …)` outside tests.


**Opened 2026-08-22.** Owner of this arc's sequencing. Items are checked off here
as they land. Detail lives in `.planning/AUTH-HARNESS-MAP.md` (the measured
authority-vs-enforcement map); this file is the worklist.

Roll-up: the python items here are rung-1 Phase B work and roll up to
`.planning/RUNG1-CHECKLIST.md` when the arc closes — they do **not** get written
into that file mid-arc.

---

## The two invariants (author, 2026-08-22)

1. **Python provides ZERO chirality function.** Not as a compiler, not as a fallback,
   not to build "a new form of chirality". chirality compiles arbitrary programs, so it
   compiles every program chirality needs — including its own tools.
2. **Python remains ONLY as an external test reference**, and that role is itself
   migrating to rocq.

Everything below is scoped by those two. An item that does not serve them, or
does not serve the authority model becoming real in the native build path, is
not on this list.

---

## §1 · Landed

```
[x] H1  Compiler promoted — B1 1,020,280 -> 1,024,376 B and blob.chiral
        600,140 -> 613,000 B, promoted TOGETHER. Fixpoint C1==C2 byte-identical;
        E151 + E152 behavioural gates exit 0; promoted-pair reconfirm clean.
        Verified against ALL 20 samples (13 exit 0, 7 exit 42 = documented
        success), not just the 6 the suite walks.                      02e45b0

[x] H2  Native test-runner built by B1, not CPython — DONE PROPERLY 741da89.
        First attempt was blob surgery (stripping the compiler's own compile-main
        and appending a shim) and was WRONGLY marked landed; that is superseded.
        Now: built from an UNMODIFIED blob, no shim, no surgery. See H4.

[x] H3  AUTH-HARNESS-MAP written — the authority model checked against the live
        compiler rather than against other docs.                       acddf66

[x] H0  Corrections to my own errors, recorded rather than quietly patched:
        "build path is lost / tools/ does not exist" was wrong (scaffold/tools/
        is fully present; run-native.sh's path is relative to scaffold/). Same
        error shape as A3 — indirect check where a direct one existed. a15194e
```

---

## §2 · The order

### H4 · The entry symbol leaves the library   ✅ DONE 2026-08-22 (741da89)
```
[x] H4  compile-all stops squatting on the entry symbol.
```
**My first diagnosis was wrong and is kept here because the correction is the
point.** I wrote that the defect was "the driver hardcodes its entry" and scoped
the fix onto E150/argv. It is not: a fixed entry symbol is fine and conventional —
`resolve.chiral:284` already defines `compile-main` directly.

The real defect: **`compile-all.chiral` is a LIBRARY** — imported by `test-runner`
and `self-wield` — **and it also defined `compile-main`.** So any root program
embedding the compiler collided on the entry symbol (`duplicate label (an object
def collides with the linked runtime): compile-main`), and the tools reached for
the CPython interpreter, which can be told an arbitrary entry name. It is the
same **definition-altitude** error as A1 in `BUILD-ORDER.md` §1: a thing living
below the level that owns it — here, an entry inside a library.

Fix landed:
- `compile-all.chiral` → library only (`compile-all`, `read-fd-all`)
- `compile-driver.chiral` (new) → the `compile-main` entry, nothing else
- `test-runner.chiral` / `self-wield.chiral` → each names its own entry `compile-main`

**Latent bug this exposed:** blobbing `self-wield` used to pick up `compile-all`'s
`compile-main` and silently produce **the compiler**, not the wielder. It now
errors if the root defines no entry, and builds a distinct binary.

Verified end to end, all with B1, zero python: compiler reproduces from HEAD
(1,024,376 B) · fixpoint byte-identical · **test-runner reproduces from an
unmodified blob** · self-wield distinct from the compiler · E151+E152 gates exit
0 · native suite green.

`scaffold/tools/build_test_runner.py` **deleted** — its only reason to exist was
the collision. `run-native.sh:68` now advertises the B1 command.

**No argv needed. E150 is NOT a prerequisite for this.**

### H4b · Retire the remaining interpreted-compile tools
```
[x] H4b DONE 2026-08-22 (8c44593) — all four retired. Every one was ALREADY
        BROKEN, measured rather than assumed:
        probe_image.py  -> REPLACED by tools/probe.sh + probe-main.chiral; all
                           five probes reproduce (exits 7/3/21/31/41) in 1.6s
                           instead of ~5min of interpreter. Its whole reason
                           was the entry-squat H4 fixed.
        map_cluster2.py -> DELETED (KernelError on compile-emit.chiral); its
                           question was answered by E70, output preserved in
                           CLUSTER-2-MAP.md.
        smoke.py        -> DELETED (SurfaceError: unknown name backend; drifted
                           at E106's linear-cap change). Zero consumers.
        ddc.py          -> MOVED to scaffold/tests/. Not a build tool — its only
                           consumer is test_ddc.py, so it is python TEST-ORACLE
                           code, which the invariant permits. Already red before
                           the move.
        selfhost.py     -> untouched, the sanctioned cold-bootstrap exception.
```
Accurate grep across `bin/` + `scaffold/tools/` now returns only `selfhost.py`.
⚑ My original DONE-WHEN pattern was too weak — it never matched `selfhost.py`'s
indented `from chirality.surface import` either, so it would have reported a clean
bill that was not one.

**Also landed here:** `--entry NAME` is honest and works for ANY name (it was
`sed`-rewriting the user's source, firing only for `main`, and would produce a
wrong binary if the source merely contained `(def main ` anywhere). And
`bin/chirality-resolve.sh` extracted `(import "...")` from **comments**, which made
`resolve.chiral` unresolvable by the shell provider — the cause of `bin/scriba`'s
dead resolver-bootstrap branch, now fixed.

**Dropped, not deferred:** `smoke.py`'s function (live HTTP/SSE against a worker)
has no replacement. It is API-dead, has zero consumers, and cannot run in ccbox
(egress blocked). A native host smoke test is NEW work, not a port. Recorded as
DROPPED rather than minted as a phantom follow-on.
H4 removed the *reason* these exist, but only `build_test_runner.py` is actually
retired and verified. **Unverified, still present:** `ddc.py` 175 L,
`map_cluster2.py` 86 L, `probe_image.py` 150 L, `smoke.py` 137 L. Each must be
rebuilt as a chirality root program naming its entry `compile-main`, or deleted.
`selfhost.py` 442 L is the honest exception — cold bootstrap predates B1 by
definition.
- **DONE-WHEN:** `grep -rl 'from chirality import\|import chirality' scaffold/tools/`
  returns only `selfhost.py`.
- **Also here:** `bin/chirality compile --entry NAME` only implements `--entry main`,
  by `sed`-rewriting the user's source (`bin/chirality:167,186–191`); every other
  value is silently ignored. Make it work for any name or remove the flag — no
  rewriting of user source. And `bin/chirality:173` must stop advertising
  `python3 tools/selfhost.py stage1` as the way to get a compiler.
- Shell paths still advertising python: `bin/chirality:173`,
  `bin/make-public.sh:28` (the latter is correctly labelled cold-bootstrap-only).

### X · Kinds as identifiers — a COORDINATE, not a bucket

**The proposal (author's).** chirality is a set of wildly different kinds of artifact
all wearing one undifferentiated suffix. Use the kind as the identifier so the
language's components are legible. Cosmetics is plumbing — `pretty.chiral` is the
precedent: legibility work whose invariants are *enforced* (*"a display function
**provably** crosses no port"*, *"no catch-all — a new former with no arm is a
**compile error**"*). A kind nothing checks is decoration; a kind the compiler
checks is plumbing.

**First cut was wrong; the correction is the content.** I derived five buckets
from *declaration syntax* — root / decl-surface / vocabulary / manifest / library.
The author's read — *"there's going to be overlap fast"* — is right, and buckets
are why: a module can be several at once, so they collide. The fix is not better
buckets.

**chirality already has the structure, and it is a coordinate.** `banks/module` §1: a
module is *"(a) placed on the typeability axis in exactly one of A/B/C, (b) spanned
across the altitude axis upper→tal→metal, (c) faced outward by a port-set (its
membrane)."* Three orthogonal axes. **Exactly one value per axis, so overlap is
not expressible** — which is precisely what buckets could not give.

| axis | values | the test (`axis-typeability`: *"what does its correctness rest on"*) |
|---|---|---|
| **typeability** | A / B / C | proof, one copy correct = **A** · an admitted hole the language cannot type = **B** · cross-checked evidence about a hole = **C** |
| **altitude** | upper / tal / metal | which tier the code is written at |
| **port-set** | empty, or the named crossings | the membrane (P3) |

**This dissolves the hard case rather than deciding it.** `sys-tal` was "manifest
or library?" — a false dilemma produced by bucketing. Its coordinate is
**altitude: tal**; its 64 hand-authored `TIFn`s are tal-tier code, and nothing
about that competes with being data. The dilemma was an artifact of the wrong
frame.

**The convention is ALREADY LATENT — in prose, where nothing checks it.** Ten
modules annotate their own coordinate today:
```
prelude.chiral:1       "the category A floor"  :5 "The port floor (category C) is lib/ports.chiral"
ports.chiral:1         "the category C boundary, declared in source"
target-linux.chiral:1  "Pure B-referent data"
pretty.chiral:1        "display, NON-trusted … provably crosses no port"
collections.chiral:4   "All pure, all category A"
string-utils.chiral:4  "All category A, no host binding of their own"
```
So this is not a new discipline to impose — it is an existing one to **promote
from comment to declaration**, and then check.

**⚑ The manifest question answers itself.** *"We'll probably do our own type of
manifest file in place of json."* In coordinates that is a module at
**(B-referent data, upper, empty port-set)** — and `target-linux.chiral` is already
exactly that, saying so in its own first line. **chirality's replacement for JSON is
not a new file format; it is a module at that coordinate.** What is missing is the
declaration and the check, not a format.

**⚑ This is the same work as H6/H7/H8, at a different granularity.** A profile
*freezes a port set*; a module *declaring* its port set is the per-module form of
the same fact, and E78 is the per-component attenuation of it. The legibility arc
and the authority arc converge on one declaration.

**⚑ MEASURED 2026-08-22 — the port-set axis is NOT already computed. I claimed it
was; that was wrong.** `row-infer.chiral` really does implement the effect-row
inference (*"the monotone call-graph closure producing def_rows"*), but it is
**not in the compiler**: `infer-row`, `row-of`, `RowSig`, `assoc-row` all have
**zero** occurrences in the compiler blob, and its only importer,
`sig-driver.chiral`, is outside `compile-front`'s import closure
(`parse` / `load-batch` / `specialize-singleton` / `closconv-driver` / `lowspec`).

So this is **built-but-unadopted** — the fifth instance recorded in this repo,
after `checked-sys-lib` (verdict computed, never read), `string-utils` before
E151b, E42, and E147's obsolete workaround. The correction that matters for
sequencing: **H8 does not get cheaper for free.** Adopting `row-infer` into the
compiler is its own step, and it is a prerequisite for the port-set axis being
derivable rather than authored.

```
[x] X1  DONE — measured in `.planning/COORDINATE-MEASUREMENT.md`; corrected four
        of my own numbers, one of which flipped a recommendation. Was: Three axes (typeability / altitude / port-set),
        derived over all 88 lib modules, with the 10 existing prose annotations
        as the seed and ground truth. Where a module's prose and its contents
        disagree, that is a finding, not a default.
        DONE-WHEN: every lib module has exactly one value on each axis, and the
        disagreements are listed rather than silently resolved.

[x] X2  DONE 2026-08-22 (`0407cfa`) — minted as **E160**.
        `(kind <module> A|B|C upper|tal|metal [(pure)|(crosses)])`, optional; an
        unannotated module compiles exactly as before.
        CHECKED at emit: the port-set claim, reusing H8's own `xw-code` predicate
        with an empty allow-set (no second copy to desync). CHECKED at load:
        shape, axis values, redeclaration-by-name. STORED but deliberately NOT
        derived: typeability (a judgment — "what does correctness rest on") and
        altitude (only two-thirds derivable, and a check right two-thirds of the
        time gets suppressed).
        ⚑ FIRST CUT FAILED VERIFICATION and was redispatched: its scope rule left
        the last module in a blob open forever, so appending a program that
        declared its own kind was refused as a redeclaration — breaking
        `chirality_blob > x && cat prog >> x`, which is how every gate here is built.
        Fixed by keying redeclaration on the module NAME; my instruction to omit
        the name was wrong (a `target`'s name and a `profile`'s name are equally
        unverifiable and nobody calls those decoration).
        VERIFIED LIVE, not test-only: flipping `pretty.chiral`'s claim refuses an
        ordinary program that imports it, and flipping `prelude`'s refuses the
        COMPILER'S OWN SELF-BUILD. 29-case gate as run-native Phase 8.
        ⚑ This mark was itself stale until 2026-08-23 — an earlier notch targeted
        the wrong string and silently no-op'd because I omitted the assert I use
        everywhere else. Caught by re-reading the file rather than trusting the
        edit.```

**Re-homed, not part of this:** `mode-from-path`
(`TUI/scriba/file-io.chiral:101–107`) matches `.chiral` with `str-find` — substring
anywhere — so `/tmp/.chiral-old/notes.txt` gets chirality mode; `manas-path?` above it
has the same shape. Boundary-sums finding, **scriba's lane**. The
`bin/chirality compile --entry` defect is folded into H4b.

### H5 · `chirality check` on the native checker
```
[x] H5  DONE 2026-08-22 (8c44593) — `chirality check` runs the native compiler.
```
Verified independently: a `(1 f Fd)` closed once → `OK`, exit 0; closed twice →
`load: linear binder usage mismatch`, exit 1. New
`scaffold/tests/test-check-cli.sh` (7 assertions, 3 positive / 4 negative, each
pinning exit code AND message), wired into `run-native.sh` as Phase 3 so it
gates. The only `python3` left in `bin/chirality` is `test-python`, the advisory
floor — the sanctioned role.

**Known regression in kind, recorded:** native diagnostics are terser than the
retired Python ones (`effectful application inside a pure function (use => not
->)` became `load: type mismatch`). Same verdict, less information. Belongs to
the text & diagnostics arc (E157/E158), not here.
B1 **already type-checks** — measured: a `(1 f Fd)` used twice or dropped is
refused with `load: linear binder usage mismatch`. This is CLI wiring, not
missing semantics.
- **DONE-WHEN:** no `python3` in any core subcommand (`check`/`compile`/`run`,
  and `test`'s gating floors).

### H6 · `profile` / `target` in the native front end   ✅ DONE 2026-08-22 (eb7ec6a)
```
[x] H6  Port the two toplevel forms from surface.py to parse.chiral.
```
**The frozen port set is now real in the compiler that compiles everything** —
mechanism 2 of the capability bank's four. Of the conjunction it says *"pulling
any one leaks"* of: opacity ✅, q=1 linearity ✅, frozen port set ✅ (this),
reflective floor (E45) ✗ still unbuilt.

Scope was parse + elaborate + store. Enforcement is H7/H8 and was deliberately
not implemented.

**It was much bigger than a `parse.chiral` change**, and the reason matters: the
chirality `Sig` had **five** fields and **no `prim_is_port`** — the oracle's
`sig.profiles` / `sig.targets` / `prim_is_port` had *no chirality counterpart at
all*. `Sig` is now 7 fields across **19 `mk-sig` sites in 5 files**, threaded
through `closconv-sig` and `specialize-singletons` so the manifest survives to
lower/emit time, which is exactly where H7/H8 needs it. `prim_is_port` was NOT
replicated as a registry — `ty-crosses` derives it from the stored type, so there
is no second copy to desync.

Rejection reasons are a **closed sum** (`MfErr`, 18 reasons) rendered to string
only at the `step-err` boundary, per the standing boundary-sums rule.

**What H7/H8 can now read:** `sig-profiles` / `sig-targets` (+ keyed
`sig-profile` / `sig-target`). Per profile: `name` · `ports` (the frozen set,
each name validated as a declared extern AND proven to cross) · `target` (already
installed) · `memory` `(Maybe Str)` · `total` `Bool`. Per target:
`reqs : (List (Pair Str Term))`. Plus `sig-prim-crosses` / `ty-crosses` as the
is-it-a-crossing predicate. **H7/H8 needs nothing further from the front end.**

Verified with my own tests, not the agent's suite — each exit 1, own message:
`profile port str-len is pure; only crossings belong in the port set` ·
`profile port nonesuch is not a declared extern` ·
`profile P names unknown target Nope` ·
`profile P: unknown memory discipline gc (have linear, region)` ·
`profile P redeclared`. Positive case exit 0.

**Ceremony** (compiler sources changed): blob regenerates from HEAD identically at
636,845 B · B1 rebuilds byte-identical at **1,044,856 B** · fixpoint holds ·
promoted pair self-reproduces · e120/e125/e104 exit 42, e151/e152/e147/e140
exit 0 · run-native green across all four phases (6 / ALL PASS / 7 / 31) ·
resolver 19/19. New `test-profile-target.sh` (31 cases) is Phase 4.

**Oracle behaviour preserved rather than improved** (deliberate): `surface.py`
fuses "malformed `(target)`" and "missing `(target)`" into one message, and a
duplicate clause is last-wins. The agent's first cut took first-wins, corrected
with the full ceremony re-run.

### H7 + H8 · E76 ENFORCED   ✅ DONE 2026-08-22 (612a2d9)
```
[x] H7  emit-elf REFUSES unless the chokepoint verdict is `sok`.
[x] H8  The check is per-program, against the profile's permitted subset.
```
E76's catalog remainder was *"profile-permitted-subset + load-time gate owed"*.
Both land, at emit.

**H7.** `checked-sys-lib` had one definition site and zero uses — computed and
discarded, with a Python test as its only enforcement. `emit-elf` now runs the
chokepoint over the **whole emitted image** (`native-lib ++ link-lib ++
reify-all nfns`) and refuses through the existing `elf-err` arm. Strictly
stronger than the dead def, which covered only `sys-lib`: a hand-authored
`ti-sys` in object code is now caught too.

Proven by poisoning a **blob copy** (tree never touched), both arms:
```
number rewritten -> E76 chokepoint REFUSED emit: sys: ti-sys number does not
                    match registered number (E76)
row renamed away -> E76 chokepoint REFUSED emit: sys: crossing not in permitted
                    registry (default-deny, E76)
```
It refuses even a **pure** program, because the image includes the linked
runtime. Default-deny governs unconditionally — that is the point, not a bug.

**H8 — the first time two configurations in this repo produce different
outcomes.** Identical program bodies, different manifests:

| declaration | body | result |
|---|---|---|
| `(profile Talker (ports print) …)` | `(print "hi")` | **emits**, runs, exit 42 |
| `(profile Muted (ports put) …)` | `(print "hi")` | **REFUSED** — *crossing print (wrap-print) is outside the declared profile port set* |
| `(ports)` empty | `(print "hi")` | REFUSED |
| `(ports)` empty | no crossing | emits |
| no profile | `(print "hi")` | emits |

**How the crossing set is determined — and why NOT `row-infer`.**
`tal-erase.chiral` rewrites `i-prim <extern>` into exactly `n-call <wrapper>`, so
the **codomain of `crossing-wraps` is the vocabulary of "this code crosses"**, in
the last representation before bytes. `row-infer` is source-level, is not in the
compiler, and would place the check one image *above* where the fact lives.
Sound over-approximation: a lowered-but-never-called crossing counts, which errs
toward refusal, never toward permission.

**A profile-less program is NOT "everything permitted."** Default-deny by absence
over the swappable `target-linux` registry still governs it — the poison test
refuses a no-profile program. **A profile ATTENUATES an already-closed set, never
grants.** Multiple profiles **intersect**, so a second declaration can only
narrow (union or last-wins would let a second line hand back a crossing the first
froze out).

**Ceremony:** blob 644,433 B regenerates from HEAD · B1 byte-identical at
**1,053,048 B** · fixpoint holds · promoted pair self-reproduces · run-native
green across all **five** phases (6 / ALL PASS / 7 / 31 / 12) · resolver 19/19 ·
e120/e125/e104 exit 42, e151/e152/e147/e140 exit 0. New
`test-syscall-manifest.sh` (12 cases) is Phase 5; it poisons blob copies, never
the tree.

**Known and correct:** the 3-arity `emit-elf` is retained for the Python-RT
callers and passes `(none)`, so the oracle path gets H7 but never H8 — it holds
no `Sig`. Phase 5 is the only cover for the profile gate, which is why it gates
natively.

### H9 · The linear-mint hole   ✅ DONE 2026-08-22 (7b2b87e) — E159
```
[x] H9  A linear value cannot be bound at ω. (NOT "an extern must use `=>`".)
```
**⚑ My diagnosis was wrong and the correction is the finding.** I said the pure
`->` arrow was what let a minted capability escape linearity. The `adopt-pty`
control I minted E159 on was FALSE — its failure was `no emitted label for entry
compile-main`, a LOWERING failure (no `prim2lib` row, so it never reaches the
checker), and its *correct* single-close fails identically. I truncated stderr at
70 chars, saw `exit=1`, and read a lowering error as a linearity refusal.
**Flipping both arrows and rebuilding leaves all three holes compiling clean,
exit 0 — measured.**

**The real hole is the BINDER QUANTITY.** `parse.chiral`'s `parse-lbind` binds a
plain `(let (f v) …)` at **quantity 2 = ω**, and `qfits` accepts any number of
uses of an ω binder. Same one level up: `(-> Fd Unit)` is an ω-quantified
parameter of a linear type. **`check_data` already had exactly this rule for a
data FIELD** — the missing twins were the let binder and the Pi binder. That is
the class, and only the `(1 f Fd)` parameter control was ever real.

Now refused (all three previously compiled clean, exit 0):
```
(let (f (adopt-fd 999)) (do (fd-close f) (do (fd-close f) 0)))
(let (f (adopt-fd 1))   0)
(let (b (backend-open "http://x")) … double close …)
  -> load: let binds a linear value at quantity omega -- a linear value must be bound at 1
(=> Fd I64) with an omega param
  -> load: function parameter of a linear type at quantity omega -- a linear parameter must be declared (1 x T)
```
**The layering is right — the new rule does not replace the old audits:**
q1 bind + closed once → **compiles and runs, exit 42**; q1 bind + closed twice →
`load: let binder usage mismatch` (pre-existing).

The arrow rule is kept in `loader.chiral` — it is a real invariant and it is what
E159's row mints — but the tests say honestly it is *declaration hygiene*, and
the binder rules are what stop duplication. It checks `ty-crosses` over the whole
Pi spine, not the outermost arrow, or `pool-write`'s
`(-> (0 n I64) (=> … (Pool n)))` would be wrongly refused.

**Blast radius, swept old-vs-new over every `.chiral` comparing exit code AND
stderr:** all 149 `scaffold/lib` modules load byte-identically clean, manas
included. Eight violators, all outside `lib/` — the two declarations, `e145`'s
local extern redecl, and five ω-let sites in samples + `agent/tools-fs.chiral`.

**Ceremony:** blob 650,717 B · B1 byte-identical at **1,057,144 B** · fixpoint ·
run-native green across all **six** phases (6 / ALL PASS / 7 / 31 / 12 / 21) ·
resolver 19/19 · **primary gates `e137_backend_linear` and
`e145_be_peek_roundtrip` both exit 42** · the three `e124_reject_*` still refuse
for their INTENDED reason, not the new one.

**Scope honesty, unchanged:** at rung 1 an `Fd` is a raw integer and a `Backend`
IS its base string, so this restores the TYPE-LEVEL discipline only. Nothing here
stops emitted machine code from closing a descriptor twice. That tier is E77.

### H10 · E155 — resolver named collision   ✅ DONE 2026-08-22 (cc9604d)
```
[x] H10 Named collision error + multi-root search path.
```
A collision between two DIFFERENT modules sharing a basename is now a named
error naming both paths, with **no blob emitted** — it fails closed. Re-importing
the SAME module still dedups (the DFS relies on it). Multi-root landed in
`resolve.chiral` (`-L <dir>` on stdin, first hit wins); `bin/chirality-resolve.sh`
stays single-libdir.

**Identity is not the path.** `scaffold/lib/scriba/{prelude,ports}.chiral` are
symlinks to the lib-root files and `scaffold/lib/render.chiral` symlinks into
`TUI/scriba/`, so a path-keyed check would have refused the scriba build. Shell
uses canonical-path-then-bytes; chirality uses source text (no `realpath` crossing
exists). This is the A3 symlink web from `BUILD-ORDER` §1 biting a second time.

**⚑ My premise was wrong** and is corrected in `BUILD-ORDER` §1 A3: `resolve.chiral`
did NOT dedup on basename. Line 15's *comment* said so; the code keyed on the
import string as written, so `(import "ports/proc")` and `(import "proc")` were
different keys and BOTH emitted — a duplicate hole, not a drop. I cited a comment
as code.

Verified independently of the agent: real `ports/proc` vs `proc.chiral` case
refused with 0 bytes emitted · compiler blob byte-identical to committed ·
fixpoint `C1==C2` and `C1==`committed B1 · native suite green · 19/19 in the new
`scaffold/tests/test-resolver-collision.sh`.

**Found while doing it, pre-existing, NOT fixed** (loud failures, not the
silent-drop class — left alone rather than widening scope):
- `bin/chirality-resolve.sh` greps `(import "...")` out of **comments** too, so
  `chirality_blob scaffold/lib resolve` fails with a bogus not-found. This is why
  `bin/scriba`'s resolver-bootstrap branch is dead.
- The scriba blob does not compile at HEAD — `load: lambda checked against a
  non-function type` — verified identical with the E155 changes stashed.

`bin/chirality-resolve.sh` and `resolve.chiral:15` dedup on **basename**,
first-occurrence-wins — a module silently vanishes with no name for the event.
**Prerequisite for H11**, which takes the collision surface from 1 name to ~9.

### H11 · Split `ports.chiral` into port registries   ✅ DONE 2026-08-22 (04f6b3b)
```
[x] H11 ports/{fd,sock,pool,file,pty,tty,stdio,clock,process}
```
`ports.chiral` was the only declaration-surface module in the tree (50 decls,
zero defs) holding nine concerns. Now nine registries, with `ports.chiral` kept as
a **façade** so all **103** `(import "ports")` sites are untouched.

**`ports/process`, not `ports/proc`** — E155 makes the collision with
`scaffold/lib/proc.chiral` a hard error, firing on the first real split. That is
H10 paying for itself immediately; all nine names were checked free first.

**⚑ My premise was WRONG and this is the fourth such correction in this arc.** I
told the agent `ports.chiral` is not in the compiler's import closure. It **is** —
`asm-reloc.chiral:9` imports it, reaching the compiler via
`emit-core ← emit-x64 ← compile-emit`. Blob went 613,961 → 619,241 B. Full
self-hosting ceremony was therefore required, and the result is the good one:

> `B1 < new-blob` → **1,024,376 B, byte-identical to the committed B1**;
> fixpoint `N1 == N2` byte-identical. **The split moved zero emitted bytes.**

**Gates:** `e120_pool_roundtrip` · `e125_sock_roundtrip` · `e104_pty` ·
`e110_cloexec_pty` · `e121_fcntl` all **exit 42** (success for these) ·
`run-native.sh` green incl. `chirality check` Phase 3 · resolver collision 19/19 ·
declaration sets before/after identical (50 = 50, empty diff).

**The split is real:** `chirality_blob scaffold/lib ports/stdio` = 6,126 B vs 22,068 B
for the façade, carries `print`/`put`/`trace` 3/3, leaks zero `Sock`/`Fd`/`Pty`/
`open-rw`/`exit`.

**And still worth 0 bytes, as predicted** — a trivial program importing
`ports/stdio`, `ports`, or nothing is 33,144 B either way. The new files' comments
say so and cite `compile-emit.chiral:189`; they claim a naming boundary, not
runtime savings.

**Did not fit:** `(data Port () (port))` — scriba's puffer handle placeholder, a
nullary data type with no crossing behind it. Left on the façade with a comment
rather than minting a tenth registry for one placeholder.

**⚑ Pre-existing, unrelated, and worth its own look:** `scriba/scriba-main` does
not compile at HEAD — `load: lambda checked against a non-function type`. The blob
*resolves* (917,999 B); the compile fails. Confirmed identical before and after
this change, and independently by the H10 agent. **Not caused by this arc.**

---

## §3 · Elements

**Exist, correctly motivated, no minting needed:**
E76 remainder (its own words: *"profile-permitted-subset + load-time gate owed"* —
H7 and H8) · E77 (rung-1 seccomp) · E78 (number-in-type attenuation) ·
E80 (cap-reify) · E45 (reflective floor, DECISION-gated on edge 5) ·
E155 (H10) · E150 (H4, argv half) · **E2's deferred slice** (H6).

**NOT YET MINTED — proposals, deliberately not deferred to a phantom:**
```
[x] M1  DONE 2026-08-22 — minted as **E159** (`linearity`, state `design`) in
        both `LEDGER.md` and `SELF-IMPLEMENT-CATALOG.md`, with the measurement
        and the arrow-is-the-discriminator control in the row. H9 now has a home
        and is no longer a phantom deferral.
```
H6 needs no new element but **does** need E2's row corrected — see §4.

---

## §4 · Corrections owed (A5 claim-altitude)

```
[x] C1  DONE 2026-08-22 — LEDGER E76 is now `ported, NOT enforced`. Was: catalog says "first slice BUILT 2026-07-28 (registry + name↔number
        binding in `tal.py check_fn`)". That is the PYTHON build. The chirality port
        (sys-check.chiral) exists but is inert. The row must distinguish PORTED
        from ENFORCED.
[x] C2  DONE 2026-08-22 (7148a51). ⚑ And I had the FILE wrong: the stale claim is
        `target-linux.chiral:3`, not `sys-check.chiral:12`. It said the trusted mechanism
        "(SysReg / sys-lookup / ck-sys) lives in lib/tal-check.chiral" — verifiably false:
        `tal-check.chiral` holds ZERO of those; `sys-check.chiral` holds 14. A stale citation
        inside the file that IS the E76 permitted set, pointing at the wrong trusted core.
        Compiler source, so full ceremony: fixpoint byte-identical at 1,057,144 B,
        behavioural gates before promotion, pair promoted together, test-runner rebuilt.

[x] C3  DONE 2026-08-22 — LEDGER E2 is now `part`, with E2's deferred slices
        listed. Was: LEDGER E2 reads `built` — "(name→deBruijn, desugar, profile/target
        verify)" — while the catalog's own build-state column says "Python
        `surface.py`" and surface.chiral:11 calls profile/target verify a DEFERRED
        slice. Correct the ledger row.
[x] C4  DONE 2026-08-22 — annotated in place with the measurement rather than
        deleted, so the type-theory claim survives beside the build-path truth.
        Was: permission-model.md's "everything that does the work already exists" is
        already flagged a stale overclaim by CONFORMANCE-MAP:84, but still reads
        as settled.
```

---

## §5 · Explicitly NOT in this arc

- **The remaining ~6k impl / 14.8k test lines of python.** RUNG1-CHECKLIST Phase C
  owns that as a feature-by-feature migration, explicitly *"confirmed not
  mechanical"* and *"not a stop-the-world rewrite."* Its triage is
  delete / sample / prove, and **~93% of the suite is white-box tests of a floor
  that is leaving** — deletion, not work.
- **Repo pipeline tooling** (`chirality-pack`, `chirality-doc`, `ledger-lint`,
  `paren-audit`, …). Python, but not the language floor — a different lane.
- **E77 / E78 / E80 / E45.** Correctly motivated, gated on H7/H8 landing first.
- **The text & diagnostics arc** (E157/E158) — parked in its own handoff.

---

## §6 · Acceptance for the arc — MET 2026-08-22

| criterion | result |
|---|---|
| no `python3` in `check`/`compile`/`run` or `test`'s gating floors | ✅ only the ADVISORY floor remains |
| `test-runner` rebuilds from an unmodified blob with B1 | ✅ (H4/H2) |
| a poisoned `SysReg` row makes B1 refuse to emit | ✅ both arms — renumber and rename |
| two profiles over the same source give different verdicts | ✅ `(ports print)` emits, `(ports put)` REFUSES |
| `(adopt-fd 999)` closed twice is a compile error | ✅ — though NOT for the reason I minted E159 on |

`run-native.sh` went from **2 gating phases to 7 · 81 assertions**:
6 inline · test-runner ALL PASS · 7 `chirality check` · 31 profile/target ·
12 syscall manifest · 21 linear mint · 4 downstream roots.
B1: 1,020,280 → **1,057,144 B**, fixpoint holding at every promotion.
`ledger-lint`: clean, all 13 checks. Working tree clean.

---

## §7 · What this arc cost me in wrong premises — the honest tally

Every one was caught by measurement, and each is recorded at its site. Kept
together because the *pattern* is the finding, not any single error.

1. **`tools/` does not exist** — I ran `ls tools/` from the repo root; the path in
   `run-native.sh` is relative to `scaffold/`.
2. **`resolve.chiral:15` dedups on basename** — that line is a COMMENT; the code
   keyed on the import string as written. I cited a comment as code.
3. **`ports.chiral` is not in the compiler's import closure** — it is, via
   `asm-reloc:9 → emit-core → emit-x64 → compile-emit`.
4. **The `->` arrow is what breaks linear minting** — it is not; the BINDER
   QUANTITY is. My `adopt-pty` control was a lowering failure I mistook for a
   linearity refusal after truncating stderr at 70 chars. E159 was minted on it.
5. **Every coordinate axis is ~90% skewed** — the port-set axis is 71/63, the most
   informative split available. I had mismeasured it.
6. **89 lib modules / 8 with a port set / 4 roots** — 134 / 63 reaching / 22.
7. **scriba's breakage is pre-existing, not caused by this arc** — true when first
   said, FALSE after E159 landed at 08:35, and I repeated it anyway. The
   verification was confounded: the pre-existing breakage short-circuits the
   compile, so the old compiler gave a byte-identical message either way. **A test
   that cannot distinguish the hypotheses is not evidence.**

**The shape, in one line:** six of the seven came from reading an artifact
*about* the code — a comment, a doc, a truncated error, a proxy measurement —
where reading the code itself was one command away. That is the repo's own A5
claim-altitude rule, and the arc's §1 A3 now carries three of my instances of it.

**What actually caught them:** the fixpoint caught none. Behavioural gates,
negative tests, and one-command direct observation caught all seven. A fixpoint
is a stability check, and this arc is seven more data points for that.

