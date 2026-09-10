---
node: arc-tool-authority
layer: navigation
related: [arcs/README, goals/coding-agent, arcs/coding-turn-arc, banks/capability, banks/port, permission-model, status-ledger, decisions/decision-tool-capability, decisions/decision-orchestration-boundary, decisions/decision-syscall-governance, decisions/decision-work-ids, decisions/decision-design-before-mint, elements/catalog, records/author-calls, index]
status: current
updated: 2026-09-09
---

# Arc: tool-authority

- goals: [[goals/coding-agent]], condition 1: "A coding turn is decomposed
  across the engine rather than run as one loop, and each step holds only the
  tools it was granted."
- reserved element block: **`E240-E259`**, [[decisions/decision-lane-split]], reserved 2026-09-10 for the coding agent and the tools under it. Rows keep their arc-local ids per [[decisions/decision-work-ids]], which survive the mint
  [[decisions/decision-work-ids]]. This arc spells the letters `TA`, for tool
  authority: `tool-authority/TA1` upward. `TA` is free tree-wide, verified
  2026-09-09. Author call B was ruled 2026-09-06, "let overlap exist", so a band
  is advisory and an arc without one mints the next number free tree-wide. The
  two-letter form follows `baseline-alignment`'s `BA`.
- build-state authority: [[status-ledger]]
- checklist: none. No `records/tool-authority.md` exists.
- sibling: [[arcs/coding-turn-arc]], same goal, same condition, the other half.

## Why this arc exists

Condition 1 has two halves and one arc. [[arcs/coding-turn-arc]] opened
2026-09-08 against the first half, the decomposition: a turn that is a tree of
engine nodes rather than the single recursion at
`prog/shilpa/turn.chiral:410-438`. **This arc takes the second half, the
grant**: what "holds only the tools it was granted" means when the holder is a
process and the thing held is a descriptor. Two arcs on one condition is
established practice; [[goals/local-ai]] condition 1 is served by both
[[arcs/transport-arc]] and [[arcs/unit-lane-arc]].

Two decisions committed 2026-09-09 are why it opens now.
[[decisions/decision-orchestration-boundary]] puts the tool layer on the consumer
side and runs the dependency consumer to prapañca and never back.
[[decisions/decision-tool-capability]] finds the one thing every tool is
represented through: the name-to-descriptor transition that
`lib/ports/file.port:3-7` already isolates, with narrowing structural because
`lib/typing/refine.chiral:13-18` is an integer-interval language and a path is
not decidable by `entails`. That decision's §5 measures the boundary as
unenforced and reads as though the substrate forbids the layer. **The reading is
wrong and this arc carries the correction.** The critique in §5 is about the type
system, which cannot make an integer unforgeable inside one process. If the
enforcement is a process boundary with a constructed child, the kernel enforces
and the type system only accounts; in-process forgery does not cross into a child
that was handed nothing.

The real defect is that spawn shares identity. A child inherits the parent's
principal, so holding a terminal is holding everything reachable from that
principal, and no fd discipline inside the parent fixes it. The requirement this
arc serves is therefore **one session can ask for another session with its own
allow set**, which is `E43`'s spawn and teardown half at
`docs/elements/catalog.md:170`, reached from [[goals/coding-agent]] rather than
from the deferred `OT` track.

## What the tree already holds

Measured 2026-09-09. [[banks/INDEX]] holds thirteen and two own this territory.
Neither is re-derived below.

- [[banks/capability]] holds the four grant operations. Of them only **Move** is
  ENFORCED, by linearity. **Attenuate** is present-but-unapplied: the `subtype`
  mechanism is IMPLEMENTED at `lib/typing/kernel.chiral:799` and unwired to grant
  narrowing (`docs/banks/capability.md:193-201`). **Delegate** is built at the
  local linear-Move floor and DESIGNED at the node boundary
  (`docs/banks/capability.md:219-227`). **Revoke** is DESIGNED with no code,
  riding the broker's grant/revoke/audit, `E43`
  (`docs/banks/capability.md:242-246`).
- [[banks/port]] holds the typed crossing. [[permission-model]] is the thin note
  over both, and its thesis at `docs/definitions/permission-model.md:44-47` is
  what this arc's requirements answer to: a guard on a command must lower into
  constraints on the access it entails, or the guard is theater.

