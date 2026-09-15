---
node: arc-syscall-custody
layer: navigation
related: [arcs/README, goals/enforcement, arcs/enforcement-arc, arcs/tool-authority-arc, banks/capability, banks/port, permission-model, status-ledger, decisions/decision-syscall-governance, decisions/decision-deployment-custody, decisions/decision-profiles, decisions/decision-scope, decisions/decision-work-ids, elements/catalog, records/homing-triage, records/findings, records/author-calls, index]
status: current
updated: 2026-09-14
---

# Arc: syscall-custody

- goals: [[goals/enforcement]], condition 1: "A capability sits at ENFORCED, or
  its ledger row says why it does not."
- reserved element block: **none**. All five rows carry an element minted long
  before this file, and their arc-local ids per [[decisions/decision-work-ids]]
  spell the letters `SC`, for syscall custody: `syscall-custody/SC1` upward. A
  grep for `SC` followed by a digit over `docs/`, `records/` and `.planning/`
  returns nothing, verified 2026-09-14. The two-letter form follows
  `baseline-alignment`'s `BA` and `tool-authority`'s `TA`.
- build-state authority: [[status-ledger]]
- checklist: none. No `records/syscall-custody.md` exists.
- sibling: [[arcs/enforcement-arc]], same goal, same condition, a different
  surface. That arc owns what the compiler states about its own work, the
  typed-assembly floor, the gate tier and memory safety. This arc owns the
  syscall surface.

## Why this arc exists

[[decisions/decision-syscall-governance]] settled three mechanisms on
2026-07-28 and named an element for each: E76 the chokepoint, E77 the rung-1
seccomp filter, E78 the number-in-type attenuation. Two further elements landed
on the same surface afterwards. E162 asks who may widen the permitted set once
the set is load-bearing, and E164 asks why nobody declares the profile that
narrows it. [[records/homing-triage]] measured all five as held by no roster and
proposed this arc; the author approved opening it 2026-09-14.

Condition 1 is the goal's rung question and each of the five sits on it
differently. E76's row reads `built (ENFORCED)` and names two artifacts that do
not exist. E77 and E78 are `design` rows and their track cells read `SH` since
the author's ruling of 2026-09-15, so why each sits below ENFORCED is now the
row's own to state. E162 has no mechanism at
any rung. E164 is the SEEDED pattern the goal names, turned on a gate: the
narrowing works and the tree declines to opt in.

**The ownership check was run before this arc claimed anything.**
[[arcs/tool-authority-arc]] lists `decision-syscall-governance` in its
`related:` field at `docs/arcs/tool-authority-arc.md:4`, which is the mention
the triage flagged. Its six requirements reach path naming, the inheritance
flag word, descriptor hand-off, the constructed child, the ask as a value, and a
placement check. None reaches a syscall number, a permitted set, a seccomp
filter or a profile declaration. Its own boundary section at
`docs/arcs/tool-authority-arc.md:241-291` refuses E43, E148, E149 and contests
E30, and it names none of these five. No other arc names E76, E162 or E164 at
all; `docs/arcs/orchestration-engine-arc.md:270` names E77 and E78 only as two
of the six elements the `?` track call covers, which is a citation of the call
rather than a claim on the work.

## What the tree already holds

Measured 2026-09-14 against the working tree. [[banks/INDEX]] holds thirteen and
two own this territory. [[banks/port]] Shard 2 places the syscall behind an
extern whose contract is chirality's and whose referent is bound at load
(`docs/banks/port.md:116-120`). [[banks/capability]] Shard C places attenuation
as subtyping composed with refinement entailment over a value-index, and
measures it as present-but-unapplied (`docs/banks/capability.md:181-201`).
Neither is re-derived below.

