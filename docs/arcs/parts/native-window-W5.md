---
row: native-window/W5
arc: native-window
title: "sock-send-fd lowers: a TAL wrapper joins the built `nb-sys-send-fd` floor crossing to the declared `SendFdR` port face, plus its `crossing-wraps` row"
kind: port
origin: connect
req: 1
status: draft
updated: 2026-09-15
---

# native-window/W5: `sock-send-fd` lowers

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** a chirality program that calls `sock-send-fd` compiles and emits,
  so a pool's backing memfd can reach a Wayland compositor over the client's
  `AF_UNIX` socket.
- **Serves:** requirement 1 of [[arcs/native-window-arc]], "A window opens on a
  stock compositor through xdg-shell, with the configure and ack dance honored,
  in the tree's own codec." Requirement 1 is the only requirement W5 touches.
  W1 through W4 sit above this crossing and none of them reaches a screen until
  it lowers.
- **Goal:** [[goals/native-stack]], condition 2, Screen.

## 2. What the tree holds

Measured in the working tree 2026-09-14 unless a line dates itself otherwise.

- **Bank:** [[banks/port]], the 547-line refraction of the concept this row is
  about. Its thesis applies here directly: a port is four things at once and the
  cardinal error is reading one absent shard as an absent subsystem. `banks/port`
  is the arc's named bank, and `banks/capability` carries the fd-passing
  crossing as a shard of *capability* too (`docs/banks/capability.md:216`,
  *"Home. local: kernel linearity (Move). Cross-node: the fd-passing crossing"*),
  since the linear `Fd` this crossing
  consumes is authority that the kernel physically moves. Three shards of
  `sock-send-fd` exist, and one does not.

| what exists | where | rung | reached by |
|---|---|---|---|
| the **port face**: `(extern sock-send-fd (=> (1 s Sock) Bytes (1 f Fd) SendFdR))` | `lib/ports/sock.port:68` | IMPLEMENTED (declared, type-checked) | `prog/demo/wl-client.chiral:201-202`; `chirality check prog/demo/tomodachi.chiral` returns `OK` |
| the **result sum** `SendFdR`, `sfd-ok (1 s Sock)` / `sfd-err (errno I64) (1 s Sock) (1 f Fd)`, with its own comment stating the custody law | `lib/ports/sock.port:47-52` | IMPLEMENTED | both arms cased at `prog/demo/wl-client.chiral:203` and `:206`, and QTT forces it |
| the **floor crossing** `nb-sys-send-fd-t`: `sendmsg(2)` + a `SCM_RIGHTS` cmsghdr, msghdr/cmsghdr/iovec built in byte cells at the ABI's offsets, all four cells `ti-bptr`'d before the one `ti-sys` | `lib/lowering/tal/sys.chiral:359-366` and after | **BUILT** | listed in `sys-lib` (`lib/lowering/tal/sys.chiral:1308`) at `:1338`, and present in the compiler blob at blob line 16061 of 17,797 |
| the **E76 chokepoint permit** for it, `nb-sys-send-fd -> 46` | `lib/lowering/tal/target-linux.manifest:40` | ENFORCED | `ck-tiprog linux-syscalls image` at `lib/lowering/compile-emit.chiral:296` |
| the **linear `Fd` cap** and its carrier, `Fd` in `porttype-word?` so it peels to `nt-i64` | `lib/ports/fd.port:16`; `lib/lowering/compile-front.chiral:41` | BUILT (E123) | every compile through `term->ntalty` |
| the **pool** that supplies the memfd, `(pool-r (1 pool (Pool n)) (1 fd Fd))` | `lib/ports/pool.port:15`; its lowering row at `lib/lowering/tal/crossing-wraps.chiral:50` | BUILT (E122) | measured: a root calling `pool-create` + `fd-close` + `pool-close` compiles (probe A below) |
| the **wrapper family this row joins**: `nb-sock-send-t`, `nb-sock-recv-t` (E125) and `nb-sock-connect-t` (E127), each threading its linear cap back and assembling a boxed result sum via `ti-cona` | `lib/lowering/tal/sys.chiral:820`, `:834`, `:919`; rows at `lib/lowering/tal/crossing-wraps.chiral:37`, `:38`, `:40` | BUILT | `prog/samples/e127_sock_connect_err.prog` compiles to 33,144 bytes, measured 2026-09-14 |
| the **`ti-cona` boxed-sum precedent** those three cite, `nb-sys-socketpair-t` | `lib/lowering/tal/sys.chiral:749`, listed at `:1332`; table row at `lib/lowering/tal/crossing-wraps.chiral:39` | BUILT (E126) | probe D below compiles |
| E125's own **statement that this row is its follow-on**: *"Scope: send/recv only; `sock-send-fd` (SCM_RIGHTS, `nb-sys-send-fd-t` already exists) is a follow-on"* | `docs/examples/E125-sock-use.md:4` | written 2026-09-01 | the design that shipped E125 |
| the **table this row edits**, `crossing-wraps`, carrying **45** rows today | `lib/lowering/tal/crossing-wraps.chiral:14-57`; `grep -c '(pair ' ` returns 45 over a 65-line file | BUILT | `lib/lowering/tal/erase.chiral:23` and `:216`; `lib/lowering/compile-emit.chiral:226`, `:263`, `:301` |
| the **single authority** question, settled: `sys-bindings` is *derived* from `crossing-wraps`, so one table edit cannot drift from a second | `lib/lowering/tal/sys-linkage.chiral:87-93`, `(def sys-bindings (List SysBinding) (cw->binds crossing-wraps))` | BUILT | `lib/module/sig-derive.chiral:16`; `lib/lowering/compile-emit.chiral:17` |
| the **profile port set** already naming this crossing, in two profiles | `prog/demo/profile-tomodachi.chiral:31`; `prog/demo/profile-node-render.chiral:14` | declared | `ports->wrappers` at `lib/lowering/compile-emit.chiral:223-228`, which **silently drops** a port with no `crossing-wraps` row, so today these two profiles permit nothing for it |
| the **problem row** that owns this work | `records/lenses/problems.md:996-1008`, PRB-71, `owner: native-window/W5` | OPEN, `author: unreviewed` | this design |