⚑ **The naming boundary the whole layer rests on is not whole.** Five crossings
in this tree turn a name into a descriptor or into a running program. Three are
declared inside `lib/ports/`. Two are not, and one of those two is the widest
authority the tree has.

| group | what exists today | where | rung |
|---|---|---|---|
| G1 the boundary | the seam stated in prose, and why the registry is its own file | `lib/ports/file.port:3-7` | IMPLEMENTED |
| G1 | what a registry buys, stated: a naming boundary, not a smaller binary, since `native-lib ++ link-lib` is appended unconditionally | `lib/ports/fd.port:9-12` | IMPLEMENTED |
| G1 | `open-rw` and `open-create`, the two naming crossings that are in the floor, both taking an absolute NUL-terminated path | `lib/ports/file.port:14`, `:15` | ENFORCED |
| G1 | `spawn-in-pty`, the third in-floor naming crossing, taking ELF bytes and a slave path | `lib/ports/pty.port:47` | IMPLEMENTED |
| G1 | `openat`, the O_RDONLY naming crossing. **Declared in no `.port` file at all**, and declared in five files outside the floor | `lib/module/resolve.chiral:49`, `prog/wield.prog:14`, `prog/paren-audit.prog:36`, `prog/prose-lint.prog:45`, `prog/samples/e106_drain_control.prog:18` | SEEDED |
| G1 | `raw-proc-spawn`, argv resolution, the widest authority reached from a tool schema. Declared under `lib/runtime/`, not under `lib/ports/`, and re-declared once in the agent | `lib/runtime/proc.chiral:110`, re-declared at `prog/shilpa/turn.chiral:46` | IMPLEMENTED |
| G1 | the placement rule itself, and the flag that nothing checks it | `MAP.md:64-67`, `MAP.md:86` | SEEDED |
| G1 | 21 files outside `lib/ports/` declare an `extern`; 12 of them declare one of the five naming crossings | measured 2026-09-09 | SEEDED |
| G2 inheritance | `open-rw` lowers to `openat` with `O_RDWR｜O_NOCTTY｜O_CLOEXEC = 0x80102 = 524546` | `lib/lowering/tal/sys.chiral:646-647`, body at `:654` | ENFORCED |
| G2 | `open-create` lowers with `O_RDWR｜O_CREAT｜O_TRUNC｜O_NOCTTY｜O_CLOEXEC = 0x80342 = 525122` | `lib/lowering/tal/sys.chiral:663-664`, body at `:670` | ENFORCED |
| G2 | `openat` lowers with flags hardcoded to **0**, so O_RDONLY with **no `O_CLOEXEC`**, and `AT_FDCWD` hardcoded at `ti-const 2 -100` | `lib/lowering/tal/sys.chiral:27`, `:33`, `:34` | ENFORCED |
| G2 | the port floor's own text disagrees with that lowering in two places: `lib/ports/file.port:14` omits the `O_CLOEXEC` `open-rw` has, and the agent's header repeats the omission | `lib/ports/file.port:14`, `prog/shilpa/tools-fs.chiral:11` | SEEDED |
| G3 hand-off | `sock-send-fd`, SCM_RIGHTS with linear give-up: the `Fd` is consumed on success because the kernel moved it to the peer, and on error the `Sock` and the `Fd` both come back | `lib/ports/sock.port:68`, discipline stated at `:47-52` | IMPLEMENTED |
| G3 | its TAL body, built, and registered in the function list | `lib/lowering/tal/sys.chiral:366-367`, listed at `:1338` | IMPLEMENTED |
| G3 | ⚑ **it does not lower.** `grep -c 'sock-send-fd' lib/lowering/tal/crossing-wraps.chiral` returns **0**, so the one consumer, `prog/demo/wl-client.chiral:201`, reaches nothing. `docs/elements/catalog.md:142` files `E30` as BUILT | `lib/lowering/tal/crossing-wraps.chiral` | SEEDED |
| G3 | `sock-listen` and `sock-accept` are declared and absent from the same table | `lib/ports/sock.port:64`, `:65` | SEEDED |
| G3 | there is **no receive half**. `recvmsg` with SCM_RIGHTS is declared nowhere and lowered nowhere | measured 2026-09-09 | absent |
| G4 the child | `proc-spawn` returns a linear `Reap`, so child custody is already structural: dropping it is a type error, consuming it twice is a type error | `lib/runtime/proc.chiral:27-28`, `:33`, `:124` | ENFORCED |
| G4 | the two spawn shapes are opposite. `raw-proc-spawn` takes a NUL-framed argv packet and resolves by name; `spawn-in-pty` takes ELF bytes, so a caller can spawn only what it already holds | `lib/runtime/proc.chiral:110`, `lib/ports/pty.port:47` | IMPLEMENTED |
| G4 | what the argv shape costs, live: the model's string and `/bin/sh -c` reach the argv spawn from `ag-bash` | `prog/shilpa/turn.chiral:61`, `:63` | IMPLEMENTED |
| G4 | the `Fd` cap governs closing, not reaching. `adopt-fd` mints a linear `Fd` from any `I64` and calls itself trusted; `read`, `write-fd` and `fcntl` take a raw `I64` and never see the cap | `lib/ports/fd.port:32`, `:34-36` | IMPLEMENTED |
| G5 the ask | the grant as it exists: `Expert.tools`, a `(List Str)` declared least-privilege, bound at seven destructuring sites and read at zero | `prog/prapanca/core/types.chiral:64-65` | SEEDED |
| G5 | `E43`, the component broker: AUTH/AUDIT, grant/revoke/audit, spawn/teardown/link-at-load only, edge 8, track **OT**. Minted, design-only | `docs/elements/catalog.md:170` | DESIGNED |
| G5 | the narrowing algebra that would account it: narrow freely, forget freely, reach only ever shrinks | `lib/typing/kernel.chiral:796-799` | IMPLEMENTED |
| G5 | the built precedent for deriving a narrower handle without losing the wider one, in a pure arrow through a `case` accounting both binders | `prog/prapanca/backend.chiral:56-57` | IMPLEMENTED |
| G5 | why the refinement engine is the wrong instrument: `Constraint` is `lo`/`hi`/`ex`/`sym` over `I64`, and `entails` decides integer intervals and holes | `lib/typing/refine.chiral:13-18`, `:93` | ENFORCED |

