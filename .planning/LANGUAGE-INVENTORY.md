# chirality — common-language primitive inventory

**Minted 2026-08-21**, read from live source at HEAD `1cafe80`. **Re-measured
2026-09-10** at HEAD `39be4bb`, under `doc-audit`. The question:
*which primitives and stdlib pieces that any working language provides does chirality not
have yet?* — asked because the scriba user layer (and everything after it) will reach
for them.

⚑ **This file was minted against a tree that no longer exists.** The 2026-08-31
migration evicted `scaffold/` and `TUI/` whole. Every path below that named
either has been repointed at the live file or marked unverifiable; a citation
nobody can open is not evidence (`records/findings.md:23`). Where a state
disagreed with `docs/elements/catalog.md` or `docs/elements/ledger.md`, the
ledger won and the row was corrected toward it.

This is the **language** axis. The **editor** axis is
`.planning/SCRIBA-PRIMITIVE-CHECKLIST.md`; the **terminal substrate** axis is
`.planning/TUI-PRIMITIVES.md`, which is the surviving derivative of the evicted
`TUI/PRIMITIVE-AUDIT.md` and carries that file's gap analysis forward. A row
below that cites the audit cites it through its derivative. Different lanes — do
not merge them.

**Reading the state column:**
`HAVE` · `BUILT E###` (was missing, now built and gated) · `MINTED E###` (missing,
a cataloged element with a named consumer) · `SLOTTED E###` (a reserved ledger
slot with **no catalog row** — a number held open, not an element; see §7) ·
`DESIGNED <arc>/<id>` (missing, carried by an arc roster row that is **not** an
element and must never be cited as an `E#`, per
`docs/decisions/decision-work-ids.md:48`) ·
`GAP` (missing, **not** minted — no consumer yet; mint it when one appears, per the
no-phantom-dep rule) · `DELIBERATE` (absent by decision — do not "fix").

⚑ *The `SLOTTED` and `DESIGNED` states were added 2026-09-10. The original four
predate both the reserved-slot distinction and the arc roster tier, and folding
either into `MINTED` names an element that was never minted.*

---

## §0 · The floor as it stands

Measured 2026-09-10 against the live tree.

| Layer | Count | Where |
|---|---|---|
| Pure primitive externs (the category-A floor) | **34** | `lib/prelude/prelude.chiral:59-104` |
| Pure prelude defs on top | **11** | `str->i64`, `not/and/or/if`, `max/min`, `op-name/op-cmp?`, … |
| Crossings (the category-C floor) | **51** | `lib/ports/*.port`, nine registries |
| Library modules | **95** | `lib/**/*.chiral` (+ the 9 `.port` registries) |

⚑ *Was 32 / 11 / 50 / 88 at `scaffold/lib/prelude.chiral` and
`scaffold/lib/ports.chiral`. Those two paths are gone; the counts moved with the
migration, and the extern count moved again when `E189` bound `mulhi` and added
`mulhu`.*

The 34 externs, in full: `+ - * / %` · `=i <i <=i` · `band bor bxor shl shr sar
mulhi mulhu` · `str-len str-eq str-sub str-find str-find-from str-cat i64->str` ·
`str->bytes bytes->str` · `blen bget bslice bcat brepeat pack-u32 unpack-u32 pack-u16
unpack-u16`. Base types: `Unit Bool Pair Maybe List` (+ `Op` for the TAL),
all at `lib/prelude/prelude.chiral:17-38`.

That is the whole of it. **Everything else in chirality is written in chirality** — which is
the point, and also why the gaps below are gaps rather than bindings.

---

## §1 · Numeric tower

| Primitive | State | Note |
|---|---|---|
| Signed 64-bit int, wrapping | HAVE | Euclidean `/` `%` across reference/fold/native — **settled, do not re-argue** |
| The eight bitwise ops the `Op` sum names | HAVE | `band bor bxor shl shr sar` at `lib/prelude/prelude.chiral:67-72`, plus the two multiplies below. ⚑ *This row read "Full bitwise set" and that is an overclaim.* `docs/goals/emitted-speed.md` condition 6 measures the three sets — the `Op` sum (`lib/prelude/prelude.chiral:36-39`), the extern block (`:59-74`), `op-bytes` (`lib/lowering/x64/mach.chiral:355-391`) — as agreeing at **sixteen constructors** since 2026-09-08, and enumerates **38 bucket-C rows** the sum omits (`docs/benchmarks/OPT-CANDIDATES-2026-09.md`). `bnot` is among them. The set is closed and complete against itself, not against an ISA |
| Widening multiply (`mulhi` / `mulhu`) | **BUILT E189** | The fifteenth and sixteenth constructors. `emitted-speed/X7` decided the shape — signed and unsigned as two constructors — and 2026-09-08 is the first day the three sets agreed |
| Bit rotation (`rotl` / `rotr`) | **DESIGNED `emitted-speed/X8`** | Designed at `455bfb4`, awaiting `pipeline-audit` at DESIGN level (`docs/arcs/emitted-speed-arc.md:348`). ⚑ **Not an `E#`.** Decision 8 of `docs/arcs/parts/emitted-speed-X8.md` mints fresh rather than claiming the reserved `E115` slot, and narrows that slot to `bnot`. The live consumer is `rotl32` at `lib/crypto/chacha.chiral:24-25`, which rotates at 32 bits inside a 64-bit lane; what width a named rotate carries is the open half of the row |
| `max` / `min` | HAVE | `lib/prelude/prelude.chiral:153,156` |
| **Floating point (`F64`)** | **MINTED E153** | Not built — **zero float support anywhere**: no type, no literal, no arithmetic, no conversion (`docs/elements/catalog.md:479`). No average, rate, ratio, probability or temperature is expressible without hand-rolled integer scaling. ⚑ **Whether that absence is a hole or a design is a live fork this file does not settle — §12 FLAG 1** |
| `abs` | GAP | one line, no home yet; grep-clean under `lib/` |
| `sqrt` / `pow` / `log` / `exp` / trig | GAP | no math module exists |
| Unsigned integer type | DELIBERATE | width is a moduleset `NumProfile` decision (**decided, do not re-pitch**) — `docs/decisions/decision-numeric-width-pluggable.md`. ⚑ *Path repointed; the old `docs/decision-numeric-width-pluggable.md` does not resolve* |
| Arbitrary-precision integers | GAP | — |
| Checked / saturating arithmetic | GAP | wraps two's-complement by decision |

