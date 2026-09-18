---
node: homing-triage
layer: measurement
related: [arcs/README, elements/catalog, elements/ledger, records/author-calls, records/findings, goals/README, goals/self-hosting, index]
status: current
updated: 2026-09-18
---

# Homing triage: the catalog elements no arc rosters

144 of the 186 catalog elements hold no roster row, measured 2026-09-10. This
file proposes a home for each and rules on none. §Where this stands is current.

## Method

**Homed means a roster row whose element cell carries the number.** An arc that
names an element in prose has not claimed it. ⚑ **The rest of this paragraph is
the tool before `8a7b644`.** `ledger-lint` check AE conflated the two:
`tools/ledger-lint/ledger-lint.py:1883` matched `\bE(\d+)\b` over a whole arc
file, so a boundary section, a dependency note and a rejection read as coverage.

The worklist came from the roster cells alone:

```
python3 - <<'PY'
import importlib.util, glob, os, re, sys
spec=importlib.util.spec_from_file_location("pack","tools/pack/pack.py")
pack=importlib.util.module_from_spec(spec); sys.argv=["pack.py"]; spec.loader.exec_module(pack)
homed=set()
for f in sorted(glob.glob(os.path.join(pack.ARCDIR,"*-arc.md"))):
    for line in pack.roster_all(open(f).read()):
        c=[x.strip() for x in line.strip().strip("|").split("|")]
        homed.update(pack.row_elements(c[-1]))
nums=[m.group(1) for m in (re.match(r"^\| E(\d+) ",l) for l in open("docs/elements/catalog.md")) if m]
print(" ".join("E"+n for n in nums if "E"+n not in homed))
PY
```

It printed 144 elements, reproduced 2026-09-10. The table below holds 144 rows,
one per element, in ascending order. `state` and `track` are read from
`docs/elements/ledger.md`; `subject` is compressed from `docs/elements/catalog.md`.

**38 of the 144 are named in arc prose and rostered by nobody.** Three of those
mentions are evidence against ownership rather than for it:
`docs/arcs/tool-authority-arc.md:274` names E148 and E149 in its boundary section
and says `ls` and `find` need naming authority for a reason that arc does not
address; `docs/arcs/scriba-arc.md:76` is blocked on E132; and
`docs/arcs/independent-judgment-arc.md:121` refuses E166 on two independent
grounds. A fourth is a rejection of its own kind:
`docs/arcs/enforcement-arc.md:504` records of E169 that *"no arc names it
(UNS-45)"*.

Matching was on subject. The ledger category records a minting-era bucket, and
the tree already shows it crossing arcs: `VAL` spreads across seven arcs and
`enforcement` rosters `VAL`, `CG` and `EF` rows. 18 of the 28 arcs roster no minted element at all, so
each arc's stated scope was read rather than its roster inferred from.

### The four classes behind a `-` home

| class | what it marks | count |
|---|---|---|
| **Q1** | a built self-hosting-core element whose residue no arc's requirement names. `docs/goals/self-hosting.md:70` says that goal carries no arc and none is owed, and `docs/goals/README.md:142` states the shape: a goal held by a standing gate carries no arc, and that is its finished shape. Whether such an element owes a roster row at all is the author's | 55 |
| **Q2** | an unbuilt language-feature element no goal states. An arc cannot open against an ambition the repo has not claimed, so a goal is owed first | 4 |
| **Q3** | `superseded`. E86 went to E99 and owes no work | 1 |
| **Q4** | no arc states a requirement the subject could serve, and no goal does either. E37, a test-only PNG writer | 1 |

### Counts

| verdict | rows |
|---|---|
| `clear` | 42 |
| `author-call` | 81 |
| `new-arc` | 21 |
| **total** | **144** |

Four new arcs are proposed across the 21 `new-arc` rows: `orchestration-engine`
(14), `syscall-custody` (5), `surface-syntax` (1) and `runtime-loading` (1).

## The triage