| group | what exists today | where | rung |
|---|---|---|---|
| G1 the registry | the chokepoint rule: default-deny by absence, a refusal when a `ti-sys` immediate does not equal its crossing's registered number, and zero Linux numbers in the rule file | `lib/lowering/tal/sys-check.chiral:21`, `:35-37`, 77 lines | ENFORCED |
| G1 | the rule runs on the shipping compile. `emit-elf-m` folds `ck-tiprog` over the whole emitted image before it emits | `lib/lowering/compile-emit.chiral:296`, reached from `lib/lowering/compile-all.chiral:34` | ENFORCED |
| G1 | the permitted set: 40 `(sys-row ...)` entries, ordinary chirality source carrying an `import`, a `module` coordinate and a `def` | `lib/lowering/tal/target-linux.manifest` | ENFORCED |
| G1 | the gate: phase 5, a positive control plus four poison mutants that rebuild a poisoned copy of the compiler's own blob and watch it refuse | `tools/test/syscall-manifest.sh:79`, `:111-121`, wired at `tools/test/run-tests.sh:146` | ENFORCED |
| G1 | `checked-sys-lib`, the older narrow verdict: one definition site and zero uses, superseded by the whole-image fold above | `lib/lowering/tal/sys-linkage.chiral:112` | SEEDED |
| G1 | ⚑ **the registry's rows do not tell themselves apart.** Seven of the 40 carry the syscall number `16`, and three of those seven carry no comment at all, so the ioctl request that distinguishes them appears nowhere in the file | `lib/lowering/tal/target-linux.manifest:30-35`, `:60` | ENFORCED as data |
| G1 | the rule the file fails: `.planning/MANIFEST-DESIGN-MAP.md:118` requirement 3, constructors have named fields, and `:119` requirement 4, anything distinguishing two rows is a field. Requirement 4's stated justification is these seven rows and the lexer dropping comments | `.planning/MANIFEST-DESIGN-MAP.md:118-119` | DESIGNED |
| G1 | ⚑ **two artifacts E76's state claim names do not exist.** `find . -name 'target-linux*'` returns one file and its extension is `.manifest`; `find . -name 'test-syscall-manifest*'` returns nothing. The ledger row cites both | `docs/elements/ledger.md:196` | absent |
| G1 | six live spans in three files name the dead `target-linux.chiral`. A seventh at `lib/module/loader.chiral:263` names the module without an extension and resolves | `lib/lowering/tal/sys-check.chiral:11`, `:13`, `lib/lowering/tal/sys.chiral:785`, `:1003`, `tools/test/syscall-manifest.sh:14`, `:73` | SEEDED |
| G1 | the one span that resolves, and why the rename announced nothing: an extensionless import against a resolver that probes three extensions | `lib/lowering/tal/sys-linkage.chiral:23`, rule at `MAP.md:20` and `MAP.md:27` | ENFORCED |
| G1 | the gate that does exist and the name it goes by | `tools/test/syscall-manifest.sh` | ENFORCED |
| G2 attenuation | H8, the per-program profile check: the crossings the object program calls must lie inside the declared frozen port set, and two sources with different profiles get different verdicts | `lib/lowering/compile-emit.chiral:200-202`, `manifest-offender` defined at `:259` and called at `:299` | ENFORCED |
| G2 | the granularity is the whole object program. `manifest-offender` scans `obj`, and the scope decision is stated: the byte runtime's arena machinery is the substrate every program is built on and is charged to no profile | `lib/lowering/compile-emit.chiral:259-260`, scope at `:207-210` | ENFORCED |
| G2 | the refinement decision procedure the number would ride: interval with holes over `I64`, 168 lines, inside the compiler blob through `lib/typing/kernel.chiral:18` | `lib/typing/refine.chiral:13-18`, `:93` | IMPLEMENTED |
| G2 | the `subtype` mechanism attenuation composes with, built and unapplied to grant narrowing | `lib/typing/kernel.chiral:799`, measured at `docs/banks/capability.md:193-201` | IMPLEMENTED |
| G3 the kernel | nothing. `grep -rn seccomp` over `lib/`, `prog/`, `tools/` and `bin/` returns one line, and that line is a comment pointing at E77 | `tools/test/linear-mint.sh:28` | absent |
| G4 custody | the framing: acquire a moduleset, stage it, certify at staging, with auth as linear ports. The note states in its own words that it settles the framing and does not claim the enforcement is built | `docs/decisions/decision-deployment-custody.md` §Honest state | DESIGNED |
| G4 | the four grant operations custody must not reinvent. Only Move is ENFORCED; Attenuate is present-but-unapplied, Delegate is built at the local floor, Revoke has no code | `docs/banks/capability.md:193-201`, `:219-227`, `:242-246` | mixed |
| G4 | nothing records who may add a `(sys-row ...)`. The permitted set is a source file and any edit to the tree widens it silently | measured 2026-09-14 | absent |
| G5 ergonomics | the profile form in the grammar, with its shape error message | `lib/surface/parse.chiral:851`, `:762` | IMPLEMENTED |
| G5 | ⚑ **six `(profile ...)` declarations exist outside the gate fixtures, and nothing reaches them.** All six sit under `prog/demo/`, and `grep -rn 'prog/demo' tools/ bin/` returns nothing | `prog/demo/profile-node-sensor.chiral:12`, `prog/demo/profile-duo.chiral:13`, `prog/demo/verify-total.chiral:25`, `prog/demo/profile-node-render.chiral:13`, `prog/demo/profile-headless.chiral:12`, `prog/demo/profile-tomodachi.chiral:30` | SEEDED |
| G5 | the one path that declares a profile and runs: phase 4, the composition manifest gate | `tools/test/profile-target.sh`, wired at `tools/test/run-tests.sh:145` | ENFORCED |
| G5 | the lever named and priced: dev-profile ambient threading, with the risk stated as people routing around a painful discipline | `docs/decisions/decision-deployment-custody.md` §The bet | DESIGNED |

