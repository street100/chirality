---
node: records-ledger-reconciliation
layer: record
related: [records/README, elements/README, status-ledger, records/spec-tier-triage, goals/enforcement]
status: current
updated: 2026-09-05
---

# Ledger reconciliation, 2026-09-04

`docs/elements/ledger.md` is the build-state authority that
[[goals/enforcement]] requirement 1 rests on: *a capability sits at ENFORCED, or
its ledger row says why it does not*. `records/spec-tier-triage.md` reported
seven rows disagreeing with live source. Each was re-measured here. **Three were
real, one was a naming finding, and four were the triage reading the wrong
subject.** The triage's own count is corrected by this file.

The run that began this reconciliation was killed by a session rate limit
part-way through. What it had written was verified and committed at `138a3e3`;
the remainder was finished by hand and is below.

## Corrected

| E# | was | now | evidence |
|---|---|---|---|
| E69 | `design` | `built`, at IMPLEMENTED | `closconv.chiral:1` names itself E69; `compile-front` imports its driver; `apply-word.sh` is undispatched so no phase reddens when closconv breaks |
| E113 | `flight` | `built` | built under E120's number: `pool.port:30`, wrap at `crossing-wraps.chiral:52`, called at `grid.chiral:194` |
| E26 | `built` | `built`, qualified PARTIAL | crossing half real (`process.port:14`); the typed alarm is E42's named residue, hard-gated on E39, which is `design` |
| E185 | catalog `Not built` | catalog `BUILT` | landed `ccff8e8`, promoted `1157028`, fixpoint `B2 == B3` at 1,192,312 B. The ledger already read `built`; the two cells disagreed |

## Kept, with the reason added

| E# | state | why it stays |
|---|---|---|
| E70 | `design` | SEEDED. `sig-driver` has **zero importers** and `eff-lower`'s only importer is `sig-driver`, so the chain is unreached. Two comments naming E70 are not the element: the effect-row tal shadow is absent |
| E45 | `design` | SEEDED. `reflect-floor.chiral` (54 L) realizes the type-level floor and has **zero importers** |

## A finding rather than a cell edit

**E20.** The row and the element disagree about what E20 is. There is no
`nb-blit` and no mmap-to-mprotect *code loader* under `lib/`;
`lib/module/loader.chiral` is the **compiler's** module loader by its own
header, a different thing, and the name is a collision. The real
`mmap`/`mprotect` pair in `compile-emit.chiral` is E89/E91's arena
reserve-commit, never a W→X transition. **The W^X half is not held:**
`x64/elf.chiral:59-60` emits one RWX `PT_LOAD` in its own words and
`readelf -l bin/chirality-bin` reports a single `RWE` segment.
`docs/definitions/status-ledger.md` already demoted its W^X loader row for this
reason. Naming the surviving element is an author call.

## What the triage got wrong

Four of its seven reported disagreements do not exist. Recorded because a triage
that over-reports is the same defect class as a ledger that is stale.

- **E129** and **E130** already read `built`. Both are reached: `inet.chiral` has
  seven importers, `http.chiral` nine including `prog/agent/agent.chiral`.
- **E45** already carried its SEEDED annotation.
- **E24** is correct as `built`. The triage searched `lib/prelude/prelude.chiral`
  for `div`, `mod`, `divmod` and `try-div` and found none. E24's subject is the
  **x86-64 emitter**, which its catalog row states: `lib/lowering/x64/mach.chiral`
  emits `cqo`/`idiv` with the #DE guards at `:159-189`. Absent prelude wrappers
  say nothing about it.

## What this does to requirement 1

The requirement is not restored by this pass, and the reason is structural rather
than a count. Two of the six rows checked are SEEDED with the ledger reading
`design`, which the four rungs distinguish and this table's vocabulary does not:
`docs/definitions/status-ledger.md` separates DESIGNED from SEEDED (code exists,
nothing reaches it), and `docs/elements/ledger.md` has one cell for both. So a
row saying `design` cannot say whether the code is absent or merely unreached,
and the requirement's *or its ledger row says why it does not* half is carried by
prose in the title cell rather than by the state.