| element | state | track | subject | proposed home | verdict | evidence |
|---|---|---|---|---|---|---|
| E1 | `built` | `SH` | S-expression reader, lexer and parser | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E2 | `part` | `SH` | surface elaborator: name to de Bruijn, desugar, profile/target verify | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E3 | `built` | `SH` | NbE: eval, quote, conv, eta | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E4 | `built` | `SH` | bidirectional infer/check, universes, cumulativity | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E5 | `built` | `SH` | QTT quantity semiring and usage-vector linearity | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E6 | `built` | `SH` | data: constructors, case coverage, ctor-param unification | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E7 | `built` | `SH` | strict positivity and variance analysis | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E8 | `built` | `SH` | linear-kind decision for data | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E9 | `built` | `SH` | refinement decision procedure: interval-with-holes, symbolic `entails` | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E10 | `built` | `SH` | path sensitivity and occurrence typing | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E11 | `built` | `SH` | totality: structural and numeric-measure termination | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E12 | `built` | `SH` | effect membrane rules, pure `->` against process `=>`, built as a model and reached by nothing | [[arcs/enforcement-arc]] | **clear** | `docs/arcs/enforcement-arc.md:25` |
| E13 | `built` | `SH` | term de-Bruijn machinery, zero importers | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E14 | `built` | `SH` | pretty-printer, display and non-trusted, zero importers | [[arcs/diagnostics-arc]] | **clear** | `docs/arcs/diagnostics-arc.md:59` |
| E15 | `built` | `SH` | reference interpreter, golden semantics, zero importers | [[arcs/enforcement-arc]] | **clear** | `docs/arcs/enforcement-arc.md:49` |
| E19 | `built` | `SH` | x86-64 codegen: encoding, SysV, relocation, Mach interface | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E20 | `design` | `SH` | typed W^X seal: `MapRW` sealed to `MapRX`, unbuilt | - (now `substrate-floor/SU1`) | **author-call**, ruled 2026-09-18 | `records/author-calls.md:100`; Q1 no longer holds |
| E21 | `built` | `SH` | mmap as the arena, bump-allocator base and end | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E22 | `design` | `SH` | memory allocator, region types, GC outside the TCB, beyond the bump arena | [[arcs/memory-discipline-arc]] | **clear** | `docs/arcs/memory-discipline-arc.md:67` |
| E23 | `built` | `SH` | FFI trampoline, discharged by the oracle's eviction | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E24 | `built` | `SH` | I64 two's-complement arithmetic | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E25 | `built` | `SH` | byte cells `[len][payload]` | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E26 | `built` | `SH` | alarms and control flow: every refusal a closed sum, one `halt` crossing | [[arcs/diagnostics-arc]] | **clear** | `docs/arcs/diagnostics-arc.md:52` |
| E27 | `built` | `SH` | data-structure registries: dict and set become chirality maps | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E28 | `built` | `SH` | `mmap`/`munmap`/`mprotect`/`close` as sys crossings | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E29 | `built` | `SH` | sockets: socket, connect, bind, listen, accept, send, recv | [[arcs/native-window-arc]] | **clear** | `docs/arcs/native-window-arc.md:41` |
| E30 | `built` | `SH` | fd passing: `sendmsg` plus `SCM_RIGHTS` | [[arcs/tool-authority-arc]] or [[arcs/native-window-arc]] | **author-call** | `docs/arcs/tool-authority-arc.md:160` against `docs/arcs/native-window-arc.md:57` |
| E31 | `built` | `SH` | `poll`/`select`, the `pollfd` struct shape | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E32 | `built` | `SH` | `clock_gettime`, `exit`, env access | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E34 | `built` | `SH` | ELF executable format, ahead-of-time output | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E35 | `design` | `SH` | Wayland wire protocol | [[arcs/native-window-arc]] | **clear** | `docs/arcs/native-window-arc.md:41` |
| E36 | `design` | `SH` | niri IPC event stream | [[arcs/native-window-arc]] | **author-call** | the arc's four requirements name xdg-shell, seat input, text and resize, and a compositor IPC stream is none of them |
| E37 | `design` | `SH` | PNG writer, test-only | - | **author-call** | no arc states an image-output requirement |
| E38 | `design` | `SH` | graded cost and coeffect semiring | [[arcs/emitted-speed-arc]] or [[arcs/memory-discipline-arc]] | **author-call** | `docs/arcs/emitted-speed-arc.md:224` against `docs/arcs/memory-discipline-arc.md:67` |
| E39 | `design` | `SH` | effect algebra and typed rows, alarms and counter-effects | [[arcs/enforcement-arc]] or a goal that is owed | **author-call** | `docs/arcs/enforcement-arc.md:49` holds the tal shadow of the effect row; the surface algebra has no goal |
| E41 | `design` | `SH` | region types, retiring runtime offset and bounds checks | [[arcs/memory-discipline-arc]] or [[arcs/enforcement-arc]] | **author-call** | `docs/arcs/enforcement-arc.md:572` is already an open call on which arc owns the bounds class |
| E42 | `built` | `SH` | runtime supervisor: critical sections, register-root custody, scheduler | [[arcs/bridge-arc]] or [[arcs/ownership-and-trust-arc]] | **author-call** | `docs/arcs/bridge-arc.md:89` assigns it to `bridge/C4` and the roster cell at `:88` carries only `E40`, `E56` |
| E43 | `design` | `OT` | component broker: AUTH and AUDIT, grant, revoke, audit | [[arcs/ownership-and-trust-arc]] | **clear** | `docs/arcs/ownership-and-trust-arc.md:30`, and `docs/arcs/tool-authority-arc.md:268` declines it |
| E44 | `design` | `OT` | whole-assembly conformance: totality, non-interference, tier weight | [[arcs/enforcement-arc]] and [[arcs/ownership-and-trust-arc]] | **author-call** | totality is `docs/arcs/enforcement-arc.md:42`; the other two are `docs/arcs/ownership-and-trust-arc.md:30` |
| E45 | `design` | `OT` | reflective floor: what is reconfigurable from inside | [[arcs/ownership-and-trust-arc]] | **clear** | `docs/arcs/ownership-and-trust-arc.md:30` |
| E46 | `design` | `OT` | proof-presentation and auditor layer, Isar-equivalent | [[arcs/ownership-and-trust-arc]] | **clear** | `docs/arcs/ownership-and-trust-arc.md:30` |
| E47 | `design` | `SH` | sized types, termination promotion | - | **author-call** | Q2 |
| E48 | `design` | `SH` | dependent records and telescopes, field dependence | - | **author-call** | Q2 |
| E49 | `design` | `SH` | real surface syntax, stage 4 | NEW: surface-syntax | **new-arc** | serves [[goals/readable-surface]]; its two arcs are diagnostics and file-types and neither states surface syntax |
| E50 | `built` | `SH` | bidirectional and mutual termination, lexicographic measures | - | **author-call** | Q2 |
| E51 | `built` | `SH` | sys-face linkage: upper-effectful chirality reaches syscalls through `sys-tal` | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E52 | `design` | `OT` | kernel-core certificate split: spec artifact plus a small re-checking core | [[arcs/module-split-arc]] or [[arcs/ownership-and-trust-arc]] | **author-call** | `docs/arcs/module-split-arc.md:68` against `docs/arcs/ownership-and-trust-arc.md:43` |
| E54 | `design` | `OT` | split-provider and split-role: guarded combine, per-axis tiers | [[arcs/ownership-and-trust-arc]] | **clear** | `docs/arcs/ownership-and-trust-arc.md:30` |
| E55 | `design` | `OT` | C-bridge evidence elaborator, attestation first | [[arcs/bridge-arc]] | **clear** | `docs/arcs/bridge-arc.md:59` |
| E57 | `design` | `OT` | staging and binding-time modality: link, load and runtime in the type | [[arcs/ownership-and-trust-arc]] | **clear** | `docs/arcs/ownership-and-trust-arc.md:30` |
| E58 | `design` | `OT` | `reflect-typed`: staged metaprogramming over typed terms | [[arcs/ownership-and-trust-arc]] | **clear** | `docs/arcs/ownership-and-trust-arc.md:30` |
| E59 | `design` | `OT` | taint tracking, the security trio's first member | [[arcs/native-protocol-arc]] or [[arcs/ownership-and-trust-arc]] | **author-call** | `docs/arcs/native-protocol-arc.md:49` needs it for `N5`; `E44`'s row calls IFC E44's |
| E60 | `design` | `OT` | constant-time enforcement, preserve-check's first customer | [[arcs/native-protocol-arc]] | **clear** | `docs/arcs/native-protocol-arc.md:49`, row `N5` at `:64` |
| E61 | `design` | `OT` | Adhikara: capability protocol over the wire | [[arcs/native-protocol-arc]] or [[arcs/ownership-and-trust-arc]] | **author-call** | `docs/arcs/native-protocol-arc.md:41` owns the wire; the capability discipline is the OT track |
| E62 | `design` | `OT` | bootstrap floor: cross-checked independent runtimes | [[arcs/independent-judgment-arc]] or [[arcs/ownership-and-trust-arc]] | **author-call** | `docs/arcs/independent-judgment-arc.md:78` against `docs/arcs/ownership-and-trust-arc.md:41` |
| E63 | `design` | `OT` | cheri-floor: the B mark carried into silicon | [[arcs/ownership-and-trust-arc]] | **clear** | `docs/arcs/ownership-and-trust-arc.md:30` |
| E64 | `built` | `SH` | JSON value tree | [[arcs/transport-arc]] or [[arcs/file-types-arc]] | **author-call** | `docs/arcs/transport-arc.md:151` against `docs/arcs/file-types-arc.md:43` |
| E65 | `built` | `SH` | HTTP request and SSE streaming | [[arcs/transport-arc]] | **clear** | `docs/arcs/transport-arc.md:151` |
| E66 | `built` | `SH` | FSM engine, the Mealy `Step` spine | NEW: orchestration-engine | **new-arc** | serves [[goals/local-ai]] condition 1; `docs/goals/local-ai.md:53` gives that condition only transport and unit-lane |
| E67 | `built` | `SH` | manas orchestration profile and coordinator cycle | NEW: orchestration-engine | **new-arc** | `docs/goals/local-ai.md:53` |
| E68 | `built` | `SH` | model-server backend seam, OpenAI-compatible | NEW: orchestration-engine | **new-arc** | `docs/goals/local-ai.md:53` |
| E69 | `built` | `SH` | closure conversion and quantities-to-tal | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E73 | `design` | `OT` | outbound confinement membrane, the bridge's outbound half | [[arcs/bridge-arc]] | **clear** | `docs/arcs/bridge-arc.md:54` |
| E74 | `design` | `OT` | tier carrier: a per-axis split-role tier riding the type | [[arcs/ownership-and-trust-arc]] | **clear** | `docs/arcs/ownership-and-trust-arc.md:30` |
| E75 | `design` | `SH` | typed ABI-layout abstraction above the tal floor | [[arcs/native-protocol-arc]] | **clear** | `docs/arcs/native-protocol-arc.md:41`, row `N9` at `:68` |
| E76 | `built` | `SH` | syscall chokepoint: an enumerated crossing-to-number registry | NEW: syscall-custody | **new-arc** | serves [[goals/enforcement]]; `docs/arcs/tool-authority-arc.md:4` lists `decision-syscall-governance` and no arc claims it |
| E77 | `design` | `SH` | rung-1 seccomp default-deny derived from E76's permitted set | NEW: syscall-custody | **new-arc** | serves [[goals/enforcement]] |
| E78 | `design` | `SH` | number-in-type attenuation: the `ti-sys` immediate in a refinement | NEW: syscall-custody | **new-arc** | serves [[goals/enforcement]] |
| E79 | `built` | `SH` | mutual and forward data groups: SCC scan plus group judge | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E80 | `design` | `OT` | capability reification to `main`: the profile grants the entry point | [[arcs/tool-authority-arc]] or [[arcs/ownership-and-trust-arc]] | **author-call** | `docs/arcs/tool-authority-arc.md:166` against `docs/arcs/ownership-and-trust-arc.md:30` |
| E86 | `superseded` | `SH` | generic 3-arg `ioctl` crossing and typed terminal wrappers | - | **author-call** | Q3, superseded by E99 |
| E87 | `built` | `SH` | import resolution and module bundler, two live providers pinned against each other | [[arcs/enforcement-arc]] | **clear** | `docs/arcs/enforcement-arc.md:315` |
| E88 | `built` | `SH` | mark and region system in scriba | [[arcs/scriba-arc]] | **clear** | `docs/arcs/scriba-arc.md:12` |
| E89 | `built` | `SH` | arena startup: the reserve and commit split | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E90 | `built` | `SH` | `nb-arena-grow` TAL wrapper, mremap doubling | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E91 | `built` | `SH` | growing allocator, replacing `x-trap` with a retry loop | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E92 | `built` | `SH` | effect chain decoupling, `try-dispatch` in the command loop | [[arcs/scriba-arc]] | **clear** | `docs/arcs/scriba-arc.md:12`, and the ledger row records the rehome to `scriba:S32` |
| E93 | `built` | `SH` | B1 multi-pass signature pre-scan | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E94 | `flight` | `SH` | B1 form and type capacity limit raise | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E95 | `built` | `SH` | B1 effectful mutual recursion | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E96 | `built` | `SH` | bitwise op family `band`, `bor`, `bxor`, `shl` at the surface | [[arcs/emitted-speed-arc]] | **clear** | `docs/arcs/emitted-speed-arc.md:252` |
| E97 | `built` | `SH` | B1 lowering skip-chain diagnostics | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E98 | `built` | `SH` | honest crossing table: `nb-read-key` as a real raw read | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E99 | `built` | `SH` | honest ioctl surface: per-family out-cell allocation | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E100 | `built` | `SH` | 2-type-param plus fn-param call lowering through B1 | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E101 | `built` | `SH` | sexp-reader error context: line, column, depth, last-opened form | [[arcs/diagnostics-arc]] | **clear** | `docs/arcs/diagnostics-arc.md:52` |
| E102 | `flight` | `SH` | sexp-reader follow-up: per-function paren delta, depth guard, form splitter | [[arcs/diagnostics-arc]] | **clear** | `docs/arcs/diagnostics-arc.md:52` |
| E103 | `built` | `SH` | terminal raw-mode fidelity, a `cfmakeraw` equivalent | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E104 | `built` | `SH` | native pty acquisition crossings | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E106 | `built` | `SH` | linear collection of caps: `SockVec` and `lincoll` | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E107 | `built` | `SH` | porttype-consuming native close family | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E108 | `built` | `SH` | right-shift surface ops `shr` and `sar` | [[arcs/emitted-speed-arc]] | **clear** | `docs/arcs/emitted-speed-arc.md:252` |
| E109 | `built` | `SH` | `bput-u16-le`, the little-endian u16 writer | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E110 | `built` | `SH` | close-on-exec fd hygiene on the pty path | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E111 | `built` | `SH` | bounded native cell array: pool-backed `(Grid n)` plus a 16-byte Cell codec | [[arcs/display-calculus-arc]] | **clear** | `docs/arcs/display-calculus-arc.md:79`, cashed by row `C1` at `:115` |
| E112 | `built` | `SH` | structured side-channel framing: the APC transport codec | [[arcs/vocabulary-arc]] | **clear** | `docs/arcs/vocabulary-arc.md:55` |
| E113 | `built` | `SH` | `Pool` region read and peek crossing | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E120 | `built` | `SH` | native `Pool` representation: write, read and close bodies | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E121 | `built` | `SH` | `fcntl`/`F_GETFD` crossing, the cloexec readback | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E122 | `built` | `SH` | native `pool-create` mint: memfd, ftruncate, mmap, box | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E123 | `built` | `SH` | native word carrier for handle porttypes | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E124 | `built` | `SH` | `adopt-fd`: a raw `I64` fd becomes a linear `Fd` | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E125 | `built` | `SH` | native `sock-send` and `sock-recv` | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E126 | `built` | `SH` | native `socketpair`, two connected `Sock` caps | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E127 | `built` | `SH` | native `sock-connect`, the real-client-networking follow-on | [[arcs/native-protocol-arc]] | **clear** | `docs/arcs/native-protocol-arc.md:41` |
| E128 | `design` | `SH` | APC handshake: the negotiation that sets `term-structured?` | [[arcs/vocabulary-arc]] or [[arcs/native-window-arc]] | **author-call** | a terminal capability negotiation sits under neither arc's stated requirements |
| E129 | `built` | `SH` | native AF_INET TCP `sock-connect-in` | [[arcs/transport-arc]] | **clear** | `docs/arcs/transport-arc.md:151` |
| E130 | `built` | `SH` | native HTTP/1.1 client, the transport swap | [[arcs/transport-arc]] | **clear** | `docs/arcs/transport-arc.md:151` |
| E131 | `built` | `SH` | native SSE streaming, retiring the `chat-*` shim | [[arcs/transport-arc]] | **clear** | `docs/arcs/transport-arc.md:158` |
| E132 | `design` | `SH` | runtime dynamic loading: a resident binary loads a fresh artifact | NEW: runtime-loading | **new-arc** | serves [[goals/local-ai]] condition 2; `docs/arcs/scriba-arc.md:76` is blocked on it and owns it nowhere |
| E133 | `built` | `SH` | manas core types: `GateRule`, `Config`, `RunManifest` and the rest | NEW: orchestration-engine | **new-arc** | `docs/goals/local-ai.md:53` |
| E134 | `built` | `SH` | the GATE and router: which agents fire, pure `->` | NEW: orchestration-engine | **new-arc** | `docs/goals/local-ai.md:53` |
| E135 | `built` | `SH` | config binding, slot to model, the add-backends seam | NEW: orchestration-engine | **new-arc** | `docs/goals/local-ai.md:53` |
| E136 | `built` | `SH` | match, assemble and stop, the pure-core remainder | NEW: orchestration-engine | **new-arc** | `docs/goals/local-ai.md:53` |
| E137 | `built` | `SH` | `Backend` as a linear porttype | NEW: orchestration-engine | **new-arc** | `docs/goals/local-ai.md:53` |
| E138 | `built` | `SH` | the multi-agent run loop: gate, fan out, combine | NEW: orchestration-engine | **new-arc** | `docs/goals/local-ai.md:53` |
| E139 | `built` | `SH` | `be-log`, the worker seam op | NEW: orchestration-engine | **new-arc** | `docs/goals/local-ai.md:53` |
| E140 | `built` | `SH` | profiles and the doc-refine pipeline as typed values | NEW: orchestration-engine | **new-arc** | `docs/goals/local-ai.md:53` |
| E141 | `built` | `SH` | golden-manifest conformance | NEW: orchestration-engine | **new-arc** | `docs/goals/local-ai.md:53`, and `docs/arcs/coding-turn-arc.md:171` consumes the manifest without owning it |
| E142 | `design` | `SH` | trust-zone capability tokens as erased proof tokens | NEW: orchestration-engine | **new-arc** | `docs/goals/local-ai.md:53` |
| E143 | `design` | `SH` | dependent config-coverage type | NEW: orchestration-engine | **new-arc** | `docs/goals/local-ai.md:53` |
| E144 | `built` | `SH` | non-word `Str` porttype carrier | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E145 | `built` | `SH` | `be-peek` laundering peel for linear str-porttypes | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E147 | `built` | `SH` | nested and higher-order defunctionalization | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E149 | `design` | `SH` | filesystem mutation crossings: `unlink`, `rename`, `mkdir` | [[arcs/zero-python-arc]] or an unopened coding-agent arc | **author-call** | `docs/arcs/tool-authority-arc.md:274` declines it and routes it to [[goals/coding-agent]] condition 3, which holds no arc; `docs/arcs/zero-python-arc.md` rosters its read half `E148` at `Z2` |
| E151 | `built` | `SH` | string comparison gets an owner: `str-cmp` and the string module | [[arcs/text-tools-arc]] | **clear** | `docs/arcs/text-tools-arc.md:207` |
| E152 | `built` | `SH` | polymorphic comparator-passed stable merge sort | [[arcs/text-tools-arc]] | **clear** | `docs/arcs/text-tools-arc.md:207`, cashed by the coverage row at `:38` |
| E153 | `design` | `SH` | `F64` float tower: type, literals, arithmetic, SSE codegen | - | **author-call** | Q2, and `docs/goals/coding-agent.md:85` holds a line against `F64` at the surface |
| E154 | `design` | `SH` | per-module label namespace at lowering | [[arcs/enforcement-arc]] | **clear** | `docs/arcs/enforcement-arc.md:51` |
| E155 | `built` | `SH` | multi-root module search path and collision diagnosis | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E156 | `built` | `SH` | `row-infer` adopts the sort owner | [[arcs/text-tools-arc]] | **clear** | `docs/arcs/text-tools-arc.md:207`, cashed by the coverage row at `:39` |
| E159 | `built` | `SH` | linear-result externs must be declared `=>` | - | **author-call** | Q1, `docs/goals/README.md:142` |
| E160 | `built` | `SH` | the module coordinate as a checked declaration | [[arcs/bridge-arc]] | **clear** | `docs/arcs/bridge-arc.md:52`, and row `C3` is the declaration this element supplies |
| E161 | `built` | `SH` | the module datasheet: a fixed-schema record the compiler fills | [[arcs/module-split-arc]] or [[arcs/file-types-arc]] | **author-call** | `docs/arcs/module-split-arc.md:68` against `docs/arcs/file-types-arc.md:38`, which reads the datasheet at `:107` |
| E162 | `design` | `SH` | custody of a permitted set: who may widen it, and how that is recorded | NEW: syscall-custody | **new-arc** | serves [[goals/enforcement]] |
| E164 | `design` | `SH` | C6: make the governed path the cheap path, dev-profile ambient threading | NEW: syscall-custody | **new-arc** | serves [[goals/enforcement]] |
| E165 | `design` | `SH` | the remaining private de-duplicators adopt their owners | [[arcs/text-tools-arc]] or none owed | **author-call** | `docs/arcs/text-tools-arc.md:207` owns the primitive; the adoption sites are compiler-internal |
| E166 | `built` | `?` | a conforming `Mach` that emits C, and the DDC leg it unlocked | [[arcs/independent-judgment-arc]] or [[arcs/ownership-and-trust-arc]] | **author-call** | `docs/arcs/independent-judgment-arc.md:121` refuses it as a leg on two grounds, so the mention is a rejection |
| E167 | `design` | `?` | `tal-c`: the second C seam, emitting C from `tal` | [[arcs/independent-judgment-arc]] or [[arcs/ownership-and-trust-arc]] | **author-call** | the same two candidates as E166, and the refusal at `docs/arcs/independent-judgment-arc.md:147` states the test it must pass |
| E168 | `built` | `SH` | the native test system the corpus lands in | [[arcs/enforcement-arc]] | **clear** | `docs/arcs/enforcement-arc.md:315` |
| E169 | `design` | `SH` | behavioural coverage of `lower.chiral`, both instruments | [[arcs/enforcement-arc]] | **author-call** | `docs/arcs/enforcement-arc.md:504` records `no arc names it (UNS-45)` and leaves adopt-or-mint to a design stage |
| E170 | `design` | `SH` | the corpus lands on the floor: the 709-function migration | [[arcs/enforcement-arc]] | **clear** | `docs/arcs/enforcement-arc.md:315` |
| E171 | `design` | `SH` | the `->`/`=>` membrane enforced at the call | [[arcs/enforcement-arc]] | **clear** | `docs/arcs/enforcement-arc.md:25` |
| E172 | `design` | `SH` | semantic file extensions, and the source tree by altitude | [[arcs/file-types-arc]] | **clear** | `docs/arcs/file-types-arc.md:38` |

