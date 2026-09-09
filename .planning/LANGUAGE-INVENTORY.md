# chirality — common-language primitive inventory

**Minted 2026-08-21**, read from live source at HEAD `1cafe80`. The question:
*which primitives and stdlib pieces that any working language provides does chirality not
have yet?* — asked because the scriba user layer (and everything after it) will reach
for them.

This is the **language** axis. The **editor** axis is
`.planning/SCRIBA-PRIMITIVE-CHECKLIST.md`; the **terminal substrate** axis is
`TUI/PRIMITIVE-AUDIT.md`. Different lanes — do not merge them.

**Reading the state column:**
`HAVE` · `MINTED E###` (missing, now a cataloged element with a named consumer) ·
`GAP` (missing, **not** minted — no consumer yet; mint it when one appears, per the
no-phantom-dep rule) · `DELIBERATE` (absent by decision — do not "fix").

---

## §0 · The floor as it stands

| Layer | Count | Where |
|---|---|---|
| Pure primitive externs (the category-A floor) | **32** | `scaffold/lib/prelude.chiral` |
| Pure prelude defs on top | **11** | `str->i64`, `not/and/or/if`, `max/min`, … |
| Crossings (the category-C floor) | **50** | `scaffold/lib/ports.chiral` |
| Library modules | **88** | `scaffold/lib/*.chiral` |

The 32 externs, in full: `+ - * / %` · `=i <i <=i` · `band bor bxor shl shr sar` ·
`str-len str-eq str-sub str-find str-find-from str-cat i64->str` ·
`str->bytes bytes->str` · `blen bget bslice bcat brepeat pack-u32 unpack-u32 pack-u16
unpack-u16`. Base types: `Unit Bool Pair Maybe List` (+ `Op` for the TAL).

That is the whole of it. **Everything else in chirality is written in chirality** — which is
the point, and also why the gaps below are gaps rather than bindings.

---

## §1 · Numeric tower

| Primitive | State | Note |
|---|---|---|
| Signed 64-bit int, wrapping | HAVE | Euclidean `/` `%` across reference/fold/native — **settled, do not re-argue** |
| Full bitwise set | HAVE | incl. `shr`/`sar` — `TUI/PRIMITIVE-AUDIT.md` still lists these as a WANT; **that row is stale**, they are prelude externs (`prelude.chiral:60–61`) |
| `max` / `min` | HAVE | `prelude.chiral` |
| **Floating point (`F64`)** | **MINTED E153** | **Zero float support anywhere in the tree** — no type, no literal, no arithmetic, no conversion. Nothing can compute an average, a rate, a probability, a temperature, or a ratio without integer scaling by hand |
| `abs` | GAP | one line, no home yet |
| `sqrt` / `pow` / `log` / `exp` / trig | GAP | no math module exists |
| Unsigned integer type | DELIBERATE | width is a moduleset `NumProfile` decision (**decided, do not re-pitch**) — `docs/decision-numeric-width-pluggable.md` |
| Arbitrary-precision integers | GAP | — |
| Checked / saturating arithmetic | GAP | wraps two's-complement by decision |

## §2 · Strings & text

| Primitive | State | Note |
|---|---|---|
| len · eq · substring · find · concat · int→str · str→int | HAVE | 7 externs + `str->i64` |
| starts-with · strip-prefix · contains · split · join | HAVE | `string-utils.chiral` (39 L) + `collections.chiral` |
| **Ordering (`str-cmp → Ord`)** | **MINTED E151** | **Defined 4 separate times** — `ty-cmp.chiral:34`, `row-infer.chiral:35`, `asm-reloc.chiral:79`, `compile-back.chiral:128`. Every `Map` keyed by `Str` needs a comparator and there is no canonical one |
| **case ops · trim** | **MINTED E151** | `str-lower` lives in `prapanca/chatter/router.chiral:46`; `str-trim` lives in `prapanca/core/flow.chiral:430` — **text primitives homed inside the orchestration app** because there is no string module to put them in |
| replace · pad · repeat(Str) · index-of-any | GAP | `brepeat` exists for Bytes only |
| **Format / interpolation / printf** | GAP | every message is hand-built with `str-cat` chains |
| Regex | DELIBERATE-ish | nothing uses it; the boundary-sums discipline prefers parsers over patterns. Reconsider only with a real consumer |
| Char type | DELIBERATE | chars are `I64` codepoints; `Str` is opaque, bytes via `str->bytes` |
| UTF-8 decode | HAVE | `TUI/vt-core/utf8.chiral`, RFC 3629, 11-case gate |
| Display width (`wcwidth`) | GAP | stubbed to 1 — `PRIMITIVE-AUDIT` flags this as **grid-correctness, not polish**; T17-tier |