⚑ **`ledger-lint` check N does not pair the ledger's state against the catalog's.**
E185 sat `built` in one and `Not built` in the other and nothing flagged it. That
gap is why this reconciliation was needed at all.

## The gap is closed, and it was an 18-element class

`ledger-lint` gained **check AB** on 2026-09-04: the LEDGER's state column against
the CATALOG's own prose assertion. Check N pairs the LEDGER against
`docs/examples/INDEX.md` and never opens the catalog, so the two documents that
both assert a build state could disagree with nothing watching.

The check is deliberately narrow, for check N's stated reason: it flags only pairs
that cannot both be true. The catalog's state is prose rather than a column, so it
reads **only** an unambiguous `Not built` opening the description cell, against a
LEDGER row reading `built`. Hedged cells (`partially built`, `not built as
specified`, `not built;`) are left alone. A check aimed at a guess passes by
looking at nothing.

**It fired on 18 elements**, of which E185 was the one found by hand:

`E34 · E97 · E101 · E106 · E107 · E109 · E110 · E111 · E112 · E113 · E121 · E124 ·
E129 · E151 · E155 · E157 · E159 · E182`

Three spot-checked, all genuine and all the same shape, a catalog cell frozen at
authoring time and never updated when the element landed:

- **E121** opens *"Not built — no fcntl crossing (grep clean)"*. `lib/ports/fd.port:36`
  declares `(extern fcntl (=> I64 I64 I64 I64))` with an `E121:` comment on the line.
- **E157** opens *"Not built. The outcome is already a sum; the reason is a string"*.
  `lib/typing/diag.chiral` carries 22 `Reason` arms; the sum is closed.
- **E182** opens *"Not built."* Its gate is `tools/test/arity.sh`, dispatched as
  Phase 24 and green.

⚑ **The remaining 15 were not corrected in that pass and had to be verified one
at a time.** This same file records a triage that over-reported four of seven, and
a mass-edit driven by a lint hit would repeat that. The check names the worklist;
it does not license a sweep.

## The 15, verified one at a time, 2026-09-04

Every one was read against live source before its cell was touched. **The catalog
was the stale cell in all 15 and the ledger was wrong in none**, which is the
better direction of this defect: no capability was claimed that does not exist.
`b055085`, `194fc2e`, `4e96f7f` and `4247a38` carry the corrections, grouped so a
collision cannot sweep the batch. AB falls 18 to 3.