Three facts from that table govern the roster. **The chokepoint is live**, so no
row here builds one. **The profile-permitted-subset is live too**, which
`docs/elements/catalog.md:297` still files as owed while
`docs/elements/ledger.md:196` files it as built; the code at
`lib/lowering/compile-emit.chiral:259` agrees with the ledger. **What is missing
is everything the set is for**: a set nobody narrows per component, a kernel
that does not enforce it, a widening nobody is accountable for, and a
declaration nobody writes.

## What is missing, and its structure

| group | owns |
|---|---|
| G1 the registry is what the claim says it is | a permitted set whose rows are distinguishable inside the file, and a state claim whose every cited artifact resolves. The mechanism is built; what fails is the artifact it reads and the record of what was built |
| G2 attenuation | which syscalls one component reaches, as a subtyping fact over the `ti-sys` immediate. The program-wide check is built and the per-component one is the granularity below it |
| G3 the kernel enforces the same set | a seccomp-bpf default-deny filter derived from the permitted set and installed at process start, so a native-codegen bug that issues a raw syscall meets a refusal the type system never saw |
| G4 custody of the set | who may add a row, recorded where the row is read. E76's landing made the set load-bearing, so controlling the manifest controls what can be built at all |
| G5 the governed path is the cheap path | a program that declares its port set without being asked, by default, by inference, or by generated scaffolding. The gate works and the tree does not opt in |

### The edges that run against the order

| edge | direction | what crosses |
|---|---|---|
| G5 to G2 | against, and the loudest | per-component attenuation refines a mechanism nobody invokes. H8 narrows per program today and six declarations exercise it, all of them unreached. Splitting the grain finer buys nothing until a program declares anything at all, so G2 sitting second is a dependency order and reads wrong as a schedule |
| G4 to G1 | against | custody is keyed on an artifact identity, and G1 is what makes the identity stable. FD-27 measured the failure shape: the file's declared kind changed and every consumer resolved across kinds, so a rename broke nothing and announced nothing. A signed row or a separate grant artifact inherits that hole until the identity is settled |
| G3 to G2 | against | the filter is derived from "the permitted set", and G2 decides whether that phrase names one set or one per component. A whole-process filter over a union of per-component sets enforces the widest of them, which is the attenuation undone at the kernel. Ordering G3 after G2 is the dependency; building G3 first gives a filter whose derivation G2 then invalidates |
| G3 to nothing | out of the arc | G3 vanishes at rung 2, where chirality is the kernel and simply does not implement the unpermitted call. It is the one row here whose whole purpose is a rung the project intends to leave |

## REQUIREMENTS

Six, each with the observation beside it, measured 2026-09-14.

1. **No two rows of the permitted set are told apart by something the file
   drops.** Observed as every pair of `(sys-row ...)` entries in
   `lib/lowering/tal/target-linux.manifest` sharing a number carrying a field
   that separates them. Today seven rows carry `16` at `:30-:35` and `:60`,
   three of the seven carry no comment, and the file fails
   `.planning/MANIFEST-DESIGN-MAP.md:118-119` requirements 3 and 4.

2. **Every artifact E76's state claim names exists at the name it is called.**
   Observed as `find` returning a file for each path
   `docs/elements/ledger.md:196` and `docs/elements/catalog.md:297` cite. Today
   `lib/lowering/tal/target-linux.chiral` and `tools/test/test-syscall-manifest.sh`
   return nothing, and six spans in three live files still name the first.

3. **A profile attenuates which crossings one component reaches.** Observed as
   two modules inside one program getting different permitted sets. Today
   `manifest-offender` (`lib/lowering/compile-emit.chiral:259`) scans the object
   program's own fns against one frozen port set, so the finest grain available
   is the program.