## §3 · Collections

| Primitive | State | Note |
|---|---|---|
| `List` + map/filter/foldl/foldr/find/any/concat/reverse/append/head | HAVE | `collections.chiral` |
| AVL `Map` + `Set` (comparator passed explicitly) | HAVE | `m-lookup/insert/delete/fold`, `s-add/member` |
| Association list | HAVE | `alist-get/put/has` |
| Linear collection of caps | HAVE | `lincoll.chiral` (E106) — move-only `SockVec` |
| **Sort** | **BUILT E152** (2026-08-22) | Was: an insertion sort private to `row-infer.chiral:93` (`ins-sorted`). ⚑ *Corrected 2026-08-23:* not the ONLY one — `closconv.chiral:39`'s `ins-uniq` is the same shape over `(List I64)`. Now `collections.chiral` owns `list-sort`, a comparator-passed stable merge sort |
| Array / vector (O(1) index) | GAP | `List` only; `PRIMITIVE-AUDIT` flags the O(n) cost for `Grid` cells |
| Hash map | GAP | AVL only — needs `Ord`, and there is no hash function at all (§7) |
| Queue · deque · heap | GAP | — |
| zip · enumerate · take · drop · partition · group-by · sum | GAP | re-derived ad hoc at each site |
| Iterator / generator protocol | DELIBERATE | folds and explicit recursion; proper tail calls are guaranteed |
| Comprehensions | DELIBERATE | — |

## §4 · Control & errors

| Primitive | State | Note |
|---|---|---|
| Closed result sums at every boundary | HAVE | **the discipline** — `docs/pattern-boundary-sums.md`. A which-of-N string/sentinel is a finding, not a style |
| Totality checking · guaranteed tail calls | HAVE | `totality.chiral`; the loop is constant-stack by construction |
| Exceptions / unwinding | DELIBERATE | the membrane replaces them; a failed command cannot unwind the loop |
| Generic `Result A E` alias | DELIBERATE | each boundary mints its own named sum (`RecvR`, `LoadR`, `PufR`…) — that is the point |
| Pattern matching, ADTs, generics, linear/erased quantities | HAVE | the language proper |
| Record-of-functions dictionaries (`Mach`, `Alloc`) | HAVE | the conformance seam — a frozen interface + named instances, one per blob |
| **An INDEXED record-of-functions** (`(data Alloc ((c MemCat)) …)`) | **GAP — measured 2026-08-24, no consumer, not minted** | Parses and type-checks, then **does not lower**. `specialize-singleton.chiral`'s `proj-idx` (`:99-118`) matches a projector as exactly `(t-lam (t-case (t-var 0) …))` — ONE lambda — and `_sp-rw` (`:120+`) rewrites exactly one application. An index makes every accessor a two-lambda chain and every projection a two-app spine, so nothing is rewritten, the dict threads as a runtime fn-valued value, and the lowerer er-skips it: `alo-cell: extern does not lower: body is not a lambda chain`. **This is independent of the count>1 singleton guard** (`:78-84`) — one instance still fails. Any fn-bearing record is affected. Lifting it means relaxing `proj-idx`/`_sp-rw` to tolerate leading params. **No consumer yet:** E166 wanted it and turned out not to need it (the invariant was already structural), so per this file's own rule it is a GAP, not a mint. |
| A **quantity on a `data` parameter** (`((0 c MemCat))`) | **GAP — not surface syntax** | `parse.chiral:479-493` `build-params` calls `extract-2` on each param spec — exactly `(P kind)`, two elements — and rejects anything else with `bad data parameter (want (P kind))`. Quantities exist on *fields* (`:495`, `(name ty)` or `(q name ty)`) and on function binders, **not** on data params. Value indices themselves are fine and precedented: `Grid`, `AllocR`, `AvailR`, `FeedR` are all `((n I64))`. |