| E# | the catalog claimed | live source says |
|---|---|---|
| E34 | `Not built` | `lib/lowering/x64/elf.chiral` names E34 in its header; `elf-file` at `:79`; `compile-emit.chiral:18` imports and `:144` calls it, so every executable the tree emits is its output |
| E97 | skip reasons discarded, `no emitted label` the only signal | `lib/lowering/skip-diag.chiral` (79 L) is the single decl home, imported by `compile-back.chiral:20` and `diag.chiral:57`, which JOINS the chain. `native-prim?` is grep-clean, closed by deletion |
| E101 | reader computes no line/col | **PARTIAL.** `pos-line`/`pos-col`/`fmt-pos` at `sexp.chiral:137`/`:151`/`:164` plus depth and last-form. The `parse.chiral` half the same title names is untouched |
| E106 | no linear container; `List` element param is `(type 0)` | `lincoll.chiral:26` declares `SockVec` linear in both fields, with `sv-push`/`sv-count`/`sv-detach-at`/`sv-drain`/`mux-step`. Two accept samples, four refusals |
| E107 | no porttype-consuming close lowers | five `(=> (1 x T) Unit)` closes across four `.port` files, crossing rows at `crossing-wraps.chiral:42-44` and `:53`. `pty-close` still has no row |
| E109 | only `bput-u8`/`bput-u32-le` writers | `bput-u16-le` at `bytes.chiral:628`, gated by `prog/samples/e109_bput_u16_le.prog` |
| E110 | `open-pty` opens with no close-on-exec | `nb-sys-open-rw-t` at `sys.chiral:654` hardcodes `O_CLOEXEC` in `0x80102` (`:658`), its own comment giving this element's reason |
| E111 | not built by design, T4 shipped on `List` | `grid.chiral:28` stores cells in `(1 store (Pool n))`, a linear size-indexed region, 16-byte codec at `:52` |
| E112 | no APC serialize/parse primitive | `apc.chiral` holds the envelope, the netstring grammar and the FNV-1a-64 `block-id`; `vt-parser.chiral:4` imports `dec-frame` |
| E113 | no read/peek crossing exists | `pool-read` at `pool.port:30`, `PoolReadR` at `:19`, crossing row at `crossing-wraps.chiral:52`, called at `grid.chiral:194` |
| E124 | no raw-to-porttype introducer exists | `adopt-fd` `(=> I64 Fd)` at `fd.port:32`, lowered by `(pair "adopt-fd" "nb-id")` at `erase.chiral:119`; `file.port:9` names it as the mint |
| E129 | AF_UNIX-only floor, and the LEDGER is the stale one | `inet.chiral:2` names E129 and owns `sock-connect-in`; crossing row at `crossing-wraps.chiral:41`; seven importers. The LEDGER half of its own note was fixed on 2026-09-04, leaving the cell last |
| E151 | FIVE ad-hoc string comparators | seven names, one definition each, all in `prelude/string.chiral`; `ty-cmp.chiral:15` and `row-infer.chiral:17` import it; `ar-str-cmp`/`cb-str-cmp` grep-clean |
| E155 | single libdir, silent first-wins, 9 duplicate modules | `resolve.chiral:6-11` takes a list of roots; the key is the root-relative path (`:30-38`), so the collision class is unreachable; no `TUI/` and no symlinks in the tree |
| E159 | `(adopt-fd 999)` closed twice compiles exit 0 | the two refusals are `diag.chiral:385` and `:387-394`; Phase 6 (`tools/test/linear-mint.sh`, dispatched at `run-tests.sh:146`) builds all three holes and reads them |

### What the pass left as a finding rather than a cell edit

**E101 is a genuine PARTIAL and the ledger row now says so**, on E26's precedent:
`built`, qualified. The element's own title names two files. `lib/surface/sexp.chiral`
landed in full. `lib/surface/parse.chiral` did not: its `p-err` still carries a
bare string with no position, and `(lam (x ...) body)`, one of the two opaque
messages the catalog cell was minted to retire, is unchanged at `:244-247`, beside
`(let binding body)`, `(case scrut branch...)` and `bad case pattern`. One cell
saying `built` and one saying `Not built` were each half right.

**E106's four refusal samples run under no dispatched gate.**
`tools/test/run-tests.sh:179` skips every `*_reject_*` by name, so
`e106_reject_length.chiral` and its three siblings sit on disk asserting nothing.
The element is BUILT and its negative conformance is not gated. Recorded in the
cell rather than fixed, because fixing it is a change to `tools/`.

**E107's owed `pty-close` is still owed.** Declared `(=> (1 p Pty) Unit)` at
`lib/ports/pty.port:38` and called at `session.chiral:54-55`, with NO
`crossing-wraps` row, so it does not lower. The ledger row already named this; the
catalog cell now names it too.

**E151's Element cell is stale beside its state cell.** It gives the owner as
`string-utils.chiral`, which no longer exists anywhere in the tree, and homes
`str-lower` and `str-trim` in `manas`, which no longer define them. Check AB reads
only the state column, so nothing flags this. Noted in the cell; renaming the
element's own description is an author call.

⚑ **AB stops at 3, and those three are E121, E157 and E182.** The spot-check
above verified all three against live source and none of their catalog cells was
edited, so the lint still fires on them. The finding above records them as
*corrected*; what happened was that they were *measured*. Three cells, same shape
as the fifteen, and the evidence for each is already written down two sections up.

⚑ This is the SPEC tier's disease in a second register.
`records/spec-tier-triage.md` found 104 of 129 SPECs describing work already in the
tree while reading `status: audited`. Both are artifacts frozen at authoring time
that no mechanism updates on landing. The catalog now has one; the SPEC tier does
not.

## The last three, and AB reaches 0, 2026-09-04

