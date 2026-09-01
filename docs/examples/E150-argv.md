---
element: E150
slug: argv
title: **Own `argv`** — a chirality program reads the command line it was invoked with (the `_start` stack layout: `argc` then `argv[]` then `envp[]`), surfaced as a pure `argv` library over a slurp-the-packet crossing. **Not** an `Args` cap — `E80-cap-to-main-SPEC.md` decision #2 settled that (*argv is input, not authority*), so the cap is recorded as declined, not offered.
kind: BUILD-PROPER
reference_class: OURS/SPEC
ours_source: (none)
status: reviewed
updated: 2026-08-22
---

# E150 — Own `argv`

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
>
> **Verification note:** this pre-run deliberately exceeded the skill's
> read-limit. Every code claim below was checked against the live file, the ABI
> claim was web-verified *and* probed on the metal, and the §5 snippet was
> compiled by `B1` and executed. What is unverified is labelled unverified.

## 1. Scope

- **Element:** E150 — a chirality program reads *its own* command line. **The
  capability already exists** (scope corrected 2026-08-22,
  `docs/elements/ledger.md:190`): a chirality program can read its own command line
  **today, with zero new crossings**, via `/proc/self/cmdline` over the existing
  `openat`/`read`/`close` — §5 below is that program, compiled by the *committed*
  `B1` and run. What is missing is not the reach but the **library**: no
  `lib/argv.chiral`, no `ArgvR`, no pure `pkt->argv` (verified: those names occur
  nowhere in `scaffold/`), and no `/proc`-free substrate for targets without
  procfs. `proc.chiral`'s argv machinery is **outgoing only** (`argv->pkt`,
  `proc.chiral:51-62`, packs a *child's* argv for `proc-spawn`, `:124`) — it is
  the mirror to build against, not a substitute.
- **Kind:** BUILD-PROPER (`ledger` module `sys-argv`, state `design`;
  `docs/elements/ledger.md:190`).
- **Why it is still worth building:** every entry point in the tree is
  stdin-driven — because nobody wrote the reader, not because the read is
  impossible:
  - `B1 < blob > out` — the compiler reads its input on fd 0
    (`.planning/BUGS-AND-GAPS.md:58-59`).
  - `self-wield.chiral:2-3` — "The driver entry `wield-main` reads a file PATH on
    stdin".
  - `bin/scriba` — verified: **no `"$@"` and no `$1` anywhere in the script**;
    the file to edit cannot be named on the command line.
  So `scriba <file>` and `bin/chirality` as a real CLI are blocked on a *library*,
  and every argument parser written in chirality needs a `(List Str)` to parse.
  **Note the stale doc:** `.planning/LANGUAGE-INVENTORY.md:107` still says a
  chirality program "**cannot read its own command line**" — that row is wrong and
  is doc-tier work, not this element's.

## 2. Research

**Reference class:** `SPEC` (System V AMD64 psABI, process initialization) +
`OURS` (`proc.chiral`'s outgoing packer, `ports.chiral`'s `Env` split, the
entry stub in `compile-emit.chiral`). No `OURS` Python baseline exists — this is
design-from-spec.

**Finding 1 — the init-stack layout (web-verified AND probed).**
The psABI's *Initial Stack and Register State* gives, from `%rsp` upward:
`argc` (1 eightbyte) · `argv` pointers (`argc` eightbytes) · a NULL eightbyte ·
`envp` pointers · a NULL · the auxiliary vector (2 eightbytes per entry) · a
NULL entry · then the **information block** holding the actual strings. It
states verbatim: *"The stack pointer holds the address of the byte with lowest
address which is part of the stack. It is guaranteed to be 16-byte aligned at
process entry."* Only `%rbp`, `%rsp` and `%rdx` have specified contents at
entry (`%rdx` = an `atexit`-registerable function pointer).

I probed this on the actual sandbox kernel (Linux 6.12.91, x86-64) with a
freestanding `as`/`ld` `_start` — no libc — and it matched exactly:
`[%rsp]` = 3 for two arguments; `[%rsp+8+8i]` → `./st`, `alpha`, `beta`;
`[%rsp+8+8*argc]` = NULL; `[%rsp+16+8*argc]` → `SHELL=/bin/bash`;
`%rsp & 15` = 0 for 0, 1 and 2 arguments.