## §5 · OS & I/O (50 crossings)

| Primitive | State | Note |
|---|---|---|
| open · read · write · close · openat · O_CREAT/TRUNC · fcntl | HAVE | `open-rw`, `open-create`, `read`, `write-fd`, `fd-close`, `fcntl` |
| mmap · mprotect · memfd | HAVE | E28, E122 |
| Sockets: unix + AF_INET connect · send/recv · listen/accept · socketpair · fd-passing | HAVE | E29, E125–E127, E129 |
| `poll` (N-fd) | HAVE | `poll.chiral` (E31/T3) — **built and unused by scriba** |
| fork · execve · wait4 · spawn-in-pty · setsid · dup2 · TIOCSCTTY | HAVE | E33, T1, E104 |
| termios raw · TIOCGWINSZ/TIOCSWINSZ · pty acquisition | HAVE | E103, T2, E104 |
| `rt_sigaction` (signal) | HAVE | SIGHUP ignore, clean shutdown |
| Monotonic clock · sleep · env read (`Env` porttype) | HAVE | `time-mono`, `sleep-ms`, `env-open/view/close` |
| **Directory listing (`getdents64`) + `stat`** | **MINTED E148** | Nothing can enumerate a directory or ask a file's size/mtime/existence. Three workarounds live on this: flook's stub declares, the manas setup library's `index.json`, `test-runner`'s bundled manifest |
| **`unlink` · `rename` · `mkdir`** | **MINTED E149** | flook's delete/rename are `declare`-only; `SCRIBA-STATE.md` P4 notes the missing `mkdir` for an absolute setups dir |
| **Own `argv`** | **MINTED E150** | `proc.chiral`'s argv is *outgoing* (spawning a child). **CORRECTED 2026-08-22: it CAN, today, with zero new crossings** — via `/proc/self/cmdline` over the existing `open-rw`+`read` (proven twice: a 15-line probe exits 1/2/4 for zero/one/three args). What is missing is the *library wrapper* and a `/proc`-free substrate, not the capability. Entry points are stdin-driven by habit, not necessity (`B1 < blob`, `wield-main` reads a path on stdin, `scriba` takes no file argument) |
| `lseek` · `truncate` · `symlink` · `chmod` | GAP | `open-create`'s O_TRUNC covers the one truncate case in use |
| Threads | DELIBERATE | serial mutation is the mux/linearity model |
| Timers / async / event loop | GAP→cataloged | **E42** supervisor (designed, unbuilt) + scriba `S28`/`S29` |

## §6 · Encoding & formats

| Primitive | State | Note |
|---|---|---|
| JSON (parse + emit) | HAVE | `json.chiral`, 361 L |
| UTF-8 | HAVE | `TUI/vt-core/utf8.chiral` |
| Binary pack/unpack u16/u32 | HAVE | prelude + `bytes-tal.chiral` (`bget-u16-le`, `bput-u32-le`, …) |
| ELF · Wayland wire · VT/ANSI · APC | HAVE | `elf.chiral`, `wire.chiral`, `vt-parser.chiral`, `apc.chiral` |
| `bput-u16-le` | GAP | reader exists, writer doesn't — `PRIMITIVE-AUDIT` WANT |
| base64 · hex | GAP | — |
| CSV · YAML · TOML · XML | GAP | no consumer |
| gzip / compression | GAP | — |

## §7 · Crypto, hashing, randomness

| Primitive | State | Note |
|---|---|---|
| Capability custody primitive | HAVE | `secret.chiral` (E40) — **custody, not crypto** |
| **Hash function** (SHA-256/512, SHA-3) | **ALREADY SLOTTED — E116** | Not built, but **not an uncataloged gap**: the reserved `CRY` category (`LEDGER.md` E114+) already slots it, with the width coupling called out (SHA-256 is 32-bit → a hard `NUM` consumer). Blocks hash maps and content addressing until then |
| Random / entropy | **ALREADY SLOTTED — E114** | `getrandom` crossing, `CRY` tier 1, not built |
| Bit rotations (`rotl`/`rotr`, `bnot`) | **ALREADY SLOTTED — E115** | the crypto bit-floor; extends E96/E108 |
| HMAC/HKDF · AEAD · curve25519 | **ALREADY SLOTTED — E117/E118/E119** | the `CRY` ladder, in dependency order |
| TLS | GAP | `http.chiral` is plaintext-only by design today (E129: "zero TLS") |