`c528cf9`, `e9fa0d2` and `c126136`. **Check AB is 0.** The rest of the line is
unmoved: `G(70) R(131)`, and W, X, Y, Z, J, N, I and AA all at zero.

⚑ **The section above reported these three as corrected. They were not.** The
measurements were taken and written down; no cell was edited. The lint kept
firing on all three for exactly that reason, and this is the pass that made the
edits. One measurement in that section is also wrong on its own terms: it says
`diag.chiral` carries **22** `Reason` arms. `Reason` has **ten**, at
`lib/typing/diag.chiral:121`; 36 is `Judg`'s count, at `:99`. The claim that the
sum is closed was right.

Same direction as the fifteen: the catalog was the stale cell in all three and
the ledger was wrong in none.

| E# | the catalog claimed | live source says |
|---|---|---|
| E121 | `no fcntl crossing (grep clean)` | `(extern fcntl (=> I64 I64 I64 I64))` at `lib/ports/fd.port:36` commented `E121:`; crossing row at `crossing-wraps.chiral:45` over `nb-sys-fcntl-t` at `sys.chiral:208`; syscall 72 in `target-linux.manifest`; `fd-cloexec?` at `term.chiral:188` |
| E157 | `the reason is a string` | `Reason` is ten evidence-bearing arms at `diag.chiral:121`; `LoadR` at `loader.chiral:60` and `CkR` at `kernel.chiral:411` both hold `(why Reason)`; `kernel.chiral:636`, the site this cell named, raises `(r-usage (subj-lam-binder) q (last-qty u))` |
| E182 | `Not built.` | `r-arity` is `Reason`'s tenth arm at `diag.chiral:141`, `Judg` is 36 arms at `:99`, and **the last column of the same row already carried the whole BUILT record**, five commits and the measured refusals. AB reads only column three, so a row can contradict itself and still be half green |

### What this pass left as a finding rather than an edit

**E121 is BUILT and NOT ENFORCED, and the gate it was minted to feed does not
run either.** `tools/test/samples/e121_fcntl.prog` holds both legs, (a) the
`F_SETFD` then `F_GETFD` round trip and (b) the conclusive cloexec readback the
E110 spec asked for, and **no phase dispatches it**: `e121` and `e110` are
grep-clean across every `tools/test/*.sh`. The crossing landed, and the evidence
sitting beside it asserts nothing. Recorded in the cell and here rather than
fixed, because wiring a phase is a change to `tools/`. It joins E106's four
ungated refusals as the second instance of the same shape in this file.

**E157 and E182 were promoted to ENFORCED and their gates were checked first**,
Phase 13 (`tools/test/diag.sh`, `run-tests.sh:216`) and Phase 24
(`tools/test/arity.sh`, `run-tests.sh:345`). E121 was not, on the same rule.
`tools/test/registration.sh` names seven scripts outside the dispatch table; a
gate that does not run does not enforce.

## The check-AC pass, 29 rows, 2026-09-05

`ledger-lint` gained **check AC** at `e3d6b79`, the third pairing of the ledger's
state column. Check N pairs it against `docs/examples/INDEX.md` for `built`
against `design` and for `implemented` against not-`built`; check AB pairs it
against the catalog. AC closes the reverse INDEX leg: ledger `built` against a
pipeline status in the pre-implementation set (`drafted`, `reviewed`, `specced`,
`audited`), which the INDEX itself defines as *implement-ready*.

It fired on **29**. Every one was read against live source before its cell was
touched, on this file's own rule that a lint hit is a worklist entry rather than
a verdict. **The INDEX was the stale registry in 26 and the ledger was wrong in
none.** Three are left as findings, firing.

⚑ **No element was promoted to a rung whose gate was not named and confirmed
dispatched.** The INDEX's `implemented` is a pipeline status, not a rung: it says
a run built the element, and it carries no enforcement claim. Two cells name
ENFORCED and both gates were checked in `tools/test/run-tests.sh` first, E130's
Phase 20 at `:326` and E157's Phase 13 at `:216`. E121's cell says IMPLEMENTED
and NOT gated, on the same rule.

