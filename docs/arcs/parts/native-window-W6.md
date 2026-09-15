---
row: native-window/W6
arc: native-window
title: a gate reads `prog/demo/`, which is why W5 went unnoticed while the demos were described as running
kind: tool
origin: new
req: 1
status: draft
updated: 2026-09-15
---

# native-window/W6: a gate reads `prog/demo/`, which is why W5 went unnoticed while the demos were described as running

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

⚑ **Design audit 2026-09-15: BLOCKED, and it mints nothing until §5 question 5 is
answered.** Every §2 measurement was reproduced from fresh sources and every one
of them holds: the 18-OK-6-refusing `check` sweep to the message, the eight-root
compile probe to the byte count and the skip chain, the 103-root selector yield
with 6 `*_reject_*` skips, `_recurse-ceiling.prog`'s arrow refusal through Phase
7's own route, and both absent blockers. Eleven citation and arithmetic defects
were repaired in place, each marked where it sits. The one thing the audit did not
take is the proportion question: a gate whose seven subjects include five declared
blocking conditions on day one is a scope call, and §5 question 5 now carries it
as **NEEDS-AUTHOR** with the question written out.

## 1. The obligation

- **The row:** a phase of `tools/test/run-tests.sh` compiles the programs under
  `prog/demo/` and goes red when one of them stops compiling. Today the suite
  names no file in that directory, so a rung claim about the demos rests on
  nothing a gate checked.
- **Serves:** requirement 1 of [[arcs/native-window-arc]], "A window opens on a
  stock compositor through xdg-shell, with the configure and ack dance honored,
  in the tree's own codec" (`docs/arcs/native-window-arc.md:41-42`). The arc's
  coverage line assigns this row to requirement 1 beside `W1` and `W5`
  (`docs/arcs/native-window-arc.md:62`).
- **Goal:** [[goals/native-stack]], condition 2, the screen condition
  (`docs/goals/native-stack.md:37-38`).

The row's real subject is narrower than its title. `W5` is already minted as
`E199`, so this row discovers no blocker. What it closes is what a gate over
the demos has to do in order to be **able** to fail, which
turns on one measured fact: the instrument the tree reaches for first cannot
fail on the `W5` class at all.

## 2. What the tree holds

Measured in the working tree 2026-09-15 unless a row says otherwise. The bank
comes first.

- **Bank:** [[banks/verification]], and the shard is Shard 3, the native
  behavioural suite, `BUILT` (`docs/banks/verification.md:137-168`). The bank
  already holds this row's governing sentence, written about a demo in this same
  directory: `prog/demo/_eff.chiral` refuses under `chirality check` and refuses
  for the wrong reason, and *"Running the mutant is the whole difference between
  a demo and a gate, and nothing was checking that it had been run"*
  (`docs/banks/verification.md:276-288`). The membrane hole that example exposed
  is `E171`. The bank's Shard 3 home is `tools/test/run-tests.sh` plus
  `tools/test/samples/`, and `prog/demo/` appears in neither.
  [[banks/port]] is the arc's named bank and carries the crossing side of the
  same measurement.

### The sweep that exists, and the one property the demos lack