### The three measurements the roster row and the arc file get wrong

**One.** The floor crossing is built and the row does not say so. The row's
`origin` column reads `new`, which the arc glosses at
`docs/arcs/native-window-arc.md:63` as *"every `origin` is `new`: none of this
exists in the tree."* `lib/lowering/tal/sys.chiral:366` is the `sendmsg` +
`SCM_RIGHTS` body, `docs/elements/ledger.md:191` files E30 `built`, and
`docs/elements/catalog.md:145` reads *"BUILT native: the `sendmsg`+`SCM_RIGHTS`
body is `lib/lowering/tal/sys.chiral:359-360` and after."* The `origin` legend
at `docs/arcs/README.md:74` reads `connect` as *"two built things need
joining"*, and that is what this row is: a built floor crossing and a built
port face with no join. **The mint does not carry this flip.**
`tools/pack/pack.py:1181-1194` is `roster_flip`, which calls
`set_roster_state` and touches the state cell alone, so the `origin` column is
an arc-file edit the orchestrator owes (§3).

**Two.** The count is stale. The row and the arc's resume state at
`docs/arcs/native-window-arc.md:76` both say `crossing-wraps.chiral` carries 44
lowered crossings. It carries 45.

**Three.** `crossing-wraps.chiral`'s own header cites an authority that does not
exist. `lib/lowering/tal/crossing-wraps.chiral:8-11` reads *"INVARIANT: this
must agree with lib/sys-linkage.chiral `sys-bindings` (the linkage-side
authority, consulted by native.py)"*. `lib/sys-linkage.chiral` is absent from
the tree; the file is `lib/lowering/tal/sys-linkage.chiral`, and `find . -name
'native.py'` returns nothing, because that file went with the evicted Python
backend. The live shape is the opposite of what the header states:
`lib/lowering/tal/sys-linkage.chiral:87-93` derives `sys-bindings` *from*
`crossing-wraps`, and says so in its own comment. **A row added to
`crossing-wraps` owes no second edit anywhere.** The header text is wrong in
three ways and is owed a `PRB-` row.

### The failure, measured by isolation

Four probe roots were compiled with `bin/chirality-bin` through `bin/chirality
compile` on 2026-09-14. Sources are outside the repo; the measurement is the
exit and the message.