`44913ce` carries the 29 row edits.

### The 26 where the INDEX row was stale

| E# | live source says |
|---|---|
| E21 | the entry stub mmaps and stores `heapptr`/`heapbase`/`heapend`/`heapreserve` (`compile-emit.chiral:34-98`); the bump advance is `x-lea-bump` (`x64/mach.chiral:449`, `:479`) |
| E24 | the subject is the x86-64 emitter, as the AB pass measured. `x-div-guarded`/`x-mod-guarded` wrap `cqo`/`idiv` with the #DE guards at `x64/mach.chiral:173-189`, `:299-307`, dispatched at `:367` |
| E25 | `[len][payload]` is the live cell for `Str` and `Bytes` alike: `tal/bytes.chiral:8`, `tal/ir.chiral:15`, `x64/mach.chiral:611`, `:739` |
| E31 | `nb-sys-poll-t` at `tal/sys.chiral:302` and `nb-pollfd-fill-t` at `:310`, registered at `:1339`. The surface wrappers the row called E51-gated landed: `poll2` at `sock.port:71`, `nb-poll` at `:74` |
| E33 | `lib/runtime/proc.chiral:1` names itself E33 and owns `proc-spawn` over fork+execve+wait4; crossing row `raw-proc-spawn` to `nb-run-cmd` at `crossing-wraps.chiral:54`; imported by `evidence/harness.chiral:7` |
| E51 | `impl_ports` is gone from the tree and CPython is off the compile path. The `wrap-*` E51 wrappers are `tal/sys-linkage.chiral`, imported at `compile-emit.chiral:17` and read at `:204` |
| E69 | `upper/closconv.chiral:1` names itself E69, `closconv-driver.chiral:2` is its stateful driver, `compile-front.chiral:21` imports it onto the shipping path |
| E87 | `module/resolve.chiral:2` names E87 and retires `bin/chirality-resolve.sh`; imported by `prog/resolve.prog:20` and `evidence/test-floor.chiral:44` |
| E88 | `prog/scriba/mark-region.chiral`, imported by `init-loader.chiral:17`. Rehomed to scriba:S31 |
| E92 | `prog/scriba/dispatch.chiral:3` defines `try-dispatch`; `init-loader.chiral:361` routes every op through it. Rehomed to scriba:S32 |
| E100 | `field-erased?` at `closconv.chiral:765`, applied at `:1018`, `:1054` and `closconv-driver.chiral:162` |
| E106 | `SockVec` linear in both fields at `capability/lincoll.chiral:26-28`, `sv-push` at `:31`, `CountR` at `:37` |
| E107 | four fd-backed closes lower: `sock-close`/`lsock-close`/`fd-close` at `crossing-wraps.chiral:42-44`, `pool-close` at `:53` |
| E108 | `shr`/`sar` externs at `prelude/prelude.chiral:71-72`, Op ctors and names at `:38`, `:49-50` |
| E109 | `bput-u16-le` at `tal/bytes.chiral:628` |
| E110 | `nb-sys-open-rw-t` hardcodes `O_RDWR\|O_NOCTTY\|O_CLOEXEC` = `0x80102` at `tal/sys.chiral:646-658` |
| E113 | `pool-read` at `pool.port:30` under an `E113/E120` comment, crossing row `crossing-wraps.chiral:52`, called at `grid.chiral:194` |
| E121 | `fcntl` extern at `fd.port:36` commented `E121:`, crossing row `crossing-wraps.chiral:45` |
| E123 | `porttype-word?` maps the handle porttypes to `nt-i64` inside `term->ntalty` at `compile-front.chiral:62-68` |
| E124 | `adopt-fd (=> I64 Fd)` at `fd.port:32`, lowered by the `adopt-fd`/`nb-id` pair at `tal/erase.chiral:119` |
| E129 | `protocol/inet.chiral:2` names E129 and owns `sock-connect-in`; crossing row `crossing-wraps.chiral:41`; consumed by `http.chiral` and five `prog/samples` roots |
| E130 | `protocol/http.chiral:4-8` records the swap; `http-request` is a `def` at `:436-437` over the native socket caps |
| E151 | `str-cmp` at `prelude/string.chiral:91`, `str-lower` `:116`, `str-upper` `:132`, `str-trim` `:163`, `str-replace` `:186`; `ar-str-cmp` and `cb-str-cmp` grep-clean |
| E156 | `row-infer.chiral:104` calls `list-sort Str str-cmp`; the private `ins-sorted`/`sort-dedup` are gone, survived by the comment at `:95-96` |
| E157 | `Reason` is a closed sum at `typing/diag.chiral:121`; `LoadR` carries `(why Reason)` at `module/loader.chiral:60` |
| E161 | the checked `(module <key> (cat A) ...)` datasheet form is live across the prelude, e.g. `prelude/string.chiral:11`, with its derived `crossings` noted at `:9-10` |