## What the author works from

### The `new-arc` proposals, 21 rows in four arcs

| proposed arc | rows | the goal it serves | what it would own |
|---|---|---|---|
| `orchestration-engine` | E66, E67, E68, E133, E134, E135, E136, E137, E138, E139, E140, E141, E142, E143 | [[goals/local-ai]] condition 1 | the prapañca engine itself. `docs/goals/local-ai.md:40` calls E133 to E143 *"the engine's element set"*, and `:53` gives condition 1 only [[arcs/transport-arc]] for reachability and [[arcs/unit-lane-arc]] for the model of computation beneath it. [[arcs/part-split-arc]] moves the files and [[arcs/coding-turn-arc]] consumes the manifest. Neither owns the engine |
| `syscall-custody` | E76, E77, E78, E162, E164 | [[goals/enforcement]] | the permitted set and who may widen it: the chokepoint registry at ENFORCED, the seccomp rung derived from it, attenuation carried in a refinement, custody of the manifest, and the profile ergonomics `decision-deployment-custody` names. `docs/arcs/tool-authority-arc.md:4` lists `decision-syscall-governance` among its authorities and its six requirements are about path naming, so it reaches none of these |
| `surface-syntax` | E49 | [[goals/readable-surface]] | the real surface, stage 4. That goal's two arcs are [[arcs/diagnostics-arc]] and [[arcs/file-types-arc]], and neither states syntax |
| `runtime-loading` | E132 | [[goals/local-ai]] condition 2 | a resident binary loading a freshly compiled artifact. `docs/arcs/scriba-arc.md:76` blocks `scriba/S6` on it and `:84` repeats the block, which is a dependency rather than a claim |