| probe | body | result |
|---|---|---|
| A | `sock-connect` + `pool-create` + `fd-close` + `pool-close` + `sock-close` | compiles, 33,144 bytes |
| B | probe A plus one `sock-send-fd` call | `no emitted label for entry compile-main \| skip chain for compile-main: compile-main: extern does not lower: sock-connect` |
| D | `socketpair` + `pool-create` + `fd-close` + `pool-close` + two `sock-close` | compiles, 33,144 bytes |
| C | probe D plus one `sock-send-fd` call | `no emitted label for entry compile-main \| skip chain for compile-main: compile-main: extern does not lower: socketpair` |

⚑ **Reproduced at the design audit, 2026-09-15, from fresh sources.** D and C
were rebuilt as new roots and compiled through `bin/chirality compile`: D emits
33,144 bytes, and C fails with the byte-identical message above naming
`socketpair`. `pool-create` sits in both roots and lowers in both, and the
blame passes over it to name the outermost `case`'s scrutinee, which is the
characterization the paragraph below states.

A and B differ by one call. D and C differ by one call. `sock-send-fd` is the
sole offender, and it is the offender at the **lower** stage: the refusal is an
`le-skip` recorded as `sk-extern` (`lib/lowering/compile-back.chiral:269-271`,
`lib/lowering/skip-diag.chiral:15`), rendered by `leaf-label` at
`lib/lowering/skip-diag.chiral:86-88`, and the whole def is dropped, so emit
finds no label for `compile-main`.

**A second defect falls out of the isolation, and it is not this row's.** In
both failing probes the recorded blame names the def's *scrutinee* crossing,
which probes A and D prove lowers. The reason string reaching `sk-extern` is
wrong about which extern refused. The apparatus that renders it is correct;
what it is handed is not: `lib/lowering/upper/lower.chiral:278` is the one site
that builds the string, `(str-cat "extern does not lower: " n)`, where `n` is
whichever name `sig-assoc` over `ce-prims` missed. That survives any fix to
`sock-send-fd` and is owed a `PRB-` row of its own (§3). ⚑ The `PRB-` row owes
one more measurement than this design took: whether the string is wrong about
the name, or whether the prim signature table genuinely lacks `socketpair` in
the failing compile and carries it in the passing one. The two have different
repairs and the probes here do not separate them.

### The verification floor, and its ceiling

`sendmsg`'s payload arrives at the peer as ordinary bytes, so the existing
`sock-recv` (E125) reads it back over a `socketpair`. The **descriptor's**
arrival is a different matter: `grep -rn 'recvmsg\|recv-fd\|SCM_RIGHTS' lib/
prog/` returns exactly one comment line,
`lib/lowering/tal/sys.chiral:360`, and nothing else, there is no `recvmsg`
row in `lib/lowering/tal/target-linux.manifest`, and no receive-fd extern in
`lib/ports/`. **Nothing in this tree can receive a descriptor.** The
`st_ino`-match round-trip that `docs/examples/E30-fd-passing.md:207-209` names
as E30's conformance target was a differential against CPython
`socket.send_fds`, and that oracle is evicted.

No gate reads `prog/demo/`. `tools/test/run-tests.sh:175-176` builds Phase 7's
root list by `grep -rl '^(def compile-main' lib prog`, and
`grep -rln '^(def compile-main' prog/demo/` returns one file,
`prog/demo/_recurse-ceiling.prog`, which `KNOWN_FAIL` at
`tools/test/run-tests.sh:173` excludes. `prog/demo/tomodachi.chiral:128`
defines an entry named `main`, which the grep does not match, and
`prog/demo/wl-client.chiral` defines no entry at all: `grep -n 'main'` over it
returns nothing, and it is a module `prog/demo/tomodachi.chiral:16` imports. So
no phase compiles either one. `native-window/W6` is the row for that gate.

## 3. The delta

Three of the four shards of `sock-send-fd` are built. **One is missing: the TAL
wrapper that joins them, and the one table row that routes to it.** Concretely:

1. **No `nb-sock-send-fd` wrapper exists.** `grep -rn 'nb-sock-send-fd\|nb-send-fd' lib/ prog/`
   returns nothing. The raw crossing `nb-sys-send-fd` returns a bare integer,
   bytes sent or `-errno`; the extern's declared result is `SendFdR`, a boxed
   two-arm sum whose error arm carries the `Sock` **and** the `Fd` back. Nothing
   in the tree performs that conversion for this crossing.