### The three left firing, and why each is a finding

Same shape as E20's precedent in this file: the two cells are not disagreeing
about one fact, they are naming different things, and moving either cell would
record a claim neither document holds. Each INDEX row now carries the finding
and check AC keeps reporting all three.

**E20.** Unchanged from this file's 2026-09-04 disposition, re-verified against
`lib/lowering/x64/elf.chiral:59-60` and re-read here rather than re-measured. The
row and the element disagree about what E20 is. Naming the survivor is an author
call, so the INDEX row was given the finding and left at `audited`.

**E26.** The ledger's `built` is already qualified PARTIAL and covers the
crossing half: `halt` at `lib/ports/process.port:14` beside `exit` at `:13`. The
typed alarm the INDEX row is still waiting on is hard-gated on E39, which reads
`design` at `ledger.md:114`. Each cell is half right.

**E101.** The ledger's `built` is already qualified PARTIAL and covers the reader
half: `pos-line` at `lib/surface/sexp.chiral:137`, `pos-col` at `:151`, `fmt-pos`
at `:164`. The `lib/surface/parse.chiral` half this element's own title names in
the same breath is untouched, with `(lam (x ...) body)` still a bare `p-err` at
`:244-247`, exactly where the AB pass measured it. Each cell is half right.

⚑ **AC provides an escape hatch these three were NOT given.** A ledger row
carrying the literal marker `UNRESOLVED` is honored the way check N honors E52:
reported on every run, not failing the gate. Pulling it for E20, E26 or E101
would take AC to 0. It was left alone deliberately, because in all three the
disposition is an author call and a self-issued `UNRESOLVED` would retire the
worklist entry on the strength of an agent's reading. **Author call.**

### What this pass found beside the cells

**E107's owed close family is TWO, not one.** The ledger row names `pty-close`
(declared at `lib/ports/pty.port:38`) as the owed binding. `env-close` is the
second: declared at `lib/ports/clock.port:40`, called from four `prog/demo` roots
and from `prog/samples/e106_reject_drop_tail.chiral`, and it has **no
`crossing-wraps` row either**. Four of the element's five named closes lower;
two do not. Recorded in the INDEX cell and here; adding a row is a change to
`lib/`.

**E121's gate still does not run, and the count moved.** `e121` and `e110` remain
grep-clean across every `tools/test/*.sh`, so the pass took the cell to
IMPLEMENTED and no further, on the 2026-09-04 rule. `tools/test/registration.sh`
now reports **11 of 24** scripts outside the dispatch table; the section above
says seven, which was that day's figure.

**E156's element title cites a home that moved.** It names `list-sort` as coming
from `collections`. The live definition is `lib/prelude/list.chiral:143` and
there is no `collections.chiral` in the tree. Same shape as E151's stale Element
cell recorded above: the state cell is right and the description is behind a
migration. Renaming is an author call.

**E25 carries stale gating prose in two prelude headers.** `prelude/map.chiral:7`
and `prelude/alist.chiral:51` both read *"bytes-cmp is E25-gated (no byte-compare
primitive yet)"*. E25 is the `[len][payload]` cell and it is built;
`typing/ty-cmp.chiral:13` says the comparison is *"composed from the existing byte
face"* with no `bcmp` primitive needed. The comments name a gate that closed.