That count is 14 plus 5 plus 1 plus 1, which is 21.

### The `author-call` rows, 81, gathered by the question

**A. Does a built element under a goal that carries no arc owe a roster row?**
55 rows, class Q1. E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E13, E19, E20,
E21, E23, E24, E25, E27, E28, E31, E32, E34, E51, E69, E79, E89, E90, E91, E93,
E94, E95, E97, E98, E99, E100, E103, E104, E106, E107, E109, E110, E113, E120,
E121, E122, E123, E124, E125, E126, E144, E145, E147, E155, E159.
`docs/goals/self-hosting.md:70` says none is owed and `docs/goals/README.md:142`
states why. A yes here opens an arc against a goal the BUILD RULE already holds.
A no exempts 55 rows from homing and shrinks the gap to 89.

**B. Is a goal owed before these four can be scheduled?** E47 sized types, E48
dependent records, E50 lexicographic termination measures, E153 the `F64` float
tower. No goal states any of them, and `docs/goals/coding-agent.md:85` holds a
line against `F64` reaching the surface at all.

**C. Is a `superseded` row exempt from homing?** E86, superseded by E99.

**D. Which arc owns the bounds and region class?** E41 region types.
`docs/arcs/enforcement-arc.md:572` is already an open call of this shape for the
bounds class, and E41 is the type-level half the same question reaches.

