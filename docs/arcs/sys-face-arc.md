---
node: arc-sys-face
layer: navigation
related: [arcs/README, goals/self-hosting, arcs/syscall-custody-arc, arcs/terminal-arc, arcs/tool-authority-arc, arcs/native-window-arc, arcs/zero-python-arc, banks/port, banks/capability, banks/module, status-ledger, bug-classes, decisions/decision-b-in-type, decisions/decision-scope, decisions/decision-work-ids, elements/catalog, records/homing-triage, records/lenses/problems, records/author-calls, index]
status: current
updated: 2026-09-17
---

# Arc: sys-face

- goals: [[goals/self-hosting]], condition 5: "Every built element of the
  compiler holds a roster row in an arc." The same goal's condition 4 is
  served by requirements 2 and 3 below, which state over this arc's own code
  the reach and assertion the condition names.
  `docs/goals/self-hosting.md:102-107` is the table that names this arc as one
  of four subject arcs, opened 2026-09-17, and `:92-100` gives it both
  conditions in one sentence: each "rosters the elements of that subject that
  no other arc rosters, and states over the same code the reach and assertion
  requirements condition 4 names". No second goal is served.
- reserved element block: **none**. Every homeable row carries an element minted
  long before this file, and the arc-local ids per [[decisions/decision-work-ids]]
  spell the letters `SF`, for sys-face: `sys-face/SF1` upward. A grep for `SF`
  followed by a digit over `docs/`, `records/` and `.planning/` returns one hit,
  `OSF1` inside a pinned external source at `.planning/sources/TILPLDI.txt:846`,
  and no row id, verified 2026-09-17. The two-letter form follows
  `syscall-custody`'s `SC` and `tool-authority`'s `TA`.
- build-state authority: [[status-ledger]]
- checklist: [[records/sys-face]], prefix `SF`.
- neighbour: [[arcs/syscall-custody-arc]], stated in full under *What this arc
  does not take*. That arc owns the permitted set and its custody. This arc owns
  the crossings the set governs.

## Why this arc exists

Condition 5 is the homing invariant [[goals/README]] states at `:27`, and the
SYS category is where it fails hardest. Measured 2026-09-17 against the working
tree: `docs/elements/ledger.md` §SYS holds 27 rows, seven of them already
rostered by [[arcs/syscall-custody-arc]], [[arcs/zero-python-arc]] and
[[arcs/native-window-arc]], and **twenty hold no roster row anywhere**. One of
the twenty, `E86`, is `superseded` and exempt from homing by the author's ruling
of 2026-09-13, which leaves nineteen. They are the crossings themselves: the
mmap family, sockets and socketpair, fd passing, poll, clock and exit, the
sys-face linkage, tty and termios, pty acquisition and hygiene, fd adoption and
close, and filesystem mutation.

Condition 4 reads the same claim over the compiler's parts. Its failure shape is
`docs/definitions/bug-classes.md:171-173`: a rule can be written, compile
cleanly, pass the suite, get marked built in the catalog, then run on no path.
This subject is the worked case. All ten files of `lib/ports/` sit inside the
compiler's import closure, so condition 4(a) holds here; condition 4(b) does
not, and the measurement below is that **no `tools/test/*.sh` script names any
of the nineteen, and eighteen sample roots written for nine of them are
dispatched by nothing**.

## What the tree already holds

Measured 2026-09-17 against the working tree. [[banks/INDEX]] holds thirteen and
three own this territory. [[banks/port]] Shard 2 places the syscall behind an
extern whose contract is chirality's and whose referent is bound at load
(`docs/banks/port.md:116-120`). [[banks/capability]] holds the four grant
operations. [[banks/module]] §1 holds the coordinate three axes this arc's
group G5 turns on. None is re-derived below.