Two facts from that table govern the roster. **`open-rw` is not the leak**: the
lowering sets `O_CLOEXEC` on it and on `open-create`, and only the port floor's
prose says otherwise. **`openat` is the leak**, it has no home in the registry
that exists to be the boundary, and it is the crossing the module resolver and
three shipping programs actually use.

## What is missing, and its structure

| group | owns |
|---|---|
| G1 the boundary is whole | every name-to-descriptor crossing declared inside `lib/ports/`, and a check that keeps it there. Two of five sit outside it today and `MAP.md:86` records that nothing notices |
| G2 the inheritance default | what a descriptor does at the child's `exec`, stated where the crossing is declared and true of every one of them. This is the half the type system can never hold: a flag word belongs to the kernel, and a comment that misstates it is the only failure mode available |
| G3 the hand-off | the constructed give and its receive. `sock-send-fd` is how a parent hands a child a descriptor the child can never name, and it is declared, bodied, registered and unrouted |
| G4 the constructed child | a spawn whose child holds what it was handed and can name nothing else. `Reap` already makes custody structural; the descriptor set is what is missing, and `AT_FDCWD` hardcoded at `lib/lowering/tal/sys.chiral:33` is why "rooted at this subtree" is inexpressible even to a child that holds a directory descriptor |
| G5 the ask | one session asking for another with its own allow set, as a value the grantor cases, plus what the type system still accounts once the kernel does the enforcing |

### The edges that run against the order

| edge | direction | what crosses |
|---|---|---|
| G5 to G1 | against | the ask decides whose boundary G1 draws. **Author call 2 is open**: if the coding agent is always handed its descriptors, `prog/shilpa/` should declare no naming crossing at all and the floor G1 completes is a supervisor's. If the agent is ever a holder, G1 is the agent's own port set. `prog/shilpa/turn.chiral:46` re-declares `raw-proc-spawn` today, which answers the call in code without answering it |
| G4 to G3 | against | **author call 3 is open** and it decides whether G3 is on the path. The ELF-bytes shape at `lib/ports/pty.port:47` hands the child nothing, so every descriptor it gets arrives through `sock-send-fd`. The argv shape at `lib/runtime/proc.chiral:110` resolves a name and inherits the parent's table, so what governs is G2's flag word and G3 is optional. Ordering G3 before G4 reads as a schedule and is not one |
| G4 to G2 | against | nothing observes an inheritance default until a child exists to leak into. G2 sits second and is unfalsifiable until G4 lands: the tree has one `exec` path with a chirality parent, `nb-spawn-in-pty` (`lib/lowering/tal/sys.chiral:670` and after), and no gate runs it. Built bottom-up, G2 is a comment audit |
| G1 to G5 | against, and the loudest | **author call 1 is open.** While `bash` is in the goal toolset, `ag-bash` (`prog/shilpa/turn.chiral:61-63`) hands `/bin/sh -c` a model string, and a shell resolves every name the principal can reach. Every row in G1 through G4 is decorative until that call is ruled, which is why the call is carried on the rows it governs rather than treated as a blocker |