## §2 · Strings & text

The full refraction of this section is `docs/banks/text.md`, which measures the
same ground shard by shard. Read it before naming anything here as missing.

| Primitive | State | Note |
|---|---|---|
| len · eq · substring · find · concat · int→str · str→int | HAVE | 7 externs (`lib/prelude/prelude.chiral:78-87`) + `str->i64` (`:124`). Shard A. ⚑ **`str-sub` is unclamped** and its own comment claims it clamps — E176, BA-35 |
| starts-with · strip-prefix · contains · split · join | HAVE | `lib/prelude/string.chiral` (228 L). ⚑ *Was cited as `string-utils.chiral` (39 L) + `collections.chiral`; neither file exists. `collections.chiral` split into `lib/prelude/{list,map,set,alist,ord}.chiral`* |
| **Ordering (`str-cmp → Ord`)** | **BUILT E151** | ⚑ *Was `MINTED`.* One definition, `lib/prelude/string.chiral:91`. The four duplicates this row counted are retired: `lib/typing/ty-cmp.chiral:15` and `lib/typing/row-infer.chiral:17` are now imports of the owner, and the prefix-renamed dodges `ar-str-cmp` / `cb-str-cmp` are grep-clean. `Ord` is owned by `lib/prelude/ord.chiral` |
| **case ops · trim** | **BUILT E151** | `str-lower` `:116`, `str-upper` `:132`, `str-trim` `:163`, all in `lib/prelude/string.chiral`. ⚑ *The app homes this row named are gone: `prog/prapanca/chatter/router.chiral:19` now imports the owner and says so in its comment, and `prog/prapanca/core/flow.chiral` carries no `str-trim`* |
| replace · pad | **BUILT E151** | `str-replace` `:186`, `str-pad` `:209` |
| repeat(Str) · index-of-any | GAP | `brepeat` exists for Bytes only; both grep-clean |
| **Format / interpolation / printf** | **BUILT E158** | ⚑ *Was `GAP — every message is hand-built with str-cat chains`.* `Doc` is printf's template split from its flatten: `lib/prelude/doc.chiral` (226 L), six constructors, no `d-union`, Lindig's strict worklist behind one exit `doc->str`; `doc->rendering` at `lib/protocol/render-doc.chiral`. Gated by suite Phase 14, 26 assertions, graded on evidence survival. Shard H, with E174 and E181 |
| Regex | DELIBERATE, and **replaced** | ⚑ *Was `DELIBERATE-ish — nothing uses it`.* `docs/banks/text.md` §1 states why there cannot be one: a backtracking matcher's cost is not bounded in its input and `PRINCIPLES.md` §2 makes a process's cost its type, so the thing is unwritable rather than discouraged. What stands in its place is built: `lib/text/matcher.chiral` (602 L), **E173 slice 1**, Antimirov partial derivatives, one pass, first consumer `prog/prose-lint.prog`, gated by Phase 19. ⚑ **Captures are slice 2 and unbuilt** |
| Char type | DELIBERATE | chars are `I64` codepoints; `Str` is opaque, bytes via `str->bytes` |
| UTF-8 decode | HAVE | `lib/protocol/utf8.chiral` (105 L), RFC 3629, 11-case gate. ⚑ *Was `TUI/vt-core/utf8.chiral`* |
| Display width (`wcwidth`) | GAP | Still stubbed. The only occurrence of the name in the tree is a comment at `lib/protocol/render.chiral:436`. `.planning/TUI-PRIMITIVES.md` carries the evicted audit's framing: grid-correctness, not polish; T17-tier |
| The match score · the edit script · the stable address | GAP | Shards E, F and G of `docs/banks/text.md`, all **UNASSIGNED**. `docs/arcs/text-tools-arc.md` holds them and has no reserved element block, so they cannot be scheduled yet. Named here so a future pass does not re-discover them as new |

## §3 · Collections

| Primitive | State | Note |
|---|---|---|
| `List` + map/filter/foldl/foldr/find/any/concat/reverse/append/head | HAVE | `lib/prelude/list.chiral` (190 L) |
| AVL `Map` + `Set` (comparator passed explicitly) | HAVE | `lib/prelude/map.chiral`, `lib/prelude/set.chiral` — `m-lookup/insert/delete/fold`, `s-add/member` |
| Association list | HAVE | `lib/prelude/alist.chiral` — `alist-get/put/has` |
| Linear collection of caps | HAVE | `lib/capability/lincoll.chiral` (E106) — move-only `SockVec`, `sv-push` at `:31`, four refusal samples |
| **Sort** | **BUILT E152** (2026-08-22) | Was: an insertion sort private to `row-infer.chiral` (`ins-sorted`). ⚑ *Corrected 2026-08-23:* not the ONLY one — `closconv.chiral`'s `ins-uniq` is the same shape over `(List I64)`. Now `lib/prelude/list.chiral:143` owns `list-sort`, a comparator-passed stable merge sort |
| Adjacent dedup | **BUILT E156** | `list-dedup-adj` at `lib/prelude/list.chiral:186`; `row-infer` adopted the owner and its private pair is retired. ⚑ **Its gate does not run**: the Phase 9 script was not ported in the migration and `tools/test/run-tests.sh:410` prints it skipped, with its reason, on every run |
| The last two private de-duplicators | **MINTED E165**, not built | `ins-uniq` at `lib/lowering/upper/closconv.chiral:41` and `dedup-str` at `lib/lowering/compile-back.chiral:118`. Both are compiler sources in the blob, and the conversion is not mechanical — `ins-uniq` maintains an *incremental* sorted accumulator |
| Array / vector (O(1) index) | GAP | `List` only; the evicted audit flagged the O(n) cost for `Grid` cells, carried in `.planning/TUI-PRIMITIVES.md:113` |
| Hash map | GAP | AVL only — needs `Ord` (have) and a hash function (see §7) |
| Queue · deque · heap | GAP | — |
| zip · enumerate · take · drop · partition · group-by · sum | GAP | re-derived ad hoc at each site. `ms-take`/`ms-drop` exist at `lib/prelude/list.chiral:95,105` but are `list-sort` internals, not a general face |
| Iterator / generator protocol | DELIBERATE | folds and explicit recursion; proper tail calls are guaranteed |
| Comprehensions | DELIBERATE | — |