2. **No `crossing-wraps` row for `sock-send-fd`.** PRB-71's measurement holds:
   `grep -c sock-send-fd` over `lib/lowering/tal/crossing-wraps.chiral` returns
   0 against 45 present rows.
3. **No gate.** No sample root exercises `sock-send-fd`, and no phase runs one.

**The delta is a join.** Proposing to write the `sendmsg` + `SCM_RIGHTS`
body is proposing to build `lib/lowering/tal/sys.chiral:366` a second time, and
proposing an E76 permit is proposing
`lib/lowering/tal/target-linux.manifest:40` a second time.

**Scope: the row's sentence bundles work that requirement 1 does not need.** The
row names `sock-listen`, `sock-accept` and `bind` alongside `sock-send-fd` and
calls the whole thing *"E29's unowned server half"*. Requirement 1 is *"a window
opens on a stock compositor"*, and `prog/demo/wl-client.chiral` **connects to**
a compositor: its acquisition path is `sock-connect`, which
`lib/lowering/tal/crossing-wraps.chiral:40` lowers today and E127 built. A
client calls no `listen`, no `accept` and no `bind`. The server residue is real
and separately recorded at `docs/elements/ledger.md:447`: `sock-listen` and
`sock-accept` are externs at `lib/ports/sock.port:64-65` with no
`crossing-wraps` row and no TAL body, and `grep -rn '(extern bind\|sock-bind' lib/ports/`
returns nothing, so there is no `bind` extern to lower. None of it stands
between the demo and a screen. §5 takes the call.

**Verdict:** a real delta, one element wide. One TAL wrapper, one table row,
one hermetic gate.

**Residue this row does not carry**, each owed its own row and named here so the
mint does not absorb it:

