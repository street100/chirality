# HANDOFF — the VERIFICATION ARC (opened 2026-08-23)

> ⚑ **CLOSED BY THE DROP, 2026-09-01. This is a record, and it is not the live
> workset any more.** The arc's stated goal was the C/CompCert differential
> legs; those legs were built (2026-08-24, 2026-08-25) and then **dropped**
> (`d8bcec5` the modules, `d0c5dd5` the four `e166_*` fixtures). Every present
> tense below is August's and **nothing below is rewritten** — the whole value
> of a session handoff is that it records what was true when it was written.
>
> **The reason is the criterion, not the leg's quality.** Self-verification here
> goes through N semantically distinct judgment cores that must agree, and the
> test is *different formulations*. The C leg shared `compile-front` and
> `compile-back` whole with the canonical instance and differed only at emit, so
> it was a second **target** under one formulation. `CLAUDE.md` values three
> encodings of one rule set at nothing; one encoding emitted twice is less.
> See `docs/decisions/decision-self-verification.md` for the route that replaces
> it, and `docs/definitions/open-edges.md` for what the drop left open.
>
> **What survives the arc:** Rules 1, 2 and 3 of `docs/definitions/testing-floors.md`,
> the run-the-mutant rule, the expectation-provenance ranking, and E168's
> `lib/evidence/test-floor.chiral`. Those are findings about differentials in
> general and outlive the leg that produced them.

> **This is the live workset. Start here in a new chat.**
>
> It was first written into `HARNESS-REFACTOR-CHECKLIST.md`'s resume banner,
> which was the wrong home: that arc is CLOSED and this one is not. A handoff
> for arc B living inside arc A's closed checklist is the same altitude error
> `BUILD-ORDER.md` §A4 catalogues. Moved here 2026-08-23, following the
> existing `HANDOFF-*.md` convention (`HANDOFF-RUNG1-FIXPOINT.md`,
> `HANDOFF-SELF-WIELD.md`).
>
> **The arc:** make chirality's correctness externally checkable — repair and then
> retire the Python oracle, build the C/CompCert differential legs, and put the
> reasoning in the note base rather than in commit messages.

**Orientation:** `CLAUDE.md` · `docs/testing-floors.md` (the verification
contract + coverage map) · `docs/banks/verification.md` (its depth tier) ·
`.planning/BUILD-ORDER.md` · then this file.

### THE PLAN OF THE PLAN — lanes, and what gates what (author, 2026-08-26)

This section replaces the single "one next action". The arc is now five lanes
with explicit gates, because "next action" hid a dependency that a linear list
cannot express: **Lane E is a precondition of Lane B, and looked orthogonal.**

**The framing the rest depends on.** The judgment core is the logic behind port
typing. It is not a component that swaps like the others — varying it does not
give a different checker over the same ports, it gives *a different notion of
what conformance is*, inherited by everything compiled into that set. So
multiple cores means multiple semantic worlds, and **the relation between cores
cannot live inside a core**: any value-level description of how cores relate is
itself typed by some core, privileging one as arbiter. Comparison is external,
over emitted evidence.

#### The three stances, RESOLVED — retrofitting any of them is expensive

- **D1 — the axis of semantic variation: CONVERSION STRATEGY.** Cores differing
  only in which optional rules are on are one core with switches: they agree
  wherever the shared rules decide, and the comparison is cheap and empty.
  Conversion is decided differently (NbE vs algorithmic with η), is reachable
  from ordinary terms because `infer-app` / `infer-pi` / `subtype` all call it,
  and `conv` eta is one of the three rules measured to have **no isolated
  coverage** (`RUNG1-CHECKLIST.md`, 3c5d35c). ⚑ **Multiplicity was considered and
  REFUSED as the axis:** the semiring is already parametric
  (`decision-graded-kernel`), so varying it is configuration, not a different
  notion of conformance — D1's own trap.
  ⚑ **What a green run does NOT mean, and this must be known going in.** NbE and
  algorithmic conversion with η are *extensionally equivalent by construction* —
  that is what NbE is for. So a disagreement on ordinary terms is a **bug in one
  implementation**, not a semantic difference, and broad-middle agreement is
  **not confirmation of anything**. Under E168's ranks it is two implementations
  of one specification concurring: **implementation-derived, rank 4**, and it
  must be labelled that way rather than remembered as strong. Aim generated terms
  at the **η fringe**, at **conversion × refinement**, and at **defaulting** —
  that is where a genuinely semantic divergence would live if one exists.
- **D2 — what a core emits: DERIVATIONS. This is not a fork.** Written as
  verdict-only, Lane A + Lane B is *a quorum of test-agreeing implementations* —
  which is precisely what `docs/certificate-discipline.md:29-31` rejects: *"the
  check is re-derivation, not comparison. This is why the split-checker uses
  certificates for the provable core rather than a quorum of test-agreeing
  implementations."* Derivations are therefore **the condition under which Lane B
  is coherent at all**, not the better of two options.
- **D3 — what the comparison layer may know: STRUCTURE ONLY, and copy the
  precedent rather than re-deriving it.** `lib/ddc.chiral` already is this layer:
  a pure total fold, verdicts as values, first divergence named, and `:111-112`
  *"the SAME `prov-disjoint?` the driver and the gate read. One owner per rule:
  there is deliberately no second disjointness routine on this path."* Anything
  smarter becomes a fourth judgment with nobody checking it.

#### ⚑ The weak-statement floor — why Lane E gates Lane B

`certificate-discipline.md:35-37`: a certificate can be *a real proof of a weak
statement* — an airtight derivation of "this term has SOME type" where "the type
it claims" was needed. **Structural comparison cannot see this**, because both
derivations are valid and they agree. And the fix is not in the derivation: what
stops a statement being weak is that the statement is **pinned tightly enough
that a weaker variant cannot be stated** — which is the port-type property
applied to certificate statements. Until Lane E says which ports carry meaning
versus only shape, nobody knows which certificate statements are weak-provable.