## §4 · Control & errors

| Primitive | State | Note |
|---|---|---|
| Closed result sums at every boundary | HAVE | **the discipline** — `docs/definitions/pattern-boundary-sums.md`. A which-of-N string/sentinel is a finding, not a style. ⚑ *Path repointed from `docs/pattern-boundary-sums.md`* |
| Diagnostics as typed values | **BUILT E157** | A closed ten-arm `Reason` at `lib/typing/diag.chiral:121`, carried by `LoadR` and `CkR`. The message is a renderer over the value, never the value |
| Totality checking · guaranteed tail calls | HAVE | `lib/typing/totality.chiral`; the loop is constant-stack by construction |
| Exceptions / unwinding | DELIBERATE | the membrane replaces them; a failed command cannot unwind the loop |
| Generic `Result A E` alias | DELIBERATE | each boundary mints its own named sum (`RecvR`, `LoadR`, `PufR`…) — that is the point |
| Pattern matching, ADTs, generics, linear/erased quantities | HAVE | the language proper |
| Record-of-functions dictionaries (`Mach`, `Alloc`) | HAVE | the conformance seam — a frozen interface + named instances, one per blob |
| **An INDEXED record-of-functions** (`(data Alloc ((c MemCat)) …)`) | **GAP — measured 2026-08-24, no consumer, not minted** | Parses and type-checks, then **does not lower**. `lib/lowering/upper/specialize-singleton.chiral`'s `proj-idx` (`:98-116`) matches a projector as exactly `(t-lam (t-case (t-var 0) …))` — ONE lambda — and `sp-rw` (`:121+`, the name in the live file; the row said `_sp-rw`) rewrites exactly one application. An index makes every accessor a two-lambda chain and every projection a two-app spine, so nothing is rewritten, the dict threads as a runtime fn-valued value, and the lowerer er-skips it with `"body is not a lambda chain"` (`lib/lowering/upper/lower.chiral:417`, formatted by `lib/lowering/skip-diag.chiral:88` into `<name>: extern does not lower: <op>`). **This is independent of the count==1 singleton guard** (`:78-97`) — one instance still fails. Any fn-bearing record is affected. Lifting it means relaxing `proj-idx`/`sp-rw` to tolerate leading params. **No consumer:** E166 wanted it, turned out not to need it, and is itself dropped (§9 note), so per this file's own rule it is a GAP, not a mint. ⚑ **Whether it should exist at all is §12 FLAG 3** |
| A **quantity on a `data` parameter** (`((0 c MemCat))`) | **GAP — not surface syntax** | `lib/surface/parse.chiral:479-495` `build-params` calls `extract-2` on each param spec — exactly `(P kind)`, two elements — and rejects anything else with `bad data parameter (want (P kind))` (`:486`). Quantities exist on *fields* (`:498-504`, `(name ty)` or `(q name ty)`) and on function binders, **not** on data params. Value indices themselves are fine and precedented: `Grid`, `AllocR`, `AvailR`, `FeedR` are all `((n I64))` |

## §5 · OS & I/O (51 crossings)