4. **The kernel refuses what the model does not name.** Observed as a
   seccomp-bpf filter derived from the permitted set and installed at process
   start, with a mutant that issues an unpermitted call and dies. Today
   `grep -rn seccomp` over `lib/`, `prog/`, `tools/` and `bin/` returns one
   comment at `tools/test/linear-mint.sh:28`. ⚑ **The track call that gated this
   requirement cleared 2026-09-15: `E77` reads `SH`.**

5. **Widening the permitted set is attributable.** Observed as an artifact that
   records who authorised a `(sys-row ...)` addition, read where the set is
   read. Today the set is ordinary source and nothing in the tree records
   manifest authorship or authority anywhere.

6. **Declaring a port set is cheaper than declining to.** Observed as the count
   of `(profile ...)` declarations a shipping path reaches. Measured
   2026-09-14: six exist outside the gate fixtures, every one under
   `prog/demo/`, and `grep -rn 'prog/demo' tools/ bin/` returns nothing, so the
   reached count is zero.

## Roster

Five rows, one per element, every one minted before this file and homed by no
roster until now. Ids spell `SC`. **This arc mints nothing and allocates no
number.**

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `syscall-custody/SC1` | the permitted set becomes an artifact the claim can rest on: rows distinguishable inside the file rather than by a comment `sexp.chiral` drops at the lexer, and a state claim whose cited artifacts resolve. The mechanism is built and runs on every compile (`lib/lowering/compile-emit.chiral:296`), and the residue is the artifact and the record. **Wanted when the row is taken up**: the seven `16` rows at `lib/lowering/tal/target-linux.manifest:30-35` and `:60` carrying the ioctl request as a field, and the six dead-name spans retired. **Blocking condition**: none measured. Nothing external gates this row | G1 | law | bind | 1, 2 | built | `E76` |
| `syscall-custody/SC2` | the `ti-sys` immediate carried in a refinement, so a profile says which syscalls one component reaches as a subtyping fact. The two halves are built and unjoined: the refinement decision procedure at `lib/typing/refine.chiral:13-18` is inside the compiler blob, and the `subtype` relation at `lib/typing/kernel.chiral:799` is IMPLEMENTED and unapplied to grant narrowing (`docs/banks/capability.md:193-201`). The grain below H8, which stops at the program. **Blocking condition**: `SC5`, because a finer grain over a declaration nobody writes buys nothing. ⚑ **The track call this row also waited on cleared 2026-09-15**: `E78` reads `SH` at `docs/elements/catalog.md:299` and `docs/elements/ledger.md:107` | G2 | law | connect | 3 | open | `E78` |
| `syscall-custody/SC3` | a seccomp-bpf default-deny filter derived from the permitted set and installed at process start, so the kernel refuses what a native-codegen bug might issue through a non-chirality path. Nothing exists: one comment at `tools/test/linear-mint.sh:28` is the whole tree. Vanishes at rung 2. **Blocking condition**: `SC2`, which decides what "the permitted set" names. ⚑ **The track call this row also waited on cleared 2026-09-15**: `E77` reads `SH` at `docs/elements/catalog.md:298` and `docs/elements/ledger.md:197`, and the ruling settled the adversary question with it | G3 | primitive | new | 4 | open | `E77` |
| `syscall-custody/SC4` | who may widen the permitted set, recorded where the set is read. E76's landing made `lib/lowering/tal/target-linux.manifest` load-bearing, so controlling it controls what can be built, and nothing records authorship or authority. The ledger's own four candidates are signed rows, a separate grant artifact, auth-to-widen as a profile the compiler checks, and attestation-at-staging per `decision-deployment-custody`. Must not reinvent the four grant operations at `docs/banks/capability.md:193-246`. **Blocking condition**: `SC1`, because every candidate keys on an artifact identity and FD-27 measured that identity as unstable | G4 | decision | new | 5 | open | `E162` |
| `syscall-custody/SC5` | the governed path made the cheap one: a default profile, inference from the crossings a program already reaches, a dev relaxation, or generated scaffolding. `manifest-offender` (`lib/lowering/compile-emit.chiral:259`) already computes the set a program calls, which is the input an inference would need. Six declarations exist, all under `prog/demo/`, and no shipping path reaches one. **Blocking condition**: none measured. `decision-profiles` default-flipping is the shape and the choice among the four is the row | G5 | decision | connect | 6 | open | `E164` |

### Coverage

Run 2026-09-14 against the table above.

- **Every requirement is served.** 1 and 2 by `SC1`, 3 by `SC2`, 4 by `SC3`, 5
  by `SC4`, 6 by `SC5`. No requirement is unscheduled.