The gABI adds a caution that matters for implementation: *"Argument strings,
environment strings, and the auxiliary information appear in no specific order
within the information block; the system makes no guarantees about their
relative arrangement."* So the strings are **not** safely contiguous — a reader
must follow each pointer, it cannot slice one blob out of the block.

**Finding 2 — `Env` is *not* a syscall, and its native leg does not exist.**
`ports.chiral:170-176` is a linear, opaque, keyed read-only view:
`env-view (=> (1 e Env) Str EnvR)`, plus INTERIM ambient `env-open (=> Unit Env)`
/ `env-close (=> (1 e Env) Unit)`, with `EnvR` threading the cap back (the
`RecvR` pattern). But its *data source* is host Python:
`scaffold/chirality/impl_ports.py:98` is `os.environ.get(name)`.
`.planning/SYSCALL-WIRING.md:65` says it plainly — *"no syscall exists — env is
exec-time stack data; the native envp walk is gated on **E34**'s psABI entry
stub"* — and none of `env-open`/`env-view`/`env-close` appears in
`crossing-wraps.chiral` (verified by reading the whole table). So **there is no
existing envp-walking machinery for E150 to compose over.** The Env porttype is
a shape precedent, not a substrate precedent.

**Finding 3 — the entry stub is already the psABI entry, and it discards `%rsp`.**
`compile-emit.chiral:59-125` is `entry-stub-v2`, 224 bytes (`:137`), and `e_entry` points
at it (`elf.chiral:48`). At its first instruction `%rsp` *is* the pointer to
`argc`. The stub mmaps a 64 GiB PROT_NONE reservation, mprotects a 256 KiB
prefix, stores four absolute arena cells (`heapptr`/`heapbase`/`heapend`/
`heapreserve` — labelled in `mach-x64.chiral:561-575` via `x-fin`), then does
`xor edi,edi` (dummy arg0) and `call <entry>`. It never saves `%rsp`, and once
chirality code runs the initial value is gone. Two hard constraints on touching it:
it "MIRRORS native.py `_entry_stub` byte-for-byte" and is gated by
`test_entry_stub_matches_native_byte_for_byte`
(`scaffold/tests/test_compile_run_chirality.py:233`), and three displacements are
hand-computed against the stub's own length (`rel32 = entry-off - 158`, the two
failure `jmp`s `+120`/`+68`, and `lea rsi,[rip+19]`).

**Finding 4 — tal-ir has no load-from-an-address op.**
The complete instruction set — `TInstr` plus `TCode`'s three control forms,
`tal-ir.chiral:19-46` — is `ti-const`, `ti-prim`,
`ti-con`, `ti-cona`, `ti-call`, `ti-lit`, `ti-bnew`, `ti-bget`, `ti-bput`,
`ti-blen`, `ti-sys`, `ti-bptr`, `ti-ret`, `ti-tcase`. `ti-bget` reads a byte of
a *chirality byte cell*; `ti-bptr` hands a cell's payload address *out* to a
syscall. **Nothing reads memory at a computed address back in.** So even with
`%rsp` saved, no hand-tal routine in `sys-tal.chiral` can walk the argv pointer
array today. This is the single fact that decides E150's implementation shape.

## 3. Conventional (other-language) approach

C hands the whole thing to the entry point, untyped and ambient:

```c
int main(int argc, char **argv) {          /* the crt0 stub did the walk */
    for (int i = 0; i < argc; i++)
        puts(argv[i]);                     /* char* — length is wherever the NUL is */
}
```

Python is the same trick one layer up — a module-level mutable global:

```python
import sys
path = sys.argv[1]                         # IndexError if absent; str, unvalidated
```

**Assumptions both bake in:**

- **Ambient authority.** `sys.argv` / `argv` is reachable from anywhere in the
  program, at any depth, with no parameter and no declaration. Nothing in either
  signature records that a function reads the command line.
- **Untyped effect.** Reading `sys.argv` is indistinguishable from pure code to
  the type system, so a "pure" helper can silently depend on the invocation.
- **Partiality as control flow.** `argv[1]` throws; `argv[i]` in C reads past
  the array if `i >= argc`. The missing-argument case is not in the type.
- **A pointer is a string.** `char **argv` is unbounded memory the callee is
  trusted to walk correctly; length lives in a NUL somewhere out there.
- **One inseparable step.** Acquiring the bytes and interpreting them are fused,
  so there is no pure half to test.

## 4. The chirality idea

### The reframing