| Primitive | State | Note |
|---|---|---|
| open · read · write · close · openat · O_CREAT/TRUNC · fcntl | HAVE | `lib/ports/file.port`, `lib/ports/fd.port` — `open-rw`, `open-create`, `read`, `write-fd`, `fd-close`, `fcntl` (E121), O_CLOEXEC (E110) |
| mmap · mprotect · memfd | HAVE | E28, E122 — `nb-sys-mmap`/`munmap`/`mprotect`/`close` in `lib/lowering/tal/sys.chiral` |
| Sockets: unix + AF_INET connect · send/recv · listen/accept · socketpair · fd-passing | HAVE | E29, E125–E127, E129 — `lib/ports/sock.port` (12 crossings), `lib/protocol/inet.chiral` |
| `poll` (N-fd) | HAVE | `lib/runtime/poll.chiral` (E31/T3); surface wrappers `poll2` at `lib/ports/sock.port:71` and `nb-poll` at `:74`. ⚑ *The old note "built and unused by scriba" is stale: `prog/scriba/command-loop.chiral:151` calls `nb-poll`* |
| fork · execve · wait4 · spawn-in-pty · setsid · dup2 · TIOCSCTTY | HAVE | E33, T1, E104 — `lib/runtime/proc.chiral` owns `proc-spawn` |
| termios raw · TIOCGWINSZ/TIOCSWINSZ · pty acquisition | HAVE | E103, T2, E104 — `lib/protocol/term.chiral`, `lib/ports/pty.port` (9 crossings) |
| `rt_sigaction` (signal) | HAVE | `nb-signal` at `lib/lowering/tal/target-linux.manifest:61`, body at `lib/lowering/tal/sys.chiral:581` — SIGHUP ignore, clean shutdown |
| Monotonic clock · sleep · env read (`Env` porttype) | HAVE **at the face, not at a caller** | `time-mono` and `sleep-ms` are declared at `lib/ports/clock.port:32-33`, `env-open` at `:39`. ⚑ **`Clock` and `Timer` are UNINHABITED** (`docs/banks/port.md:452-456`, E170 lane E): no extern returns either and a porttype has no constructor, so both crossings are unreachable from any program, and `lib/runtime/supervisor.chiral`'s `(1 c Clock)` parameter makes it uncallable from a root. Their types still refuse a drop or a duplicate — a refusal quantified over an empty set of callers |
| **Directory listing (`getdents64`) + `stat`** | **MINTED E148** | Not built — **zero `getdents`/`statx` occurrences anywhere under `lib/`**, re-verified 2026-09-10. Three workarounds live on this: `prog/scriba/flook.chiral`'s stub declares, the manas setup library's `index.json` (`.planning/SCRIBA-STATE.md:229`), and `prog/test-runner.prog`'s bundled manifest. Shard J of `docs/banks/text.md` |
| **`unlink` · `rename` · `mkdir`** | **MINTED E149** | Not built — flook's `flook-do-delete`/`flook-do-rename` are `declare`-only; `mkdir` is what an absolute setups dir needs. Split from E148 on purpose: write authority is its own grant |
| **Own `argv`** | **MINTED E150**, `specced` | `proc.chiral`'s argv is *outgoing* (spawning a child). **CORRECTED 2026-08-22: the capability EXISTS today with zero new crossings** — via `/proc/self/cmdline` over the existing **`openat` (O_RDONLY)**, ⚑ *not `open-rw`, which is `O_RDWR\|O_NOCTTY` and returns `EACCES` on a `-r--r--r--` file for any non-root process; the earlier probes passed only because the sandbox runs as uid 0*. What is missing is the *library wrapper* and a `/proc`-free substrate. `docs/elements/specs/E80-cap-to-main-SPEC.md` decision #2 settled the shape: **argv is input, not authority**, so no cap is offered. Entry points are stdin-driven by habit, not necessity |
| `lseek` · `truncate` | HAVE **at the tal floor, not at the surface** | `nb-sys-lseek-t` at `lib/lowering/tal/sys.chiral:64` and `nb-sys-ftruncate-t` at `:88`; **no `.port` registry declares either**, so no surface program reaches them. ⚑ *Was a flat `GAP`, which rounded a half-built crossing to undone* |
| `symlink` · `chmod` | GAP | grep-clean at every tier |
| Threads | DELIBERATE | serial mutation is the mux/linearity model |
| Timers / async / event loop | **BUILT E42**, unadopted | ⚑ *Was "E42 supervisor (designed, unbuilt)" — the ledger says otherwise.* `lib/runtime/supervisor.chiral` (139 L) is BUILT, imports `lib/capability/lincoll.chiral`, and is reached **only** from `prog/samples/e42_*` fixtures (`docs/elements/catalog.md:169`). scriba `S28` is `design`; `S29` was corrected 2026-08-22 to read *gated on ADOPTING E42, not on building it*. The **register-root custody** half of E42's title is on the deferred ownership track and is not current work |

## §6 · Encoding & formats

| Primitive | State | Note |
|---|---|---|
| JSON (parse + emit) | HAVE | `lib/protocol/json.chiral`, 361 L. Numbers are kept as **raw lexemes**, which is what makes it float-free (`docs/goals/coding-agent.md:77`) |
| UTF-8 | HAVE | `lib/protocol/utf8.chiral` |
| Binary pack/unpack u16/u32 | HAVE | prelude + `lib/lowering/tal/bytes.chiral` (`bget-u16-le`, `bput-u32-le`, …) |
| ELF · Wayland wire · VT/ANSI · APC | HAVE | `lib/lowering/x64/elf.chiral`, `lib/protocol/wire.chiral`, `lib/protocol/vt-parser.chiral`, `lib/protocol/apc.chiral` (E112) |
| `bput-u16-le` | **BUILT E109** | ⚑ *Was `GAP — reader exists, writer doesn't`.* Defined at `lib/lowering/tal/bytes.chiral:628`, under its own comment at `:621`, the little-endian inverse of `bget-u16-le`. Landed `1b13fe1` |
| base64 · hex | GAP | both grep-clean under `lib/` |
| CSV · YAML · TOML · XML | GAP | no consumer. ⚑ *And the tree's answer to config is not a format: `E163` proposes a **manifest module kind** — pure type-checked chirality in the blob, no parser and no schema language. Unbuilt; `lib/lowering/tal/target-linux.manifest` is the working instance nothing names* |
| gzip / compression | GAP | — |

## §7 · Crypto, hashing, randomness

⚑ **This section's framing was superseded twice and is rewritten.** The old text
read the whole territory as "the `CRY` ladder E114–E119 in dependency order".
Two things broke that. First, **E114–E119 were never minted**: they are reserved
*slots* in `docs/elements/ledger.md:353-359` with **no catalog row**, marked `?`
on the track axis, and `docs/elements/catalog.md:590-593` states it in those
words — *"they are slots rather than elements, they have no catalog row"*.
Naming a slot as a mint is the same defect this section's own footnote warns
about, one turn later. Second, **the ladder's reference class was abandoned**:
`.planning/CRYPTO-MODEL.md` (2026-09-05, twelve author rulings) re-scopes the
whole set post-quantum, and `docs/arcs/crypto-primitives-arc.md` opened
2026-09-07 with **25 rows** `K1`–`K25` against `docs/goals/own-web.md` condition
4. The scope belongs to that arc. Nothing here re-decides it.