- **Every row serves a requirement.** All five name at least one. No row is out
  of scope.
- **`SC1` is `built` and the two requirements it serves are unmet, which is the
  arc's premise rather than a contradiction.** `docs/elements/ledger.md:196`
  reads `built (ENFORCED)`, the mechanism runs on every compile, the gate runs
  four mutants, and the state column is the pipeline's authority for a row. The
  residue is the artifact the mechanism reads and the record of what was built,
  and goal condition 1 is exactly the requirement that a row's claim be
  checkable.
- **Every `origin` is defensible from the measurement.**
  - `SC1` is `bind` because the registry exists and the data telling its rows
    apart has no surface in the file: the ioctl request lives in a comment and
    `sexp.chiral` drops comments at the lexer.
  - `SC2` is `connect` because both halves are built. The refinement procedure
    is 168 lines inside the blob and the `subtype` relation is IMPLEMENTED; the
    wiring from `subtype` to grant narrowing is the measured missing step.
  - `SC3` is `new` because a grep for `seccomp` over `lib/`, `prog/`, `tools/`
    and `bin/` returns one comment line and no code anywhere.
  - `SC4` is `new` because nothing in the tree records manifest authorship or
    authority, and `decision-deployment-custody` states in its own words that it
    settles the framing and claims no enforcement.
  - `SC5` is `connect` because the computation an inference needs is already
    performed at `lib/lowering/compile-emit.chiral:259` and the profile form is
    already in the grammar at `lib/surface/parse.chiral:851`. What is missing is
    the join that makes the declaration free.

## What this arc does not take

- **The rest of [[goals/enforcement]] condition 1.**
  [[arcs/enforcement-arc]] owns the `design` rows whose state cell does not say
  why, counted at 66 by its own requirement 1 on 2026-09-05
  (`docs/arcs/enforcement-arc.md:42-48`), plus the attribution band
  `E184-E188`, the typed-assembly floor, the gate tier and the safety group. This arc adds no row to it and edits none of its
  rows.
- **Path naming, the inheritance flag word and descriptor hand-off.**
  [[arcs/tool-authority-arc]] owns all three, plus the constructed child and the
  ask as a value. Its surface is the name-to-descriptor crossing; this arc's is
  the crossing-to-number registry beneath it. The two meet at
  `lib/lowering/tal/sys.chiral`, where that arc reads flag words and this one
  reads syscall numbers. **No row of that arc is edited by this run.**
- **Widening the modelled syscall set.** `decision-syscall-governance` answered
  the scope question: the 362 are governed by default-deny at one chokepoint and
  not by 300-odd wrappers. This arc does not reopen it and mints no crossing.
- **Per-profile syscall policy.** Which subset each profile permits is
  profile-author taste, settled as unsettled by
  `decision-syscall-governance` §What is settled vs owed. `SC5` makes declaring
  a profile cheap and states no policy.
- **[[goals/ownership-and-trust]] and the `OT` track.** `E162`'s candidates
  touch signing and attestation, and the elements that carry those are `E43`,
  `E55` and `E56`, all `OT` and all deferred out of scope 2026-08-31. This arc
  takes `E162` under [[goals/enforcement]] on its own `SH` track cell and writes
  no row into `docs/arcs/ownership-and-trust-arc.md`.
- **The `.manifest` pretty parser.** `.planning/MANIFEST-DESIGN-MAP.md` is E163's
  design map and this arc cites its requirements 3 and 4 as the rule
  `target-linux.manifest` fails. Whether that file is ever read by the derived
  reader is E163's question.
- **Repairing the ledger and catalog rows.** `SC1`'s requirement 2 is what the
  row buys and this run edits neither file.

## Resume state

Opened 2026-09-14 against [[goals/enforcement]] condition 1, on the author's
approval of the `syscall-custody` proposal in [[records/homing-triage]]. Five
rows, six requirements, nothing designed. Rows spell `SC`. Every element on the
roster was minted before this file and this run mints nothing.

**The row to take up first is `SC1`.** It turns on no open call, its two
requirements are observable by `find` and by reading 40 lines, and `SC4` is
blocked on it. `SC5` is the second for the same reason: no open call, and `SC2`
is blocked on it.