**What this arc does not gate on.** Specifying an ask against an auth layer that
does not exist yet is allowed, and the gap is recorded rather than called
blocked: [[working-discipline]] rules that a capability the substrate lacks is a
finding with the workload that discovered it, and that "blocked" is the wrong
word for it. Attestation and revocation-with-audit are post-crypto and wait. The
shape of the ask, the inheritance defaults and the hand-off mechanism do not.

## REQUIREMENTS

1. **Every name-to-descriptor crossing is declared inside `lib/ports/`.**
   Observed as `grep -rn 'extern openat\|extern raw-proc-spawn'` outside
   `lib/ports/` returning zero. Today it returns six files:
   `lib/module/resolve.chiral:49`, `prog/wield.prog:14`,
   `prog/paren-audit.prog:36`, `prog/prose-lint.prog:45`,
   `prog/samples/e106_drain_control.prog:18` and `prog/shilpa/turn.chiral:46`,
   and neither crossing is declared in any `.port` file.

2. **Each naming crossing states its inheritance default where it is declared,
   and the statement matches the lowering.** Observed as `lib/ports/file.port`
   naming `O_CLOEXEC` on `open-rw`, which the lowering sets
   (`lib/lowering/tal/sys.chiral:647`), and naming the absent flag on `openat`
   (`lib/lowering/tal/sys.chiral:34`, `ti-const 3 0`). Today `lib/ports/file.port:14` omits
   the flag it has, `prog/shilpa/tools-fs.chiral:11` repeats the omission, and no
   line anywhere states the flag `openat` lacks.

3. **A descriptor can be given to a peer, not only named.** Observed as
   `grep -c 'sock-send-fd' lib/lowering/tal/crossing-wraps.chiral` returning
   nonzero. It returns 0 today, against a declaration at
   `lib/ports/sock.port:68`, a body at `lib/lowering/tal/sys.chiral:366` and a
   registration at `:1338`.

4. **A child is constructed rather than inherited.** Observed as a spawn site
   whose child's descriptor set is a value the caller supplies, so what the child
   can reach is stated at the call rather than derived from the parent's table.
   Today `raw-proc-spawn` (`lib/runtime/proc.chiral:110`) resolves a name from an
   argv packet and the caller states nothing about what the child inherits.

5. **The ask is a value.** Observed as a declared sum whose arms are the
   authorities one session may request for another, constructed at one site and
   cased at the other, replacing the `(List Str)` at
   `prog/prapanca/core/types.chiral:64-65` that is read at zero sites. `E43`
   (`docs/elements/catalog.md:170`) is the element this eventually meets.

6. **A check fails when a module outside `lib/ports/` declares a naming
   crossing.** Observed as a `ledger-lint` check or a `tools/test/` phase naming
   the five crossings and failing on a declaration outside the floor. `MAP.md:86`
   records that nothing checks the placement rule today, and twelve files are the
   live instances.