| Primitive | State | Note |
|---|---|---|
| Capability custody primitive | HAVE | `lib/capability/secret.chiral` (E40) — **custody, not crypto**. E40 is filed on the deferred ownership track |
| ChaCha20 stream | **BUILT `native-protocol/N1`** slice 1 | `lib/crypto/chacha.chiral`, 163 lines. The 32-bit lane idiom (`M32`, `add32`, `rotl32`) at `:18-25` is the word layer as one kernel spells it |
| Poly1305 + the AEAD composition | **BUILT `native-protocol/N1`** slice 2 | `lib/crypto/poly1305.chiral`, 245 lines. Both slices gated by suite Phase 31, `run_phase 31 "the crypto kernels (N1 slices 1 and 2)"` at `tools/test/run-tests.sh:367`. ⚑ **Both are MARKED pre-quantum** (`docs/arcs/native-protocol-arc.md:60`): they are built against WireGuard's suite, which the stated target abandons. `native-protocol/N10` carries what happens to them |
| **A collision-resistant digest** | **`SLOTTED E116`, and re-scoped** | Absent, and so is every layer below it (`docs/arcs/crypto-primitives-arc.md`, "What the tree already holds"). The `E116` slot text — SHA-256/512, SHA-3, needing bit-floor and exact width — stands as the reservation. The **live** work is `crypto-primitives/K1` (translate Keccak-f[b]), `K2` (the permutation module), `K3`/`K4` (the sponge), `K5` (the mark). Blocks hash maps and content addressing until then |
| Random / entropy | **`SLOTTED E114`**, and rostered twice | `getrandom` is grep-clean tree-wide. The crossing is `native-protocol/N2` (open, not started); the discipline over it — what consumes entropy, why a source is linear, where deterministic derivation replaces a draw — is `crypto-primitives/K18` |
| Bit rotations (`rotl`/`rotr`) | **DESIGNED `emitted-speed/X8`** | See §1. ⚑ *This row read `ALREADY SLOTTED — E115`; `emitted-speed/X8` decision 8 mints fresh and **narrows the `E115` slot to `bnot` alone***. The rotate's home is CG beside E96 and E108 on the self-hosting track, not the unsorted CRY band |
| `bnot` | **`SLOTTED E115`** (narrowed) | What is left of that slot after `X8`. Its row is `C21` in `docs/benchmarks/OPT-CANDIDATES-2026-09.md:337`, which wants `B6` because a complement is unary |
| HMAC/HKDF · AEAD · curve25519 | **`SLOTTED E117/E118/E119`, and the class is dead** | The AEAD half is partly built (N1 slice 2, above). The curve half is not deferred, it is **abandoned**: `.planning/CRYPTO-MODEL.md` §1 records X25519 and Ed25519 as *"genuinely dead"* under Shor, and `docs/goals/own-web.md` condition 4 states a post-quantum target. The replacements are `crypto-primitives/K7`–`K12` (a PQ KEM, a PQ signature, the signature staircase, the combiner, the PAKE) |
| TLS | GAP, **and refused in this shape** | `lib/protocol/http.chiral` is plaintext-only by design (E129: "zero TLS"), on the reasoning that WireGuard/Tailscale supplies transport crypto. `native-protocol/N4` owns the handshake and framing, Noise as reference class |

> **Checked before claiming.** An earlier draft of this table called hashing and
> randomness uncataloged gaps. They are not — `docs/elements/ledger.md` §CRY reserved
> E114–E119 for exactly this ladder. Naming an already-refracted thing as missing is
> the cardinal working error here.
>
> ⚑ **And this draft made the mirror error.** Calling those reservations `MINTED`
> for three weeks named six elements that have never existed. A slot is a number
> held open; a mint is a catalog row with a consumer. The rule that catches the
> first defect does not catch the second, and both are phantom dependencies.

## §8 · Network & time (higher tier)

| Primitive | State | Note |
|---|---|---|
| HTTP/1.1 client | **BUILT E130** | ⚑ *Was "HAVE — `http.chiral` (E130 = native transport swap, design)". The swap landed.* `lib/protocol/http.chiral:4-8` records it and `http-request` is a `def` at `:436-437` over the native socket caps; the urllib shim is retired. ENFORCED by suite Phase 20 (`tools/test/transport.sh`), dispatched at `tools/test/run-tests.sh:326`. **Non-streaming**; SSE was deferred |
| DNS resolution | GAP | E129 defers; dotted-quad only |
| TLS | GAP | see §7 |
| HTTP server / websockets | GAP | `sock-listen`/`sock-accept` exist as the floor (`lib/ports/sock.port`). Listen-side AF_INET, and UDP if the handshake wants it, is `native-protocol/N3` |
| Monotonic time | HAVE at the face, unreachable | `time-mono` — see the `Clock`/`Timer` uninhabitedness in §5 |
| Calendar date/time type · formatting · parsing · timezones | GAP | a raw counter is all there is |

## §9 · Tooling

| Primitive | State | Note |
|---|---|---|
| Test runner (native, no shell/python) | HAVE | `prog/test-runner.prog` + `lib/evidence/harness.chiral`. Rewritten onto the **E168** test floor: expectations carry the provenance of their expected exit code, judged by a pure total fold that cannot reach a crossing. Phase 2 rebuilds it from source before executing it |
| Reference interpreter over the pure fragment | HAVE, **unreached** | `lib/evidence/interp.chiral` (109 L) is a chirality reference interpreter with **ZERO importers** (`docs/elements/catalog.md:112`) — E15, built and ungated. Keep distinct from the E42 supervisor |
| Pretty-printer | HAVE | `lib/surface/pretty.chiral`, repointed at the real `Term` and returning `Doc` (E181) |
| Logging framework | **BUILT E139**, endpoint unbuilt | ⚑ *Was `GAP — E139 be-log noted optional`.* `be-log : (=> Backend RunManifest Str Unit)` lives at `prog/prapanca/pipeline/log.chiral`, fire-and-forget over `http-request "POST" {base}/internal/log`, with `manifest-to-json` beside its E141 inverse. It **B1-lowers and the JSON round-trip is gated**; the live POST is deferred because the worker's `/internal/log` endpoint does not exist. That is a consumer gap, not a language gap |
| Argument parser | GAP, waiting on E150 | ⚑ *This row read `blocked on E150 anyway`, and `blocked` is the wrong word for it* (`docs/definitions/working-discipline.md:112-124`). E150 is `specced`; a parser written against it is specifying an argv face, not obstructed by one |
| Benchmarking harness | **partly HAVE** | ⚑ *Was `GAP — perf campaign closed with ad-hoc timing`.* `tools/bench/crypto-kernel.sh` is a real driver whose instrument is `heap-allocated` (`lib/ports/process.port:36`), the arena's own bump cursor — exact bytes, not an inference from residency. `docs/benchmarks/` holds thirteen documents. What is still missing is a **general** harness: every measurement in the tree is written per subject |
| A second judgment core | GAP, and **the previous attempt is dropped** | E166's C-emitting `Mach` was built 2026-08-24 and **dropped 2026-09-01** (`d8bcec5`, `d0c5dd5`), code deleted. It shared `compile-front` and `compile-back` whole with the canonical instance and differed only at emit, so it was a second *target* under one formulation. What replaces external judgment is three semantically distinct judgment cores that must agree, and that is unbuilt (`docs/definitions/status-ledger.md`) |