| group | what exists today | where | rung |
|---|---|---|---|
| G1 the floor | 63 TAL crossing bodies, named by `ti-fn`, folded into `sys-lib` | `lib/lowering/tal/sys.chiral`, 1343 lines | ENFORCED |
| G1 | 40 registered syscall numbers, one `(sys-row ...)` each, default-deny by absence over the whole emitted image | `lib/lowering/tal/target-linux.manifest`, rule at `lib/lowering/tal/sys-check.chiral:21` | ENFORCED |
| G1 | ⚑ **`nb-sys-munmap` is registered and reachable from no extern.** Its body is `lib/lowering/tal/sys.chiral:106`, its number 11 is `target-linux.manifest:29`, and its only caller is inside another TAL body, `nb-pool-close` at `sys.chiral:1139`. No sheet declares `munmap` and no routing row names it, while `docs/elements/catalog.md:143` states E28 as four crossings "all live ... with rows in `lib/lowering/tal/crossing-wraps.chiral`" | `lib/lowering/tal/sys.chiral:106`, `:1139` | ENFORCED as a helper |
| G1 | the clock floor, built and bound to nothing: `nb-sys-clock-gettime` (nr 228) and `nb-sys-nanosleep` (nr 35), both folded into the crossing library `sys-lib` (`lib/lowering/tal/sys.chiral:1308`) at `:1339` | `lib/lowering/tal/sys.chiral:217`, `:226`, `target-linux.manifest:39`, `:42` | IMPLEMENTED |
| G1 | the fd-passing floor, built and bound to nothing: `nb-sys-send-fd`, consed at `:1338`, permitted at `target-linux.manifest:40` | `lib/lowering/tal/sys.chiral:366` | IMPLEMENTED |
| G1 | nothing for filesystem mutation. `unlink`, `rename` and `mkdir` have no TAL body, no registered number and no extern | measured 2026-09-17 | absent |
| G2 the sheets | nine `.port` registries declaring **51 externs and 8 porttypes** between them, each with a header stating why its crossings live together | `lib/ports/clock.port`, `fd.port`, `file.port`, `pool.port`, `process.port`, `pty.port`, `sock.port`, `stdio.port`, `tty.port` | IMPLEMENTED |
| G2 | all ten files of `lib/ports/` sit inside the compiler's import closure, which is 62 import targets resolved from `prog/compiler.prog` over `lib:prog` | measured 2026-09-17, method at `docs/goals/self-hosting.md:179-182` | ENFORCED |
| G2 | `nb-read-key` is a real raw read: allocate one byte, take its pointer, `read(0, ptr, 1)`, branch on the return. ⚑ `docs/elements/catalog.md:425` still states E98 as "Partially built" over stubs that "issue `read(fd,cell,0)` with NO bptr" | `lib/lowering/tal/sys.chiral:543-558` | IMPLEMENTED |
| G2 | the per-family ioctl surface allocates inside and returns a fresh cell: `nb-sys-tcgets` sets its 60-byte length as a slot, `ti-bnew`s the cell, passes its pointer. No generic `ioctl` extern survives anywhere in `lib/` or `prog/`. ⚑ `docs/elements/catalog.md:426` still states E99 as "Partially built" over "one generic 3-arg ioctl crossing" | `lib/lowering/tal/sys.chiral`, `nb-sys-tcgets-t` | IMPLEMENTED |
| G2 | `termios-set-raw` is the full `cfmakeraw` equivalent: all four flag words masked, `CS8` set, `VMIN=1` and `VTIME=0` written, a fresh cell at every step. ⚑ `docs/elements/catalog.md:435` still states E103 as "Not built" and "clears only `c_lflag`" | `lib/protocol/term.chiral:97-108` | IMPLEMENTED |
| G3 the linkage | the routing table: 44 rows binding a bound crossing to its E51 wrapper, read by erase at `erase.chiral:216` and by the profile gate at `compile-emit.chiral:226` | `lib/lowering/tal/crossing-wraps.chiral:13-57` | ENFORCED |
| G3 | `sys-bindings` is DERIVED from that one table, so the two-authority drift its header warns about cannot happen | `lib/lowering/tal/sys-linkage.chiral:87`, `:93` | ENFORCED |
| G3 | ⚑ **the header stating that invariant names three artifacts that do not exist.** `crossing-wraps.chiral:8-10` reads "this must agree with lib/sys-linkage.chiral `sys-bindings` ... tests/test_effectful_lowering and test_e76 both load sys-linkage", and `:4` cites `native.py:294`. `ls tests` fails and `find . -name 'native.py'` returns nothing | `lib/lowering/tal/crossing-wraps.chiral:4`, `:8-10` | absent |
| G3 | ⚑ **12 of the 51 declared externs reach no lowering at all**: `time-mono`, `sleep-ms`, `env-open`, `env-view`, `env-close`, `poll2`, `adopt-pty`, `pty-read`, `pty-close`, `sock-listen`, `sock-accept`, `sock-send-fd`. A thirteenth, `adopt-fd`, lowers through the erase identity peel and is correct | measured 2026-09-17 over `lib/ports/*.port` against `crossing-wraps.chiral` and `erase.chiral:119` | SEEDED |
| G3 | what an unlowered crossing does at emit: the lookup misses, the instruction falls through to `erase-prim`, and `prim2lib` refuses with "prim not in native subset: <op>". The failure is loud | `lib/lowering/tal/erase.chiral:216-223`, `:169` | ENFORCED |
| G3 | what it does at the profile gate: `ports->wrappers` drops it. The code states the consequence in its own words at `:220-221`, "A port with no crossing-wraps row names no wrapper and so permits nothing -- silently" | `lib/lowering/compile-emit.chiral:220-226` | ENFORCED |
| G4 the lifecycle | the `Fd` carrier is closed end to end: `adopt-fd` mints through the identity peel, `fd-close` releases through `nb-sys-close`, and both lower | `lib/ports/fd.port:32`, `:22`, `lib/lowering/tal/erase.chiral:120`, `crossing-wraps.chiral:44` | ENFORCED |
| G4 | the `Sock` and `LSock` carriers close: `sock-close` and `lsock-close` both route to `nb-sys-close` | `lib/lowering/tal/crossing-wraps.chiral:42-43` | ENFORCED |
| G4 | ⚑ **the `Pty` carrier is open at both ends.** `adopt-pty` and `pty-close` are declared at `lib/ports/pty.port` and neither lowers, while `lib/capability/session.chiral:46` mints through the first and `:54-55` releases through the second | `lib/ports/pty.port`, `lib/capability/session.chiral:21` | SEEDED |
| G4 | `O_CLOEXEC` is set at open, in the stronger of E110's two offered forms: `nb-sys-open-rw-t` hardcodes `O_RDWR` plus `O_NOCTTY` plus `O_CLOEXEC` as `0x80102` | `lib/lowering/tal/sys.chiral:654`, `:658`, reason at `:651-653` | IMPLEMENTED |
| G4 | the readback that would prove it: `fd-cloexec?` over the `fcntl` crossing with `F_GETFD` | `lib/protocol/term.chiral:185`, `:188`, crossing at `crossing-wraps.chiral:45` | IMPLEMENTED |
| G5 the coordinate | the supervisor exists and says what importing it means: `(module ports/ports (cat C) (alt upper))`, with the header at `:54` reading "importing this module names the category C floor" | `lib/ports/ports.chiral:55` | IMPLEMENTED |
| G5 | ⚑ **nothing declares itself supervised.** `grep -c '(module ' lib/ports/*.port` returns zero for all nine sheets, so the quarantine [[decisions/decision-b-in-type]] puts on the signature at `:29` binds nothing across the crossing surface. The tree holds one `(cat B)` declaration in total, and it is the lowering backend | `lib/lowering/tal/target-linux.manifest:18`, measurement at `records/lenses/problems.md` PRB-94 | absent |
| G5 | the scale: 14 of `lib/`'s 95 `.chiral` modules open a coordinate at line start, and the nine sheets add none | PRB-94 `evidence:` | absent |
| G5 | the mechanism both halves are built: `E160` is the coordinate as a checked declaration, `E161` the datasheet that made its extent declared. ⚑ **`E161`'s gate does not run.** `tools/test/run-tests.sh:18` and `:409` print Phase 8 as NOT PORTED, 808 lines of fixtures stranded on old-tree module keys | `docs/elements/ledger.md:305-306`, `tools/test/run-tests.sh:409` | built, ungated |
| G6 the gate | the one crossing family a phase asserts: Phase 20 runs `prog/samples/e131_sse_socketpair.prog`, which reaches `socketpair`, `sock-send` and `sock-close`, and asserts exit 0. Its closed-port row asserts the `conn-err` arm of `sock-connect-in` | `tools/test/transport.sh:164-171`, dispatched at `tools/test/run-tests.sh:326` | ENFORCED |
| G6 | ⚑ **not one of the nineteen is named by any phase script.** `grep -rl 'e<N>_' tools/test/*.sh` returns nothing for every one of E28, E29, E30, E31, E32, E51, E98, E99, E103, E104, E107, E110, E121, E124, E125, E126, E127, E129 and E149 | measured 2026-09-17 | absent |
| G6 | ⚑ **eighteen sample roots exist for nine of them and no phase dispatches one.** Fourteen sit under `prog/samples/` and four under `tools/test/samples/`. Phase 7's selector is `grep -rl '^(def compile-main' lib prog`, so the four under `tools/` are outside it entirely, and its own `*_reject_*` skip at `tools/test/run-tests.sh:179` drops five more | `tools/test/run-tests.sh:175`, `:178`, `:423` | absent |
| G6 | what Phase 7 buys where it does reach: "compile-only: N roots built, N failed -- gates, but asserts nothing" | `tools/test/run-tests.sh:423` | ENFORCED |
| G6 | the terminal lane's own measurement of the same hole, recorded before this arc: no phase of `run-tests.sh` executes a tty or pty root. Re-measured here as `grep` over `tools/test/*.sh` for `tty`, `pty` and `termios`, whose every hit is `pretty.sh` or the word empty | [[arcs/terminal-arc]], re-measured 2026-09-17 | absent |

Four facts from that table govern the roster. **The floor is built**, so no row
here writes a TAL body from nothing except `SF19`. **The join is where the work
is**: twelve declared crossings reach no routing row and two built floors reach
no extern. **The state claims have drifted**, four of them measurably, and a
`built` cell is the pipeline's authority. **Nothing asserts any of it**, which
is condition 4(b) stated over this subject.

## What is missing, and its structure

| group | owns |
|---|---|
| G1 the floor | a TAL body and a registered number for every crossing the tree's own code needs. Almost all of it exists. What is absent is filesystem mutation, and what is stranded is a registered number no surface reaches |
| G2 the sheets | the declared surface: 51 externs over nine registries, each a typed contract whose referent the kernel supplies. What fails is the record of what they are, where four catalog cells describe code that has moved past them |
| G3 the linkage | the one table that binds a declared crossing to its wrapper. Twelve declarations miss it, and the header naming its authority cites three artifacts that do not exist |
| G4 the lifecycle | mint, thread, release, each lowering, for every carrier the sheets declare. `Fd`, `Sock` and `LSock` close. `Pty` is open at both ends |
| G5 the coordinate | a declaration on each sheet placing it on [[banks/module]]'s three axes, so the B quarantine binds something. The mechanism is built and its gate does not run |
| G6 the gate | a phase that runs a crossing root and judges what comes back. Eighteen roots wait for one |

### The edges that run against the order

| edge | direction | what crosses |
|---|---|---|
| G6 to everything | against, and the loudest | G6 reads as last and is first. `docs/definitions/bug-classes.md:171-173` names the class: a rule marked built in the catalog that runs on no path. Every group above already ships elements in that class, and four of this arc's own state claims drifted undetected because nothing executes them. Building further down the order adds to the unasserted set before it subtracts from it |
| G2 to G1 | against | several sheet externs have their floor built and bound to nothing: `time-mono` and `sleep-ms` over `nb-sys-clock-gettime` and `nb-sys-nanosleep`, `sock-send-fd` over `nb-sys-send-fd`. Reading G1 first as a build order sends a session to write TAL bodies that are already in `sys-lib` |
| G5 to G2 | against | the coordinate's letter is the judgment "what does this module's correctness rest on", and `docs/decisions/decision-b-in-type.md:32-33` makes a category B module one "whose signature names its untyped referent and routes it through a category C supervisor". Declaring a sheet B may therefore change its signature, which is G2's own surface. Declaring last is the dependency order; declaring first is what stops the surface being written twice |
| G4 to G3 | against | the `Pty` lifecycle's whole residue is two missing routing rows. A lifecycle question answered in the linkage table cannot close while G3 is open, so G4 sitting after G3 is the dependency and G4 has no independent work until it lands |
| G5 to G6 | out of this arc's reach | the coordinate's own gate is Phase 8, NOT PORTED. Adopting the mechanism on nine sheets is observable only through a check that does not run, so `SF20` buys an unobserved declaration until whoever owns `E161` ports the phase. That owner is owed and this arc does not name it |

## REQUIREMENTS

Six, each with the observation beside it, measured 2026-09-17.

1. **The declared crossing surface and the lowered one are the same set.**
   Observed as every `(extern ...)` on the nine `.port` sheets holding a
   `crossing-wraps` row or a named erase peel, and every `(sys-row ...)` number
   being reachable from some extern. Today 12 of 51 externs hold neither, and
   `nb-sys-munmap` is registered at `lib/lowering/tal/target-linux.manifest:29`
   and reached only from inside `nb-pool-close`.

2. **Every state claim over a crossing element names code that says what the
   claim says.** Observed by opening each cited span and reading it. Today four
   fail: `docs/elements/catalog.md:143` claims a `crossing-wraps` row for
   `munmap` and there is none, and `:425`, `:426` and `:435` describe E98, E99
   and E103 as partial or unbuilt against code measured above as built. This is
   the class [[records/findings]] FD-27 states and `E76` worked.

3. **A phase runs a crossing root and asserts what comes back.** Observed as a
   root's basename appearing in some `tools/test/*.sh` script, which is goal
   condition 4(b)'s own observation. Today no phase script names any of the
   nineteen, eighteen sample roots are dispatched by nothing, and the one
   crossing family under assertion is reached through roots named for `E130` and
   `E131`.

4. **Every crossing module declares its module coordinate.** Observed as
   `grep -c '(module ' lib/ports/*.port` returning nonzero for all nine. Today it
   returns nine zeros against the supervisor at `lib/ports/ports.chiral:55`, so
   the quarantine `docs/decisions/decision-b-in-type.md:29` puts on the signature
   binds nothing. `records/lenses/problems.md` PRB-94 is the measurement.

5. **Every carrier the sheets declare closes: a mint and a release, both
   lowering.** Observed as each `(porttype ...)` on the nine sheets having both
   ends in `crossing-wraps.chiral` or in the erase peel table. Today `Fd`, `Sock`
   and `LSock` close and `Pty` does not, while `lib/capability/session.chiral:46`
   and `:54-55` call both of its open ends.

6. **No crossing the tree's own code needs is undeclared.** Observed as no
   `declare`-only stub standing where a crossing belongs. Today
   `prog/scriba/flook.chiral:43-44` declares `flook-do-delete` and
   `flook-do-rename`, calls them at `:157` and `:192`, and no `def` for either
   exists; `unlink`, `rename` and `mkdir` are absent at every layer; and
   `docs/elements/catalog.md:144` records that there is no `bind` extern at all.

## Roster

Twenty rows. Nineteen carry an element minted long before this file and homed by
no roster until now, and one carries a lens row. Ids spell `SF`. **This arc
mints nothing and allocates no number.**

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `sys-face/SF1` | the linkage is the whole join and twelve declarations miss it. `crossing-wraps.chiral:13-57` holds 44 routing rows, `sys-bindings` is derived from it at `sys-linkage.chiral:93`, and both consumers read it: erase at `erase.chiral:216`, the profile gate at `compile-emit.chiral:226`. **Wanted when the row is taken up**: a routing row or a stated refusal for each of the twelve, and the header's dead citations retired. **Blocking condition**: none measured. The twelve split into three causes and each is separately decidable | G3 | law | bind | 1, 2 | built | `E51` |
| `sys-face/SF2` | the mmap family's fourth crossing has a number and no surface. `mmap` and `mprotect` are externs at `lib/ports/process.port:16-17` with routing rows; `close` reaches the surface as `fd-close`, `sock-close` and `lsock-close` at `crossing-wraps.chiral:42-44`; `munmap` has a body at `sys.chiral:106`, the number 11 at `target-linux.manifest:29`, and one caller inside `nb-pool-close`. **Wanted**: either a declared `munmap` crossing or the catalog cell saying what the fourth name means. **Blocking condition**: none measured | G1 | port | bind | 1, 2 | built | `E28` |
| `sys-face/SF3` | poll has two shapes and one lowers. `nb-poll` routes to `nb-sys-poll` at `crossing-wraps.chiral:24`; `poll2`, the two-descriptor form `prog/demo/node-render.chiral:43` and `prog/demo/tomodachi.chiral:59` call, routes to nothing. `lib/runtime/poll.chiral` is 92 lines with six importers and sits outside the compiler's import closure. **Wanted**: the `poll2` row, or the two callers moved onto `nb-poll`. **Blocking condition**: none measured | G3 | port | connect | 1, 3 | built | `E31` |
| `sys-face/SF4` | time and environment: five externs, zero lowered, two floors already built. `nb-sys-clock-gettime` (nr 228) and `nb-sys-nanosleep` (nr 35) are folded into `sys-lib` (`lib/lowering/tal/sys.chiral:1308`) at `:1339` and bound by no routing row, so `time-mono` and `sleep-ms` are a join. `env-open`, `env-view` and `env-close` have no floor, E98 having retired the `nb-sys-env-get` stub. `exit` is the one member of this element that lowers, and it lives on `process.port`. **Wanted**: two routing rows and a decision on what backs the environment. **Blocking condition**: none measured | G1 | port | connect | 1 | built | `E32` |
| `sys-face/SF5` | the socket registry's server half is declared and reaches nothing. `sock-listen` and `sock-accept` are externs on `lib/ports/sock.port` with no routing row and no TAL body, and there is no `bind` extern anywhere. `docs/elements/catalog.md:144` states it: "The CPython transport that used to supply the server half is evicted, so it has no implementation anywhere now", against a ledger cell reading `built`. **Wanted**: the three crossings, or the cell saying which half is built. **Blocking condition**: none measured. [[arcs/native-window-arc]] proposes a `W7` for the same three and rosters none today | G1 | port | new | 1, 6 | built | `E29` |
| `sys-face/SF6` | fd passing is built at the floor and bound to nothing. The `sendmsg` plus `SCM_RIGHTS` body is `lib/lowering/tal/sys.chiral:366`, folded into `sys-lib` (`lib/lowering/tal/sys.chiral:1308`) at `:1338` and permitted at `target-linux.manifest:40`; `sock-send-fd` on `lib/ports/sock.port` has no routing row. **This row homes the element and claims no build.** The one routing line is claimed twice already, by `tool-authority/TA5` requirement 3 and by `native-window/W5` through `E199`, and the author call over which arc owns the crossing is open. **Blocking condition**: that call, carried verbatim under FLAGs | G1 | port | connect | 1 | built | `E30` |
| `sys-face/SF7` | the honest crossing table, and the record that says it is not. `nb-read-key` allocates one byte, takes its pointer and issues `read(0, ptr, 1)` at `sys.chiral:543-558`, which is the real raw read the element asked for; `docs/elements/catalog.md:425` still describes the stub it replaced. **Wanted**: the cell re-measured, and a phase that runs a key read. **Blocking condition**: requirement 3 for the second half. The first half is a record repair and this run edits no catalog | G2 | port | bind | 2, 3 | built | `E98` |
| `sys-face/SF8` | the per-family ioctl surface, and the record that says it is generic. `nb-sys-tcgets` sets its 60-byte length as a slot, `ti-bnew`s the cell and passes the pointer, which is alloc-inside; no generic `ioctl` extern exists in `lib/` or `prog/`; `E86`, the generic crossing, is `superseded` and exempt from homing. `docs/elements/catalog.md:426` still reads "Partially built". **Wanted**: the cell re-measured, and an assertion over one ioctl family. **Blocking condition**: requirement 3 for the second half | G2 | port | bind | 2, 3 | built | `E99` |
| `sys-face/SF9` | raw-mode fidelity, built and unrun. `termios-set-raw` at `lib/protocol/term.chiral:101-108` masks all four flag words, ORs `CS8` and writes `VMIN=1`/`VTIME=0`, returning a fresh cell at every step; `docs/elements/catalog.md:435` reads "Not built" and "clears only `c_lflag`". Two roots exist, `prog/samples/e103_termios_raw.prog` and `e103_pty_roundtrip.prog`, and no phase names either. **Wanted**: the pure mask assertion, which needs no tty, and the cell re-measured. **Blocking condition**: none measured. The mask leg is assertable today | G2 | port | bind | 2, 3 | built | `E103` |
| `sys-face/SF10` | pty acquisition, built and unrun. The `/dev/ptmx` path is `lib/protocol/term.chiral:129` onward over `nb-ptsno-raw` and `nb-ptunlock`, both routed at `crossing-wraps.chiral:32-33`. Its root is `tools/test/samples/e104_pty.prog`, which Phase 7's selector cannot see: that selector greps `lib prog` at `tools/test/run-tests.sh:175` and the file is under `tools/`. **Wanted**: a phase that acquires a pair and judges the result. **Blocking condition**: none measured for the acquisition leg | G2 | port | connect | 3 | built | `E104` |
| `sys-face/SF11` | the close family, with the `Pty` end still open. Five releases lower: `fd-close`, `sock-close` and `lsock-close` at `crossing-wraps.chiral:42-44`, `pool-close` at `:53`. `pty-close` is declared `(=> (1 p Pty) Unit)` on `lib/ports/pty.port`, has no routing row, and `lib/capability/session.chiral:54-55` calls it twice. The element's own ledger row at `docs/elements/ledger.md:204` already carries the residue as owed. **Wanted**: the `pty-close` binding, a stopgap over raw `close` or a true porttype-taking close. **Blocking condition**: none measured. `SF1` is the same work counted once | G4 | port | connect | 1, 5 | built | `E107` |
| `sys-face/SF12` | close-on-exec hygiene, set at open and asserted by nothing. `nb-sys-open-rw-t` hardcodes `O_RDWR` plus `O_NOCTTY` plus `O_CLOEXEC` as `0x80102` at `lib/lowering/tal/sys.chiral:658`, its comment at `:651-653` giving this element's reason in this element's words. Its root is `tools/test/samples/e110_cloexec_pty.prog`, outside Phase 7's selector and named by no phase. **Wanted**: the phase. **Blocking condition**: `SF13`, which supplies the readback the assertion reads | G4 | port | bind | 3 | built | `E110` |
| `sys-face/SF13` | the readback that would make `SF12` conclusive. The `fcntl` crossing is declared at `lib/ports/fd.port:36`, routed at `crossing-wraps.chiral:45` over `nb-sys-fcntl-t` at `sys.chiral:208`, numbered 72 at `target-linux.manifest:25`, and `fd-cloexec?` at `lib/protocol/term.chiral:188` reads `F_GETFD`. Its root is `tools/test/samples/e121_fcntl.prog`, carrying both legs, and `docs/elements/catalog.md:450` already records that no phase dispatches it. **Wanted**: the phase. **Blocking condition**: none measured | G4 | port | bind | 3 | built | `E121` |
| `sys-face/SF14` | fd adoption, the cheapest cap producer, with three of its four roots unreachable by any phase. `adopt-fd` is declared `(=> I64 Fd)` at `lib/ports/fd.port:32` and lowers through the identity peel at `lib/lowering/tal/erase.chiral:120`, which is the runtime no-op `E123`'s carrier predicted. Four roots exist; `e124_reject_double_close`, `e124_reject_drop` and `e124_reject_use_after_move` are skipped by Phase 7's own `*_reject_*` branch at `tools/test/run-tests.sh:179`, and `e124_adopt_roundtrip` is compiled there and asserted nowhere. **Wanted**: a phase that runs the round trip and judges the three refusals. **Blocking condition**: none measured | G4 | port | bind | 3, 5 | built | `E124` |
| `sys-face/SF15` | socket use, reached by an assertion that names another element. `sock-send` and `sock-recv` route at `crossing-wraps.chiral:37-38` over bodies in `sys.chiral`, and `SendR`/`RecvR` live on `lib/ports/sock.port`. Phase 20 reaches both through `prog/samples/e131_sse_socketpair.prog:19`, so the crossing is exercised and this element's name appears in no phase. Its own two roots, `e125_send_recv_roundtrip.prog` and `tools/test/samples/e125_sock_roundtrip.prog`, are dispatched by nothing. **Wanted**: the assertion carrying this element's name. **Blocking condition**: none measured | G2 | port | bind | 3 | built | `E125` |
| `sys-face/SF16` | the hermetic socket pair, same shape. `socketpair` routes at `crossing-wraps.chiral:39` over `nb-sys-socketpair`, nr 53, and Phase 20 reaches it at `tools/test/transport.sh:170` through `E131`'s root. Its own three roots, one drain and two refusals, are dispatched by nothing, and the two refusals fall under Phase 7's `*_reject_*` skip. The `sv-drain` milestone this element was minted against lives in `lib/capability/lincoll.chiral`. **Wanted**: the drain milestone asserted under this element's name. **Blocking condition**: none measured | G2 | port | bind | 3 | built | `E126` |
| `sys-face/SF17` | AF_UNIX client acquisition. `sock-connect` routes at `crossing-wraps.chiral:40` over `nb-sock-connect`, which fuses `socket` and `connect` and packs the `sockaddr_un`. Its one root, `prog/samples/e127_sock_connect_err.prog`, is named by no phase; the element's ledger row calls it DEFERRED as needing a live peer, and the error arm needs none. **Wanted**: the error-arm assertion, which is hermetic. **Blocking condition**: none measured for the error arm. The success arm needs a peer and that is the element's own stated deferral | G2 | port | bind | 3 | built | `E127` |
| `sys-face/SF18` | AF_INET client acquisition, the one crossing of the nineteen at ENFORCED. `sock-connect-in` routes at `crossing-wraps.chiral:41`, `lib/protocol/inet.chiral:2` owns it and seven modules import that, and Phase 20 asserts the `conn-err` arm against a closed port at `tools/test/transport.sh:167`. Its own three roots, `e129_parse_quad`, `e129_pack_sa_in` and `e129_sock_connect_in_refused`, are dispatched by nothing, and the two pure ones assert pure functions that need no network. **Wanted**: the two pure roots under a phase. **Blocking condition**: none measured | G2 | port | bind | 3 | built | `E129` |
| `sys-face/SF19` | filesystem mutation: `unlink`, `rename` and `mkdir`, absent at every layer. No TAL body, no registered number, no extern. `prog/scriba/flook.chiral:43-44` declares `flook-do-delete` and `flook-do-rename`, calls them at `:157` and `:192`, and defines neither. Split from `E148`'s read half on purpose, write authority being its own grant. **Wanted when the row is taken up**: the three crossings and their typed result sums. **Blocking condition**: none measured. [[arcs/zero-python-arc]] rosters the read half at `Z2` and does not roster this; `docs/arcs/tool-authority-arc.md:274` declines it to [[goals/coding-agent]] condition 3, which holds no arc. ⚑ The straddle `records/homing-triage.md:299-301` records, and `records/lenses/unspoken.md` UNS-39, are carried under FLAGs | G1 | port | new | 6 | open | `E149` |
| `sys-face/SF20` | the nine sheets declare their module coordinate, so the B quarantine binds something. `lib/ports/ports.chiral:55` declares the supervisor and `grep -c '(module ' lib/ports/*.port` returns nine zeros. The mechanism is built at both halves, `E160` the checked declaration and `E161` the datasheet, and **this arc rosters neither**: they are the module tier and `records/homing-triage.md:215-216` proposes [[arcs/bridge-arc]] for one and an open call between [[arcs/module-split-arc]] and [[arcs/file-types-arc]] for the other. `bridge/C3` covers the modules that state a category in prose; the nine sheets state none, so the letter is the question. **Wanted**: a coordinate on each sheet, and the owner of `E161`'s NOT PORTED Phase 8 named. **Blocking condition**: the placement author call, carried verbatim under FLAGs. `records/lenses/problems.md` PRB-94 is this row's measurement and names it as owner | G5 | decision | bind | 4 | open | `unminted` |

### Coverage

Run 2026-09-17 against the table above.

- **Every requirement is served.** 1 by `SF1`, `SF2`, `SF3`, `SF4`, `SF5`, `SF6`
  and `SF11`; 2 by `SF1`, `SF2`, `SF7`, `SF8` and `SF9`; 3 by `SF3`, `SF7`,
  `SF8`, `SF9`, `SF10`, `SF12`, `SF13`, `SF14`, `SF15`, `SF16`, `SF17` and
  `SF18`; 4 by `SF20`; 5 by `SF11` and `SF14`; 6 by `SF5` and `SF19`. No
  requirement is unscheduled.
- **Every row serves a requirement.** All twenty name at least one. No row is out
  of scope.
- **Eighteen rows are `built` and the requirements they serve are unmet, which is
  this arc's premise.** The state column is the pipeline's authority for a row,
  the elements are built, and what the rows carry is the residue: a join not
  made, a record that drifted, a gate that never ran. Goal condition 4 is exactly
  the requirement that a built rule run on a path something asserts.
- **Every `origin` is defensible from the measurement.**
  - `SF1`, `SF3`, `SF4`, `SF6` and `SF11` are `connect` or `bind` because both
    halves exist and the routing row between them does not: two clock floors in
    `sys-lib` (`lib/lowering/tal/sys.chiral:1308`) at `:1339`, a `sendmsg` body at `:366`, a `pty-close`
    declaration on `lib/ports/pty.port`, a `poll2` call at
    `prog/demo/node-render.chiral:43`.
  - `SF2`, `SF7`, `SF8`, `SF9`, `SF12`, `SF13`, `SF14`, `SF15`, `SF16`, `SF17`
    and `SF18` are `bind` because the code is built and what is absent is a
    surface onto it: a record that matches, or a phase that runs it. Each names
    the span measured.
  - `SF5` and `SF19` are `new` because a grep returns nothing: no `bind` extern
    anywhere for the socket server half, and no body, number or extern for
    `unlink`, `rename` or `mkdir`.
  - `SF10` is `connect` because the acquisition path is built at
    `lib/protocol/term.chiral:129` and its root sits where Phase 7's selector
    cannot see it.
  - `SF20` is `bind` because `E160` and `E161` are both `built` and the nine
    sheets carry no declaration, which is adoption of a mechanism rather than a
    mechanism.

## What this arc does not take

- **The permitted set and its custody.** [[arcs/syscall-custody-arc]] owns
  `E76`, `E77`, `E78`, `E162` and `E164`: the chokepoint registry, the rung-1
  seccomp filter, per-component attenuation, who may widen the set, and the
  ergonomics that would make a program declare its port set. **The boundary is
  the direction the two read `lib/lowering/tal/target-linux.manifest`.** That arc
  reads it as a policy artifact and asks who may change it. This arc reads it as
  a registry and asks whether each row is reachable from a declared crossing, in
  both directions: `SF2` is a registered number no surface reaches, and `SF19` is
  a needed crossing no row registers. Neither arc's requirements touch the
  other's file. That arc's six requirements reach row distinguishability, E76's
  cited artifacts, per-component granularity, a kernel filter, attribution for a
  widening, and the cost of declaring a profile. None reaches a sheet extern, a
  routing row, a carrier lifecycle, a module coordinate or a test phase. **No row
  of that arc is edited by this run.**
- **The terminal as a surface.** [[arcs/terminal-arc]] owns `TM1` through `TM9`:
  the APC handshake, the line discipline as a negotiation, the emulator, and
  which category C supervisor the terminal's B referents route through. This arc
  owns the crossings underneath: `tty.port`'s five ioctl and key externs and
  `pty.port`'s nine. The two meet at `TM9`, and `SF20` does not answer it. That
  arc reads the coordinate question over one facility with two referents; `SF20`
  reads it over all nine sheets, seven of which the terminal does not touch.
- **The fd-passing routing row.** `tool-authority/TA5` takes it under
  requirement 3 and `native-window/W5` takes it as `E199`, with the author call
  over which arc owns the crossing open since 2026-09-06. `SF6` homes the element
  and takes neither the row nor the build.
- **The `sock-send-fd` receive half.** `docs/arcs/native-window-arc.md:103`
  measured it: no `recvmsg` row and no receive-fd extern, so the round trip
  `docs/examples/E30-fd-passing.md:207-209` describes is unreachable, and that
  arc's gate ships with the ceiling stated. This arc adds no row for it.
- **Path naming and the inheritance flag word.** [[arcs/tool-authority-arc]] owns
  both, plus the constructed child and the ask as a value. `file.port`'s two
  `openat` crossings are this arc's; what a path may name is that arc's.
- **The read half of the filesystem.** [[arcs/zero-python-arc]] rosters `E148` at
  `Z2`, `E150` at `Z3`, `E33` at `Z4` and `E105` at `Z5`, and rosters `E149`
  nowhere, verified 2026-09-17. `SF19` takes the mutation half and adds no row to
  that arc.
- **The module coordinate mechanism.** `E160` and `E161` are `built` and this arc
  rosters neither, for a stated reason: they are the module tier and this arc is
  the crossing surface. `records/homing-triage.md:215` proposes
  [[arcs/bridge-arc]] for `E160` as `clear`, naming row `C3`, and `:216` records
  `E161` as an open call between [[arcs/module-split-arc]] and
  [[arcs/file-types-arc]]. `SF20` adopts the mechanism over this arc's nine
  sheets and claims no ownership of it.
- **Repairing the catalog and the ledger.** Requirement 2 is what `SF2`, `SF7`,
  `SF8` and `SF9` buy, and this run edits neither file.
- **Porting Phase 8.** `E161`'s gate is NOT PORTED at `tools/test/run-tests.sh:409`
  with 808 lines of fixtures stranded. It belongs to whoever owns `E161`, and
  this arc names it as owed.

## FLAGs

⚑ **Author call, verbatim, `records/author-calls.md:372`, `unreviewed`, opened
2026-09-15.** *"whether that repair is a `terminal/TM9` row, a port-tier row of
its own, or belongs to an existing element. Placement decides which arc carries
the work and which requirement it serves, so a pass can measure the hole and
cannot schedule it"*. `SF20` is drawn while that call is out, following
[[arcs/syscall-custody-arc]]'s precedent for `SC2` and `SC3` and
[[arcs/tuning-arc]]'s before it. The row is carried as blocked on the call and
not as its answer. One measurement bears on it and is offered rather than
decided: `TM9` is scoped to the terminal's two referents, and seven of the nine
sheets carry no terminal facility, so an answer naming `TM9` covers `tty.port`
and `pty.port` and leaves `clock`, `fd`, `file`, `pool`, `process`, `sock` and
`stdio` unplaced. An answer naming an existing element or a different row retires
`SF20` rather than rewriting it.

⚑ **Author call, verbatim, `records/author-calls.md:368`, `ruled` 2026-09-10,
carried because it governs `SF19`'s state cell.** The author's words: the
deferral *"is just an implementation work defer. says literally nothing about
planning"*, with the instruction that each row record *"what is actually wanted
when the track begins, and what stays deferred, naming the real blocking
condition rather than a track"*. Every row above follows it. `E149` reads
`design` at `docs/elements/ledger.md:213`, and `SF19`'s state cell reads `open`
because the roster's closed state set holds no `design`, which `ledger-lint`
check AG enforces. The same mapping stands at `syscall-custody/SC3` for `E77`
and at `zero-python/Z2` for `E148`.

⚑ **`E149`'s home is a straddle the tree records as awaiting a ruling.**
`records/homing-triage.md:299-301` states it: `docs/arcs/tool-authority-arc.md:274`
routes the element to [[goals/coding-agent]] condition 3, a condition holding no
arc, while [[arcs/zero-python-arc]] rosters its read half `E148` at `Z2`. **This
run was told that the author routed it to `zero-python` on 2026-09-10 on the
reasoning that the arc rosters the syscall crossings, and no tracked document
carries that routing.** `grep -rn E149 records/ docs/` returns the triage row,
`UNS-39`, the catalog and ledger rows, and two arc mentions, and none of them is
a ruling. Verified 2026-09-17 that `zero-python` does not roster it: its nine
rows carry five elements, `E173`, `E148`, `E150`, `E33` and `E105`, and `E149`
appears in no element cell anywhere in `docs/arcs/`. `SF19` homes it here on
[[goals/self-hosting]] condition 5 and duplicates no row. If the author prefers
the `zero-python` seat, `SF19` retires and the element moves with its id
intact.

⚑ **`records/lenses/unspoken.md` UNS-39 admits `E149` as unhomed and stands at
`unreviewed`.** `SF19` gives it a home, so the row is owed a state change and a
`checked:` date. `owner:` on a lens row other than PRB-94 is outside this run's
write scope and the edit is owed.

⚑ **The author call over `E30`'s owning arc is open**, routed 2026-09-06 to
`native-window/W5` with the routing recorded as not a ruling
(`docs/arcs/tool-authority-arc.md:285-291`). `SF6` homes the element and takes
neither the routing row nor the build, so an answer on either side leaves it
standing.

⚑ **DISCHARGED 2026-09-18 at `749ce10`. This arc was unanchored on
`arc -> goal done-condition` and is anchored now.** The FLAG read that
`docs/goals/self-hosting.md` condition 5 declares itself unopened, which
`tools/lens/lens.py:254` treats as naming no arc whatever the body links, so
`lens.py chain` reported this file in that rung's uncovered set at 33 of 34. The
word is gone from the goal: a grep for it over `docs/goals/self-hosting.md`
returns nothing on 2026-09-18, condition 4 names this arc at `:63` and
condition 5 at `:77`, and the rung reads **37 of 37**. The `⚑` at
`docs/goals/self-hosting.md:124` stands, and `docs/goals/README.md:48` is owed.

⚑ **Four catalog state cells disagree with the code this arc measured**, listed
under requirement 2. `docs/elements/catalog.md:143` for `E28`'s `munmap`, `:425`
for `E98`, `:426` for `E99`, `:435` for `E103`. `ledger-lint` check AB pairs the
catalog's build column against the ledger's state column and reports zero issues,
so all four drifted in the direction AB cannot see: the catalog understating what
is built. Neither file is in this run's write scope.

⚑ **`E161`'s gate does not run and this arc does not own it.** Phase 8 prints
NOT PORTED at `tools/test/run-tests.sh:18` and `:409`, with 808 lines of fixtures
stranded on old-tree module keys. `SF20` adopts a mechanism whose only check is
that phase, so the adoption is unobservable until someone ports it. Whether that
belongs to [[arcs/module-split-arc]] or [[arcs/file-types-arc]] is the `E161`
homing call at `records/homing-triage.md:216`.

⚑ **Whether a design or a SPEC for an `OT` element counts as planning is an open
author call**, and no row above is `OT`. Every one of the nineteen reads `SH` in
`docs/elements/ledger.md` §SYS, verified 2026-09-17, so the call governs nothing
here. It is named because `tools/lens/lens.py` reports it as standing inside
rung 2 and a reader of this arc will meet it there.

## Resume state

Opened 2026-09-17 against [[goals/self-hosting]] condition 5, on the author's
approval with the instruction that it be "sliced well and fully covering the
thing its being created over". Twenty rows, six requirements, nothing designed.
Rows spell `SF`. Every element on the roster was minted before this file and this
run mints nothing.

**The census.** `docs/elements/ledger.md` §SYS holds 27 element rows. Seven
already hold a roster row: `E33`, `E105`, `E148` and `E150` in
[[arcs/zero-python-arc]], `E76` and `E77` in [[arcs/syscall-custody-arc]], `E199`
in [[arcs/native-window-arc]]. Twenty hold none. `E86` is `superseded` and exempt
by the author's ruling of 2026-09-13, which leaves the nineteen rostered above.
Eighteen read `built` and `E149` reads `design`, which `SF19` carries as `open`
for the reason under FLAGs.

**The row to take up first is `SF9`.** Its mask leg needs no tty, no pty and no
network: `termios-set-raw` is a pure function over a `Bytes` cell and
`prog/samples/e103_termios_raw.prog` already exists. It turns on no open call, it
is the cheapest member of requirement 3, and requirement 3 is the back-edge that
runs against the whole order. `SF13` is the second for the same reason, and
`SF12` is blocked behind it. `SF1` is the third: it is the single row that twelve
of this arc's measurements converge on, and `SF11`, `SF3`, `SF4` and `SF6` all
resolve inside it.

**What was measured before any row's state was written.** The lowering census is
re-runnable: for each `(extern <name>` on `lib/ports/*.port`, look `<name>` up in
`lib/lowering/tal/crossing-wraps.chiral` and then in
`lib/lowering/tal/erase.chiral`. It returns 38 routed, 1 peeled and 12 reaching
neither, over 51 declarations. The closure census resolves `(import "...")`
transitively from `prog/compiler.prog` over `lib:prog` across the three
extensions `MAP.md:20` names and returns 62 targets, all ten files of
`lib/ports/` among them. The gate census greps `tools/test/*.sh` for each
element's sample prefix and returns nothing for all nineteen, and greps the same
files for `tty`, `pty` and `termios`, whose every hit is the word empty or the
filename `pretty.sh`.