> **Checked before claiming.** An earlier draft of this table called hashing and
> randomness uncataloged gaps. They are not — `LEDGER.md §CRY` reserved E114–E119 for
> exactly this ladder. Naming an already-refracted thing as missing is the cardinal
> working error here.

## §8 · Network & time (higher tier)

| Primitive | State | Note |
|---|---|---|
| HTTP/1.1 client | HAVE | `http.chiral` (E130 = native transport swap, design) |
| DNS resolution | GAP | E129 defers; dotted-quad only |
| TLS | GAP | — |
| HTTP server / websockets | GAP | `sock-listen`/`sock-accept` exist as the floor |
| Monotonic time | HAVE | `time-mono` |
| Calendar date/time type · formatting · parsing · timezones | GAP | a raw counter is all there is |

## §9 · Tooling

| Primitive | State | Note |
|---|---|---|
| Test runner (native, no shell/python) | HAVE | `test-runner.chiral`, `harness.chiral` |
| Reference interpreter over the pure fragment | HAVE | `interp.chiral` (E15) |
| Pretty-printer | HAVE | `pretty.chiral` |
| Logging framework | GAP | E139 `be-log` noted optional |
| Argument parser | GAP | blocked on E150 anyway |
| Benchmarking harness | GAP | perf campaign closed with ad-hoc timing |

---

## §10 · The pattern behind the gaps

Not "chirality is missing 40 things." The shape is narrower and more specific:

1. **The floor is deliberately tiny (32 externs) and the tower is honest** — every OS
   capability that was needed got built as a real, typed, linear crossing. The
   *systems* surface is unusually complete for a language this young: ptys, sockets,
   fd-passing, mmap, poll, fork/exec are all there and PTY-proven.
2. **The gaps cluster in the "boring middle"** — sort, string ordering, case
   conversion, hashing, floats, argv. Nothing hard; nothing built, because the
   compiler and the orchestration engine never quite needed them.
3. **The tell is helpers homed in the wrong module.** `str-cmp` exists **4 times** in
   4 compiler modules; `str-lower` lives in the chatter's router; `str-trim` lives in
   the Flow engine. Each was written where it was first needed because there was no
   stdlib shelf to put it on. That duplication is the measurable symptom, and E151 is
   the fix.
4. **Floats are the one genuine language-level hole** (E153). Everything else is a
   library. A float tower touches the type system, the literal syntax, the TAL, and
   codegen — and it collides with the numeric-width decision, so it needs a design
   pass, not an afternoon.

## §11 · Minted from this pass

| E# | What | Consumer that justifies the mint |
|----|------|-------------------------------|
| **E148** | `getdents64` + `stat` — directory read | scriba `S24` (flook); retires the setups `index.json` + test-runner manifest |
| **E149** | `unlink` + `rename` + `mkdir` — fs mutation (write authority, split from read) | scriba `S24` delete/rename; an absolute setups dir (`SCRIBA-STATE.md` P4) |
| **E150** | Own `argv` | `scriba <file>`, `bin/chirality` as a real CLI, every future entry point |
| **E151** | Give string comparison an owner: canonical `str-cmp → Ord`, `str-lower`/`str-upper`, `str-trim`, `str-replace` | retires 4 duplicate `str-cmp` defs + 2 app-homed text helpers |
| **E152** | Polymorphic sort (comparator-passed merge sort on `List`) | catalog/flook/completion listings; the only sort today is private to `row-infer` |
| **E153** | `F64` float tower — type, literals, arithmetic externs, `i64↔f64` | any measurement, rate, ratio, or probability; gated on the `NumProfile` decision |

Not minted, and correctly so: hashing/entropy/AEAD (**already slotted E114–E119** in
`CRY`), TLS/DNS, base64, dates, arrays, hash maps, `abs`/math. Everything else above is
**GAP, not minted** — deliberately. Minting an element with
no consumer creates the opposite phantom: a catalog row nobody will ever pull. Mint on
first real need.