⚑ **Where the regress ends, stated honestly.** The same residue has now surfaced
four times — compile-time eval, generated relational properties, core agreement,
certificates — and each layer pushes it down to the port types. It does not stop
there either: a port type is a claim about the world that nothing inside the
system can check (E166 already named its own: *"the kernel writes into `m_heap`
through an address C handed out — invisible to any C-level theorem"*). So Lane E
**measures how much of the surface is axiom versus derived**; it does not close
the regress, and any "verified by split" claim carries an axiom column.

**Lane E's operational test, sharper than "wrong implementations":** a port type
carries meaning **iff there exists a wrong implementation satisfying its shape
that the type rejects**. That is mutation testing with the *type* as the test and
the *implementation* as the mutant — so Lane E and Lane D's generator share
machinery, and a port whose type rejects nothing yields a measurable zero rather
than a vague verdict.

#### The lanes

- **Lane A — cores.** Build the incumbent's first genuine peer. ONE core, not
  three. It is a probe: it exists to teach what kind of divergence actually
  occurs, which Lane B's design needs and cannot guess. Expect the first several
  disagreements to be bugs in the new core — normal, not failure. Three remains
  the target; whether the third is the same kind of work is answered by the
  second. **Handoff point: first genuine divergence**, which opens Lane B.
- **Lane B — the self-verification system.** Blocked on Lane A's first
  divergence AND on Lane E (above). Three pieces are draftable early: what
  travels with an artifact (which cores checked it, what each concluded, what
  evidence each emitted — non-forgeable, it is a security claim not a build
  log); where the comparison runs, per D3; how a checking record is represented,
  as a held value rather than a note in a file. Everything else waits.
- **Lane C — orphaned rules.** `conv` eta · the QTT semiring tables · `base <:
  refine` only-if-TOP. **Gates the corpus deletion and nothing else.** Runs in
  parallel with everything. **DONE 2026-08-26** — three fixtures on the E168
  floor (`e170_conv_eta` · `e170_qtt_semiring` · `e170_refine_top`, Phase 12 rows
  C1/C2/C3) and **six harness-run mutants** through a new `mutant_red` helper,
  because `mut-run` cannot express a mutant of a rule that lives in
  `scaffold/lib`. Isolation is a measured 6×3 mutant×fixture diagonal, not a
  claim. ⚑ **The result that changes a design rather than confirming one:** with
  `qadd`'s `1+1` saturation reverted to `(q1)`, EVERY algebraic law in the
  semiring fixture stays green — a law suite alone re-founds nothing, and only
  the pin composing the tables the way the checker's accounting composes them is
  red. Suite **187 ok / 0 FAIL / exit 0**; no `.py` touched. **Lane D's deletion
  gate is now satisfiable.**
- **Lane D — corpus.** Measured: **A 267 outcome-locking (85.6 %) · B 40
  relational (12.8 %) · C 5 plumbing (1.6 %)** over 312 functions
  (`RUNG1-CHECKLIST.md`, 3c5d35c). The move is **not** migrating the 267 — it is
  writing the generator over the closed sums that already exist.
  **⚑ THE GENERATOR IS BUILT, 2026-08-29** — `scaffold/tests/samples/e170_infer_arms.chiral`,
  Phase 12 row **D1** with **seven harness-run mutants**: eight properties folded
  over `(data Term)`'s **16** constructors (not 19 — the figure in the checklist
  was a miscount, corrected there), over `Qty` × `Seat`, and over a five-member
  want set driving 62 refusals per negative half. `ia-tag` is an exhaustive `case`
  over the sum, so a 17th constructor is a compile error. It gives `infer-pi`,
  `infer-app`, `infer-ann` and the `infer`→`check` boundary their **first isolated
  coverage** — all four were *combination only* in every corpus bucket.
  ⚑ **AND THE SUBSUMPTION HYPOTHESIS IS MEASURED FALSE.** Thirteen mutants of rules
  the corpus outcome-locks, run against the generator: **eight GREEN**. A
  relational property over `infer` re-derives the arm's result on both sides of the
  relation, so a mutant that moves an arm's result moves the relation with it —
  Lane C's `qadd` finding one level up. **Exactly 1 of the 267 is retirable**
  (`test_lambda_needs_annotation`, killed by the mode-switch pin); 2 more are RED
  only through an unpinned coupling in the witness family and are **not** retired;
  **264 stay**, labelled rank-4 regression locks. The generator's yield is ADDED
  coverage, not retired locks. Per-rule matrix: `RUNG1-CHECKLIST.md` §Lane D.
  ⚑ **Deletion is the only irreversible step in this plan — gate it on Lane C
  mechanically, not by intending to remember. Lane D does not move that gate.**
- **Lane E — port-type negatives. DONE 2026-08-29 — the per-port map is
  `RUNG1-CHECKLIST.md` §Lane E, and Lane B's precondition is discharged.**
  `e170_port_twin` + six `e170_reject_*` + `e170_port_zeros` on the E168 floor
  (Phase 12 rows **E1–E10**, +11 assertions), plus a refusal quantified over the
  porttype family READ OFF THE TREE (E8: 10/10 refuse a duplicated capability;
  E9: 10/10 admit the twin — the direction control) and an enumeration guard
  (E10) that reddens when the port surface moves. Suite **12 phases / 206 ok /
  0 FAIL / 82 roots / exit 0 / 3m29.509s**.
  ⚑ **The answer differs by port and by FACET, and the zeros are the finding.**
  Custody is one mechanism, not ten answers — every porttype is an opaque linear
  atom and every one refuses a drop or a duplicate. Only THREE ports carry
  anything beyond custody: `Sock`'s `(refine I64 (> 0))` on recv, `Pool`'s value
  index, `Secret`'s nominal identity. Everything else is a measured zero:
  **no port type says anything about what a crossing DOES** (a `sock-send`
  stand-in that reports success and sends nothing typechecks);
  **non-forgeability is 0 for every port** (every cap has an ambient mint);
  **holding an `Fd` is not required to read or write** (42 of the 62 crossings
  take no capability at all); **`Clock` and `Timer` are UNINHABITED** — nothing
  produces one, so their refusals are quantified over an empty set of callers;
  and the omega guard is porttype-only, so a cap-shaped `data` (`Reap`) can be
  duplicated outright. ⚑ Also measured, sharper than the note E171 was minted on:
  a `->` def calling the `=>` **extern** directly compiles.
  ⚑ **What this means for Lane B, stated before it is designed:** the
  weak-statement floor bites hardest on *effect* and *provenance*. A certificate
  naming a port type pins who held the authority and that the handle moved
  exactly once; it pins nothing about what crossed, and nothing about where the
  capability came from. Any "verified by split" claim inherits that as its axiom
  column.
  ⚑ **B3 is untouched and still 0** — E8 quantifies over a family of PORTS, B3 is
  a family of CONFIGURATIONS (`RUNG1-CHECKLIST.md:310`); there is still no closed
  sum of profiles to quantify over. Lane C and Lane D both refused this
  relabelling; so does this.

  *(the original framing, kept because it is what the lane was built to:)*
  Deliberately wrong implementations per port,
  each asserted rejected. **The only lane that reaches correctness rather than
  consistency**: everything else, generator included, establishes that the
  implementation is faithful to the rules and the rules are mutually consistent —
  a rule wrong in a self-consistent way passes every generated property. ⚑ **No
  test in the 709 quantifies a refusal over a family**, so there is no in-tree
  precedent for this shape; `e170_refine_top` (Lane C) is now the first, and Lane
  E generalises it per port. ⚑ *Corrected 2026-08-26: this bullet cited that
  absence as `B3 = 0`. `B3` in the survey's own labelling
  (`RUNG1-CHECKLIST.md:310`) is quantification over a family of CONFIGURATIONS,
  which is a different axis — it is still 0, Lane C did not move it, and the
  sibling gap below is exactly the row that owns it.* Its sibling gap: the profile
  axis has no negative coverage and cannot get any until a **closed sum of
  profiles** exists to quantify over — the same work from the other side.