The shape condition in [[goals/coding-agent]] governs every row below: no route,
rank or selection may assume a float. No row here introduces a score. The only
arithmetic this arc reaches is a flag word, an integer constant in the lowering
and stated as one.

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `tool-authority/TA1` | `openat` declared in `lib/ports/file.port` beside `open-rw` and `open-create`, and the five out-of-floor declarations (`lib/module/resolve.chiral:49`, `prog/wield.prog:14`, `prog/paren-audit.prog:36`, `prog/prose-lint.prog:45`, `prog/samples/e106_drain_control.prog:18`) become imports of it. The name is already routed at `lib/lowering/tal/crossing-wraps.chiral:20`, so nothing under `lib/lowering/` moves | G1 | port | bind | 1 | open | `unminted` |
| `tool-authority/TA2` | `raw-proc-spawn`'s declaration placed against `MAP.md:64-67`. It declares a crossing and lives at `lib/runtime/proc.chiral:110`, which the rule puts under `lib/ports/`, while `lib/runtime/proc.chiral:3-7` argues the surface must never see fork. The row settles which reading wins for the tree's widest authority and retires the re-declaration at `prog/shilpa/turn.chiral:46`. **Turns on author call 2**: if the agent never holds naming authority, that re-declaration is a defect rather than a workaround | G1 | decision | bind | 1 | open | `unminted` |
| `tool-authority/TA3` | the flag word each naming crossing opens with, stated in `lib/ports/file.port` against the lowering it actually has: `open-rw` `0x80102` (`lib/lowering/tal/sys.chiral:646-647`), `open-create` `0x80342` (`:663-664`), `openat` `0` (`:34`). Corrects `lib/ports/file.port:14` and `prog/shilpa/tools-fs.chiral:11`, which both omit the `O_CLOEXEC` `open-rw` carries | G2 | port | bind | 2 | open | `unminted` |
| `tool-authority/TA4` | `openat`'s inheritance default settled: whether the O_RDONLY crossing gets `O_CLOEXEC` like its two siblings, or a second crossing carries the leaking form for the callers that want it. Five call sites, one of them the module resolver at `lib/module/resolve.chiral:49` | G2 | decision | new | 2, 4 | open | `unminted` |
| `tool-authority/TA5` | `sock-send-fd` routed in `lib/lowering/tal/crossing-wraps.chiral`, so the linear give-up declared at `lib/ports/sock.port:47-52` reaches the `nb-sys-send-fd` body at `lib/lowering/tal/sys.chiral:366`, already registered at `:1338`. One table entry, against a crossing `docs/elements/catalog.md:142` files as BUILT and which does not lower | G3 | port | connect | 3 | open | `unminted` |
| `tool-authority/TA6` | the receive half: a `recvmsg` with SCM_RIGHTS crossing that takes a descriptor off a socket and mints an `Fd`, so a constructed child can hold what it was given. Declared nowhere and lowered nowhere today. `adopt-fd` (`lib/ports/fd.port:32`) is the mint it displaces on this path, since minting from any `I64` is exactly what a received descriptor must not need | G3 | port | new | 3, 4 | open | `unminted` |
| `tool-authority/TA7` | the spawn shape settled: `raw-proc-spawn` (`lib/runtime/proc.chiral:110`) resolves argv by name, `spawn-in-pty` (`lib/ports/pty.port:47`) takes ELF bytes and can spawn only what the caller holds. Which one a constructed child is spawned through, and what the other becomes. **Turns on author call 3** | G4 | decision | new | 4 | open | `unminted` |
| `tool-authority/TA8` | a spawn whose child descriptor set is a value the caller supplies, over the `Reap` custody already threaded at `lib/runtime/proc.chiral:27-28` and `:33`. **Turns on author call 1**: while `bash` is in the toolset the child holds a shell (`prog/shilpa/turn.chiral:63`) and the supplied set is decorative | G4 | primitive | new | 4 | open | `unminted` |
| `tool-authority/TA9` | a dirfd-relative naming crossing, so a child handed a directory descriptor can open beneath it. `nb-sys-openat` hardcodes `AT_FDCWD` at `lib/lowering/tal/sys.chiral:33` (`ti-const 2 -100`), which is why `decision-tool-capability` §6 records "rooted at this subtree" as inexpressible even structurally. This is the one shape that decision's §3 leaves standing | G4 | port | new | 4 | open | `unminted` |
| `tool-authority/TA10` | the ask as a value: a closed sum over the authorities one session may request for another, constructed by the asker and cased by the grantor, replacing the `(List Str)` at `prog/prapanca/core/types.chiral:64-65`. `E43` (`docs/elements/catalog.md:170`) is the element this eventually meets, scoped there to spawn, teardown and link-at-load. This row mints nothing into **OT** and writes no row into `docs/arcs/ownership-and-trust-arc.md` | G5 | primitive | new | 5 | open | `unminted` |
| `tool-authority/TA11` | what the type system accounts once the kernel enforces: the narrowing recorded through `subtype` (`lib/typing/kernel.chiral:796-799`) on the `prog/prapanca/backend.chiral:56-57` pattern, where a holder derives a narrower handle in a pure arrow while threading its own onward. The accounting must not read as the enforcement, which is the misreading `decision-tool-capability` §5 invites | G5 | law | connect | 5 | open | `unminted` |
| `tool-authority/TA12` | a check failing when a module outside `lib/ports/` declares one of the five naming crossings, the rule `MAP.md:86` records as unchecked. 21 files outside the floor declare an `extern` and 12 declare a naming crossing. `ledger-lint` is the mechanical home; whether the fixtures under `prog/samples/` are exempt is part of the row | G1 | tool | new | 6, 1 | open | `unminted` |