| what exists | where | rung | reached by |
|---|---|---|---|
| Phase 7, the downstream-root compile sweep, "a phase that only tests `lib/` cannot see an app that `lib/` broke" | `tools/test/run-tests.sh:149-151`, opened at `:172` | ENFORCED | the suite, and `chirality test` through `bin/chirality:181` |
| Phase 7's root selector, `grep -rl '^(def compile-main' lib prog` with symlinks filtered | `tools/test/run-tests.sh:175-176` | ENFORCED | Phase 7 alone |
| the selector's live yield, **103** roots, of which **6** are skipped by the `*_reject_*` convention at `tools/test/run-tests.sh:179` | measured 2026-09-15 | ENFORCED | Phase 7 |
| `KNOWN_FAIL`, three roots excluded by basename, each with a stated reason | `tools/test/run-tests.sh:173`, reasons at `:157-166` | ENFORCED | Phase 7 |
| the NEWPASS tripwire: a `KNOWN_FAIL` root that starts compiling is reported and reddens the suite | `tools/test/run-tests.sh:184-188`, into the suite's fail counter at `:196` | ENFORCED | Phase 7 |
| the `.prog` extension contract, "a `.prog` defines an entry, and two entries in one blob is a duplicate label", with `.chiral` an import target and `.prog` not | `MAP.md:9-10`, `:20-22` | ENFORCED | the resolver, `bin/chirality-resolve.sh` |

**Nothing under `tools/test/` names this directory.** `grep -rn 'prog/demo\|demo/' tools/test/`
returns zero lines over 27 scripts, measured 2026-09-15. The claim at
`docs/definitions/target-tomodachi.md:11-14` holds: *"Parked. No part of this has
been verified against a compositor"*, and the reason it gives is that nothing
under `tools/test/` reads `prog/demo/` and none of the demos is a `compile-main`
root Phase 7 would sweep.

`docs/definitions/status-ledger.md:179` states that Phase 4 gates "profiles in
`prog/demo/`". That is false. `tools/test/profile-target.sh` builds every fixture
from an inline string (`tools/test/profile-target.sh:62`, cases at `:79-92`) and
names no file in the tree.

### The census of `prog/demo/`

24 files. Exactly one carries `compile-main`, `_recurse-ceiling.prog`, and
`KNOWN_FAIL` excludes it by name at `tools/test/run-tests.sh:173`. So Phase 7
sweeps 23 of the demos zero times and deliberately skips the twenty-fourth.

**The gap is a root-shape mismatch.** Seven files carry `main`, all at signature
`(=> Unit Unit)`: `duo.chiral:9`, `headless.chiral:23`, `tomodachi.chiral:128`,
`node-render.chiral:79`, `e51-hello.chiral:4`, `node-sensor.chiral:8`,
`verify-total.chiral:21`. Phase 7 selects on `compile-main`. The two properties
differ by one symbol, and `MAP.md:9-10` says which file kind each belongs to: a
module carrying importable computation is `.chiral`, a program with an entry is
`.prog`.

The five `profile-*.chiral` files sit at the top of the import graph, one per
demo: `profile-tomodachi.chiral:13`, `profile-node-render.chiral:5`,
`profile-node-sensor.chiral:5`, `profile-duo.chiral:6`,
`profile-headless.chiral:5`. None carries `main`.

Six files carry no entry and no importer with one: `passman-min.chiral` (one def,
at `:29`) and the five `_`-prefixed probes, four of which are one or two lines
(`_tal.chiral`, `_type.chiral`, `_ref.chiral`, `_ref2.chiral`).

### What `chirality check` verifies, and what a compile verifies

This is the measurement the row turns on.

`chirality check prog/demo/tomodachi.chiral` returns `OK`, measured 2026-09-15,
while `wl-client.chiral:201` calls `sock-send-fd`, which has no row in
`lib/lowering/tal/crossing-wraps.chiral` and does not lower. The mechanism is at
`bin/chirality:171-172`:

```
grep -q '(def compile-main' "$blob" || \
  printf '(def compile-main (=> I64 I64) (lam (chirality-check-arg) 0))\n' >>"$blob"
```

`check` runs the same compiler over the same blob. When the file carries no
entry, `check` **synthesizes one that calls nothing**. The compiler's emit walk
starts at `compile-main`, so no def in the module is reachable, so no extern in
the module is ever asked to lower. `check` verifies parse, import resolution,
name resolution and the kernel judgment over every def in the blob. It verifies
nothing about lowering, because the entry it invents reaches no def that lowers.

Measured over all 24 files, 2026-09-15. Eighteen return `OK`. Six refuse:

| file | `chirality check` | what that is |
|---|---|---|
| `_ref.chiral` | `load: cannot prove refinement` | deliberate: `:2` applies `at` to `100` against a `(< 64)` bound |
| `_type.chiral` | `load: type mismatch` | deliberate: a three-domain arrow with a one-binder lambda |
| `_eff.chiral` | `load: type mismatch` | deliberate, and `docs/banks/verification.md:276-288` records that it refuses for the wrong reason |
| `_recurse-ceiling.prog` | `load: arrow needs at least a domain and codomain` | `:15` is `(def compile-main (-> I64) …)`, a one-argument arrow |
| `duo.chiral` | `load: unknown name spawn` | live breakage, undiscovered until this run |
| `profile-duo.chiral` | `load: unknown name spawn` | the same, through `:6` |

Four of the five demos that cannot lower return `OK`. `check` catches the one
defect that is a name-resolution failure and misses every unlowered-extern case,
which is the entire `W5` class.

### What a compile finds

Probe, 2026-09-15: a thin `.prog` root per demo carrying `main`, three lines,
`(import "demo/<name>")` plus `(def compile-main (=> I64 I64) (lam (n) (do (main unit) 0)))`,
resolved with `chirality_blob_file` and compiled by `bin/chirality-bin` under
`ulimit -s unlimited`, which is Phase 7's own invocation
(`tools/test/run-tests.sh:181-182`).

| root over | verdict | the compiler's own line |
|---|---|---|
| `e51-hello` | COMPILED, 33,144 bytes | |
| `verify-total` | COMPILED, 33,144 bytes | |
| `headless` | FAIL | `skip chain for compile-main: compile-main <- main: extern does not lower: env-open` |
| `node-render` | FAIL | the same, `env-open` |
| `node-sensor` | FAIL | the same, `env-open` |
| `tomodachi` | FAIL | `skip chain for compile-main: compile-main <- main <- init: extern does not lower: case on unknown data` |
| `duo` | FAIL | `load: unknown name spawn` |
| `profile-tomodachi` | FAIL | identical to the `tomodachi` line, so the profile clause adds no earlier refusal |

A compile fails on all five. `check` fails on one. The instrument is the design
decision.

### The three causes the compile probe names, and what owns each

| cause | measurement | owner |
|---|---|---|
| `sock-send-fd` has no lowering row | `grep -c` over `lib/lowering/tal/crossing-wraps.chiral` returns 0 while `prog/demo/wl-client.chiral:201` calls it and the extern is declared at `lib/ports/sock.port:68`. The table carries **44** routing rows, `crossing-wraps.chiral:14-57` | `E199`, minted, `docs/elements/ledger.md:215` |
| `env-open`, `env-view`, `env-close` have no lowering row and no floor crossing | declared at `lib/ports/clock.port:39`, `:34`, `:40`, whose own comment calls them "INTERIM ambient acquisition". Zero rows in `crossing-wraps.chiral`, and zero `nb-*env*` crossings anywhere under `lib/lowering/tal/`. No catalog or ledger row names them; `E150` covers `argv` alone (`docs/elements/catalog.md:469`) | **nothing.** A row is owed, and §5 carries it |
| `spawn` has no definition in the tree | `prog/demo/duo.chiral:17` is `(let (1 peer (spawn "demo/profile-node-render.chiral"))`. Zero `(extern spawn …)`, `(def spawn …)` or `(declare spawn …)` under `lib/` and `prog/`. `docs/definitions/status-ledger.md:193` places staging at SEEDED, at two sites, with "nothing represents binding time in a type", and `docs/definitions/resolution-patterns.md:32` calls staging "the `spawn` crossing" | `E57`, minted, `docs/elements/ledger.md:243`, Track `OT` |

One def in `tomodachi.chiral` holds two of those causes. `init` is defined at
`tomodachi.chiral:112`; its `case` at `:114` scrutinizes what `wl-init` returns,
and `wl-init`'s body contains the unlowered `sock-send-fd`, while `:116` calls
`env-open` directly. The compiler's line names the def and `case on unknown
data`, and it names neither extern.

### The phase-number ruling, and what is already in flight

`tools/test/run-tests.sh:348-354` carries the author's 2026-09-06 ruling: this
file is the only authority for a phase number, a gate takes the first number that
collides with nothing, 8 to 12 stay owed to unported old-tree phases, and 21 to
23 stay Lane B's. `run_phase 32` at `:368` is the highest present.
`docs/definitions/testing-floors.md:69` still calls this a standing author call
and is stale against that ruling.

`E199`'s design assigns **Phase 33** to its own gate
(`docs/arcs/parts/native-window-W5.md:405`). Two gates in the same arc are in
flight and a number assigned before landing order is known is a guess.

`tools/test/run-tests.sh:356-360` carries the disposition for a gate that cannot
be green: `tools/test/tal-check.sh` stays unregistered because *"Registering a
red gate would make the suite red on a question nobody has answered."*

### The ceiling, measured

`docs/definitions/target-tomodachi.md:15-16` gives the reason no run is possible:
"No environment in this tree hosts a Wayland compositor, so the wire client has
never spoken to one." So a gate over these demos compiles and does not run, and
that ceiling is a **blocking condition** in the sense
`docs/decisions/decision-scope.md:79-87` separates from a track deferral, with
`E63` and absent CHERI hardware as the author's worked example at `:84-87`.

## 3. The delta

Phase 7 is the gate's shape and it already exists. Three things are missing, and
none of them is a phase.

1. **Seven entry roots.** The demos are `.chiral` modules carrying `main`, and
   `MAP.md:20-22` puts an entry in a separate `.prog` because a module is an
   import target and two entries in one blob is a duplicate label. Phase 7's
   selector then reaches them with no edit to the selector. The delta is seven
   three-line files.
2. **The choice of instrument, stated so it cannot be re-taken wrongly.**
   `chirality check` is the cheaper reflex and it cannot fail on this class:
   `bin/chirality:171-172` gives a module an entry that calls nothing, so the
   lowering stage is handed a program with no reachable extern.
   `docs/definitions/working-discipline.md:97-101` names exactly this, that a
   check aimed at a floor this tree lacks is a gate that cannot fail. Measured,
   `check` returns `OK` on four demos that cannot lower.
3. **A place for five declared blocking conditions.** A compile-only sweep over
   the seven roots is red today. `KNOWN_FAIL` at `tools/test/run-tests.sh:173`
   is the existing mechanism and its comment block at `:157-166` is the existing
   form, one name and one reason each. What the mechanism supplies that a fresh
   phase would have to rebuild is the NEWPASS tripwire at `:184-188`: a listed
   root that starts compiling reddens the suite through `:196`. That is how this
   gate fails on the next thing that lands, and it is why the gate is worth
   building before its blockers clear.

**What the gate cannot reach, and the honest bound.** A compile walks from an
entry, so six files with no entry and no entry-carrying importer stay outside it:
`passman-min.chiral` and the five `_`-prefixed probes. Three of those refuse
`chirality check` by design and carry no `*_reject_*` marking, so no blanket
sweep of the directory is clean. `_eff.chiral` belongs to `E171` by
`docs/banks/verification.md:287-288`. The gate compiles and does not run, on
`docs/definitions/target-tomodachi.md:15`.

**Two discovered requirements this row's measurement produced, neither of them
this row's to fix**, per `docs/definitions/working-discipline.md:112-118`:

- the environment crossing family has no lowering row, no floor crossing and no
  element, and it blocks three of the seven roots on its own;
- `prog/demo/duo.chiral:17` calls a name with zero definitions in the tree, which
  `E57` covers on the build-deferred `OT` track.

**Verdict: a real delta.** Seven root files, five `KNOWN_FAIL` names with their
blocking conditions, and one comment block. No new phase, no new phase number,
no `lib/` edit.

## 4. The shapes

### Shape A: seven `.prog` entry roots, swept by the existing Phase 7

- **Form:** one three-line `.prog` beside each demo that has an entry path. The
  five with a profile go through the profile file, so the closure carries the
  `(profile …)` clause; `e51-hello` and `verify-total` go through the module.
  `KNOWN_FAIL` at `tools/test/run-tests.sh:173` gains five names, and the comment
  block at `:157-166` gains one reason each in the blocking-condition form.
- **Costs:** eight files, roughly 100 lines. The selector's yield goes from 103
  roots to 110. Five of the seven new roots are excluded on day one, so the gate
  defends two live roots and five tripwires.
- **Forbids:** a per-root assertion message. Phase 7 prints one FAIL line per
  root and is deliberately not tallied into the assertion count
  (`tools/test/run-tests.sh:199-207`). It also forbids running anything: Phase 7
  is compile-only by its own comment at `tools/test/run-tests.sh:150-151`, which
  matches the compositor ceiling and is wanted.

### Shape B: a new phase script that owns the demos' root set

- **Form:** `tools/test/demo-roots.sh` with its own `run_phase` line, its own
  root list, its own compile loop and its own per-file verdict.
- **Costs:** a phase number, which collides with `E199`'s Phase 33 depending on
  landing order. It duplicates Phase 7's compile loop, its `KNOWN_FAIL`
  mechanism and its NEWPASS tripwire, or it ships without them.
- **Forbids:** nothing structural. It buys a per-file assertion tally and a place
  to print the ceiling, and it spends a number this row does not need.

### Shape C: a `chirality check` sweep over all 24 files

- **Form:** one loop, `chirality check` per file, negatives declared by name.
- **Costs:** the cheapest by a wide margin.
- **Forbids:** failing on the `W5` class, which is the row's whole subject.
  Measured: `OK` on `tomodachi`, `headless`, `node-render` and `node-sensor`, all
  four of which cannot lower, because `bin/chirality:171-172` hands the compiler
  an entry that reaches nothing. `docs/definitions/working-discipline.md:97-101`
  rules this out.

### Shape D: teach Phase 7's selector to accept `main`

- **Form:** widen the selector to `grep -rl '^(def \(compile-\)\?main'` and let
  `chirality compile --entry main` supply the entry alias at compile time.
- **Costs:** measured to fail today. `bin/chirality:91-97` appends
  `(def compile-main (=> I64 I64) (lam (chirality-entry-arg) (main chirality-entry-arg)))`, and every demo's
  `main` is `(=> Unit Unit)`, so
  `chirality compile prog/demo/tomodachi.chiral --entry main` returns
  `load: type mismatch`. The shape needs either an `--entry` that adapts a
  signature or seven changed `main` signatures.
- **Forbids:** keeping `bin/chirality` out of this row. It widens the front-door
  CLI to serve a test phase, which is the opposite of a tool consuming
  primitives.

### What the tree settles, and what it leaves open

`MAP.md:9-10` and `:20-22` settle the **form** of the entry completely: the
demos are import targets and the entry belongs in a separate `.prog`. Shape D
argues with that contract and Shape A implements it. `docs/goals/display.md:32-35`
settles the **altitude**: *"a design feature arrives as primitives plus tools
that harness them"*, and no arc under it ships an engine. A tool consumes
primitives and reports.

What the tree does not settle is A against B, which is whether this gate reuses
Phase 7's sweep or builds a second one. §5 takes it.

## 5. The call

- **Chosen:** **Shape A**, because Phase 7 already holds every mechanism this
  gate needs and the only thing standing between it and the demos is one file
  extension. The selector at `tools/test/run-tests.sh:175-176` needs no edit.
  The NEWPASS tripwire at `:184-188` is what makes the gate able to fail while
  its blockers stand, and Shape B would rebuild it. `docs/goals/display.md:32-35`
  is the altitude argument: consuming an existing sweep is a tool, and standing
  up a second sweeper beside it is a second engine.

  The choice also dissolves the ordering dependency. Shape A consumes no phase
  number, so `E199`'s Phase 33 is unaffected by whether this element lands first
  or second.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | `chirality check` or a compile | RESOLVED | A compile. `bin/chirality:171-172` synthesizes an entry that calls nothing, so a module's externs are never asked to lower; measured, `check` returns `OK` on four demos that cannot lower while a compile fails on all five. `docs/definitions/working-discipline.md:97-101` forbids the check |
| 2 | A new phase, or Phase 7's existing sweep | RESOLVED | Phase 7. `MAP.md:20-22` forces the entry into a `.prog`, which is exactly what the selector at `tools/test/run-tests.sh:175-176` matches; the tripwire at `:184-188` and `:196` is the failure mode this row needs and exists only there |
| 3 | Which suite phase number | RESOLVED | None. Shape A registers no phase, so the ruling at `tools/test/run-tests.sh:348-354` is satisfied by spending nothing, and `E199`'s Phase 33 stands whichever lands first. `docs/definitions/testing-floors.md:69` still calls the number a standing author call and is stale against the 2026-09-06 ruling; it is one doc-audit row and not this element's edit |
| 4 | Roots over the `profile-*` files or over the bare modules | RESOLVED | Through the profile file wherever one exists. Measured: a root over `profile-tomodachi` and a root over `tomodachi` return the identical skip chain, so nothing is lost, and the profile closure covers five more files in the directory at zero extra cost |
| 5 | How the five failing roots ship, and whether a gate may carry five of its seven subjects as declared-failing on the day it lands | **NEEDS-AUTHOR** (raised at the design audit, 2026-09-15) | The two cited authorities point opposite ways and neither settles the proportion. `docs/decisions/decision-scope.md:79-87` settles the **form** a blocking condition is written in, and `:84-87` works one through with `E63`; it says nothing about how many of an element's subjects may carry one. `tools/test/run-tests.sh:356-360` is the live precedent for the other answer and it refuses a gate on the ground the design must clear: *"Registering a red gate would make the suite red on a question nobody has answered."* The design's bridge, that these five questions are *stated* rather than *unanswered*, is its own distinction and no cited doc draws it. Verified at the audit: the tripwire is real and the gate can fail both ways today, so the shape `docs/definitions/working-discipline.md:97-101` refuses is absent. What is unsettled is scope: two live roots and five tripwires, against shipping only the two that compile and adding roots as blockers clear. The question verbatim is below |
| 6 | `_recurse-ceiling.prog`'s exclusion | RESOLVED | It stays. Its reason at `tools/test/run-tests.sh:159-162` is stale and its exclusion is still load-bearing: reproduced through Phase 7's own route 2026-09-15, it fails at `load: arrow needs at least a domain and codomain` because `:15` declares `(-> I64)`, so it never reaches the native recursion ceiling the comment describes. Removing it turns Phase 7 red on a clean tree. Repairing the comment is residue |
| 7 | Who owns `spawn` | DEFERRED(`E57`) | `docs/elements/ledger.md:243`, "Staging / binding-time modality", state `design`, Track `OT`. `docs/decisions/decision-scope.md:67` makes `OT` build-deferred, and `:81` names that as a track deferral that lifts when the track resumes. So `duo-root.prog`'s `KNOWN_FAIL` reason is `E57` and the track, and it is the one entry of the five whose condition is a scope call rather than a material fact |
| 8 | Who owns `env-open`, `env-view` and `env-close` | DEFERRED, and **the row does not exist yet** | Three externs declared at `lib/ports/clock.port:34`, `:39-40`, zero `crossing-wraps` rows, zero `nb-*env*` floor crossings, and no element owns their lowering. `docs/elements/catalog.md:442` does name `env-close`, inside E107's close family and under **BUILT**, but the rows it cites at `crossing-wraps.chiral:42-44` route `sock-close`, `lsock-close` and `fd-close` only, so nothing routes `env-close` and no row anywhere names `env-open` or `env-view`. They block three of the seven roots on their own. The orchestrator owes a roster row; `docs/arcs/parts/native-window-W5.md:195` already proposes `W7` for the socket server half, so this is the next id after it. This design edits no arc file and opens nothing |
| 9 | The misattributed blame, and whether it reaches this gate's output | DEFERRED, and **the `PRB-` row does not exist yet** | It reaches it. Measured: `tomodachi`'s root fails with `compile-main <- main <- init: extern does not lower: case on unknown data`, naming the def and no extern, while the def at `tomodachi.chiral:112` holds two separate unlowered causes, at `:114` and at `:116`. A direct call is named correctly, as `headless`'s `env-open` line shows; a call behind a `case` on another skipped def's sum is not. `docs/arcs/parts/native-window-W5.md`'s question 7 already recorded this as owed a `PRB-` row and this run does not take it on |
| 10 | Whether the gate covers all 24 files | RESOLVED | No, and §3 states the bound. A compile walks from an entry, so `passman-min.chiral` and the five `_`-prefixed probes stay outside it. Three of those refuse by design and carry no `*_reject_*` marking (`tools/test/run-tests.sh:179`), which is why a blanket sweep of the directory fails on a clean tree |
| 11 | What the seven root files are named | DEFERRED(SPEC) | A naming convention is an implementation detail with one live precedent in the directory, `prog/demo/_recurse-ceiling.prog`. The SPEC settles it |

**One NEEDS-AUTHOR, raised at the design audit 2026-09-15.** Every other question
resolves against a settled doc or a measurement in §2, or names what owns it. The
suite phase number, the one author call otherwise in reach, was ruled 2026-09-06
and is spent on nothing here.

> **The question, verbatim.** May this element land a gate that carries five of
> its seven subjects in `KNOWN_FAIL` on day one, each beside a stated blocking
> condition, defended by the NEWPASS tripwire alone? Or does it ship only the two
> roots that compile today, `e51-hello` and `verify-total`, and gain a root as
> each blocker clears?

`records/author-calls.md` earns a row when this is answered. The row is the
orchestrator's to write and this run wrote none.

**What the audit verified before flagging it.** `tools/test/run-tests.sh:184-188`
prints `NEWPASS` and increments `r_newpass`, and `:196` is `[ "$r_newpass" -eq 0
] || fail=$((fail+1))`, so a listed root that starts compiling reddens the suite.
`:197` does the same for `r_fail`. Both directions are live, so the mechanism the
design leans on does what §2 and §3 say it does. The mechanism is settled. The
proportion is what stays open.

**Residue, recorded and not taken:**

- `docs/definitions/status-ledger.md:179` says Phase 4 gates "profiles in
  `prog/demo/`". `tools/test/profile-target.sh` builds every fixture inline
  (`:62`, `:79-92`) and names no file. One doc-audit row.
- `tools/test/run-tests.sh:159-162` states a reason for `_recurse-ceiling.prog`
  that its current failure contradicts.
- `docs/arcs/native-window-arc.md:85` says `crossing-wraps.chiral` carries 45
  rows. It carries **44**. `grep -c '(pair '` returns 45 over the 65-line file,
  and one of the 45 is the destructuring pattern at
  `lib/lowering/tal/crossing-wraps.chiral:64`. `grep -c '(cons (pair '` returns
  44. The arc file is the orchestrator's.
- `docs/definitions/testing-floors.md:68` carries 87 roots, measured 2026-09-04.
  The selector yields 103 today.
- `prog/demo/profile-*.chiral` are named frozen port sets carrying the `.chiral`
  extension, which `MAP.md:12` assigns to `.profile`. Pre-existing and outside
  this row.
- **Added at the design audit, 2026-09-15.** `docs/elements/catalog.md:442`
  carries `env-close` inside E107's close family under **BUILT**, citing
  `lib/ports/clock.port:40` for the declaration and
  `lib/lowering/tal/crossing-wraps.chiral:42-44` for the rows. Those three rows
  route `sock-close`, `lsock-close` and `fd-close`. `grep -c 'env-'` over
  `crossing-wraps.chiral` returns 0, so E107's cell names a crossing its own
  cited rows do not carry. One doc-audit row, and it is the reason question 8's
  family still has no owner.
- **Added at the design audit, 2026-09-15.** `tools/test/run-tests.sh:157-166`
  gives reasons for five root names while `KNOWN_FAIL` at `:173` carries three.
  `t5_vt_parser` and `t6_apc_roundtrip` are documented and not listed. Adjacent
  to this element's comment-block edit and not its subject.

## 6. The mint packet

- **Elements:** **one.** The seven roots and the `KNOWN_FAIL` edit constrain each
  other absolutely. Roots landing without the five names turn Phase 7 red on a
  clean tree; the names landing without the roots refer to files that do not
  exist, and Phase 7 matches `KNOWN_FAIL` by basename against roots the selector
  found, so an unmatched name is silently inert. One commit, one element.

- **Band:** `UNASSIGNED`. [[arcs/native-window-arc]] holds no reserved block, and
  `docs/decisions/decision-lane-split.md:60-61` covers the case: an arc with no
  band takes the next free number and records the range it landed in. Measured
  2026-09-15, the highest number in `docs/elements/catalog.md` and
  `docs/elements/ledger.md` is **E199**. The next free number lands inside the
  unit lane's reserved `E196-E239` (`docs/decisions/decision-lane-split.md:64`),
  which the 2026-09-06 overlap ruling at
  `docs/decisions/decision-lane-split.md:38-58` permits: the allocator and the
  roster stop a collision (`:51-52`) and a band stops none.
  **The mint assigns the number, and this design names none.**

- **Catalog row** (columns `| E# | Element | State / location | Reference (class) | Track |`):

  `| E<NN> | The demos' compile gate: seven `.prog` entry roots under `prog/demo/`, so Phase 7's `compile-main` sweep reaches the demo modules, with each root that cannot lower carried in `KNOWN_FAIL` beside its blocking condition | Not built: `grep -rn 'prog/demo\|demo/' tools/test/` returns zero lines over 27 scripts (2026-09-15), and Phase 7's selector at `tools/test/run-tests.sh:175-176` matches one demo file, `_recurse-ceiling.prog`, which `KNOWN_FAIL` excludes at `:173`. Seven demos carry `main` and none carries `compile-main`; `MAP.md:20-22` puts the entry in a separate `.prog`. Two of the seven compile today, three are blocked on the unlowered `env-*` family, one on `sock-send-fd` (E199) and one on `spawn` (E57). A `chirality check` sweep cannot substitute: `bin/chirality:171-172` synthesizes an entry that reaches no def, so `check` returns OK on all four demos that cannot lower | `OURS` | SH |`

- **Ledger row** (columns `| E# | Module | State | Title | Cites | Track |`):

  `| E<NN> | demo-gate | design | **The demos compile under the suite.** Seven three-line `.prog` entry roots so Phase 7 reaches `prog/demo/`, plus five `KNOWN_FAIL` names each carrying its blocking condition in the `decision-scope.md:79-87` form. Compile-only by the compositor ceiling at `docs/definitions/target-tomodachi.md:15`. Registers no phase and spends no phase number, so it is independent of E199's Phase 33. Its power while the blockers stand is the NEWPASS tripwire (`tools/test/run-tests.sh:184-188`, into the suite's fail counter at `:196`), which reddens the suite the moment E199 lands | →`native-window/W6` | SH |`

- **Size.** Eight files, roughly 100 lines.

  | file | change | lines | basis |
  |---|---|---|---|
  | `prog/demo/` | seven `.prog` entry roots, five over the `profile-*` files and two over `e51-hello` and `verify-total` | ~85 | three lines of code each, measured working in the §2 probe, plus a header comment on the `_recurse-ceiling.prog` scale (16 lines over nine lines of code) |
  | `tools/test/run-tests.sh` | five names appended to `KNOWN_FAIL` at `:173`, and one reason each appended to the comment block at `:157-166` | ~18 | the existing block spends 10 lines on five names; five names with a cited blocking condition each runs longer |

  **No fixpoint is owed.** `docs/definitions/working-discipline.md:23` conditions
  the generation loop on the compiler's own sources changing. This element edits
  no file under `lib/`, and the compiler's transitive closure holds no demo.
  Measured 2026-09-15: `chirality_blob_file "lib:prog" prog/compiler.prog` emits
  61 `(end-module …)` markers and zero of the 61 keys contains `demo`. ⚑ The
  command this row first reported, `chirality_imports "lib:prog"
  prog/compiler.prog`, measures nothing: `chirality_imports` takes ONE argument
  and it is the FILE (`bin/chirality-resolve.sh:92`, `:108-109`), so `lib:prog`
  is read as a path that does not exist and the call prints nothing at all.
  Against the file it yields one line, `lowering/compile-all`, the direct imports
  rather than a closure. The gate is a shell edit plus seven files outside the
  compiler's closure, so `build-new → test → promote` reduces to running the
  suite.

  **The verification is the phase itself.** After the edit, Phase 7's root count
  goes from 103 to 110, its compiled count rises by two and its known/negative
  count rises by five. Removing any one of the five names turns the phase red
  with the compiler's own line, which is the conformance check.

- **Related:** [[banks/verification]], [[arcs/native-window-arc]],
  [[target-tomodachi]], [[decisions/decision-scope]],
  [[decisions/decision-lane-split]], [[working-discipline]], [[status-ledger]],
  [[goals/display]], `MAP.md`, `PRB-71`.

Every `E#` named here is already minted: `E57` at `docs/elements/ledger.md:243`,
`E63` at `:249`, `E150` at `:214`, `E171` at `docs/elements/catalog.md:490`,
`E199` at `docs/elements/ledger.md:215`. Two rows are owed and neither exists:
one for the environment crossing family, and one `PRB-` for the misattributed
skip-chain blame. Both are the orchestrator's and this run opened neither.