---

## §10 · The pattern behind the gaps

Not "chirality is missing 40 things." The shape is narrower and more specific,
and three of the four points below have moved since this file was minted.

1. **The floor is deliberately tiny (34 externs) and the tower is honest** — every OS
   capability that was needed got built as a real, typed, linear crossing. The
   *systems* surface is unusually complete for a language this young: ptys, sockets,
   fd-passing, mmap, poll, fork/exec are all there and PTY-proven. ⚑ *With one
   correction: `Clock` and `Timer` are declared and uninhabited, so two of the
   crossings this point counts are unreachable.*
2. **The "boring middle" was the gap, and most of it closed.** ⚑ *This point
   listed sort, string ordering, case conversion, hashing, floats and argv.
   Sort is E152, ordering and case are E151, formatting is E158, the writer is
   E109, the matcher is E173.* What is left of the list is **hashing** (§7, an
   arc's subject now), **floats** (§1, and a fork — FLAG 1), and **argv** (E150,
   specced). The pattern held: nothing in the closed set was hard, and each
   waited on a consumer rather than on a design.
3. **The tell was helpers homed in the wrong module, and E151 retired the
   symptom it named.** ⚑ *`str-cmp` no longer exists four times; the two
   app-homed text helpers are gone from `prog/prapanca/`.* The **mechanism** is
   still live and is not a stdlib problem: `E154`, per-module label namespacing
   at lowering. When a shared name cannot be defined twice safely in the flat
   emitted-label space, modules write prefixed clones instead of importing.
   Its own catalog row cites this file's §10 as the root it names, and it lists
   three hand-patches (`gate-contains`, `agent-ok2xx`, an inlined
   `lookup-scribaop`) plus the surviving clones `puf-length`/`puf-reverse`,
   `se-length`/`se-reverse`, `list-nth`×2. **The duplication was the symptom;
   the flat label space is the cause, and it is unbuilt.**
4. **Floats are the one place the tree points two ways.** ⚑ *This point read
   "the one genuine language-level hole" and asserted a verdict the tree does
   not hold unanimously.* E153 is real and unbuilt, and a float tower would
   touch the type system, the reader, the TAL and codegen. But two live
   authorities call the absence a design rather than a hole, and this file is
   not the tier that settles it — §12 FLAG 1.

## §11 · Minted from this pass

State column re-measured 2026-09-10 against `docs/elements/catalog.md` and
`docs/examples/INDEX.md`.

| E# | What | State today | Consumer that justifies the mint |
|----|------|-------------|-------------------------------|
| **E148** | `getdents64` + `stat` — directory read | not built | scriba `S24` (flook); retires the setups `index.json` + test-runner manifest |
| **E149** | `unlink` + `rename` + `mkdir` — fs mutation (write authority, split from read) | not built | scriba `S24` delete/rename; an absolute setups dir |
| **E150** | Own `argv` | `specced` | `scriba <file>`, `bin/chirality` as a real CLI, every future entry point |
| **E151** | Give string comparison an owner: canonical `str-cmp → Ord`, `str-lower`/`str-upper`, `str-trim`, `str-replace`, `str-pad` | **BUILT**, all seven names at `lib/prelude/string.chiral` | retired 4 duplicate `str-cmp` defs + 2 app-homed text helpers |
| **E152** | Polymorphic sort (comparator-passed merge sort on `List`) | **BUILT** `lib/prelude/list.chiral:143` | catalog/flook/completion listings |
| **E153** | `F64` float tower — type, literals, arithmetic externs, `i64↔f64` | not built, and **contested** — FLAG 1 | any measurement, rate, ratio, or probability |

Not minted, and correctly so: TLS/DNS, base64, dates, arrays, hash maps,
`abs`/math. ⚑ *This sentence used to open with "hashing/entropy/AEAD (**already
minted E114–E119**)". Corrected: those are reserved slots, not mints, and their
live work is the `crypto-primitives` and `native-protocol` rosters.* Everything
else above is **GAP, not minted** — deliberately. Minting an element with no
consumer creates the opposite phantom: a catalog row nobody will ever pull. Mint
on first real need.

---

## §12 · Forks this file does not settle

A primitive's existence is a language-design decision.
`docs/definitions/working-discipline.md` section *"A capability the substrate
lacks is a finding"* governs the form: a discovered requirement carries the
workload that discovered it and the citation that proves the absence, and the
word `blocked` is wrong for it. The rows below are the ones where the fork is
the **author's** rather than the tree's — either the tree points two ways, or
the question is whether a primitive should exist at all. **This file records
them and answers none.** They belong in `records/author-calls.md`.

### FLAG 1 — `F64`, and whether its absence is a hole or a design

- **The primitive.** An IEEE-754 binary64 type: the type, literal syntax in the
  reader, arithmetic and comparison externs, `i64↔f64` conversion, a TAL
  representation, and x86-64 SSE codegen. Minted as **E153**, not built.