**E. Where does the cost grading go?** E38, the coeffect semiring.
`docs/arcs/emitted-speed-arc.md:224` grades every transformation;
`docs/arcs/memory-discipline-arc.md:67` selects a discipline by profile and its
`M5` wants E38's static size bound.

**F. Does the surface effect algebra belong to enforcement?** E39.
`docs/arcs/enforcement-arc.md:49` owns the effect row's tal shadow through E70.
The algebra above it has no goal.

**G. Straddles inside the `OT` track.** E44 splits three ways and does not sit in
one arc whole: totality is `docs/arcs/enforcement-arc.md:42`, non-interference and
tier weight are `docs/arcs/ownership-and-trust-arc.md:30`. E52 splits between the
trusted-core boundary at `docs/arcs/module-split-arc.md:68` and `ownership/O3` at
`docs/arcs/ownership-and-trust-arc.md:43`. E59 taint tracking, E61 Adhikara and
E62 the bootstrap floor each have a second candidate outside the track:
[[arcs/native-protocol-arc]] for the first two, [[arcs/independent-judgment-arc]]
for the third. E80 splits between `docs/arcs/tool-authority-arc.md:166` and the
track. E42 is `built`/`SH` at `docs/elements/ledger.md:115`, and
`docs/arcs/bridge-arc.md:89` assigns it to `bridge/C4` while the roster cell at
`:88` carries only `E40` and `E56`.

**H. The two C legs.** E166 and E167.
`docs/arcs/independent-judgment-arc.md:121` refuses E166 as a leg on two
independent grounds and `:147` records the trap any candidate must pass, so that
arc names them without taking them. [[arcs/ownership-and-trust-arc]] `O1` holds
DDC and is deferred.

**I. Adopt or mint.** E169. `docs/arcs/enforcement-arc.md:504` says *"no arc names
it (UNS-45), so whether this row adopts E169 or mints is the design stage's"*
call.

**J. The remaining pairwise straddles.** E30 fd passing, between
`docs/arcs/tool-authority-arc.md:160` and `docs/arcs/native-window-arc.md:57`.
E64 JSON, between `docs/arcs/transport-arc.md:151` and
`docs/arcs/file-types-arc.md:43`. E128 the APC handshake, a terminal capability
negotiation under neither [[arcs/vocabulary-arc]] nor [[arcs/native-window-arc]].
E149 filesystem mutation, which `docs/arcs/tool-authority-arc.md:274` routes to
[[goals/coding-agent]] condition 3, a condition holding no arc, while
[[arcs/zero-python-arc]] rosters its read half `E148` at `Z2`. E161 the module
datasheet, between `docs/arcs/module-split-arc.md:68` and
`docs/arcs/file-types-arc.md:38`. E165 the private de-duplicators, between
`docs/arcs/text-tools-arc.md:207` and compiler-internal adoption sites. E36 the
niri IPC stream, whose only candidate arc states xdg-shell, seat input, text and
resize and reaches none of them. E37 the test-only PNG writer, which no arc and
no goal reaches.

## What this run measured beside the homing

- ⚑ **A first pass of this file read E42 as having no ledger row.** It has one,
  `docs/elements/ledger.md:115`, `built`/`SH`. The row's `E#` cell is written
  `**E42**` and it is the only bolded one in the file, so a parser anchored on a
  bare `E\d+` dropped it. Corrected on merge; the other 143 rows' state and track
  were cross-checked against the ledger and agree.
- **Five elements carried `?` as their track when this ran**: E52, E77, E78, E166
  and E167. ⚑ **Two still do.** The author sorted E52 to `OT` and E77 and E78 to
  `SH` on 2026-09-15, each re-derived from the sourcing rule at
  `docs/elements/catalog.md:59-63`, and this file's three Track cells are written
  to match. E166 and E167 still read `?`: their 2026-09-01 parking ruling settles
  whether the work happens and names neither track token, so
  `records/author-calls.md:369` stays open on them.
- **`ledger-lint` check AE reads 38 prose mentions as coverage.** Of those 38,
  the substantive ones resolve to 14 elements this triage could home from the
  mention; the rest are arc-local row ids that happen to spell `E1` to `E4`
  (`docs/arcs/display-calculus-arc.md:127-130`) or a rejection.

## Where this stands, 2026-09-18