`proc.chiral` already solved this problem — in the *outgoing* direction, and its
shape is the answer. `argv->pkt (-> (List Str) (Maybe Bytes))` (`proc.chiral:51`)
validates and marshals a child's argv into a NUL-framed byte block **before the
membrane**, so "a bad argv issues zero syscalls" (`proc.chiral:55`). E150 is
that same seam run backwards: **an acquisition step that yields the NUL-framed
block, and a pure `pkt->argv` that interprets it.** The effect row is *narrow and
bounded* — one crossing under substrate (b), three already-registered ones
(`openat`/`read`/`close`) under substrate (a), as §5 shows — and, crucially, it
stops there: everything a program actually does with its arguments — splitting,
matching, validating, refining — stays `->`, provably no crossing, testable
without a process.

### The A-vs-B question — already settled, restated here as rationale

**This is not an open fork.** `docs/elements/ledger.md:190` records it plainly:
*"A-vs-B was never open"* — `E80-cap-to-main-SPEC.md` decision #2 resolved it in
2026-08-01. What follows is the *reasoning* behind the settled call, kept because
a SPEC reader needs to know why cap-shaped uniformity was declined; it is not a
re-litigation and a SPEC must not treat it as one.

**Option A (the settled answer) — a plain named crossing** (`argv-raw`,
result-sum-returning) beside the other process externs in `ports.chiral`.
**Option B (declined) — an `Args` porttype cap** beside `Env`:
`args-open`/`args-view`/`args-close`, linear, opaque, RecvR-threaded.

**Why A, in order of weight:**

1. **The repo already resolved it, on the record.** `docs/elements/specs/
   E80-cap-to-main-SPEC.md:83`, decision #2, asks exactly this question and
   answers: **RESOLVED → entry-stack data** — *"`argv` is *input*, not
   *authority* — it carries no crossing power, so gating it would be ceremony
   without a violation to close. A gated `Args` cap remains available later if a
   use case needs read-mediation, exactly as `Env`/`env-view` sits beside raw
   env."* E80 is the element that reifies the ambient externs behind caps; this
   is that element's own scoping call, not an outside opinion. Reversing it here
   would be a settled-decision violation.