- **The workload that asked for it.** `prog/prapanca/core/types.chiral:4-6` —
  the pure data model the whole orchestration engine is typed against — states
  the absence as a wall it worked around: *"NO floats (the float->I64 wall:
  num-ctx, duration-ms, chunk ids are I64; sha256s + timestamps are Str)"*.
  `prog/prapanca/core/match.chiral:5-6` is the second, routing by an integer
  keyword-overlap count with a header saying why it is not a cosine.
- **What the absence costs today, measured.** Every quantity that is naturally a
  ratio is carried as a scaled integer or a string. `lib/protocol/json.chiral`
  keeps every number as a **raw lexeme** rather than a value, which is what lets
  a JSON tower exist at all without floats; a consumer that wants arithmetic on
  a JSON number re-parses it itself. `prog/prapanca/pipeline/log.chiral`'s
  `manifest-to-json` renders every I64 through `i64->str`→`j-num`, explicitly
  *"(no float)"*.
- **Side A — it is a hole.** `docs/elements/catalog.md:479`: *"Not built —
  **zero float support anywhere**… Consequence: no average, rate, ratio,
  probability, or temperature is expressible without hand-rolled integer
  scaling."* This file's own §1 and §10 said the same for three weeks.
- **Side B — it is a design.** `docs/goals/coding-agent.md:75` carries a shape
  condition stated by the author: **"no route, rank or selection may assume a
  float"**, quoted as *"No float type in chirality. lib/protocol/json.chiral
  keeps numbers as raw lexemes. Any routing scheme that needs a score has to
  answer for that."* Its consequence 1 is checkable and currently green:
  *"`F64` and `Float` stay grep-clean under `lib/surface/` and `lib/typing/`…
  work under this goal that reaches for it **has changed the language rather
  than answered the constraint**."*
- **What the tree does NOT settle.** Whether E153 is a build target or a
  standing refusal. Side B constrains one goal's work and does not say the tower
  may never exist; side A calls it a hole and names no scope in which it is
  owed. Nothing states which reading governs a workload outside
  `docs/goals/coding-agent.md`, and nothing says what E153's status should be if
  the constraint is permanent.

### FLAG 2 — the `Op` sum's boundary: which of 38 machine operations get names

- **The primitive.** Not one primitive — a **rule** for admitting them. The `Op`
  sum is a closed set of sixteen (`lib/prelude/prelude.chiral:36-39`).
  `docs/benchmarks/OPT-CANDIDATES-2026-09.md` bucket C enumerates **38 rows** a
  current ISA offers and the sum omits: rotate, conditional move, byte swap,
  count-leading-zeros, count-trailing-zeros, popcount, add-with-carry, bit
  deposit and extract, the unsigned comparisons and divisions, a native 32-bit
  lane.
- **The workload that asked for it.** `lib/crypto/chacha.chiral:18-25` — the
  `M32`/`add32`/`rotl32` idiom, a 32-bit lane simulated inside a signed 64-bit
  one, with a rotation written as shifts and an or.
- **What the absence costs, measured.** ChaCha20's `qround` is **28 operations**
  here: `4 x (add32=2, bxor=1, rotl32=4)`
  (`docs/benchmarks/crypto-kernel-allocation.md` §3). A machine holding a rotate
  and a 32-bit lane pays one apiece for the three, so **12**. That is an
  operation count, and `docs/goals/emitted-speed.md` condition 6 is explicit
  that it is unrelated to the 2.2–2.3x wall clock the same document reports.
- **Side A — every operation gets named or refused.**
  `docs/goals/emitted-speed.md` condition 6: *"Every operation the machine
  offers is named or refused, and every name the `Op` sum carries reaches the
  surface."* `PRINCIPLES.md` P1 fixes the form — an operation the backend emits
  that the language does not name is *"P1's forgotten-syscall hole one level
  down"*, so an idiom recognized in the emitter must sit underneath a named
  primitive and substitute for none.
- **Side B — the floor is deliberately tiny.** This file's §0 and §10.1, and the
  whole self-hosting posture: 34 externs, *"everything else in chirality is
  written in chirality — which is the point"*. Thirty-eight more constructors is
  a doubling of the language's primitive surface.
- **What the tree does NOT settle.** The **admission test**. `emitted-speed/X8`
  takes exactly one row (rotate) and says in its own decision 8 that its width
  is open; `X7` took one more. Condition 6 says the other 36 are *"named or
  refused"* and no document says which, or what evidence a refusal owes. Nothing
  states whether a bucket-C row needs a measured consumer before it may be
  named, or whether the enumeration itself is the obligation.

### FLAG 3 — the indexed record-of-functions: lift the lowerer, or refuse the shape

- **The primitive.** A `data` declaration carrying a parameter *and* function
  fields — `(data Alloc ((c MemCat)) …)`. It parses and type-checks and does not
  lower.
- **The workload that asked for it.** The memory-discipline shape: one `Alloc`
  interface indexed by a memory category, so a discipline is a value rather than
  a module. `docs/banks/memory.md` §5 residue 1 and 4 are the standing demand
  for exactly this kind of indexed custody. E166 wanted it and turned out not to
  need it — and E166 is now dropped, so the shape has **no live consumer at
  all**.
- **What the absence costs, measured.** `lib/lowering/upper/specialize-singleton.chiral`'s
  `proj-idx` (`:98-116`) matches a projector as exactly one lambda over one
  `t-case` on `t-var 0`, and `sp-rw` (`:121+`) rewrites exactly one application.
  An index makes every accessor a two-lambda chain and every projection a
  two-app spine, so **nothing is rewritten**, the dict threads as a runtime
  fn-valued value, and lowering er-skips it with *"body is not a lambda chain"*
  (`lib/lowering/upper/lower.chiral:417`). This is independent of the `count==1`
  singleton guard (`:78-97`): a single instance still fails. **Any fn-bearing
  record is affected.** The fix is bounded and named: relax `proj-idx`/`sp-rw`
  to tolerate leading params.
- **Side A — it is a defect to lift.** The shape is accepted by two of the three
  tiers that see it. A thing that parses and type-checks and then silently
  becomes an unlowerable runtime value is the specialization pass's reach
  falling short of the surface language's, which is the same class of
  discrepancy P1 refuses elsewhere.