| residue | owed as |
|---|---|
| the E29 server half: `sock-listen`, `sock-accept`, and a `bind` extern that does not exist | a new roster row in this arc, `native-window/W7`. **Not opened by this run** (the arc file is not this run's to edit); the orchestrator owes the roster edit |
| no crossing receives a descriptor, so a full fd round-trip is unconstructible in-tree | a `GAP-` row in `records/lenses/gaps.md`. Nothing schedules `recvmsg` today. A client never receives an fd, so requirement 1 does not want it |
| the skip-chain blame names the scrutinee crossing instead of the one that refused | a `PRB-` row in `records/lenses/problems.md`, level `source`, about `lib/lowering/upper/lower.chiral:278` |
| `crossing-wraps.chiral:8-11` cites `lib/sys-linkage.chiral` and `native.py`, neither of which exists, and inverts the derivation direction | a `PRB-` row, level `source`. The comment edit is itself compiler source and owes the fixpoint, so it rides this element's rebuild or waits for one |
| the arc file owes **two** cells, and the mint carries neither: `44` in the roster row and at `docs/arcs/native-window-arc.md:76` against 45 measured, and the roster row's `origin: new` against the `connect` §2 measures | the arc file, orchestrator-owed. `tools/pack/pack.py:1181-1194` writes the state cell alone |
| no gate reads `prog/demo/` | `native-window/W6`, already on the roster |

## 4. The shapes

The delta is a join, and the family that joins this way is built three times
over. What is genuinely open is the wrapper's **send discipline**, because the
two built precedents in `sys.chiral` disagree with each other.

### Shape A: one `sendmsg`, two-arm sum

- **Form.** `nb-sock-send-fd(sock, payload, fd)`: one `ti-call` into
  `nb-sys-send-fd`, one `op-lti` against zero, one `ti-tcase` with two arms, two
  `ti-cona`. Tag 0 is `sfd-ok` re-threading the `Sock`; tag 1 is `sfd-err`
  carrying the errno register, the `Sock` and the `Fd`. Issues no `ti-sys` of
  its own, so it needs no E76 name row: the precedent and its reason are stated
  at `lib/lowering/tal/sys.chiral:864-868`, *"a name maps to exactly ONE syscall
  number at the E76 chokepoint ... so a single body cannot carry 41 AND 42."*
  One `crossing-wraps` row, `"sock-send-fd" -> "nb-sock-send-fd"`.
- **Costs.** One `TIFn` of roughly the size of `nb-sock-recv-t`
  (`lib/lowering/tal/sys.chiral:834-861`, 28 lines), simpler by one nesting
  level because `SendFdR` is two-way where `RecvR` is three-way. One
  `sys-lib` registration line. One table row.
- **Forbids.** A short payload send is not retried: the wrapper reports what the
  kernel reported. That is wanted here. `sendmsg` carrying `SCM_RIGHTS` is not
  resumable the way `write` is, because a retry after a partial send would hand
  the peer a second copy of the descriptor, and the linear `Fd` was already
  consumed. The payload at `prog/demo/wl-client.chiral:201-202` is one Wayland
  `wl_shm.create_pool` message, 16 bytes whole: `wenc`
  (`lib/protocol/wire.chiral:13-17`) prepends an 8-byte object-id and
  opcode-plus-size header to the two `pack-u32`s at
  `prog/demo/wl-client.chiral:202`. Far under any pipe buffer.

### Shape B: map the extern straight at the raw crossing

- **Form.** One `crossing-wraps` row, `"sock-send-fd" -> "nb-sys-send-fd"`, and
  no wrapper. The `sock-close`/`lsock-close`/`fd-close` rows at
  `lib/lowering/tal/crossing-wraps.chiral:42-44` all do exactly this, three
  externs onto one `nb-sys-close`.
- **Costs.** One line.
- **Forbids.** It is refused by the type, so it forbids the element. Those three
  rows work because each extern's declared result is `Unit`, which
  `lib/lowering/tal/erase.chiral:217-219` handles by overwriting `dst` with the
  Unit tag. `SendFdR` is not `Unit`, so erase takes the value-crossing arm at
  `:221` and keeps the raw integer in `dst`, and the caller at
  `prog/demo/wl-client.chiral:203` would `ti-tcase` a bytes-sent count as a
  boxed sum. It also destroys the custody law that `lib/ports/sock.port:47-49`
  states: *"on error the Sock AND the Fd come back, so the caller can retry or
  discharge them."* A bare integer returns neither cap, and QTT has no linear
  witness to consume. This shape is listed because it is the one-line temptation
  and because the tree's own rows look like it; it is closed by
  `lib/lowering/tal/erase.chiral:217-221`.

### Shape C: a `sendall` loop over `sendmsg`

- **Form.** The `nb-sock-send-t` shape: an entry that resolves the payload
  address and length, seeds `off = 0`, and tail-calls a worker that loops until
  the whole payload is gone (`lib/lowering/tal/sys.chiral:820-826`, and the
  recursive `sendall` worker it tail-calls at `:790`).
- **Costs.** Two `TIFn`s instead of one, plus the offset-advance arithmetic, and
  a second `iovec` rebuild per iteration because `iov_base` moves.
- **Forbids.** It forbids nothing, and it cannot be made correct here. The
  control message must ride exactly one `sendmsg`: a loop that re-sends the
  remainder with the same `msghdr` sends the descriptor twice, and one that
  clears `msg_control` after the first iteration has already consumed the linear
  `Fd` and cannot report a partial-transfer failure through `SendFdR`'s two arms.
  ⚑ The custody half stands on the tree: `lib/ports/sock.port:47-49` states that
  the linear `Fd` is consumed on success. The duplication half is an unpinned
  reading of the ABI (§4). So cost does enter here, and it still picks A.

**The tree does not fully settle it, and A is what the measurement leaves
standing.** Shape B is closed inside the tree by
`lib/lowering/tal/erase.chiral:217-221`.

**Shape C's correctness case is not closed inside the tree.**
`docs/examples/E30-fd-passing.md:52-53` carries the one-fd arithmetic,
`cmsg_len = CMSG_LEN(4) = 20` inside a `CMSG_SPACE(4) = 24` buffer, and says
nothing about retry: `grep -n 'retry\|partial\|twice\|duplicate'` over that file
returns nothing, and `SIGPIPE` and `MSG_NOSIGNAL` appear nowhere under `lib/`,
`prog/` or `docs/`. That a re-sent `msghdr` passes the descriptor a second time
is this design's reading of `SCM_RIGHTS` and owes a `research` run's `FD` row in
`records/findings.md` before a gate may rest on it. `records/findings.md:23-24`
is the rule: *"A citation nobody can open is not evidence."* Shape C's **cost**
case stands on the tree alone and this leaves it standing.

Because the shapes were live before these citations were read, this row is
**not** `direct`: the element mints and takes a SPEC, which is where the
register allocation, the tag order and the gate's exit codes get pinned against
the three built siblings.

## 5. The call

- **Chosen:** **Shape A**, one `sendmsg` per call with a two-arm `ti-cona` sum,
  because it is the E125 / E126 / E127 wrapper family unchanged
  (`lib/lowering/tal/sys.chiral:820`, `:834`, `:919`), because E125's own design
  named this crossing as its follow-on at `docs/examples/E125-sock-use.md:4`, and
  because Shape C costs two `TIFn`s and a per-iteration `iovec` rebuild to move
  a 16-byte message. The stronger claim, that `SCM_RIGHTS` makes the `sendall`
  discipline outright incorrect, is this design's reading of the ABI and carries
  no in-tree pin (§4). The choice stands without it.

- **Scope:** **the client fd-passing path only.** This element lowers
  `sock-send-fd` and nothing else. The server half leaves the row.

- **The gate, and what it cannot reach.** A hermetic `socketpair` round-trip in
  the Phase 20 shape (`tools/test/run-tests.sh:305-326`: compile a root under
  `prog/samples/`, run it, judge it against the exit code its own header
  specifies). Two roots, both hermetic and hard-gated, no network and no
  compositor:
  - **the success arm.** `socketpair` → `pool-create` → `sock-send-fd` on half
    `a` → `sock-recv` on half `b` → the payload arrives byte-identical and the
    reported count matches. Discriminating in the sense
    `prog/samples/e127_sock_connect_err.prog:14` uses: the pre-fix compiler
    cannot compile the root at all.
  - **the error arm.** `sock-send-fd` returns `-errno`, the `sfd-err` arm is
    reached, and QTT forces the test to discharge both the returned `Sock` and
    the returned `Fd`. This is
    `prog/samples/e127_sock_connect_err.prog`'s exit-42 shape exactly.

    ⚑ **The trigger is not settled and the SPEC owes it.** A closed peer is the
    obvious trigger, and it carries a hazard: the floor crossing hardwires
    `sendmsg`'s flags to zero.
    `lib/lowering/tal/sys.chiral:413-414` is `(ti-const 48 0)` feeding
    `(ti-sys 49 46 (cons 0 (cons 47 (cons 48 nil))))`, so no `MSG_NOSIGNAL`
    rides the call, and `grep -rn 'NOSIGNAL\|SIGPIPE' lib/ prog/ docs/` returns
    nothing: the tree has never met this. Whether a closed-peer send reaches
    `sfd-err` or dies on a signal first is unmeasured here, and a root that
    dies grades nothing. Three ways out, none picked by this design: a trigger
    that raises no signal, a `signal` call ahead of the send (the crossing is
    built, `lib/ports/process.port:18`, row at
    `lib/lowering/tal/crossing-wraps.chiral:56`, number at
    `lib/lowering/tal/target-linux.manifest:61`), or a flags argument on the
    wrapper. The third widens the element and the first two do not.

  **Stated bound.** The gate verifies that the crossing lowers, runs, reports
  correctly, and moves its payload. It does **not** verify that the descriptor
  arrived, because nothing in this tree receives one (§2). The `st_ino` match at
  `docs/examples/E30-fd-passing.md:207-209` is unreachable until something does.

- **W5 is verifiable without W6.** The gate above is a sample root plus a phase,
  and it depends on nothing under `prog/demo/`. The agent sandbox hosts no
  compositor, so a window cannot be observed from inside it and this element
  never claims one: the element's claim is that the crossing lowers and runs.
  Requirement 1's own claim, a window on a stock compositor, is satisfied by W1
  through W4 riding this crossing and is observable only on a host with a
  compositor. W6 is what makes `prog/demo/` compile under the suite and this §6
  does not absorb it.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | One `sendmsg` or a `sendall` loop | RESOLVED | Shape A, on the tree's side of the argument alone: Shape C costs two `TIFn`s and an `iovec` rebuild per iteration against Shape A's one, and the payload is one 16-byte Wayland message (`prog/demo/wl-client.chiral:201-202`, `lib/protocol/wire.chiral:13-17`). `docs/examples/E30-fd-passing.md:52-53` carries the one-fd arithmetic, `cmsg_len = CMSG_LEN(4) = 20` in a `CMSG_SPACE(4) = 24` buffer. ⚑ That a retry duplicates the descriptor is an unpinned reading of `SCM_RIGHTS` (§4) and the ruling does not rest on it |
| 2 | Wrapper, or a straight row onto `nb-sys-send-fd` | RESOLVED | `lib/lowering/tal/erase.chiral:217-221`: the Unit arm is what makes the `sock-close` family's straight rows legal, and `SendFdR` is not `Unit` |
| 3 | Does a second authority owe an edit beside `crossing-wraps` | RESOLVED | No. `lib/lowering/tal/sys-linkage.chiral:87-93` derives `sys-bindings` from `crossing-wraps`. The header's claim of a second authority at `crossing-wraps.chiral:8-11` cites two absent files and is itself a `PRB-` row |
| 4 | Does this element carry `sock-listen`, `sock-accept` and `bind` | RESOLVED | No. Requirement 1 at `docs/arcs/native-window-arc.md:41-42` is a window on a compositor, and `prog/demo/wl-client.chiral` is a client whose acquisition path is `sock-connect` (built, E127). The server residue is recorded separately at `docs/elements/ledger.md:447` |
| 5 | Is this a new element or an amendment to E30 | RESOLVED | A new element. E125, E126 and E127 are three separate elements layered over E29's already-`built` sockets (`docs/elements/ledger.md:451`), which is the same relation this bears to E30 |
| 6 | Does the element need its own E76 name row | RESOLVED | No. Shape A issues no `ti-sys`, and `nb-sys-send-fd -> 46` already sits at `lib/lowering/tal/target-linux.manifest:40`. The reason a fused body carries no `ti-sys` is stated at `lib/lowering/tal/sys.chiral:864-868` |
| 7 | Who fixes the skip-chain misattribution | DEFERRED | Out of scope and stated as residue in §3. It needs a `PRB-` row before it can be deferred to anything that exists; the orchestrator owes that row |
| 8 | Does the roster row's `origin: new` change to `connect` | DEFERRED | The arc file, orchestrator-owed. §2 measures `connect` as the honest value and this run does not edit the arc |

No NEEDS-AUTHOR. Every question above resolves against a settled doc or live
code, or names the existing row that owns it. The suite phase number §6 assigns
was an open author call until 2026-09-06 and is now settled:
`records/author-calls.md:63` carries it as `ruled` and
`tools/test/run-tests.sh:348-354` states the rule the design applies.
`records/author-calls.md` earns no row from this design.

⚑ **Two questions are owed to a later stage, and neither is the author's.** The
`SCM_RIGHTS` retry reading owes a `research` run's `FD` row before a gate may
rest on it (§4), and the error arm's trigger owes a measurement in the SPEC
(§5). Both were added at the design audit, 2026-09-15.

## 6. The mint packet

- **Elements:** **one.** The wrapper body and its `crossing-wraps` row constrain
  each other absolutely: a row pointing at a wrapper that does not exist names a
  label emit cannot resolve, and a wrapper with no row is never reached by
  `lib/lowering/tal/erase.chiral:216`. They are one commit and one element. The
  gate rides with them, on E125's and E127's precedent, where the conformance
  sample shipped inside the element.

- **Band:** `UNASSIGNED`. [[arcs/native-window-arc]] holds no reserved block, and
  `docs/decisions/decision-lane-split.md:60-61` covers exactly this case: *"An
  arc with no band still mints. It takes the next free number and records the
  range it landed in."* Measured 2026-09-14, the highest number in
  `docs/elements/catalog.md` and `docs/elements/ledger.md` is **E198**. The next
  free number lands inside the unit lane's reserved `E196-E239`, which the
  2026-09-06 overlap ruling at `docs/decisions/decision-lane-split.md:38-58`
  permits: the allocator and the roster stop a collision (`:52`), and a band
  stops none.
  **The mint assigns the number, and this design names none.**

- **Catalog row** (section SYS, columns `| E# | Element | State / location | Reference (class) | Track |`):

  `| E<NN> | `sock-send-fd` lowers: the TAL wrapper joining `nb-sys-send-fd` to `SendFdR`, plus its `crossing-wraps` row | Not built: the floor crossing is BUILT at `lib/lowering/tal/sys.chiral:366` and permitted at `lib/lowering/tal/target-linux.manifest:40`, and the extern is declared at `lib/ports/sock.port:68`, but no wrapper converts the raw count into `SendFdR` and `crossing-wraps.chiral` carries no row, so a def calling it is skipped at lower and emit finds no entry label. E125's follow-on, on the `nb-sock-send-t` / `nb-sock-connect-t` pattern | `sendmsg`/`cmsg` ABI (`SPEC`), via `docs/examples/refs/ref-fdpass.md` | SH |`

- **Ledger row** (section `SYS · Syscall crossings`, columns `| E# | Module | State | Title | Cites | Track |`):

  `| E<NN> | sys-net | design | `sock-send-fd` lowers: `nb-sock-send-fd` TAL wrapper over the built `nb-sys-send-fd` crossing, assembling `SendFdR` via `ti-cona` with the `Sock` re-threaded and the `Fd` returned on the error arm, plus the `crossing-wraps` row. Closes PRB-71 and unblocks `native-window` W1-W4 | →`native-window/W5` | SH |`

- **Size.** Four files, and the fixpoint dominates.

  | file | change | lines | basis |
  |---|---|---|---|
  | `lib/lowering/tal/sys.chiral` | `nb-sock-send-fd-t` plus a header comment, and one entry appended to the crossing list that `lib/lowering/tal/sys.chiral:1308` defines | ~30 + 1 | `nb-sock-recv-t` is 28 lines at `:834-861` for a three-way sum; this is two-way with a three-field error arm |
  | `lib/lowering/tal/crossing-wraps.chiral` | one `(pair …)` row, 45 to 46 | 1 | the rows at `:37-41` |
  | `prog/samples/` | two hermetic round-trip roots, success arm and error arm | ~70 | `prog/samples/e127_sock_connect_err.prog` is 25 lines; the success root adds `socketpair`, `pool-create` and a `sock-recv` comparison |
  | `tools/test/run-tests.sh` (or a new `tools/test/send-fd.sh`) | one `run_phase` block. **Phase 33**, under the rule at `tools/test/run-tests.sh:348-354`: *"a gate takes the first number that collides with nothing"*, with 8-12 owed to unported old-tree phases and 21-23 Lane B's. `run_phase 32` is the highest present, so 33 is the first that collides with nothing. Not an author call: `records/author-calls.md:63` carries the question as `ruled` 2026-09-06 | ~20 | `transport.sh`'s compile-run-judge loop |

  **Total: roughly 120 lines across four files.**

  ⚑ **The BUILD RULE fixpoint is owed, and it is most of the cost.** Both edited
  `lib/` files sit inside `prog/compiler.prog`'s closure, measured 2026-09-14:
  `chirality_blob_file "lib:prog" prog/compiler.prog` produces 17,797 lines, with
  `(def crossing-wraps …)` at blob line 10917 and `(def nb-sys-send-fd-t …)` at
  16061. **Re-measured at the design audit 2026-09-15: all three figures hold to
  the line.** `lib/lowering/tal/erase.chiral:23` and
  `lib/lowering/compile-emit.chiral:17` are the two import paths that put them
  there. So this element owes `build-new → test → promote` per
  `docs/definitions/working-discipline.md:15-49`: generations from one blob until
  two consecutive ones are byte-identical, `(ulimit -s unlimited; …)` on each, a
  non-empty check before each `cmp`, stop after `C4`, then promote
  `bin/chirality-bin` (1,220,984 bytes tracked today). The change touches the
  routing table the emitter reads, so the first agreement may land at `C2 == C3`.
  `docs/definitions/working-discipline.md:35-40` covers that case and E188
  measured it.

- **Related:** [[arcs/native-window-arc]] requirement 1, [[goals/native-stack]]
  condition 2, `records/lenses/problems.md` PRB-71 (this element closes it),
  `docs/examples/E30-fd-passing.md` (the ABI reasoning and the floor crossing),
  `docs/examples/E125-sock-use.md` (the wrapper family and the statement that
  this is its follow-on), `docs/examples/E126-socketpair.md` (the `ti-cona`
  precedent and the hermetic pair the gate runs over), `native-window/W6` (the
  gate that reads `prog/demo/`), `docs/banks/port.md`, `docs/banks/capability.md`.