⚑ **`E77` and `E78` carried `?` as their track when this arc opened, and both
were sorted `SH` on 2026-09-15.** The author re-derived each from the catalog's
own sourcing rule and neither fires a clause, so the rule's default stands;
`docs/elements/catalog.md` §UNSORTED carries both derivations beside the words
they replace. [[records/author-calls]] still carries the row as "The six `?`
UNSORTED tracks", raised 2026-08-31 by `docs/elements/catalog.md` §UNSORTED and
tracked 2026-09-10, and it stays open on `E166` and `E167` alone. The catalog's
words at the time this arc drew its roster, kept because the roster was drawn
against them:

- **E77.** *"No clause reaches it: `docs/decisions/decision-scope.md` list does
  not name it, it is in §XII, and LEDGER files it **SYS**. But its whole content
  is the kernel refusing what a codegen bug might issue, and
  `docs/decisions/decision-scope.md` decision 5 states that every rung is
  `enforcement against error, not against an adversary`. The two read it
  opposite ways."* What the answer changes: *"Whether adversary-facing hardening
  is in the current track at all."*
- **E78.** *"LEDGER files it **SYS** (SH), and its own last sentence names its
  purpose as 'the capability discipline ([[permission-model]]) reaching the raw
  floor'. The capability/permission model is **E40**, which is OT."* What the
  answer changes: *"Whether the refinement fragment carries syscall attenuation
  now."*

The call was carried on `SC2` and `SC3` as a blocking condition. It was never a
gate, following [[arcs/tool-authority-arc]]'s three open calls and
[[arcs/tuning-arc]]'s precedent for drawing a roster while a call is out. Both
blocking conditions now record it cleared, and the precedent held: the roster
drawn under the open call needed no row rewritten when the answer came. Homing
is planning: `docs/decisions/decision-scope.md` §What "deferred" means here,
exactly makes a scope deferral build-deferred, so a deferred element still
takes a row.

⚑ **This arc is unanchored on `arc -> goal done-condition`.**
`docs/goals/enforcement.md` condition 1 names `[[arcs/enforcement-arc]]` rows
`N1` and `N4` and no second arc, so `tools/lens/lens.py chain` reports this file
in that rung's uncovered set. Two arcs on one condition is established practice,
`goals/local-ai` condition 1 being served by four. The goal file is outside this
run's write scope and the edit is owed.

⚑ **`docs/elements/catalog.md:297` and `docs/elements/ledger.md:196` disagree
about E76's remainder.** The catalog reads *"Profile-permitted-subset +
load-time gate still owed"*; the ledger reads *"REMAINDER BUILT 2026-08-22"*.
Measured 2026-09-14: the profile-permitted-subset is live at
`lib/lowering/compile-emit.chiral:259` and refused at `:299` with *"E76 profile REFUSED
emit"*, and `tools/test/syscall-manifest.sh:138-162` runs three mutants against
it. The ledger agrees with the code on that half. Neither file is in this run's
write scope.

⚑ **`docs/elements/catalog.md:479` states E164's premise as zero `(profile ...)`
declarations outside the fixtures, and that is stale.** Six exist, listed in §3,
all under `prog/demo/`. The premise survives the correction because none of the
six is reached: `grep -rn 'prog/demo' tools/ bin/` returns nothing, so they are
declared and unrun, which is the SEEDED shape rather than the absence the
catalog claims. Not in this run's write scope.

**What was measured about E76 before any row's state was written.**
[[records/findings]] FD-27 used E76 as its worked failure and every claim in it
that this arc leans on was re-measured 2026-09-14. `find . -name 'target-linux*'`
returns exactly `lib/lowering/tal/target-linux.manifest`.
`find . -name 'test-syscall-manifest*'` returns nothing; the gate that exists is
`tools/test/syscall-manifest.sh`, phase 5 at `tools/test/run-tests.sh:146`. The
file was added already carrying `.manifest` at `9a206fe`, dated 2026-08-30,
whose message is *"migrate slice 1: move the source, rename the language,
compile nothing"*, confirmed by `git log --diff-filter=A`. It holds 40
`(sys-row ...)` entries, of which seven carry `16` at `:30`, `:31`, `:32`,
`:33`, `:34`, `:35` and `:60`, and `:30`, `:31` and `:32` carry no comment.
Against that, the mechanism is live: `ck-tiprog` is called at
`lib/lowering/compile-emit.chiral:296` from `emit-elf-m`, which
`lib/lowering/compile-all.chiral:34` reaches on the shipping compile, and the
gate runs a positive control plus four poison mutants at
`tools/test/syscall-manifest.sh:111-121`. **So `SC1`'s state is `built` because
the element is built, and requirements 1 and 2 record what the build does not
deliver.** This session ran no phase of `tools/test/run-tests.sh`.