### Coverage

Run 2026-09-09 against the table above.

- **Every requirement is served.** 1 by `TA1`, `TA2` and `TA12`; 2 by `TA3` and
  `TA4`; 3 by `TA5` and `TA6`; 4 by `TA4`, `TA6`, `TA7`, `TA8` and `TA9`; 5 by
  `TA10` and `TA11`; 6 by `TA12`. No requirement is unscheduled.
- **Every row serves a requirement.** All twelve name at least one. No row is
  out of scope.
- **Every `origin` is defensible from the section above.** Five rows are `bind`
  or `connect`, which is what the measurement supports: the mechanisms here are
  largely declared and unreached rather than absent. The rows marked `new` carry
  the burden.
  - `TA6` is `new` because a grep for `recvmsg` or a receive-side SCM_RIGHTS
    returns nothing anywhere in the tree. The send half is built and unrouted;
    the receive half does not exist.
  - `TA8` is `new` because no spawn in this tree takes a descriptor set.
    `raw-proc-spawn` takes a NUL-framed argv packet and `spawn-in-pty` takes ELF
    bytes and a path.
  - `TA9` is `new` because `AT_FDCWD` is a hardcoded constant in the only
    `openat` body, `lib/lowering/tal/sys.chiral:33`, and no crossing in the tree
    takes a dirfd.
  - `TA10` is `new` because the tree's one grant carrier is a `(List Str)`
    (`prog/prapanca/core/types.chiral:64-65`) read at zero sites, and `E43` is
    DESIGNED with no code (`docs/banks/capability.md:242-246`).
  - `TA12` is `new` because `MAP.md:86` states in the tree's own words that
    nothing checks the rule.
  - `TA4` and `TA7` are `new` as decisions. Both settle a shape between built
    alternatives rather than build one, which is the `coding-turn/A6` precedent.
  - `TA1`, `TA2`, `TA3`, `TA5` and `TA11` are `bind` or `connect` and each names
    the built thing it surfaces: a routed lowering with no port declaration, a
    declaration in the wrong directory, a flag word set in one file and misstated
    in two others, a registered TAL body missing one routing-table line, and a
    `subtype` mechanism that is IMPLEMENTED and unapplied to grants.

### What this arc does not take

- **The decomposition half of condition 1.** [[arcs/coding-turn-arc]] owns it:
  the tool as a closed sum, a `Flow` node that fires one, the `RunManifest`, and
  `overflow-guard`'s first caller. This arc adds no engine node and widens no
  `Flow` constructor.
- **Three rows of that arc overlap this one, and the boundary is not settled
  here.** That arc is to be revisited against the two 2026-09-09 decisions and
  its rows may move or die. **No row of it is edited by this run**, and the
  revisit resolves each overlap.
  - `coding-turn/A4`, the grant checked at the one dispatch point with an
    ungranted call yielding a typed refusal, overlaps `tool-authority/TA10`. `A4`
    checks a `(List Str)` inside one process; `TA10` asks what the grant is when
    the enforcement is a process boundary. Whether `A4` survives as an in-process
    accounting beside `TA10`, or is subsumed by it, is the revisit's to rule.
  - `coding-turn/A2`, the four built tools reached through the tool sum,
    overlaps `tool-authority/TA8` at `ag-bash`. Both turn on author call 1: if
    `bash` leaves the goal toolset, `A2`'s fourth arm dies and `TA8`'s child gets
    a set worth stating.
  - `coding-turn/A3`, `assemble-prompt` rendering the granted tool names,
    overlaps `TA10` at the carrier. `A3` renders a `(List Str)`; `TA10` replaces
    it. The revisit decides whether `A3` is rewritten or held.
- **[[goals/ownership-and-trust]] and the `OT` track.**
  `docs/goals/README.md:57` records that goal deferred out of scope 2026-08-31,
  with every row in its arc deferred. This arc takes its rows under
  [[goals/coding-agent]] and cites `E43` as the element the work eventually
  meets, which keeps the deferral honest: `E43` is minted at
  `docs/elements/catalog.md:170`, so citing it satisfies the deferral rule. **No
  row here mints into `OT`, and no row is written into
  `docs/arcs/ownership-and-trust-arc.md`.**