Every figure in this section was measured in one run on 2026-09-18 against
`d9ff2cd`. The triage table above keeps its 2026-09-10 verdicts and every one of
its line numbers, because thirteen files cite this file by line: seven arc files,
`docs/elements/catalog.md`, `docs/goals/self-hosting.md`,
`records/author-calls.md` and three `records/` lens and findings files. A
`grep -rl 'homing-triage\.md:[0-9]'` over the tree lists them.

| the rung | 2026-09-10 | today | command |
|---|---|---|---|
| catalog element to arc roster row | 42 of 187 | **142 of 188** | `python3 tools/lens/lens.py chain` |
| element homes owed | 99 | **18** | `python3 tools/ledger-lint/ledger-lint.py` |
| catalog elements holding no roster row | 144 of 186 | **46 of 188** | the recipe at `:24-37` |
| arcs | 28 | **37** | `ls docs/arcs/*-arc.md \| wc -l` |

Of the 46 that hold no roster row, one is exempt by the author's ruling of
2026-09-13 and 27 are admitted by a row in `records/lenses/unspoken.md`, which
leaves the 18 owed. `ledger-lint` reports 163 violations, 18 element homes owed,
28 author calls owed, 160 lens rulings owed and 2 checks that check nothing.
`python3 tools/lens/lens.py check` reports 191 rows and 0 findings.

**Nine arcs opened after this file landed**, and the four it proposed are four of
them. The file landed at `9045060`, 2026-09-10 22:46.

| arc | commit | date |
|---|---|---|
| `terminal` | `ec0a7ec` | 2026-09-10, 53 minutes after this file |
| `orchestration-engine` | `f15499c` | 2026-09-14 |
| `syscall-custody` | `394484a` | 2026-09-14 |
| `surface-syntax` | `7e0eb24` | 2026-09-14 |
| `runtime-loading` | `7e0eb24` | 2026-09-14 |
| `sys-face` | `68d0b3c` | 2026-09-17 |
| `checker-core` | `e50157f` | 2026-09-18 |
| `lowering-and-emit` | `1ee6990` | 2026-09-18 |
| `substrate-floor` | `9d3d5cd` | 2026-09-18 |

### What the 144 rows did

98 of the 144 hold a roster row today and 46 do not. Measured by the recipe at
`:24-37`, with each row's proposed home read against the arc that now carries it.

| verdict | rows | landed where proposed | landed in another arc | still unhomed |
|---|---|---|---|---|
| `clear` | 42 | **0** | 15 | 27 |
| `author-call` | 81 | 0 | 62 | 19 |
| `new-arc` | 21 | 21 | 0 | 0 |

⚑ **Not one `clear` row landed in the arc this file proposed.** Fifteen of the
forty-two are homed and every one went somewhere else. Each of those verdicts
read `clear` because the proposed arc named the element in prose, and belonging
is a roster row's element cell. Three arc-opening runs each measured the trap,
the one that hid E149:

| element | proposed | landed | what the arc measured |
|---|---|---|---|
| E87 | `enforcement` | `lowering-and-emit` | `docs/arcs/lowering-and-emit-arc.md:216`: that arc's element cells are `E16`, `E17`, `E18`, `E70`, `E184` through `E188` and `E198`, and hold no `E87` |
| E15, E154, E168, E170 | `enforcement` | `lowering-and-emit` | the same roster measurement |
| E96, E108 | `emitted-speed` | `lowering-and-emit` | that arc's roster carries one element cell, `E189` |
| E22 | `memory-discipline` | `substrate-floor/SU15` | `docs/arcs/substrate-floor-arc.md:192`: that arc names E22 in prose and in its §3 table and rosters `E81` through `E85` instead |
| E111 | `display-calculus` | `substrate-floor/SU14` | `docs/arcs/substrate-floor-arc.md:191`: that arc rosters no element at all, its twenty element cells reading `unminted`, and `display-calculus/C1` names E111 inside a `what` cell |
| E14, E101, E102 | `diagnostics` | `checker-core` | diagnostics rosters `E157`, `E158` and `E174` through `E183`, and holds none of the three |
| E29, E127, E129 | `native-window`, `native-protocol`, `transport` | `sys-face` | that arc took the crossings whole |

⚑ **E41's proposal hit the same trap from the `author-call` side.**
`docs/arcs/substrate-floor-arc.md:270-282` measured enforcement's twenty-three
element cells and found no `E41` and no `E22`; E41's two appearances in that file
sit inside `enforcement/N22`'s `what` cell and in a resume state. The element is
`substrate-floor/SU16` and question D behind it is unruled.

### The `author-call` questions, re-read

| question | rows | where it stands today |
|---|---|---|
| **A.** does a built element under a goal that carries no arc owe a roster row | 55 | **answered by the tree, and the answer is yes.** All 55 are homed across `checker-core`, `sys-face`, `lowering-and-emit` and `substrate-floor`, with no author ruling given. `docs/goals/self-hosting.md:71-73` states it: homing is planning, "so a `built` element still takes a row" |
| **B.** is a goal owed before these four can be scheduled | 4 | open for three. E48 is `checker-core/CK17`; E47, E50 and E153 are unhomed |
| **C.** is a `superseded` row exempt from homing | 1 | **ruled exempt 2026-09-13**, `records/author-calls.md:92`. E86 stays unhomed and check AE excludes it |
| **D.** which arc owns the bounds and region class | 1 | **unruled.** E41 is `substrate-floor/SU16` and the class is unseated. Register row `records/author-calls.md:85`, `unreviewed` |
| **E.** where does the cost grading go | 1 | open. E38 unhomed |
| **F.** does the surface effect algebra belong to enforcement | 1 | open. E39 unhomed |
| **G.** straddles inside the `OT` track | 7 | open, all seven unhomed: E42, E44, E52, E59, E61, E62, E80 |
| **H.** the two C legs | 2 | half moved. E167 is `lowering-and-emit/LE21` and E166 is unhomed. Both tracks still read `?` |
| **I.** adopt or mint for E169 | 1 | **resolved by adoption.** E169 is `lowering-and-emit/LE20` |
| **J.** the remaining pairwise straddles | 8 | three moved: E30 and E149 to `sys-face`, E128 to `terminal/TM4`. E36, E37, E64, E161 and E165 are unhomed |

### Corrections to this file, with what was wrong

| where | what it said | the correction |
|---|---|---|
| `:16-20` | check AE matches `\bE(\d+)\b` over a whole arc file | AE was rewritten at `8a7b644`, 2026-09-13. `tools/ledger-lint/ledger-lint.py:1882-1903` builds its homed set from each roster row's element cell through `pack.row_elements`, so prose homes nothing. The paragraph is marked in place as historical |
| `:62` | class `Q1` cites `docs/goals/self-hosting.md:70` for that goal carrying no arc and owing none | the goal was amended at `2d8dbac` and again at `749ce10`. `:70` now sits inside condition 4, and `:86-101` says conditions 1 to 3 carry no arc while conditions 4 and 5 are open and name four arcs. `docs/goals/self-hosting.md:97` cites `:62` back and `:176` already records the count as pre-arc, so the pair is mutually stale |
| `:77` | `orchestration-engine` (13) | 14, corrected in place 2026-09-18. The proposal row at `:234` lists fourteen elements and the arithmetic at `:239` reads 14. `docs/arcs/orchestration-engine-arc.md:284` found the contradiction on 2026-09-14 |
| `:58-65` | the four classes with their counts | a 2026-09-10 population. All 55 `Q1` rows are homed and the one `Q3` row is ruled exempt |
| `:55` | 18 of the 28 arcs roster no minted element | 16 of 37 today, from `python3 tools/lens/lens.py chain`, rung `arc -> minted id`, which reports 21 of 37 |