- **Side B — it is a shape to refuse.** The `count==1` guard's own comment
  (`:78-84`) states the principle it defends: *"two distinct fn-bearing
  instances (e.g. two Alloc disciplines) cannot coexist in one blob, and the
  pass must NOT silently pick one"*, recording that a `count>=1` relaxation at
  `16d6d1a` produced an order-dependent silent miscompile and was reverted. A
  monomorphizing pass and an indexed dictionary are in tension by construction.
  And this file's own no-phantom rule says a shape with no consumer is not
  minted.
- **What the tree does NOT settle.** Whether the language's `data` grammar
  should accept a form the lowerer cannot carry. The parser and checker say yes,
  the lowerer says no, and no decision document owns the boundary. The
  companion row — a quantity on a `data` parameter (§4) — has the same shape
  and the same silence: `lib/surface/parse.chiral:486` refuses it with a message
  and no document says whether the refusal is a limit or a rule.

### FLAG 4 — the six reserved CRY slots: keep, retire, or re-point

- **The primitive.** Six element numbers, `E114`–`E119`, reserved in
  `docs/elements/ledger.md:353-359` for entropy, a bit floor, a hash, a KDF, a
  symmetric AEAD and an asymmetric pair.
- **The workload that asked for it.** Two live arcs now cover the same ground
  with roster rows: `docs/arcs/crypto-primitives-arc.md` (25 rows, `K1`–`K25`,
  opened 2026-09-07) and `docs/arcs/native-protocol-arc.md` (`N1`, `N2`, `N5`,
  `N6`, `N10`).
- **What the ambiguity costs, measured.** Three tree documents cite the slots as
  if they were mints — `.planning/USER-LAYER-GAP.md:170` reads `MINTED
  E114–E119`, `:171` reads `MINTED E116`, `:704` lists `E114–E119` under
  *"Already minted — cite freely"* — and this file did the same until today.
  Four documents therefore carry deferrals to elements that have never been
  minted, which is the phantom dependency the deferral rule exists to prevent.
  `docs/arcs/parts/emitted-speed-X8.md` decision 8 is the one row that met the
  question head-on and routed around it, declining to claim `E115` because doing
  so would *"pull an author call into a row that owes none"* — and narrowing the
  slot's text in passing, which is a slot edit made by an arc row.
- **Side A — the slots stand.** `docs/elements/catalog.md:590-593` explains the
  `?` track deliberately: crypto is named nowhere in
  `docs/decisions/decision-scope.md`'s split, and the ledger's own
  `crypto-secret-independence` note founds itself on E59+E60, both on the
  deferred track. The `?` is an honest unsorted, not a stale one.
- **Side B — the slots are stale reservations.** Their content is superseded.
  `.planning/CRYPTO-MODEL.md` §1 records X25519 and Ed25519 as *"genuinely
  dead"*, which is `E119`'s whole subject; `E118`'s AEAD is half-built under
  `native-protocol/N1` and marked pre-quantum; `E115` has been narrowed to
  `bnot` by an arc row; `E116`'s live work is `K1`–`K5`. Four of six no longer
  describe work anyone will do under that number.
- **What the tree does NOT settle.** Whether a reserved slot with no catalog row
  may be cited at all, and by what state word. This file added `SLOTTED` today
  to say what it is without saying it is minted — that is a naming choice, not a
  ruling. Nothing says whether the slots should be given catalog rows, retired
  into the two arcs' rosters, or left as numbers held open; and nothing says
  whether an arc row may edit a slot's text, which `X8` has now done.

### FLAG 5 — `Clock` and `Timer`: two crossings no program can reach

- **The primitive.** A monotonic clock and a sleep. Declared at
  `lib/ports/clock.port:32-33` as `time-mono : (=> (1 c Clock) TimeR)` and
  `sleep-ms : (=> (1 t Timer) I64 SleepR)`.
- **The workload that asked for it.** `lib/runtime/supervisor.chiral` (E42, 139
  lines, BUILT) takes a `(1 c Clock)` parameter. scriba `S28` (interruptible
  run) and `S29` (background work and completion events) are both written
  against a supervised loop.
- **What the absence costs, measured.** `docs/banks/port.md:452-456`, from E170
  lane E: *"No extern returns either and a porttype has no constructor, so
  `time-mono` and `sleep-ms` are crossings no program can reach and
  `supervisor.chiral`'s `(1 c Clock)` parameter makes it uncallable from a root.
  Their types still refuse a drop or a duplicate — a refusal quantified over an
  empty set of callers."* E42 is consequently reached only from
  `prog/samples/e42_*` fixtures (`docs/elements/catalog.md:169`), and "built but
  unadopted" is named in `prog/test-runner.prog:8-9` as this repo's measured
  failure mode, *"four occurrences including E42"*.
- **Side A — mint the constructors.** Every other cap family has an ambient mint
  (`adopt-fd`, `env-open`, `pool-create`, `sock-connect`), and
  `docs/banks/port.md` measures non-forgeability at **0 for every port**
  already. A `clock-open : (=> Unit Clock)` would be consistent with the whole
  existing family and would make E42 and S28/S29 reachable.
- **Side B — the uninhabitedness is the point.** Ambient mints are exactly what
  that bank names as the violation of *no ambient authority*, with a number
  attached: **42 of the 62 crossings took no capability at all**. Adding two
  more ambient mints widens the hole the bank is measuring. And time is the one
  authority a supervisor arguably should receive from its caller rather than
  conjure.
- **What the tree does NOT settle.** How a root acquires its first capability.
  This is the general question — `E80-cap-to-main` names it and its decision #2
  settled only argv's half (*argv is input, not authority*). Until it is
  answered, `Clock` and `Timer` stay declared, typed, gated by linearity, and
  reachable by nothing; §5's `HAVE` for that row is a claim about the face only.