- **Attestation, and revocation with audit.** `E43`'s AUTH/AUDIT half and the
  revocation chain at `docs/banks/capability.md:242-246` are post-crypto and wait
  on [[arcs/crypto-primitives-arc]]. The shape of the ask does not.
- **Enumeration.** `E148` and `E149` (`docs/elements/catalog.md:463-464`) are
  [[goals/coding-agent]] condition 3. `ls` and `find` are the two goal tools that
  need naming authority for a reason this arc does not address.
- **Parameterizing a porttype with a path.** `decision-tool-capability` §3
  disposes of it and this arc does not reopen it.
  `lib/typing/refine.chiral:13-18` is integer-only and `(porttype Pool (n I64))`
  at `lib/ports/pool.port:13` works because its parameter is an `I64`.
- **Gating on content.** Inspecting what is written to a terminal or handed to a
  shell loses to quoting, `$()` and `eval`, and is what capability systems exist
  to avoid.
- **[[arcs/native-window-arc]]'s claim on `sock-send-fd`.**
  `records/author-calls.md` carries an `unreviewed` row asking which arc owns the
  fd-passing crossing, routed 2026-09-06 to `native-window/W5` with the routing
  recorded as not a ruling. `TA5` takes the one routing-table line requirement 3
  needs and takes neither `sock-listen` nor `sock-accept`, which that row also
  names and which serve a screen rather than a grant. **The call stays open and
  this run writes no row to `records/author-calls.md`.**

## Resume state

Opened 2026-09-09 against [[goals/coding-agent]] condition 1, second half, on
the day [[decisions/decision-orchestration-boundary]] and
[[decisions/decision-tool-capability]] were committed. Twelve rows, six
requirements, none started and none designed. Rows spell `TA`.

**Three author calls are open and none blocks this arc.** They are
`decision-tool-capability`'s own three, and each is carried on the rows it
governs rather than treated as a gate. [[arcs/tuning-arc]] is the precedent for
drawing a roster while a call is out. This run answers none of them and writes no
row to `records/author-calls.md`.

1. Does `bash` exist in the goal toolset at all. Governs `TA8`, and through the
   G1-to-G5 back-edge it governs the value of every row in G1 through G4.
2. Is the coding agent ever the holder of naming authority, or is it always
   handed its descriptors. Governs `TA2`, and decides whose port floor `TA1` and
   `TA12` complete.
3. Which spawn shape is the model, the argv one or the ELF-bytes one. Governs
   `TA7`, and decides whether G3 is on the path at all.

**The row to design first is `TA5`.** It is one table entry against a body that
is already built and registered, it makes requirement 3 observable by a single
grep, and it turns on no open call. `TA1` and `TA3` are the next two for the same
reason: each is a placement or a comment against a lowering that already decided
the question.

⚑ **One measurement this arc was opened on was wrong, and is corrected here.**
The brief read `open-create` sets `O_CLOEXEC` and `open-rw` does not, taken from
the comment at `lib/ports/file.port:14`. The lowering sets `O_CLOEXEC` on both:
`lib/lowering/tal/sys.chiral:647` gives `open-rw` flags `0x80102 = 524546`, which
is `O_RDWR｜O_NOCTTY｜O_CLOEXEC`, and `:653` records the `MFD_CLOEXEC` precedent
it was copied from. **The leak is `openat`**, whose body hardcodes flags to `0`
at `lib/lowering/tal/sys.chiral:34`, which has no declaration in `lib/ports/` at
all, and which the module resolver and three shipping programs use. That
correction is why `TA1` exists and why `TA3` is a documentation repair rather
than a flag change.

⚑ **`docs/goals/coding-agent.md`'s Arcs table lists one arc and
`docs/goals/README.md:56` reads "one arc opened, three conditions unopened".**
Both are stale as of this file. Neither is in this run's write scope, which is
this file and the `docs/arcs/README.md` row.

Every measurement above was taken against the working tree on 2026-09-09 and
each cites its own `file:line`. Four counts hold this arc's premise and each was
re-verified: `sock-send-fd` occurrences in
`lib/lowering/tal/crossing-wraps.chiral` (0), `.port` declarations of `openat`
(0), `.port` declarations of `raw-proc-spawn` (0), and reads of `Expert.tools`
(0).