## The queue this program carries

Recorded 2026-09-18 from an orchestrating session's context before it was lost.
Nothing here is ruled and nothing here is closed. `records/findings.md` FD-29
measured why this section exists: no surveyed mechanism reaches a decision made
out of band, and the moment a person speaks emits no key a tool can index.
`.planning/FAILURE-MODES-2026-09.md:21` is the local instance, row A7, a ruling
given in session and never written down that cost a later agent a wrong count.

### Author calls standing

`ledger-lint` check AK reports 28 owed and every one of them is a row of
`records/author-calls.md`. Every one of the six below is carried on an arc roster
row, and three of them hold no register row, so AK cannot see those three.

| the call | carried on | register row |
|---|---|---|
| which element the surviving W^X work belongs to | `substrate-floor/SU1`, `docs/arcs/substrate-floor-arc.md:178` | none. The call is at `docs/elements/ledger.md:464`: "The row and the element disagree about what E20 is. Naming the survivor is an author call" |
| which arc owns the bounds and region class, question D of this file | `substrate-floor/SU15` and `SU16`, both `open` | `records/author-calls.md:85`, `unreviewed` |
| E167's `?` track | `lowering-and-emit/LE21` | `records/author-calls.md:90`. Four of that row's six were ruled 2026-09-15; E166 and E167 hold it open |
| E166 and E167's tracks generally | E166 is unhomed | the same row. The 2026-09-01 parking ruling settles whether the work happens and names neither track token, and the cut it records was of external judgment, a different axis from the `SH` and `OT` split |
| what `E128`'s `(1 t Terminal)` names | `terminal/TM9`, `docs/arcs/terminal-arc.md:199` | none for the naming half. `records/author-calls.md:93` is that row's placement call, where the port tier's missing module coordinates get repaired, a different question |
| where the fixpoint compare's phase sits | `lowering-and-emit/LE24`, `docs/arcs/lowering-and-emit-arc.md:224` | none. The arc carries it verbatim under FLAGs |

⚑ **A claim that the author ruled question D to `enforcement` on 2026-09-14 was
measured false.** `.planning/FAILURE-MODES-2026-09.md:16` records it as row A2,
an author ruling no tracked document carried, caught by the dispatched agent
because the prompt said to re-verify. `records/lenses/unspoken.md`'s E41 row
records the homing as ruled 2026-09-18 and flags question D as untaken by it.

A `Terminal` is nothing in this tree. `terminal/TM9`'s two referents are the tty
fd and the `Pty` master at `lib/ports/pty.port:14`, and a coordinate on
`tty.port` and `pty.port` routes them through `ports/ports` while minting no
`Terminal`, which is why that arc's requirement 6 has nothing holding it.

### Owed work with no owner

| the work | what is known |
|---|---|
| the fixpoint compare as a phase | `lowering-and-emit/LE24` takes it, `unminted` and `open`. Measured 2026-09-18 at `docs/arcs/lowering-and-emit-arc.md:107`: the blob regenerates in 1.193 s at 17,797 lines, generation one builds in 0.765 s at 1,220,984 B and is byte-identical to the committed `bin/chirality-bin`, generation two builds in 0.766 s, and `cmp` reports `C1 == C2`. `tools/test/run-tests.sh:412` gives Phase 11's blocker as "no committed blob artifact to cmp against" and the compare takes no committed blob: both inputs are tracked. `.planning/FAILURE-MODES-2026-09.md:59` states the same as row C10 and rounds the two generations to 1.6 s |
| FD-29's `element:` field | it still reads that the row leaves four things in the author's hands. All four were ruled at `7fc6eb0`, 2026-09-17, and `records/author-calls.md:99` records the owed FD-29 update in its own text. `records/findings.md` was outside this run's write scope and another session was appending to it |
| a citation rule in `.planning/protocol/tone.md` | the file carries none. `grep -niE 'cite|citation|file:line'` over its 95 lines returns nothing, and its §What the linter cannot check lists five rules of which none is about citations. The author asked on 2026-09-18 for one covering density and the distinction between a citation that is part of a sentence and one appended as a mark. ⚑ **No tracked document carries that request.** It reached this file through a session prompt, which is FD-29's class exactly |
| `.planning/FAILURE-MODES-2026-09.md` shaped into `records/` rows | 69 lines, 28 rows in three sections, covering one orchestrating session 2026-09-10 to 2026-09-18. Its own header says `records/` is where a claim sits beside its measurement and that this file is the unshaped material a later pass turns into rows there |

### Known tool defects, each with its measurement

| defect | measurement |
|---|---|
| check AH globs the bare element form while single-digit SPECs are zero-padded on disk | 32 AH findings in the 2026-09-18 run. Nine of them name `E1` through `E9` absent in `checker-core`, against `docs/elements/specs/E01-sexp-reader-SPEC.md` through `E09-refinement-SPEC.md` on disk. All nine are in one arc |
| `pack.py --revisit` resolves no bare token, and says so with exit 0 | An explicit path resolves: `pack.py docs/elements/specs/E20-loader-SPEC.md --revisit <trigger>` returned a 212-line bundle on 2026-09-18, and arc paths resolve too. A bare element or row id does not: `pack.py E20 --revisit` and `pack.py LIM-16 --revisit` each print *"no artifact resolves for 'E20' — tried E20, docs/arcs/parts/E20.md, docs/arcs/E20.md, docs/arcs/E20-arc.md"*. ⚑ **The failure exits 0**, so a caller that checks the status code reads the miss as a success. The `revisit` skill's own trigger table names an author call as a trigger and `records/` rows as artifacts, which is the form that does not resolve. No `records/lenses/problems.md` row |
| check T's SPEC half enumerates nothing, silently | `tools/ledger-lint/ledger-lint.py:1183` sets `specdir = ROOT / ".planning" / "specs"` and that directory does not exist; SPECs live in `docs/elements/specs/`. The artifact-versus-registry pairing therefore runs on examples only. It does NOT raise Vacuous, because the examples directory is non-empty, so the half-blindness reports nothing at all. Measured 2026-09-18 during the `E20` ruling's propagation. No `records/lenses/problems.md` row |
| check U cannot see a quote attached to a line-numbered citation | `tools/ledger-lint/ledger-lint.py:1273` matches ``` `<path>.<ext>` ``` with the closing backtick required immediately after the extension, so `` `docs/elements/catalog.md:126` reads *"..."* `` never matches. Measured 2026-09-18 during the `E20` ruling's propagation: `docs/arcs/substrate-floor-arc.md` carries two stale quotes of cells that moved, at `:178` and `:304`, and the check reports only `:304`. The blind spot is the form the tree writes MOST often, because a citation here is expected to carry its line. No `records/lenses/problems.md` row |
| check AI is keyed on a file, so refreshing one row's date clears findings on rows that did not move | 110 of the run's 163 violations are AI. `.planning/FAILURE-MODES-2026-09.md:51` records the other direction: 13 ruled rows cleared 8 violations at once |
| `docs/arcs/README.md` frontmatter reads `updated: 2026-09-05` | its table gained rows through 2026-09-18, the nine arcs listed above among them, at `:193-200` |
| the four subject arcs cite stale and mutually inconsistent spans for one table in `docs/goals/self-hosting.md` | each arc's `- goals:` field at `:14` calls its span "the table that names this arc, unopened, as one of four subject arcs". `sys-face` reads `:86-91`, `checker-core` and `lowering-and-emit` `:91-96`, `substrate-floor` `:97-102`. The table begins at `:102` today and the spans disagreed with each other before `749ce10` moved it |