```
D1 · D2 · D3  ──────────────────────────►  everything

Lane A (cores) ──first divergence──┐
                                   ├──►  Lane B (self-verification system)
Lane E ── DONE 2026-08-29 ─────────┘      (E gated B; the map is the input)

Lane C (orphaned rules) ──gate──►  Lane D's DELETION step only

Lane D generator ── DONE 2026-08-29   Lane A is now the only thing B waits on
```

#### Deliberately undecided — forcing these now means guessing

What the provenance record contains (depends on D2's shape in practice) · whether
cores are peers or ordered (depends on whether observed divergence has structure;
an ordering asserted rather than observed is worth nothing) · how many cores past
the second (the second one's results decide) · what "verified by split" means as
a claim (that is Lane B's OUTPUT, not its input).

#### Known shape risk

Three cores plus a full self-verification design are two efforts with different
readiness: the cores are buildable now, the verification system is specifiable
only after. Planned as one deliverable, either the specifiable half waits on the
unspecifiable half or the unspecifiable half gets guessed. Hence the explicit
handoff at first divergence.

### ⚑ Session 2026-08-25 — the `->`/`=>` membrane is NOT enforced at the call (E171 minted)

**Measured, not inferred.** The E168 spec-level audit needed the membrane to be
load-bearing — its decision 4 dropped a `Builder` capability on the grounds that
*"`Obs` is producible only inside an `=>` def, and a `->` function cannot call
one"* — so it tested the premise. It does not hold. Method: each program written
as a source file, resolved with `bin/chirality-resolve.sh`
(`chirality_blob_file scaffold/lib`), compiled `B1 < blob > out` with
`scaffold/build/B1` (1,077,624 B, at `4f64d91`), then RUN. Zero Python in the
path. Re-measured independently at the mint:

1. a `(-> I64 I64)` def calling the `=>` extern `backend-open` (`backend.chiral:36`)
   — compiles, **exit 42**;
2. a `(-> I64 I64)` def calling the bound crossing `put`
   (`scaffold/lib/ports/stdio.chiral:11`, `(=> Str Unit)`) — compiles, **writes to
   stdout**;
3. `(def observe (=> Str I64) …)` beside `(def check (-> Str I64) (lam (s) (observe s)))`
   — compiles, prints, **exit 7**;
4. the module coordinate does not catch it: the same program under
   `(module tfloor (cat A) (alt upper))` compiles and prints, because `crossings`
   is sense (a) BINDS — `scaffold/tests/test-module-kind.sh:717-719`, *"A def is
   not a crossing … a def that CALLS one has bound nothing"*;
5. **the README's own membrane demo fails for the wrong reason** —
   `scaffold/demo/_eff.chiral:3` is `(def f (-> I64 Unit) (lam (n) (put 42)))` and
   the refusal is the ARGUMENT mismatch; repaired to `(put "x")` under the same
   `(-> I64 Unit)` signature it compiles and prints. A gate that could not fail
   for its stated reason — `banks/verification` Shard 7's run-the-mutant rule,
   unenforced, with a live instance now attached to it.

**There is no enforcing code.** The three `Rules` seams live only in
`scaffold/chirality/effects.py:23,38,46` — the retired oracle, which compiles
nothing. The native compiler says so itself: `kernel.chiral:897` *"No
allow_eff/erased_allow/on_binder -- the row/membrane layer is E12, kept as the
seat"*, `:998` the same for the con/tcon arms, `:14-15` still listing the seams
among what is owed to E12. `scaffold/lib/effects.chiral:1-6` is the E12 *model*
and its header says so: *"effects.py stays the oracle … The membrane only GATES
-- it interprets nothing."* E161 removed the last authored per-def claim —
`kernel.chiral:303-304`, *"There is no declaration left for a module to
contradict."*

**Why it matters at principle level.** P2: *"If any category of code opts out of
the type, some things are 'just functions' the effect system does not inspect,
that category is an ungoverned path, P1's hole restated. One atom with no
exemptions is what makes the effect typing total."* P3: *"The port-check is the
type-check."* So the direction is settled — **a `->` body must not reach a
crossing, transitively** — and only the design is open.

**Recorded:** `.planning/SELF-IMPLEMENT-CATALOG.md` E171 · `.planning/LEDGER.md`
EF·E171 · `docs/banks/effect-and-alarm.md` §5d (with Shards 1/2 and the gradient
summary corrected from `CONFORMS`/`ENFORCED`) · `.planning/audit/CONFORMANCE-MAP.md`
E12 row (`CONFORMS` → `EXTEND`, live tally recounted) · `docs/banks/verification.md`
Shard 7 · `README.md` (the demo claim rewritten to what the demo actually shows).

**⚑ E171 is NOT the next action on this arc, and was not made one.** E167 still
is (above). E168 is not gated on E171 either: the author's call, 2026-08-25, is
that **E168 mints its own `Builder` capability rather than wait for the
membrane** — which is what closes its reopened decision 4
(`.planning/specs/E168-test-floor-SPEC.md:132`; that SPEC is owned by a separate
run and was not edited here). The blast radius, the E160/E161 granularity
question, `Sheet` composition, and infer-vs-annotate are E171's own pre-run and
were deliberately left undecided at the mint.

### Session 2026-08-24 (b) — re-measured the Step 5 inputs, wrote no chirality code

The session was pulled onto unrelated infrastructure work before Step 5 began.
**No file under `scaffold/`, `lib/` or `.planning/specs/` was changed.** What it
did establish, so the next run does not re-measure it:

- **Blob A resolves and its composition is right.** `chirality_blob scaffold/lib
  compile-driver-c` → **674,612 B, 51 modules** *(⚑ corrected 2026-08-24 —
  the "68" first written here was `grep -c 'end-module'`, which also counts the
  form's mentions inside source comments. The anchored count,
  `grep -c '^(end-module '`, is the real one: **51** for blob A, and **52** for
  the committed `scaffold/build/blob.chiral` where the unanchored number is 69)*,
  and G0b holds by grep:
  `mach-c` 1 · `alloc-fixed` 1 · `emit-c` 1 · `compile-driver-c` 1 ·
  **`mach-x64` 0 · `alloc-growing` 0**. Blob A's root is `compile-driver-c`
  alone — it is transitively closed, so the canonical six-root list does not
  apply to it.
- **`B1 < blobA` → `chirality-bin-emit-c`, 1,007,992 B**, matching the SPEC's figure.
- **The fixpoint holds on HEAD sources.** Fresh blob B (the six canonical roots)
  → `B1 < B` = C1 (1,077,624 B) → `C1 < B` = C2, **C1 == C2 byte-identical**.

⚑ **A trap I walked into — do not repeat it.** A fresh blob B (708,039 B) differs
from the committed `scaffold/build/blob.chiral` (707,125 B), and the module list
gains one entry, `alloc-growing`. **That is not staleness and not a defect.**
E166 Step 0 moved the growing instance out of `alloc.chiral` into its own module;
both blobs still carry **exactly one** fn-bearing `Alloc` instance
(`alloc-growing` 1, `alloc-fixed` 0), which is the invariant that actually
matters (`specialize-singleton.chiral:78-84`). The SPEC already said to expect
this — *"Moving a def between modules renumbers per-def indices … 'before vs
after differs' is not the check."* The check is the fixpoint, and it passes.
`alloc-growing` is an **optional instance** that deliberately cannot appear
everywhere (blob A must exclude it), so its presence or absence in a module list
is never by itself a staleness signal. `C1` also differs from the committed
`B1` for the same reason; the committed pair simply predates the Step 0
relocation and is internally consistent.

### Session 2026-08-24 (c) — ⚑ E166 IS COMPLETE END TO END. DDC HAS TWO LEGS.

The header above previously read *"E166 IS BUILT AND BOTH GATES PASS — but the
leg is NOT yet in `ddc.chiral`"*. Steps 5 and 6 landed; it is no longer true.

**Built this session, three commits:**
- `50b18d0` **Step 3 heap default 4 GiB → 1 GiB** — the constant, not just the
  claim (see the trap below).
- `a9eebcd` **Step 6, `ddc-legc`** —
  `(def ddc-legc Leg (leg "c-external" (prov "c" "gcc-12" "shred" 2026)))` in
  `scaffold/lib/ddc.chiral`, gated by `scaffold/tests/samples/e166_ddc_legc.chiral`
  (**36 cases**; 13 as first built) **because `ddc.chiral` is a SHELF module the fixpoint cannot
  see** — nothing in a shipping blob imports it, so a leg whose provenance
  overlapped leg 0 would byte-reproduce the compiler perfectly. The teeth have
  to be a program that runs. Case 9 asserts the state the ordering constraint
  exists to prevent: **leg 0 alone is `ddc-bad-quorum`.**
- `e426a30` **Step 5 + F3, as one command and as Phase 10** —
  `scaffold/tests/ddc-c-leg.sh`.

**`bash scaffold/tests/ddc-c-leg.sh` = 10 gates green in 2m21s standalone:**
**G0b** (blob A 674,612 B, 51 modules; `mach-c` + `alloc-fixed` present,
`mach-x64` + `alloc-growing` absent) · **G1** (`B1 < blobA` → `chirality-bin-emit-c`,
1,007,992 B) · the **shim gate 51/51** · **G2** (an exit-42 program through
`mach-c` → C → gcc) · **F3** (25 samples) · `chirality-bin-c` built (**2,171,314 B** of
C → an **813,656 B** binary) · **G4 conviction** (`chirality-bin-c < blobB` ==
`B1 < blobB`, byte-identical at **1,077,624 B**) · the emitted artifact then
**RUNS**, compiling a program to exit 42 · **G5** (`prov-disjoint?` + 36 quorum
cases) · **G3 admission** (the whole native suite under `chirality-bin-c`: **154
assertions, 0 failed, 82 roots**, re-measured 2026-08-25).

⚑ **The admission figure this handoff first carried — 135 — was wrong, and it is
the second claim this session that outran its evidence.** `CHIRALITY_BIN`, the
variable G3 exports to put `chirality-bin-c` under the suite, was honoured by
`run-native.sh`'s own inline phases only. The five sub-scripts it drives
re-derived the compiler from `bin/chirality-bin` → `scaffold/build/B1`, and
`test-check-cli.sh` / `test-profile-target.sh` went through `bin/chirality`, which
had its own resolution — so **Phases 3, 4, 5, 6, 8, 9 and 11 ran under `B1`**
while their assertions were counted as C-leg coverage. Of the 135 rows, **6**
(Phase 1) were genuine and **129** were not; Phase 7's 82 root compiles were
genuine, that phase being inline. Fixed at `ce593c4` — all five sub-scripts and
`bin/chirality` now resolve `CHIRALITY_BIN` first — and mechanized as `ledger-lint`
**check P**, which fails any `scaffold/tests/*.sh` that names
`scaffold/build/B1` without consulting the override. **The re-run is the
finding: 148 assertions that had never once run under the C-built compiler now
do, and nothing diverged.** Two limits stay named: Phase 2 contributes no
assertions (it executes the prebuilt `scaffold/build/test-runner`, which no
compiler in the run rebuilds) and Phase 10 is skipped by construction
(`CHIRALITY_C_LEG_SKIP`), so **9 of 11 phases are genuine `chirality-bin-c` coverage**.

**The full native suite with Phase 10 wired in: exit 0, 144 `ok` assertions,
0 FAIL, 82 roots compiled / 0 failed / 12 known-negative / 0 newly passing,
2m17s** — 135 baseline + 9 Phase 10 rows (2026-08-24). **Live at `70ee90f`, with
Phase 11 wired in: eleven phases, 163 `ok`, 0 FAIL, 82 roots, exit 0 in 3m35s**
— 144 + 19. Self-compile heap high-water
**36,547,557 words = 292 MiB**, inside the 1 GiB reserve (134,217,728 words).

**Built earlier in the element:** `alloc` split into interface +
`alloc-growing`/`alloc-fixed` (`0436b48`) · `c-assemble.chiral` 113 L
(`de5d529`) · `mach-c.chiral` 189 L, all 37 arms (`ded38a2`) ·
`scaffold/rt/chirality-rt.c` **103 code L** (`e0fbd82` + `50b18d0`) · `emit-c.chiral` +
`compile-driver-c.chiral` (`7d8604d`) · F1 (`0ba2004`) · F2 (`20ba530`).
`emit-core.chiral` **untouched** (gate G0, the proof that Choice 1's seam was
right).

**The shim's line count, with its method attached** — because this number IS the
element's honesty check, and a figure nobody can reproduce cannot discharge one.
Measured 2026-08-25 at `1e51228`:

```
wc -l scaffold/rt/chirality-rt.c                                   # 197 raw
grep -cvE '^[[:space:]]*(//|/\*|\*|$)' scaffold/rt/chirality-rt.c  # 103 code
```

188 of the 197 are non-blank; a separate regex strip of `/* */` and `//` comment
spans lands on the same 103. **103 is well under the SPEC's *"if it passes
~150 L, stop and say so"* threshold, so the honesty check PASSES** — the verdict
is unchanged and this is a correction to the figure, not a defect being
confessed. The "94 code L" carried here until now came from `e0fbd82`'s own
commit message and reproduces at no commit: `e0fbd82` itself measures 98, and
`50b18d0` (the heap-default fix) then added comment lines. Copying a number
instead of measuring it is what produced the drift, so the command travels with
the number from here on.

**⚑ F3 carries TWO expectations per sample**, and that is what makes it a gate
rather than a comparison: the two legs must **agree**, AND the agreed exit code
must match the one the sample's own header documents. **Agreement alone is not
correctness** — that is the E161 G0 shape, two providers wrong the same way
reporting `ok`.

**⚑ THREE MUTANTS RUN AND REVERTED, and the third is the one to remember:**
1. Re-inverting `mach-c.chiral:138`'s `!=` back to `==` — the F1 defect — makes
   **F3 diverge on nearly every sample while G2's exit-42 program still
   passes**. That pair is precisely how the defect hid for two sessions.
2. `(import "mach-x64")` in `compile-driver-c` fails **G0b and G1** with
   `mc: extern does not lower: lambda stays upper`.
3. Dropping `m_div`'s Euclidean correction is caught by the **shim gate** and by
   **G4** and **NOT by F3** — no sample divides negatively. ⚑ **State this
   wherever this leg's adequacy is discussed: F3 does not subsume the shim
   gate.** A behavioural differential covers what its input vector reaches, not
   what the ops span.

### ⚑ THE TWO DEFECTS, AND WHY THE GATES DID NOT SEE THEM

Worth reading before building any further conforming target.

1. **The three comparison ops were polarity-inverted.** `true` is tag 0
   (`prelude.chiral:18`), so a comparison materialized as a *value* must yield the
   **tag**, which is why `mach-x64:367/369/371` emit `setne`/`setge`/`setg`.
   Spelling them `==`/`<`/`<=` negates every materialized Bool. **And `fjc` was
   compensating with `? 0 : 1`** — two errors that cancelled, so the fused
   compare-and-branch path worked perfectly while every materialized Bool was
   wrong. That is why seven subsystems tested clean during diagnosis and the
   symptom surfaced three layers away as `no such def: compile-main`.
2. **`_start` never realigned the stack.** The kernel enters 16-aligned with no
   return address; gcc compiles a C `_start` assuming a return address was
   pushed, so every frame is skewed by 8 and any 16-byte SIMD spill faults.
   Presented as an `-O2`-only SIGSEGV for two sessions and was **not** an
   optimizer bug. Found by core dump: `movaps %xmm0,(%rsp)`, RSP ≡ 8 (mod 16).

**The lesson, and it is this arc's own subject.** `mach-c`'s gate had 68
assertions over each arm's **emitted text**, and three of them were *pinning*
defect 1 — `op-eqi` rendering `==` looks right and is semantically inverted.
Text cannot see polarity. Nothing checked the runtime behaviour of the
composition until the whole compiler was run. **A conforming-target gate must be
behavioural, not textual** — F3 is that rule institutionalised, and it is now
`run-native.sh` Phase 10 rather than a one-off probe.

**Also latent, recorded not fixed:** `-foptimize-strlen` and
`-ftree-loop-distribute-patterns` each turn a shim loop into a call to `strlen`,
which does not link under `-nostdlib`. Harmless at plain `-O2` today because
other passes reshape those loops first, so the freestanding build survives by
luck rather than by design.

### ⚑ BOTH AUTHOR CALLS ANSWERED 2026-08-24 — the residue is mechanical
1. **Rocq toolchain: ANSWERED — install here (ccbox).** Status: `coq 8.16.1`
   installed via apt and working, **but it cannot read the sources** —
   `rocq/Chirality/*.v` use `From Stdlib Require Import`, the Rocq-9 root rename, and
   8.16 rejects it (`Cannot find a physical path bound to logical path ZArith
   with prefix Stdlib`). The `.vo` files in the tree were built on the **host**
   (`Makefile.coq.conf` records `/home/shea/.opam/5.3.0/lib/coq/`), not here.
   An opam Rocq-9 build was attempted twice and failed twice: first on the fd
   limit (`Too many open files` extracting the ~50k-package repo index), then —
   after raising `ulimit -n` to 65536 — opam **exhausted the system fd table**
   and took the box down until the job was killed. ⚑ **Retry serially with
   `ulimit -n` capped near 16384**, never alongside other work. Cheap alternative
   worth considering first: `From Stdlib Require Import` → `Require Import`
   resolves on **both** 8.16 and Rocq 9, giving a working `coqc` gate today
   without CoqHammer. ⚑ *`ccomp` is no longer absent — see the measured section
   below; CompCert is built, the shim split landed, and the C leg convicts under
   it FROM THE COMMITTED TREE, as Phase 10's default.*
2. **CompCert licensing: ANSWERED.** INRIA NC restricts *use of CompCert* and
   carries **no output restriction**; a one-off comparison is *"evaluation"* on
   its face, so a demo is fine even for a company. The line is one-time
   evaluation vs standing production QA. chirality's own BUSL-1.1 is untouched —
   CompCert is never vendored, linked, or redistributed. ⚑ *"The swap is one
   `Prov` constant" is MEASURED FALSE — see below; it was one constant plus two
   real changes, all three now landed, and the constant was ADDED beside the gcc
   one rather than swapped, since the two C legs are not disjoint from each
   other.* ⚑ Also settled: **AGPL cannot express the hole the author
   wants closed** — §7's permitted-additions list is closed, §10 lets recipients
   strip anything else, and §4 explicitly permits selling. BUSL-1.1 stays.

### ⚑ COMPCERT: BUILT AND MEASURED HERE, 2026-08-25 — the leg CONVICTS

Run end to end in ccbox. **Every number below is from a command, not an
estimate.** `ddc-legc`'s `Prov` is deliberately **unchanged** — see "what still
blocks the swap".

**1 — Acquisition: NOT opam, and not a Debian package either.** Debian ships no
`compcert` in any suite or component (`packages.debian.org` search for
`compcert` across all suites: *"Sorry, your search gave no results"*), so the
long-standing note *"it installs via opam"* points at the one route that already
took this box down twice. It is wrong. The route that works needs **no opam at
all**: CompCert bundles Flocq and MenhirLib in its own tarball, and every other
prerequisite is in **Debian bookworm `main`**, which is the only component this
box has —

| need | Debian `main` candidate | CompCert 3.17 requires |
|---|---|---|
| Coq | `coq 8.16.1+dfsg-1+b2` | `>= 8.15.0 & < 9.2~` ✓ |
| OCaml | `ocaml 4.13.1-4` | `>= 4.05.0 & < 5~` ✓ |
| Menhir | `menhir 20220210+ds-2` | `>= 20200624`, `!= 20260122` ✓ |
| menhirLib (findlib) | `libmenhir-ocaml-dev 20220210+ds-2` | required by `configure` ✓ |
| Flocq, MenhirLib (Coq) | — | **bundled in the tarball** ✓ |

```
apt-get install -y --no-install-recommends coq menhir ocaml-findlib libmenhir-ocaml-dev
curl -sSL -o v3.17.tar.gz https://github.com/AbsInt/CompCert/archive/refs/tags/v3.17.tar.gz
./configure x86_64-linux -prefix /opt/compcert && make -j2 all && make install
```

**2 — It fits this box, comfortably.** `make -j2 all` (259 Coq proof files
re-checked, then OCaml extraction) returned **RC=0**; a watchdog sampling
`/proc/meminfo` every 5 s recorded **min MemAvailable 1,369,324 kB** — the 1 GiB
floor was never approached and nothing thrashed. `ccomp --version` →
*"The CompCert C verified compiler, version 3.17"*. Egress to `github.com` works
(the 1.9 MB tarball fetched over plain `curl`). ⚑ **The opam disaster was not a
CompCert cost — it was an opam cost, and CompCert does not need opam.**

**3 — The shim does NOT survive `ccomp` unmodified. Three refusals, measured
one at a time.**

| construct | `ccomp` verdict |
|---|---|
| `register long r10 __asm__("r10")` (`chirality-rt.c:54`) | **HARD REFUSAL** — `syntax error after 'r10' and before '__asm__'`. GNU local register variables are not in CompCert's grammar; no flag reaches it. |
| top-level `__asm__(".globl _start…")` (`chirality-rt.c:191`) | **HARD REFUSAL** — `syntax error … At this point, one of the following is expected: a function definition; or a declaration; or a pragma`. CompCert has no file-scope asm. |
| `"=a"`/`"a"`/`"D"`/`"S"`/`"d"` constraints | **HARD REFUSAL** — `unsupported feature: asm result of kind '=a'` (and one per argument). CompCert's inline asm takes only the generic classes. |
| `__asm__ volatile ("ud2")`, and generic-`"r"` asm | accepted, but **only** under `-finline-asm` (off by default). |
| the 1 GiB `static long m_heap[]` | **accepted**, no flag, no diagnostic. |
| `-nostdlib`, `-static`, `-Wl,--defsym,m_entry=…` | **all accepted** — CompCert drives `gcc -m64` as its own assembler and linker, so the link step passes straight through. |
| `-ffreestanding`, `-fno-strict-aliasing` | `error: Unknown option`. Both are *semantic* no-ops for CompCert (it performs no type-based alias analysis), so this is vocabulary, not meaning. |

⚑ **The trap worth naming.** Rewritten with generic `"r"` constraints the
crossing *compiles clean* — and is **silently wrong**. `ccomp -finline-asm -S`
on it emits the bare instruction and nothing else:

```
# begin inline assembly
	syscall
# end inline assembly
```

No operand ever reaches `%rax`/`%rdi`/`%rsi`/`%rdx`, and the result is
uninitialized. CompCert substitutes operands into the template text by name; a
template that names none gets none. So "it built" is not evidence here — this is
the reported-ok-forever class, one level down.

**4 — With the three constructs moved into a hand-written `.s`, everything
passes.** `m_sys`, `m_trap` and `_start` were split out (22 lines of assembly;
`m_sys` becomes the six SysV→syscall register moves plus `syscall; ret`), the
remaining 183 lines of `chirality-rt.c` compiled by `ccomp -O2` unchanged:

- **the shim's own gate: `e166 rt gate: 51 checks, 0 failed`, exit 0.**
- **the whole leg, `--no-admission`: 9 gates, 9 passed, 0 failed.** G1 lowers,
  G2 exits 42, F3's 25-sample behavioural differential agrees on all 25,
  `chirality-bin-c` builds from **2,171,314 B** of generated C.
- ⚑ **G4 CONVICTS: `chirality-bin-c < blobB == chirality-bin < blobB`, byte-identical at
  1,077,624 B** — *the same figure gcc produces*, and the artifact then runs.

So **`mach-c`'s generated C is CompCert-clean as it stands.** 2.1 MB of it, and
`ccomp` had no complaint about any of it. The deliberate `switch`-not-computed-
`goto` choice in `mach-c.chiral`'s `jtb` arm paid off exactly as intended. The
entire CompCert obstacle is in the **hand-written shim**, not in generated code.

**5 — What blocked the `Prov` swap — ⚑ CLOSED THE SAME DAY, and it is now
LANDED IN THE TREE.** The paragraph here used to say the leg had convicted only
through a scratch wrapper, that the committed tree did not build under `ccomp`,
and that naming CompCert would assert a compiler that never built the committed
thing. All three were true for about an hour. Both changes are committed:

1. **The shim split — `aa055ec`.** `m_sys`, `m_trap` and `_start` are
   `scaffold/rt/chirality-rt.s`. ⚑ **The author's decision on the accounting, which
   was the actual open question:** a `.s` beside the shim is a *second trusted
   artifact*, so the trusted drop is counted as **C code lines + asm code lines,
   SUMMED** against the SPEC's ~150-line honesty threshold — **89 + 27 = 116** —
   because moving code across a file boundary must not be able to shrink the
   number that measures how much we are trusting, or the honesty check becomes a
   filing trick. The threshold was NOT widened. Both file headers carry the rule
   and the two `grep -cvE` commands that produce the numbers.
2. **Per-compiler `CFLAGS` — same commit.** gcc keeps its measured flag set byte
   for byte; `ccomp` gets `-O2 -nostdlib -static`. ⚑ `-finline-asm` turned out
   **not** to be needed: the split left no inline asm in the C at all, so the
   flag the pre-split variant required is gone with it.
3. **Two `Prov` constants — `4eeeb1e`.** `ddc-legcc ("c" "compcert-3.17")` was
   ADDED beside `ddc-legc ("c" "gcc-12")` rather than overwriting it, both now
   naming a toolchain that actually built something. ⚑ **The two C legs are NOT
   disjoint from each other** — `leg2-disjoint?` needs both language and
   toolchain to differ, and they share `"c"` — so a quorum is leg 0 plus
   **exactly one** of them and a driver listing both has one leg fewer than it
   thinks. `e166_ddc_legc.chiral` went 13 → **23 cases** to assert that — and
   then to **36** at `f713ec8`, because 23 was not enough. ⚑ **`ddc-compare`
   never consulted `prov-disjoint?` at all.** It folded bytes, so leg 0 + BOTH
   C legs came back `ddc-converged`: three entries carrying two opinions,
   reported as a three-leg quorum, which is the exact common mode DDC exists to
   refuse and which `DdcR`'s own declaration already promised was refused. Every
   case up to 23 interrogated the PREDICATE, which was always right; none asked
   whether the compare path ASKED it, and case 21 asserted the convergence as a
   seam the driver owed. The gate now fires before any byte is read, reusing
   `prov-disjoint?` (one owner per rule), with the three refusal reasons kept
   distinct. Mutants run with a first-failure sweep over all 36, each reverted:
   gate removed → 21 24 25 26 29 30 32 35 36 · head-vs-rest only → 29 30 · a
   second routine on language only → 35 · on toolchain only → 21 24 29 30 32 36
   · the two refusal strings collapsed → 24 26 30 34.
4. **CompCert is Phase 10's DEFAULT — `bc7cbbd`**, chosen by measurement, not
   preference: the leg is **1m41.6s / 1m41.2s under ccomp against 1m51.7s / 1m40.1s under gcc** — ⚑ *two samples each, OVERLAPPING, so the honest reading is "indistinguishable", not "ccomp is faster"* — and
   the full native suite is **5m26.139s / 5m26.160s** — a 21 ms spread, both
   163 `ok` / 0 FAIL. Selection is a printed preference order (ccomp → gcc → cc),
   so a host without CompCert still runs a real leg instead of losing the gate,
   and the banner names the compiler on every run. ⚑ **FLAG RETIRED — the budget
   did not exist.** This line read *"5m26s breaches the ~4-minute suite budget,
   and it breaches it under BOTH compilers"*. The **~4 minutes was asserted in
   conversation and never measured**, so the breach was a finding about an
   invented number. Three further serial runs at `8db4af0` measured
   **5m24.523s / 5m25.725s / 5m21.253s** (163 `ok` / 0 FAIL / exit 0 each), which
   with the two above gives **5m21s–5m26s over five runs, a 4.9 s ≈ 1.5 %
   spread** — a range, deliberately, not a replacement threshold. `user`+`sys`
   is 4m04–4m08, so **~1m17 is not CPU time**, on a box reporting 12 logical
   CPUs; the figure is host-dependent and is not a claim about compute cost.
   ⚑ *What IS still owed a diagnosis:* the prior figures disagree with each
   other — BUILD-ORDER recorded **2m52s** at `70ee90f`, `docs/testing-floors.md`
   **3m35s** for the same commit and the same 163 assertions — and the extremes
   span more than the budget that was invented to bound them. That needs a
   bisect; the C leg is not the suspect (21 ms). Table and method now live in
   `.planning/BUILD-ORDER.md`, which owns the number.

**Acquisition, kept verbatim above because the next session must not re-derive
it and must not reach for opam:** `apt-get install -y --no-install-recommends coq
menhir ocaml-findlib libmenhir-ocaml-dev`, the INRIA v3.17 tarball,
`./configure x86_64-linux -prefix /opt/compcert && make -j2 all && make install`.
No opam anywhere; Debian ships no `compcert` package in any suite, and does not
need to. ⚑ Standing constraint, unchanged and now live rather than prospective:
**never distribute a CompCert-built artifact** — build, compare, discard. Every
artifact `ddc-c-leg.sh` produces lands in a work dir its EXIT trap removes, and
that constraint is carried as a comment at both the leg script's head and
`run-native.sh`'s Phase 10.

### ⚑ SUPERSEDED 2026-08-24 — the oracle is NOT being repaired

**Author, 2026-08-24: *"ignore python oracle we changed gears to something much
higher in worth."*** The directive below was last session's and is retired. It is
kept because its *reasoning* still holds — routing around a failing check and
reporting green on the half you like is the error it names — but the oracle is no
longer the check. E166 is: it now provides the external opinion the oracle was
standing in for, and it passes. Re-measured 2026-08-24 before the change of gear:
**638 tests, 88 errors, 22 failures.** Not green, deliberately, and not to be
spent on.

**Also settled this session:** rung-1's python scope is now *enumerated and
mechanically enforced* — `.planning/RUNG1-CHECKLIST.md` §C-inventory classifies
all 133 `.py` (102 owned by C3/C5/C6a/C6b, 988 LOC newly owned by **C7**, two
judgment calls, ~4,400 LOC of authoring harness explicitly **out** of scope
because it is not chirality), and `ledger-lint` **check O** fails on any
unclassified `.py`. "Zero python" means those tables are empty, **not** "no
`.py` under `find`".

### ⚑ RETIRED DIRECTIVE (last session): KEEP THE ORACLE GREEN
*"the oracle is the external verification. If the verification is failing why
are you ignoring it."* I had found it red, filed it NEEDS-AUTHOR/non-blocking,
and shipped three elements past it. **That was routing around a failing check
and reporting green on the half I liked.** Do not repeat it.

**State: 348 → 638 tests running, errors 318 → 88, failures 23. NOT GREEN.**
(`cd scaffold && python3 -m unittest discover -s tests`.) 290 tests were not
executing at all — setUpClass died before discovery, so the suite reported a
small number that looked mostly-working. Four causes fixed in `60c3061`:
import resolution had no libdir fallback (predates E160); the loader never
learned `kind`/`module`; data groups were installed in file order instead of
hoisted; and two tests carried their OWN rotted resolver. Plus one deliberate
behaviour change: `RT()` demanded a host impl for every DECLARED extern, now
checked AT THE CROSSING (P3 — declaring is not crossing).

**The remaining 111 are NOT one cause and need per-case adjudication.** Two
already triaged, both the differential working as intended:
`lib/reflect-floor.chiral` fails on BOTH floors (a real source defect, invisible
because nothing compiles it natively — it defines no `compile-main`), and
`test_kernel_fulladt_chirality`'s Con/Tcon cases are a genuine chirality-vs-Python
disagreement needing a verdict on which side is right, not a patch to quiet it.

### Built in the 2026-08-23 session
**E161** module datasheet (8 steps, `913e718`…`95694a1`; gate 44 assertions,
six mutants) · **E156** sort adoption (full pipeline, `06b0789`; Phase 9, 14
assertions) · **S18** the `Scriba` record (`5a88be3`+`130062f`; the 11-param
thread → one value). Native suite: **nine phases, 135 assertions + 81 roots,
exit 0**, and it stayed green throughout.

### The verification architecture — the machine-ward half is now BUILT
`docs/testing-floors.md` carries the **coverage map** and the two rules that
generate it: **(1) a differential only covers what is BELOW its branch point**
— above it both legs are wrong the same way and the compare says `ok`;
**(2) it is only worth building when the new translator is much smaller than
what it tests** (`mach-c` ~1:5–1:12 ✓ · `tal-c` ~1:6–1:11 ✓ · upper→C ~1:1.3 ✗,
a rewrite wearing a differential's clothes).

| stage | lines | in-house | external |
|---|---|---|---|
| upper→tal | `lower` 407 | `interp` vs `tal-eval` (**E169**) | Rocq-verified `preserve-check` (E169) |
| tal→Mach | `emit-core` 573 | `tal-eval` vs native | **E167** `tal-c` |
| Mach→machine | `mach-x64` **1,737** | — | **E166** `mach-c` |
| the checker | — | — | the `rocq/` leg |

**The shape:** the C trick covers the machine-ward half, Rocq the proof-ward
half, **and they meet at tal** — because that is where `axis-altitude`'s "types
preserved and checked down to" already ends. Same seam, read from both sides.

**Minted, no pipeline run:** E162 manifest-custody · E163 manifest-kind ·
E164 profile-ergonomics · E165 dedup-adopt · **E167** tal-c · **E168**
test-floor (what the 709 Python tests migrate INTO) · **E169** lower-cover.

### The Python corpus, measured — the migration this all serves
**79 files, 14,784 LOC, 709 test functions** = **335 differential** (41 files,
**cannot be ported** — delete Python and there is nothing to differ against;
they re-found on a new second opinion or lose their meaning) + **68 B1-driven**
(9 files, port to native gates, mechanical) + **306 python-checker-only**
(29 files, rewrite as chirality-in-chirality). **E166's leg is load-bearing here:**
`ddc.py`'s leg 1 IS the Python oracle, and `ddc-bad-quorum` refuses a quorum
below two disjoint legs — so retiring Python kills DDC outright unless the C
leg is ADMITTED FIRST.

### ⚑ What cost time — do not re-learn these

*Cross-session, dated. Entries without a date are from the 2026-08-23 session.*

- **2026-08-24 — a claim in a commit message is not a constant in a file.**
  `e0fbd82`'s subject line says *"4 GiB → 1 GiB heap"*; the constant it shipped
  still read **4 GiB**, and `50b18d0` is what actually changed the number. The
  cost is not cosmetic: a 4 GiB-`.bss` static binary **SIGSEGVs at load** here
  (`MemTotal` 3.9 GiB, `vm.overcommit_memory=0` *accounts* a `.bss` mapping
  rather than reserving it lazily), and past ~2 GiB the shim will not even
  **link** against a second translation unit without `-mcmodel=medium`. So the
  leg would not have RUN, and a leg that does not run is not a leg. **Read the
  diff, not the subject line** — including your own.
- **2026-08-24 — `grep -c 'end-module'` is the WRONG count, by 17.** The
  handoff said blob A had **68 modules**; it has **51**. The unanchored grep
  also counts the form's mentions inside source comments. The anchored one,
  `grep -c '^(end-module '`, is the count: **51** for blob A, **52** for the
  committed `scaffold/build/blob.chiral` (where the unanchored number is 69, the
  figure that had also propagated into the E166 SPEC's G0b row). Same shape as
  the measurement traps already catalogued in `BUILD-ORDER.md` §1 A3 — an
  indirect artifact read as if it were the direct one.
- **A stale build root list that failed OPEN.** The documented ceremony ended
  at `compile-all`; since H4 the entry is in `compile-driver`, so it produced a
  **0-byte compiler** — and the next line, `cmp C1 C2`, then PASSED, because two
  empty files are identical. Fixed `fb2bcaa`.
- **A gate fixture blind to its own mutant.** E156 G4 passed **14/14 with
  `list-sort` deleted**: the input reversed into something accidentally sorted
  and `row-join` ate the duplicate before it reached the function under test.
  *Byte-identical to the old implementation is also what a fixture that
  exercises nothing achieves.*
- **A differential reporting `ok` while both sides were wrong.** E161 G0, two
  providers emitting the same wrong marker. Only a FIXED committed expectation
  caught it.
- **Fixing a fail-open in one loader and not its twin.** The EOF close landed
  in `load-source`; `compile-front` runs `load-source-batched`. A probe that
  passed on both compilers proved nothing (it reads the loader from the blob) —
  a git-worktree control against the prior commit is what made it discriminate.
- **Two bootstrap events.** A new toplevel form (E161 Step 1) and a new head
  (Step 5) each need a boot compiler built from the OLD surface. `Cboot == C1`
  byte-identical is the evidence it is surface-acceptance, not semantic.
- **A stale `test-runner` testing four compiler generations back.** Rebuild it
  at every promotion.
- **`run-native.sh` carried a DEAD gate inside `if false`** that read as active,
  covering four roots. Deleted after verifying the live sweep reaches all four.
- **`scaffold/lib/scriba` is a SYMLINK** to `TUI/scriba`. One directory, nothing
  to sync — `diff -rq` clean was the symptom, not the mechanism (A3 again).
- **Design reasoning belongs in the note base, not commit messages.** Caught by
  the author. The fix is `docs/testing-floors.md` + `docs/banks/verification.md`;
  the failure mode was excellent commit messages and an under-fed `docs/`.