2. **P3 is satisfied by naming the port, not by making it linear.** P3 says
   *"the space of values stays infinite; the space of ports to the world is
   closed and named"* and *"you govern the membrane it must cross, not the
   interior"* (`PRINCIPLES.md:78-93`). The membrane crossing here is the read
   itself, and it is closed and named the moment it is an `=>` extern in
   `ports.chiral` with a `crossing-wraps` row — it is in the closed table, it
   default-denies by absence at the tal floor (`sys-check.chiral:21-27`), and a
   profile's `(ports …)` set can withhold it entirely. Linearity buys something
   different: it makes *possession* trackable so a cap can be handed, split, or
   revoked. Argv has nothing to hand — it is a read-once, unchanging, whole-value
   fact about how the process started. A linear `Args` cap would be a cap that is
   opened, read once, and closed, in one function, forever: the moving parts of
   the capability discipline with none of its mediation. Per P1 the test is
   whether the construct closes a hole (`PRINCIPLES.md:26-35`: "build a substrate
   that can do anything, so that everything it can do is named and therefore
   gateable") — the *name* is what closes it, and A has the name.

3. **The `Env`-uniformity argument does not survive contact with the difference.**
   `env-view` is a *keyed* view: the key is a parameter, so a cap can mediate
   *which* keys a component may see, and the cap must survive the call to be
   asked again — hence `EnvR` threading it back. Argv has no key and no second
   question. Making it a cap gives an opaque handle whose only legal use is one
   total read, which is the shape chirality calls out as abstraction that does not
   constrain behaviour. Uniformity for its own sake would buy a matching
   silhouette and no invariant.

**The honest tension, stated rather than hidden:** argv is frequently
*authority-shaped* in practice — `scriba foo.txt` is a filesystem reach chosen
by whoever invoked us. But chirality gates the `openat`, not the string; a `Str` that
has been read confers no reach, and E150 hands back `Str`s. If a future profile
genuinely needs to restrict *what a component may learn* about its invocation
(argument redaction, per-component views), the `Args` cap is the right answer
then, and E80's decision explicitly leaves that door open. Adding it now is
pre-emptive.

**But not a bare `(=> Unit (List Str))` either.** The catalog title offers that
signature; take the crossing, refuse the type. Two amendments:

- **The crossing returns a boundary sum, not a list.** The acquisition can fail
  (see §5's substrate note), and the standing directive is to parse once and
  carry the reason as a value. `ArgvR` = `argv-ok Bytes` | `argv-err I64`.
- **The crossing yields `Bytes`, and `pkt->argv` is pure.** This is the
  `argv->pkt` symmetry, and it is what keeps the effect row confined to the
  acquisition step (one crossing under (b), three under (a)).

### What chirality makes impossible here

- **No ambient read.** There is no `sys.argv` global. A function that consults
  the command line has `=>` in its type and its caller can see it — or it
  receives a `(List Str)` as a parameter and is provably pure.
- **No pointer walk in user code.** `Bytes` is `[len][payload]`; `bget` is
  bounds-defined; there is no `char*` and no reading past `argc`.
- **No missing-argument exception.** `(case xs (nil …) ((cons a r) …))` is
  coverage-checked. "No argument was given" is a branch the compiler forces you
  to write, not a runtime throw.
- **No hidden partial acquisition.** `argv-err` is a constructor; the failure
  cannot be dropped or conflated with an empty command line — exactly the
  distinction `env-none` vs `env-r ""` already makes (`impl_ports.py:97`,
  "absence is a constructor, not `""` (the env-get crutch's conflation)").
  **One honest exception in §5 as written:** the fixed `read fd 4096` can return
  a *short* packet for an over-long command line, and that truncation is not in
  `ArgvR` — a `argv-truncated` arm (or the (b) substrate, where the length is
  exact) closes it. The principle holds; the §5 skeleton does not yet.

## 5. Chirality example (fleshed)

**This compiles and runs today.** `B1` compiled it from a blob
(`chirality_blob scaffold/lib prelude` + this file), and the resulting ELF, invoked
as `./argv.elf alpha "beta gamma"`, printed its own path, `alpha`, and
`beta gamma`, and exited `3`. Nothing under `scaffold/` was modified to do it.

```chirality
; ---- the boundary sum + the ONE crossing ------------------------------------
; acquisition can fail, so the reason is a value (never a sentinel -1 Bytes).
(data ArgvR ()
  (argv-ok  (line Bytes))          ; the NUL-framed packet, exactly argv->pkt's shape
  (argv-err (errno I64)))          ; positive errno; the caller must case on it

; INTERIM substrate: procfs, over crossings that already exist and are already
; registered (read 0 target-linux.chiral:13 / close 3 :15 / openat 257 :37).
; The terminus is the entry stack; see "Knobs" below. `openat` is declared
; locally here exactly as self-wield.chiral:13 declares it.
(extern openat   (=> Bytes I64))
(extern read     (=> I64 I64 Bytes))
(extern close    (=> I64 I64))
(extern write-fd (=> I64 Bytes I64))

(def nul-byte Bytes (bslice (pack-u32 0) 0 1))   ; no pack-u8 in the pure fragment
(def nl-byte  Bytes (str->bytes "\n"))
(def cmdline-path Bytes (bcat (str->bytes "/proc/self/cmdline") nul-byte))

; the crossing: Unit -> the raw packet, or the errno as a value.
(def argv-raw (=> Unit ArgvR)
  (lam (u)
    (let (fd (openat cmdline-path))
      (case (<i fd 0)
        (true  (argv-err (- 0 fd)))          ; -errno in, +errno out
        (false (let (b (read fd 4096))       ; one read; see "Deliberately omitted"
                 (let (c (close fd))
                   (argv-ok b))))))))

; ---- the pure edge: NUL-framed packet -> the argument list -------------------
; The mirror of proc.chiral's argv->pkt (:53). `->` throughout: no crossing, so
; every argument parser built on top of this is testable without a process.
(declare pkt->argv (-> Bytes (List Str)))
(declare pkt-go    (-> Bytes I64 I64 (List Str) (List Str)))
(declare list-rev  (-> (List Str) (List Str) (List Str)))

(def list-rev
  (lam (xs acc)
    (case xs
      (nil acc)
      ((cons x r) (list-rev r (cons x acc))))))

; structural recursion on the shrinking suffix (i strictly increases toward
; blen b); the accumulator is reversed once at the end -- the lib idiom.
(def pkt-go
  (lam (b i start acc)
    (case (<i i (blen b))
      (false (list-rev acc nil))                       ; packet exhausted
      (true
        (case (=i (bget b i) 0)
          (true  (pkt-go b (+ i 1) (+ i 1)             ; NUL: close this argument
                   (cons (bytes->str (bslice b start i)) acc)))
          (false (pkt-go b (+ i 1) start acc)))))))    ; ordinary byte

(def pkt->argv (lam (b) (pkt-go b 0 0 nil)))

; ---- worked use: echo each argument, exit with the count --------------------
(declare show (=> (List Str) I64 I64))
(def show
  (lam (xs n)
    (case xs
      (nil n)
      ((cons s r)
        (let (w (write-fd 1 (bcat (str->bytes s) nl-byte)))
          (show r (+ n 1)))))))

(def compile-main (=> I64 I64)
  (lam (dummy)
    (case (argv-raw unit)                    ; both arms forced by coverage
      ((argv-err e)   (- 0 e))
      ((argv-ok line) (show (pkt->argv line) 0)))))
```

**Knobs to modify**

- **The substrate behind `argv-raw` — the one real choice left.** Three variants,
  in increasing cost and increasing honesty:
  - **(a) procfs** — what is written above. Works today, adds **zero** syscall
    rows (all four numbers are already in `target-linux.chiral`), zero tal-ir
    ops, zero entry-stub churn. Costs: it needs `/proc` mounted, which the
    rung-2 microVM "chirality is the kernel" target is *expected* not to have —
    **unverified**: `.planning/RUNG2-MICROVM-MAP.md` says nothing about procfs,
    so this is an inference from "chirality is the kernel", not a recorded decision,
    and a SPEC should settle it; and it is a file crossing, so a profile that
    withholds `openat` also withholds argv.
  - **(b) entry-stub materialization** — the terminus. `entry-stub-v2` runs with
    `%rsp` = `&argc` and with the arena already live, so it can walk the pointer
    array, copy each string (the gABI forbids assuming they are contiguous —
    §2 finding 1) into a bump-allocated `Bytes` cell, and store that cell pointer
    in a fifth absolute cell — `argvpkt`, a new `a-label` beside `heapptr` in
    `x-fin` (`mach-x64.chiral:561`). `argv-raw` then becomes a trivial read of
    that cell and `pkt->argv` is unchanged. **This is the variant I would take**:
    it needs no new tal-ir op, so it punches no new hole in the membrane — all
    the pointer chasing lives in the 224 bytes that are already category-B
    hand-assembly by construction. Its real cost is the lockstep: `native.py`'s
    `_entry_stub` must change byte-for-byte with it
    (`test_entry_stub_matches_native_byte_for_byte`), and the three hand-computed
    displacements plus `entry-stub-len` all shift.
  - **(c) a new sysface tal-ir op** (`ti-peek`, load an eightbyte at a computed
    address) plus an `nb-argv-t` hand-tal walker. Rejected: it adds a raw load to
    the op set the sysface gate exists to keep closed, for a saving over (b) that
    is mostly stylistic.
- **`ArgvR`'s arms.** Add `argv-truncated` if the 4096 cap becomes real; under
  (b) the crossing cannot fail at all and `ArgvR` can shrink to one arm — but
  keep the sum, so callers do not have to change when substrates swap.
- **`(List Str)` vs `(List Bytes)`.** `bytes->str` here assumes the arguments are
  text. A `pkt->argv-bytes` sibling is a two-line change if a binary argument
  ever matters.
- **The `Args` cap, if it is ever wanted.** Nothing above prevents it: add
  `(porttype Args)`, `(data ArgsR () (args-r (line Bytes) (1 a Args)))` and
  `args-view`, threaded exactly like `EnvR` (`ports.chiral:164-176`), and leave
  `pkt->argv` untouched — the pure edge does not care where the packet came from.

**Deliberately omitted**

- **Argument *parsing*** — flags, `--key=value`, subcommands. E150 is the read;
  a parser is ordinary total chirality over the `(List Str)` and belongs to whoever
  needs one.
- **The read loop.** One `read fd 4096` is enough for every command line the tree
  actually uses; a real implementation loops until a short read (the `recv-all`
  pattern, `http.chiral:391-410`) or uses (b), where the length is exact.
- **`envp`.** The same stack walk yields it, and it would let `Env` shed its
  `os.environ` host binding — but that is E32/E80's ground, not this element's.
- **`auxv`.** Present on the same stack; nothing in the tree needs it yet.
- **Where `openat` lives.** Verified: `ports.chiral` exposes `open-rw` (:208) and
  `open-create` (:209) but **not** plain `openat`; `self-wield.chiral:13` declares
  its own. §6 keeps this as an open question rather than inventing an answer.

## 6. Use / modify notes

**Lands in:**

- `scaffold/lib/argv.chiral` — new module: `ArgvR`, `pkt->argv`, `pkt-go`, and
  (under substrate (a)) `argv-raw` itself. Note what §5 actually shows: under
  (a) `argv-raw` is **not** an extern — it is an ordinary `(=> Unit ArgvR)` def
  composed over the `openat`/`read`/`close` crossings that already exist. Only
  the `ArgvR`/`pkt->argv`/`pkt-go` half is `->`; the module is *mixed*, not pure.
- Under substrate (a): **no other file changes at all** — no new extern, no
  `crossing-wraps` row, no `target-linux` row. `openat`/`read`/`close` already
  have theirs (`crossing-wraps.chiral:19-21`; `target-linux.chiral:13/15/37`).
  Verified by construction: §5 was compiled by the *committed* `B1` with
  `scaffold/` untouched.
- `scaffold/lib/ports.chiral` — needed **only under substrate (b)**: the
  `argv-raw` extern goes in the `; ---- process` block beside `read`/`write-fd`
  (`:135-146`), with `ArgvR` declared before it (the loaders are single-pass —
  `ports.chiral:185` states the rule).
- Under substrate (b), the four-place crossing recipe applies:
  `sys-tal.chiral` (the `nb-*` TIFn) → `target-linux.chiral` (the `sys-row`
  number) → `crossing-wraps.chiral` (the surface-name → wrapper row) →
  `ports.chiral` (the extern); plus `compile-emit.chiral` `entry-stub-v2`,
  `mach-x64.chiral` `x-fin` (the `argvpkt` cell), and `scaffold/chirality/native.py`
  `_entry_stub` in byte-for-byte lockstep.

**Conformance target (golden behaviour to reproduce):**
compile a program whose `compile-main` is the §5 spine, run it as
`./out alpha "beta gamma"`, and require stdout `./out\nalpha\nbeta gamma\n` with
exit status `3`. This exact run is the evidence behind this example
(reproduced at audit: `chirality_blob scaffold/lib prelude` + the §5 block →
`scaffold/build/B1 < blob > argv.elf` → `./argv.elf alpha "beta gamma"` printed
`./argv.elf` / `alpha` / `beta gamma` and exited `3`; with no arguments it
exited `1`).

**The check does not discriminate a compiler change under (a)** — the committed
`B1` already compiles and runs it, which is the point of the corrected scope. It
is a *library* conformance test (compile `lib/argv.chiral` + a driver, run,
compare stdout and status), not an old-vs-new compiler test. An
`e124_adopt_roundtrip.chiral`-style old-B1-fails/new-B1-runs discriminator only
becomes available under substrate (b), where an OLD `B1` has no `argv-raw`
crossing row and the entry fails to emit.

**Open questions (for the SPEC, not resolved here):**

1. **Which substrate ships first.** I recommend (a) as the landing slice and (b)
   as the same element's second commit — (a) proves the seam and unblocks
   `scriba <file>` immediately, (b) removes the procfs dependency before rung-2
   needs it. A SPEC could equally argue for going straight to (b); what it must
   not do is ship (a) and call the element closed.
2. **`openat`'s home.** It is currently a local extern in `self-wield.chiral` and
   not in `ports.chiral`. Substrate (a) needs it from library code. Promote it, or
   let `lib/argv.chiral` declare it locally as `self-wield` does?
3. **Does `argv-raw` get a `(ports …)` profile entry of its own,** or ride
   `openat`'s? Under (b) it must have its own, since it stops being a file read.
4. **The 4096 cap.** Linux's `MAX_ARG_STRLEN`/total-argv limit is well above it.
   **Unverified** — I did not check the kernel's actual limit, and a SPEC should
   before choosing between a fixed buffer and a read loop.

**Related:** [[E80-cap-to-main]] (the settled decision this follows, and the
element that would own an `Args` cap if one is ever wanted) · [[E32]] (the
`Env`/`Clock`/`Timer` split this deliberately does *not* imitate) ·
[[E34]] (the psABI entry stub substrate (b) extends) ·
[[capability]] (`docs/banks/capability.md` — the bank the A-vs-B argument sits
under) · [[pattern-boundary-sums]] (`ArgvR`).