### Catalog cells stale in the direction check AB cannot read

Twelve, named by the four arcs that found them. AB pairs the catalog's build
column against the ledger's state column and reports zero issues on every one.
Do not re-measure these here; each arc carries the measurement.

| arc | cells |
|---|---|
| `sys-face`, `docs/arcs/sys-face-arc.md:349-354` | `docs/elements/catalog.md:143` for E28's `munmap`, `:425` for E98, `:426` for E99, `:435` for E103 |
| `checker-core`, `docs/arcs/checker-core-arc.md:385-392` | `:108` for E14's file, `:434` for E102's four enhancements, `:109` for E79's group pass, and E2's residue list |
| `lowering-and-emit`, `docs/arcs/lowering-and-emit-arc.md:385-395` | `:419` for E95, `:263` for E69 |
| `substrate-floor`, `docs/arcs/substrate-floor-arc.md:356-370` | `:357` for E90, `:358` for E91 |

⚑ **Two counts of this population disagree and both are wrong.**
`.planning/FAILURE-MODES-2026-09.md:56` reads eight as row C7, which was the
figure after `sys-face` and `checker-core`.
`docs/arcs/lowering-and-emit-arc.md:395` reads "fourteen in three arcs", where
those three name ten between them, and it omits `substrate-floor`, which landed
the same day with two more. Every one of the four arcs states the direction in
its own words: the catalog understating what is built.

## Where this program resumes

`CLAUDE.md`'s pointer table says a session resumes from the arc file in
`docs/arcs/` and that there is no root state file. The homing program spans every
arc and belongs to none, so no arc file can hold its state without the same
state being written in nine places, which is the regularity
violation `docs/definitions/design-principles.md` names as the worst class of
defect.

**This file is the resume point.** Four authorities already treat it as the
register and cite it by path:

| authority | what it says |
|---|---|
| `tools/ledger-lint/ledger-lint.py:1928` and `:1974` | check AE's own text: the unhomed population is a register of work the tree owes, and "records/homing-triage.md proposes a home for each of those and rules on none". The check prints this path in its output |
| `tools/lens/lens.py:460` and `:469` | rung `catalog element -> arc roster row` prints the same sentence, and rung `arc -> minted id` names the four new-arc proposals as opened |
| `docs/goals/self-hosting.md:97`, `:113` and `:176` | condition 4's seam is checked against class `Q1` of this file, and `:113` says this file proposes an existing arc for some of the 18 |
| `records/author-calls.md:90` and `:92` | the `?` track row cites `:129` for E52's proposal, and the `superseded` ruling is recorded as given on question C of this file |

Ten arc files cite it, seven of them by line, and
`records/lenses/unspoken.md`'s E41 row quotes question D verbatim out of it.

**`.planning/protocol/placement.md` does not disagree.** Its human-tier table
sends "a claim beside what was measured" to `records/<arc>.md` and this file is
already there with `layer: measurement`. Its agent-tier table sends "a live
queue, a handoff, a capture" to `.planning/`, top level, which is the one reading
that would move the queue out. That reading loses on placement's own first
question, who reads it: a queue two tools print the path of, and that a goal
checks a seam against, is read by a person and by the harness. Placement's four
overriding rules settle the rest. Say it once sends the state to the document
that already holds it. Writing is mostly amending sends a thing learned mid-task
to where it belongs in the same move.

## Closed since this section was written, 2026-09-18

Each item below was owed when the queue above was recorded and is closed now.
The queue is amended rather than rewritten, so a reader sees what moved.

| was owed | closed at | what it turned out to be |
|---|---|---|
| three author calls no register row carried | `acd7dd8` | `ledger-lint` check AK read 28 while six stood. The three lived in an arc row and at `docs/elements/ledger.md:464`. AK now reads 31 |
| four arcs carrying a FLAG a later commit satisfied | `acd7dd8` | four `revisit` runs, AMEND in every case, and each wrote its arc's first `records/` checklist row |
| `.planning/protocol/tone.md` carrying no citation rule | `9302d5a` | zero hits for cite, citation or `file:line` across 95 lines. It now carries the mechanical half under §What the linter checks and the form half under §What the linter cannot check |
| twelve catalog cells stale in the direction check AB cannot read | `9302d5a` | every one understating the tree. AB fires only where a cell opens with an unambiguous `Not built`; eight hedged with a semicolon and four opened `BUILT` |
| the verify table unable to separate a citation resolving from a claim being true | `d9ff2cd` | `.planning/protocol/dispatch.md` gains `| a claim is true |`, the `.manifest` case, and §A prompt is untrusted input |
| four arcs citing stale spans into `docs/goals/self-hosting.md` | `9302d5a` | the quoted sentence had drifted as well as the span, and five more stale spans were found beside the four named |
| `docs/banks/runtime.md` disagreeing with itself on the W^X loader | `9302d5a` | `readelf -l bin/chirality-bin` reports one `LOAD`, flags `RWE`; four mentions now carry the demotion the bank's own `:225` already recorded |

**Three items remain owed and each names its instrument.** `records/findings.md`
FD-29's `element:` field still says it leaves four forks in the author's hands
and all four were ruled at `7fc6eb0`; it is blocked only by another session
appending to that file. `docs/banks/memory.md:134` heads a shard `BUILT /
ENFORCED (E22)` against both element authorities reading `design`, and re-rating
a shard is a `doc-audit` verdict rather than a span repair. Check AH globs the
bare element form while single-digit SPECs are zero-padded on disk, misreporting
nine existing SPECs in one arc, and check AI is keyed on a file so one row's
refreshed date clears findings on rows that did not move; both are measured and
neither holds a `records/lenses/problems.md` row.

**The split that stands.** The measured state and the owed queue live here. The
raw session capture lives in `.planning/FAILURE-MODES-2026-09.md` until a pass
shapes it into `records/` rows, which that file's own header asks for and which
is listed above as owed work with no owner.
