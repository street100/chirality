---
element: E150
slug: argv
title: Own `argv` — a chirality program reads the command line it was invoked with, as a pure library over a slurp-the-packet acquisition (entry-stack data, not an `Args` cap)
kind: BUILD-PROPER
example: examples/E150-argv.md
status: specced
updated: 2026-08-22
---

# E150 SPEC — Own `argv`

> **⚑ SPEC-LEVEL AUDIT 2026-08-22 — VERDICT: BLOCKED. Do not start Phase A.**
> One blocking author call: **§3 decision 2 is REOPENED** — `lib/argv.chiral` is
> the first *library* to declare `openat`/`close` locally, and a duplicate
> extern name is a hard `load: extern redeclared` (measured against
> `term.chiral:137`, which is in `scriba`'s graph — this element's own stated
> first consumer). Two things the audit **settled** instead of parking:
> **decision 7 is discharged** (the B0 probe was run: a `ti-call` does reach an
> `x-fin` `a-label`; exit 77, with a negative control), and **decision 8 is
> confirmed empirically**. Vectors 1–5 were executed against real mutants and
> all discriminate; vector 6 was **not constructible** and is restated.
> The frontmatter `status:` field and the `examples/INDEX.md` row were flipped
> to `audited` **before** this audit ran; they are stale-forward and must go
> back to `specced` — this audit did **not** mark.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

> **Scope, corrected and carried forward.** The *capability* already exists: a
> chirality program reads its own command line today with **zero new crossings**
> (`examples/E150-argv.md` §5 compiles under the committed `B1` and runs). E150
> is therefore not "add argv". It is **(A)** the missing library — a bounded
> acquisition plus a *pure* `pkt->argv` mirroring `proc.chiral:51`'s outgoing
> `argv->pkt` — and **(B)** the `/proc`-free entry-stack substrate. Both phases
> are in this SPEC; the element closes only when both land (see §3 decision 1).

## 1. Deliverable

- **After this runs (Phase A — buildable today):** `scaffold/lib/argv.chiral`
  exists and any chirality program can name its own arguments as a `(List Str)`:
  a boundary sum `ArgvR` (`argv-ok` / `argv-trunc` / `argv-err`), a **pure**
  `pkt->argv : (-> Bytes (List Str))`, and `argv-raw : (=> Unit ArgvR)` that
  slurps `/proc/self/cmdline` **to EOF** over the `openat`/`read`/`close`
  crossings that are already wired — plus a `scaffold/samples/argv_echo.chiral`
  driver and `scaffold/tests/test_argv.py` pinning the behaviour.
- **After this runs (Phase B — gated, not buildable today):** the same
  `argv-raw` surface is served by the psABI entry stub materializing the packet
  from `%rsp` into an arena `Bytes` cell, so a target with no `/proc` (rung-2)
  gets argv unchanged. `pkt->argv` and every caller are untouched by the swap —
  that invariance is the point of the two-part shape.
- **Non-goals** (residue with homes in §6): argument *parsing* (flags,
  `--k=v`, subcommands); `envp`; `auxv`; an `Args` porttype cap (declined on the
  record, §3 decision 6); promoting `openat`/`close` into `ports.chiral` — **no longer a non-goal; §3 decision 2 is REOPENED and blocking**;
  rewiring `B1`, `wield-main`, `bin/scriba` or `bin/chirality` to *use* argv — this
  SPEC ships the library those rewires need, not the rewires.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** **none — E150 postdates the map snapshot**; the
  bundle prints `(none … treat as BUILD)`. `docs/elements/ledger.md:190` carries it
  as module `sys-argv`, state `design`. So there is no map row to satisfy; the
  gate in §5 is this SPEC's own.

- **Live code this composes with — already built, do NOT respec:**
  - **The `openat` crossing is complete in all four places.** Wrapper row
    `crossing-wraps.chiral:20` (`"openat" -> "nb-sys-openat"`); syscall number
    `target-linux.chiral:37` (`nb-sys-openat` = 257); hand-tal TIFn
    `sys-tal.chiral:30` (`nb-sys-openat-t`), documented at `:27` as
    `openat(AT_FDCWD=-100, path, O_RDONLY=0, mode=0)`; registered in the
    linkage list at `sys-tal.chiral:1343`. `read` (`crossing-wraps.chiral:19`)
    and `close` (`:21`) likewise.
  - **`ports.chiral:140`** `(extern read (=> I64 I64 Bytes))` — read(fd,count)
    -> the bytes actually read; **`:141`** `write-fd`. `close` and `openat` are
    *not* in `ports.chiral`; they are declared at the use site (§3 decision 2).
  - **An extern name may be declared exactly once per blob.** Measured at audit:
    a second `(extern read …)` beside `ports.chiral:140` makes `B1` refuse the
    blob — `load: extern redeclared: read`, zero-byte output; the same for a
    duplicate `openat`. So `read`/`write-fd` **must** come from `(import
    "ports")`, never a local declaration — which is exactly what the cited
    `resolve.chiral` does (`:19` imports `ports` *for* `read`; only `openat`
    `:24` and `close` `:25` are local). `close` and `openat` are the open
    question, not `read` (§3 decision 2, REOPENED).
  - **`term.chiral:137`** `(extern close (=> I64 Unit))` — a **library** (not a
    root) that declares `close` locally, and it is in `scriba`'s import graph.
    Measured: `term`'s blob + one more local `(extern close …)` ⇒
    `load: extern redeclared: close`; the identical blob without the duplicate
    compiles to a 442744-byte ELF. `resolve.chiral:25` and
    `samples/e106_drain_control.chiral:19` declare `close` too, as `(=> I64 Unit)`
    — a *different* type from the example's `(=> I64 I64)`.
  - **`proc.chiral:51-62`** `argv->pkt` — the outgoing mirror this inverts, and
    the source of the "validate/marshal before the membrane" shape.
  - **`http.chiral:391-410`** `recv-all` — the read-to-EOF accumulator with a
    `MAX-BODY` ceiling and **failure as a value**; the loop in Step A2 copies it.
  - **`compile-emit.chiral:59-125`** `entry-stub-v2` and **`:137`**
    `(def entry-stub-len I64 224)` — the psABI entry (E34, ledger state
    `built`, `docs/elements/ledger.md:196`). Verified by reading it: it never saves
    `%rsp`, so at the `call <entry>` (`:104-106`) `%rsp` still points at `argc`
    and chirality code never sees it.
  - **`mach-x64.chiral:537-575`** `x-fin` — the `a-label`s `arena-grow`,
    `heapptr`, `heapbase`, `heapend`, `heapreserve` emitted after the code.
  - **`asm-reloc.chiral:76-81`** — one flat label namespace; an unknown label is
    an assembler `halt`, not a guess.
  - **`tal-ir.chiral:20-46`** — the complete instruction set: `ti-const`,
    `ti-prim`, `ti-con`, `ti-cona`, `ti-call`, `ti-lit`, `ti-bnew`, `ti-bget`,
    `ti-bput`, `ti-blen`, `ti-sys`, `ti-bptr`, plus `t-seq` / `ti-ret` /
    `ti-tcase`. Re-read and confirmed: **no load-from-a-computed-address op.**
  - **`sys-check.chiral:21-40`** — E76 default-deny-by-absence, keyed on
    `ti-sys` name↔number.
  - **`surface.py:781, 825-830`** — the `(ports …)` frozen set is checked over
    **extern names** (`used_ports(sig)`; `ext not in prof["ports"]`).
  - **No `list-rev` in `prelude.chiral`** (grepped). The canonical reverse is
    `collections.chiral:21-29` (`rev-onto` / `reverse`), but it is **polymorphic
    and does not lower**: that file's own header says *"higher-order and
    polymorphic, so none of it lowers to tal yet"* (`collections.chiral:4-5`).
    So `argv.chiral` carries its own monomorphic accumulator-reverse as a
    **justified** duplicate, not an unnoticed one — named here so no reviewer
    "dedupes" it into a call that cannot lower.

- **True delta:**
  - **Phase A: one new library file, plus a sample and a test — PLUS whatever
    §3 decision 2 (REOPENED) rules for `openat`/`close`.** No new
    `crossing-wraps` row, no `target-linux` row, no `sys-tal` TIFn, no compiler
    change; those parts are established by construction (the example's §5 was
    compiled by the *committed* `B1` with `scaffold/` untouched, reproduced at
    audit: `./argv.elf alpha "beta gamma"` → `./argv.elf\nalpha\nbeta gamma\n`,
    exit 3).
    **But "zero edits anywhere else under `scaffold/lib`" is NOT established and
    is false as the change plan stands.** The example's §5 is a *standalone*
    blob over `prelude` alone; `lib/argv.chiral` is a library that must compose
    with `ports` (for `read`) and, through `scriba`, with `term` (which owns a
    local `close`). Measured at audit — see the two new baseline rows above and
    decision 2.
  - **Phase B:** `compile-emit.chiral` (`entry-stub-v2`, `entry-stub-len`),
    `mach-x64.chiral` (`x-fin`), `crossing-wraps.chiral`, `ports.chiral`, and
    `scaffold/chirality/native.py` `_entry_stub` (:778) in byte-for-byte lockstep.
    `target-linux.chiral` is **not** touched — see the Phase B note in §4.
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Which substrate ships first — (a) procfs, (b) entry stack, (c) a new tal load op? | **RESOLVED → (a) now as Phase A; (b) as Phase B of THIS element; (c) rejected** | (c) is rejected on the record already: it widens the op set that `sys-check.chiral:21-40` exists to keep closed, for a purely stylistic saving over (b) (example §5 "Knobs"). Between (a) and (b): (a) is a one-file change that compiles under the committed `B1` **today** and unblocks `scriba <file>` immediately; (b) is the only route that survives a target with no `/proc`. Shipping (a) alone and calling E150 closed is exactly what the example forbade (§6 Q1), and per the repo deferral rule a follow-on must be minted before it can be deferred to — so **(b) stays inside E150 as Phase B** rather than becoming a phantom dep on an unminted element. If the author later wants B split out, minting its catalog + ledger row is the split's first commit. |
| 2 | `openat`/`close`'s home — promote to `ports.chiral`, or declare locally in `lib/argv.chiral`? | **⚑ REOPENED AT AUDIT (2026-08-22) → NEEDS-AUTHOR. Blocks Step A2.** The prior disposition (*"RESOLVED → declare locally"*) rested on a premise measurement refutes. | **What the prior rationale said:** `resolve.chiral:19` imports `"ports"` **and** `:24` declares `openat` locally — the two coexist in shipped code; three more sites do the same (`self-wield.chiral:13`, `test-runner.chiral:13`, `samples/e106_drain_control.chiral:18`); promotion would touch four files to remove a duplication this element did not create. **What is actually true.** (i) The site list is **incomplete**: it omits `resolve.chiral:25` and, decisively, **`term.chiral:137`** `(extern close (=> I64 Unit))`. (ii) All four cited precedents are **roots** — drivers/samples that no module imports, so their duplicate declarations can never meet in one blob. `lib/argv.chiral` is a **library**: it is imported by many programs, so it meets every one of them. (iii) A duplicate extern name is a **hard load error**, measured at audit: `term`'s own blob + one more `(extern close …)` ⇒ `load: extern redeclared: close`, zero-byte output; the same blob without the duplicate compiles to a 442744-byte ELF. `term.chiral` is in **`scriba`'s** import graph — and `scriba <file>` is this element's *stated first consumer* (§6). So a locally-declared `close` in `lib/argv.chiral` makes the library uncomposable with the very program it exists to unblock. `read` is not in question — it must come from `(import "ports")` (`ports.chiral:140`; a local copy gives `load: extern redeclared: read`). **The question for the author, in full, is in the audit report.** Whatever is chosen, §2's "zero edits anywhere else under `scaffold/lib`" and the Phase A "Done when" both change. |
| 2b | **Correction to the ledger row** — use `open-rw`, or `openat`? | **RESOLVED → `openat` (O_RDONLY). `open-rw` is wrong.** | `docs/elements/ledger.md:190` says the route is `open-rw`+`read`. Measured: `/proc/self/cmdline` is mode `-r--r--r--`, and `open-rw` is `openat O_RDWR\|O_NOCTTY` (`ports.chiral:208`). Probed on this kernel **under a genuinely dropped uid** (`setuid(65534)`, re-confirmed at audit — this sandbox runs as uid 0, so a root-only probe proves nothing): `O_RDONLY` → OK, `O_RDWR` → **`EACCES (13)`**, `O_RDWR\|O_NOCTTY` → `EACCES (13)`; as root both succeed, via `CAP_DAC_OVERRIDE`. `nb-sys-openat` is hardcoded `O_RDONLY` (`sys-tal.chiral:27-37` — the flags immediate is the `(ti-const 3 0)` at `:34`) and is the correct crossing. The example's §5 already uses it; the **ledger row is the thing that is wrong** and is doc-tier work, not this element's. |
| 3 | Does `argv-raw` get its own `(ports …)` profile entry, or ride `openat`'s? | **RESOLVED → Phase A: no entry of its own; Phase B: its own** | `surface.py:781` `used_ports(sig)` and `:825-830` check the frozen set over **extern names**. Under (a) `argv-raw` is an ordinary `(=> Unit ArgvR)` **def**, not an extern — it is invisible to the profile check and rides the `openat`/`read`/`close` entries, which is correct: withhold `openat` and argv goes with it. Under (b) it becomes an extern and therefore acquires its own entry, and a profile can then grant argv **without** granting the filesystem — a strict improvement, and a second reason Phase B is not optional. |
| 4 | The 4096 read cap — fixed buffer or read loop? Linux's `MAX_ARG_STRLEN` / total limit? | **RESOLVED → read loop to EOF with a `MAX-CMDLINE` ceiling and an `argv-trunc` arm** | The example flagged this unchecked; measured on this kernel (Linux 6.12.91, x86-64): a single `read(fd, 4096)` on a 120038-byte `/proc/<pid>/cmdline` returns exactly 4096 bytes — **no error, no short-read signal, silent truncation**; the full packet needed 30 chunks. `st_size` on the procfs file is **0**, so there is nothing to stat and the length cannot be pre-sized. `getconf ARG_MAX` = **2097152** (= `RLIMIT_STACK` 8 MiB / 4, so it is *not* a constant across hosts); `MAX_ARG_STRLEN` = 32 × PAGE_SIZE = **131072** — a 131073-byte single argument is rejected at `execve` with **`E2BIG (7)`**. Conclusion: loop until a zero-length read, ceiling at `MAX-CMDLINE` = 2097152 (the measured `ARG_MAX`, generous rather than exact since it is rlimit-derived), and keep the overflow as a **value** (`argv-trunc`), never a silent slice — the `recv-all`/`MAX-BODY` shape (`http.chiral:398-410`). Retaining the arm across the Phase A→B swap means callers do not change when the substrate does. |
| 5 | Is `/proc` mounted in the rung-2 microVM? | **DEFERRED → the rung-2 arc (`.planning/RUNG2-MICROVM-MAP.md`)** | Read and confirmed: the map records **no** procfs, mount, or VFS commitment. Its filesystem row (`:69`) is *"port-views over blocks — storage = virtio-blk + block-view ports, not a VFS"*, which makes a mounted `/proc` unlikely, but that is an inference and this SPEC asserts nothing. It does not need to: Phase B removes the dependence either way, and Phase A is a host-Linux-target library. The rung-2 arc owns the answer; if it turns out `/proc` **is** mounted, Phase B becomes a portability nicety rather than a requirement — it does not become wrong. |
| 6 | Cap vs entry-stack data (`Args` porttype vs a plain named crossing)? | **RESOLVED — already settled, restated only to stop re-litigation** | `docs/elements/specs/E80-cap-to-main-SPEC.md:83` decision #2: **entry-stack data** — *"`argv` is input, not authority — it carries no crossing power, so gating it would be ceremony without a violation to close. A gated `Args` cap remains available later if a use case needs read-mediation."* E80 (`docs/elements/ledger.md:228`, state `design`) owns the cap if one is ever wanted. Reopening this is a settled-decision violation. |
| 7 | **NEW — surfaced by the spec run.** Can a `ti-call` reach an `x-fin` asm label, or does Phase B need a new `TInstr` after all? | **⚑ RESOLVED AT AUDIT (2026-08-22) → YES, a `ti-call` reaches an `x-fin` `a-label`. Step B0 was RUN; it passed. No new `TInstr`, no author call, no op-set widening.** | The example claims Phase B "needs no new tal-ir op". **That is not established.** `heapptr`/`heapend` are read by *emitter-generated* RIP-relative templates (`mach-x64.chiral:481, 512, 637, 669` — `a-rel 7 e-ldheap "heapptr"`), never by any `TInstr`; and `TInstr` has no load-from-address (`tal-ir.chiral:20-34`). So a chirality-level `argv-raw` under (b) still needs the `argvpkt` cell **pointer into a tal slot**. The narrow route is an `a-label "nb-argv-cell"` routine added to `x-fin` (`mov rax,[rip+argvpkt]; ret`) reached by `ti-call`. The namespace evidence is good — the emitter calls the `x-fin` label `arena-grow` from a lowering template (`:516` calls `:539`), `arena-grow` calls the hand-tal `nb-arena-grow` (`:553`), `ti-call` emits the *same* `(a-rel 5 e-call fname)` form (`:1629, :1641`), and `asm-reloc.chiral:76-81` resolves labels over the whole `Asm` list. It was UNVERIFIED; the audit ran the probe rather than parking the question. **Result, with a negative control:** an `a-label "nb-probe"` routine (`b8 4d 00 00 00 c3` = `mov eax,77; ret`) was added to a *scratch* `x-fin`; a hand-tal `(def nb-probe-call-t TIFn (ti-fn "nb-probe-call" 0 1 (t-seq (ti-call 0 "nb-probe" nil) (ti-ret 0))))` was added to `sys-lib`; a `("probe" "nb-probe-call")` row was added to `crossing-wraps`; `B1` built the patched compiler, which compiled `(def compile-main (=> I64 I64) (lam (d) (probe 0)))` to a 323960-byte ELF that **exits 77**. **Negative control:** delete only the `a-label` and keep the `ti-call` ⇒ the assembler halts with `asm: unknown label nb-probe` (`asm-reloc.chiral:81`), exit 1, zero-byte output. So the route is real and the failure mode is loud, not silent. Note the ordering trap the probe hit: the routing table that matters is the one compiled **into the compiler** — patch `crossing-wraps`/`sys-tal` **before** rebuilding, or the extern skips with `extern does not lower`. |
| 8 | **NEW — surfaced by this run.** Under Phase B, `argv-raw` is a crossing that issues **no syscall**. Does that bypass the E76 registry? | **RESOLVED → yes, and correctly so; recorded, not hidden** | `sys-check.chiral:21-40` gates `ti-sys` immediates against `target-linux.chiral`'s `SysReg`. A Phase B `nb-argv` wrapper contains no `ti-sys` — it is a `ti-call` to a label that reads a cell the stub already filled — so it needs **no `target-linux` row** and the E76 default-deny never fires on it. That is not a hole: there is no syscall to gate. The gate that does apply is the `(ports …)` frozen set (decision 3), which under Phase B becomes *tighter* than Phase A, not looser. Flagged here so the Phase B implementer does not "fix" the missing `target-linux` row by inventing a syscall number. **Confirmed empirically at audit** by the decision-7 probe: `nb-probe-call-t` carries no `ti-sys`, has no `target-linux` row, was added to the real `sys-lib`, and `checked-sys-lib` (`ck-tiprog linux-syscalls sys-lib`) still passed — the program compiled and ran. **And E76 never claimed otherwise:** its catalog row (`docs/elements/catalog.md:244`) binds *"every `ti-sys` immediate must equal its crossing's registered number"* — it is keyed on `ti-sys`, not on "every crossing", so no false invariant is left standing. E77 (seccomp derived from the E76 set) is likewise unaffected: a crossing that issues no syscall needs no seccomp allowance. **One consequence to record, not hide:** under Phase B the entry stub materializes the argv packet into the arena for **every** program, including one whose profile withholds `argv-raw` — the gate is on *naming* the crossing, not on the bytes' presence. That is consistent with E80's settled *"argv is input, not authority"* (decision 6) and with how `heapptr` already works; a profile-conditional stub would make `entry-stub-len` profile-dependent and break `test_entry_stub_matches_native_byte_for_byte`'s single-length assumption. |

**⚑ Audit status (2026-08-22).** Decision 7 is **discharged** — the B0 probe was
run and passed, so Phase B needs no new `TInstr` and owes no author call.
Decision 8 is confirmed empirically. What blocks is **decision 2**, reopened by
measurement: it is a **blocking NEEDS-AUTHOR for Phase A**, because Step A2
cannot be written until `openat`/`close`'s home is settled, and either answer
changes §2's delta and the Phase A "Done when". Frontmatter stays `specced`
until that is answered.

## 4. Change plan (ordered, commit-sized)

**Build rule for every step: `B1` compiles it. Python compiles nothing.**
Regenerate the blob (`. bin/chirality-resolve.sh; chirality_blob scaffold/lib <roots>`
— `scaffold/build/blob.chiral` is stale), `ulimit -s unlimited`, `chmod +x` the
output. For a program with an `=>` main the linkage append order is **`tal-ir`
first**, then `crossing-wraps sys-check target-linux sys-tal sys-linkage` —
otherwise `B1` fails with `load: unknown name TInstr`. **ELF size is not a
signal** (the image is zero-padded); only behaviour is.

---

### PHASE A — buildable today, no compiler change

#### Step A1 — the pure edge
- **Target:** `scaffold/lib/argv.chiral` (new) — `ArgvR`, `list-rev`,
  `pkt-go`, `pkt->argv`
- **Change:** the boundary sum and the splitter, all `->`:
  `(data ArgvR () (argv-ok (line Bytes)) (argv-trunc (line Bytes)) (argv-err (errno I64)))`
  — three arms, per decision 4; `argv-trunc` carries what *was* read so a
  caller can still act on a prefix knowingly. `pkt-go` is the example's §5
  structural recursion on the shrinking suffix (`i` strictly increases toward
  `blen b`), accumulator reversed once by a locally-defined `list-rev`
  (prelude has none). **Emit a field for every NUL-terminated run and only
  those** — the procfs packet ends with a trailing NUL, so the loop must not
  manufacture a final empty argument after it, and must **not** skip a
  zero-length run (an empty argument `""` is a real argument). Both are pinned
  by tests in §5, not by comment.
- **Buildable now:** yes. Nothing effectful in this step; it type-checks and
  runs standalone against `prelude` alone.
- **Size:** ~S (≈45 lines)
- 2026-09-04: pre-migration scaffold/ path.

#### Step A2 — the acquisition
- **Target:** `scaffold/lib/argv.chiral` — local externs + `argv-raw`, `slurp`
- **Change:** `(import "ports")` for `read` and `write-fd` — they are
  `ports.chiral:140-141` and a second declaration is a hard `load: extern
  redeclared` (§2). `openat`/`close` come from wherever **decision 2 (REOPENED)**
  lands; do not start this step before that is answered. Then `cmdline-path` as
  NUL-terminated bytes, and:
  `argv-raw : (=> Unit ArgvR)` = `openat` → on `fd < 0` return `(argv-err (- 0 fd))`
  (negative errno in, positive out) → else `slurp fd nil-bytes` → `close`.
  `slurp : (=> I64 Bytes ArgvR)` is the `recv-all` loop
  (`http.chiral:391-410`): `read fd 4096`; **zero-length ⇒ EOF ⇒ `argv-ok acc`**;
  otherwise append and recurse while `(blen acc) < MAX-CMDLINE`
  (`(def MAX-CMDLINE I64 2097152)`), and on breaching it return
  `argv-trunc acc`. `close` is called on **every** exit path — the loop returns
  the sum to `argv-raw`, which closes and then forwards, so there is exactly
  one `close` site.
- **Buildable now:** yes — all three crossings are already wired (§2).
- **Size:** ~S (≈35 lines)
- 2026-09-04: pre-migration scaffold/ path.

#### Step A3 — the driver sample and the behavioural gate
- **Target:** `scaffold/samples/argv_echo.chiral` (new),
  `scaffold/tests/test_argv.py` (new)
- **Change:** the sample is the example's §5 spine — `compile-main` cases both
  (three) arms, `show` writes each argument and a `\n` to fd 1, exit status =
  the count. It **must `(import "ports")` alongside `(import "argv")`**: the
  example's §5 blob was `prelude`-only and therefore could not have caught the
  redeclaration class at all. A second, deliberately composition-heavy sample
  (or the same one) must also pull in `term` — the library `argv` is most likely
  to meet through `scriba`. The test compiles it with the committed `B1` (the
  `test_chirality_driver_execs_elf_no_python` shape, `test_compile_run_chirality.py:270`),
  writes the ELF `0o755`, and runs it under `subprocess` with the argument
  vectors in §5 — asserting **stdout bytes and exit status**, per case. Python
  is the harness here and compiles nothing.
- **Buildable now:** yes.
- **Size:** ~M (≈120 lines, mostly the test table)
- 2026-09-04: cut Python oracle, no live successor.

---

### PHASE B — gated on decision 7; NOT buildable today

#### Step B0 — the probe — **ALREADY RUN AT AUDIT, 2026-08-22: PASSED. Kept as the recipe, not as pending work.**
- **Target:** a scratch blob only
- **Change:** add a trivial `a-label "nb-probe"` routine to a *scratch copy* of
  `x-fin` returning a constant in `rax`, and a hand-tal TIFn whose body is
  `(ti-call 0 "nb-probe" nil)` / `(ti-ret 0)`; compile with `B1` and run.
  **This answers decision 7 empirically before any lockstep work begins.**
- **Gate:** the ELF exits with the constant ⇒ decision 7 discharged, Phase B
  proceeds as planned. The assembler halts with `asm: unknown label` or the
  loader rejects the callee ⇒ **stop and escalate decision 7 to the author**;
  do not invent a `TInstr`. **Outcome: exit 77 (the chosen constant), with the
  negative control halting at `asm: unknown label nb-probe`.** Full recipe and
  the ordering trap are in decision 7.
- **Buildable now:** yes — and built. Its outcome is no longer unknown.
- **Size:** ~S

#### Step B1 — the stub materializes the packet
- **Target:** `lib/lowering/compile-emit.chiral` — `entry-stub-v2`,
  `entry-stub-len`; `lib/lowering/x64/mach.chiral` — `x-fin`
- **Change:** insert the argv walk **after** the `mprotect` succeeds (the arena
  must be live) and **before** the `xor edi,edi` / `call <entry>`: read
  `argc` at `[rsp]`, walk `argv[i]` at `[rsp+8+8i]` following **each pointer
  individually** — the gABI states argument strings, environment strings and
  auxv *"appear in no specific order within the information block"*, so the
  strings are **not** safely contiguous and must not be sliced as one blob —
  `strlen`-copy each into a bump-allocated `[len][payload]` cell, NUL-framing
  them into exactly `argv->pkt`'s shape, bump `heapptr`, and store the cell
  pointer into a fifth `x-fin` absolute cell `argvpkt` beside `heapptr`
  (`mach-x64.chiral:561-575`), plus the `nb-argv-cell` reader label from B0.
  Then **recompute all four displacements**, which is the whole difficulty:
  with `N` bytes inserted before the `call`, `entry-stub-len` becomes `224 + N`,
  the rel32 literal `(- entry-off 158)` becomes `(- entry-off (+ 158 N))`
  (net rel32 **unchanged** — both sides shift by `N` because `entry-off` is
  computed as `(+ entry-stub-len entry-code-off)`), and the two failure jumps
  `jmp +120` (`0xeb 0x78`) and `jmp +68` (`0xeb 0x44`) each grow by `N` because
  they jump *forward across* the insertion into the fail tail. The
  `lea rsi,[rip+19]` is **not** affected — it measures lea→msg, both inside the
  fail tail, entirely after the insertion point.
- **Gate:** see §5 — the behavioural argv gate must still pass, *and* every
  existing ELF-producing test must still pass, since a wrong displacement
  breaks every compiled program, not just argv.
- **Buildable now:** **no** — gated on B0.
- **Size:** ~L

#### Step B2 — the `native.py` lockstep
- **Target:** `scaffold/chirality/native.py` `_entry_stub` (:778) and its
  `_ENTRY_STUB_LEN`
- **Change:** mirror B1's bytes exactly. `native.py` is the **oracle floor**,
  not a compiler — this edit does not violate the build rule.
- **Gate:** `test_entry_stub_matches_native_byte_for_byte`
  (`test_compile_run_chirality.py:233`) must go green **without being edited**.
  Editing that test to accommodate a drift is the failure this step exists to
  prevent.
- **Buildable now:** no — must land in the *same commit* as B1.
- **Size:** ~M
- 2026-09-04: cut Python oracle, no live successor.

#### Step B3 — swap the substrate under the unchanged surface
- **Target:** `lib/ports/process.port` (the process registry, `:13-18`, with
  `ArgvR` declared before it — the loaders are single-pass);
  `lib/lowering/tal/crossing-wraps.chiral`; a new `argv` module whose home is
  unassigned. 2026-09-04: `scaffold/` was cut in the 2026-08-31 migration and
  the port floor split into nine `.port` registries, so the one-file
  `ports.chiral` target this step named no longer exists.
- **Change:** `(extern argv-raw (=> Unit ArgvR))` in `ports.chiral`; a
  `("argv-raw" "nb-argv")` row in `crossing-wraps.chiral`; `nb-argv` in
  `sys-tal.chiral` as a `ti-sys`-free TIFn that `ti-call`s `nb-argv-cell`.
  **No `target-linux.chiral` row** — decision 8. `lib/argv.chiral` then drops its
  local `openat`/`read`/`close`/`slurp` and imports `argv-raw` from `ports`;
  `pkt->argv`, `ArgvR`, and every caller are **byte-for-byte unchanged**. Any
  profile using argv gains an `argv-raw` entry in its `(ports …)` set.
- **Gate:** the §5 behavioural gate passes **unchanged**, on a binary run with
  `/proc` unmounted or made unreadable — the substrate swap is invisible above
  the seam. That invariance is Phase B's real deliverable.
- **Buildable now:** no.
- **Size:** ~M

## 5. Conformance gate

**Standing lesson this gate is built against: a fixpoint check is not a
correctness check.** A reversed-but-total comparator once passed the fixpoint,
the 42-test, *and* a cross-compiler differential; only a behavioural sample
caught it. Every gate below is behavioural, order-sensitive, and would fail if
the change were wrong. `test_entry_stub_matches_native_byte_for_byte` is
retained in Phase B **not** as a correctness check but as a drift alarm.

**Vectors 1–5 were executed at audit against real mutants, not reasoned about.**
The reference §5 program was compiled by the committed `B1` and three wrong
implementations were compiled beside it. Measured: **V2** vs a splitter missing
its final `list-rev` → `beta gamma\nalpha\n./m2.elf\n`, **exit still 3** — the
count and the length are unchanged and only the bytes differ, which is exactly
why this gate must assert **stdout bytes**, not just status; **V3** vs a
splitter that skips zero-length runs → the empty line vanishes and the status
drops to 2; **V4** vs a splitter that emits the tail run at EOF → a phantom
seventh argument, exit 7; **V5** vs the example's single `read fd 4096` → 11
bytes of output and exit 1 instead of the full echo. Every named wrong
implementation is caught by the vector that claims it.

- **Golden behaviour (Phase A and, unchanged, Phase B).** Compile
  `samples/argv_echo.chiral` with the committed `B1` to `./argv-echo`, then for
  each vector assert exact stdout bytes **and** exit status:

  | # | invocation | stdout | exit | what a wrong implementation this catches |
  |---|-----------|--------|------|------------------------------------------|
  | 1 | `./argv-echo` | `./argv-echo\n` | 1 | argv[0] dropped; empty-list crash |
  | 2 | `./argv-echo alpha "beta gamma"` | `./argv-echo\nalpha\nbeta gamma\n` | 3 | **ordering** — a missing final `list-rev` yields `beta gamma\nalpha\n./argv-echo\n`, same length, same count, different bytes. This is the reversed-comparator case, made visible. Also: an argument containing a space stays **one** argument |
  | 3 | `./argv-echo "" x` | `./argv-echo\n\nx\n` | 3 | a splitter that skips zero-length runs (`start == i`) drops the empty argument and reports 2 |
  | 4 | `./argv-echo a b c d e` | `…\na\nb\nc\nd\ne\n` | 6 | the trailing NUL manufacturing a phantom 7th empty argument — off-by-one at the packet tail |
  | 5 | `./argv-echo <100000-byte arg>` | the argument echoed **in full** | 2 | **the truncation bug** — a single `read fd 4096` returns exactly 4096 bytes with no error (measured); this vector fails loudly on the fixed-buffer version and passes only with the Step A2 loop |
  | 6 | ~~argv total forced past `MAX-CMDLINE`~~ — **not constructible; restated below** | — | — | — |

  **Vector 6, corrected at audit.** `MAX-CMDLINE` = `ARG_MAX` = 2097152, and
  `execve` refuses any argv+envp past that: measured on this kernel, ~2.0 MB of
  argv runs, ~2.1 MB fails with **`E2BIG (7)`**. So a process's *own*
  `/proc/self/cmdline` can never reach the ceiling, and the `argv-trunc` arm
  cannot be provoked by any invocation — a test written as "force argv past
  `MAX-CMDLINE`" would never run, and the SPEC would carry a gate that passes
  because it is vacuous. Keep the ceiling and keep the arm: on procfs it is a
  **divergence guard** against an unbounded pseudo-file (a foreign `/proc`, a
  bind-mounted fifo), precisely `MAX-BODY`'s role in `recv-all`
  (`http.chiral:395-398` calls it out for "a hostile peer that never FINs").
  Test it at the `slurp` level instead: point `cmdline-path` at an ordinary file
  larger than a lowered `MAX-CMDLINE` in a test build and require `argv-trunc`
  carrying the prefix — truncation as a **value**, never a silent slice. Record
  in `argv.chiral` that the arm is unreachable for a real self-cmdline on Linux,
  so nobody deletes it as dead code.

- **Differential on the pure half, no process required.** `pkt->argv` is `->`,
  so feed synthetic packets — `""`, `"a\0"`, `"a\0\0b\0"`, one with a
  non-terminal NUL run, one 1 MiB — to the native ELF **and** the reference
  interpreter floor and require identical `(List Str)`, in the
  `test_chirality_elf_and_native_jit_agree` shape
  (`test_compile_run_chirality.py:258`). This differentially compares the native
  x86-64 floor against the chirality reference evaluator; it does **not** substitute
  for the vectors above (both floors would agree on a reversed splitter — which
  is precisely why vector 2 exists).

- **Phase B additional gate — the substrate swap must be invisible.** Run the
  **same** six vectors against a Phase-B binary in a mount namespace with no
  `/proc` (`unshare -m` + `umount /proc`, or a chroot without it). Identical
  bytes, identical statuses. Separately, the Phase A binary must **fail** that
  same run — if it does not, the test is not actually exercising the absence of
  procfs and the gate is worthless.

- **Phase B regression gate.** The full suite, unedited. A wrong stub
  displacement corrupts every compiled program, so `test_e2e.py`,
  `test_compile_run_chirality.py` and `test_native.py` are the real alarm;
  `test_entry_stub_matches_native_byte_for_byte` (`:233`) must pass **without
  being modified**. The self-hosting byte-compare (`B1` re-compiling itself
  from the same blob) applies because the compiler's own sources changed — but
  it is a **stability** check, not a correctness one, and does not substitute
  for any vector above.

- **Composition gate (added at audit — the six vectors cannot catch this).**
  Every vector above runs a *standalone* sample, so all six pass on a
  `lib/argv.chiral` that no real program can import. Compile a driver whose blob
  contains `argv` **and** `ports` **and** `term`, and require `B1` to produce a
  non-empty ELF. This is the gate that fails on a duplicate extern
  (`load: extern redeclared: <name>`, zero-byte output) — the defect decision 2
  is reopened over. It must be written before Step A2 lands, not after.

- **Tests to add:** `scaffold/tests/test_argv.py` — `test_argv_zero_args`,
  `test_argv_ordering_and_spaces`, `test_argv_empty_argument`,
  `test_argv_count_no_phantom_tail`, `test_argv_long_argument_not_truncated`,
  `test_argv_slurp_over_ceiling_reports_trunc`, `test_pkt_to_argv_floors_agree`,
  `test_argv_composes_with_ports_and_term` (Phase A); `test_argv_without_procfs`
  (Phase B).
- 2026-09-04: cut Python oracle, no live successor.

- **Green line:** 709 test functions / 77 files → **≥ 717 / 78** after Phase A
  (8 new functions in 1 new file); **≥ 718** after Phase B.
  `python3 tools/ledger-lint/ledger-lint.py` clean (verified clean at audit, checks A–M).

- **Done when (Phase A):** `scaffold/lib/argv.chiral` and
  `scaffold/samples/argv_echo.chiral` compile under the committed `B1`, the
  composition gate produces a non-empty ELF, and vectors 1–5 + corrected 6 +
  the floor differential pass. *(The old clause "with no other file under
  `scaffold/lib` changed" is struck: it presumes decision 2's reopened answer.)*
- **Done when (E150 closes):** the identical six vectors pass against the Phase
  B binary with `/proc` unavailable, `test_entry_stub_matches_native_byte_for_byte`
  is green unmodified, and `lib/argv.chiral` no longer declares `openat`.

## 6. Residue & links

- **Deliberately unbuilt:**
  - **Argument parsing** (flags, `--k=v`, subcommands, usage text) — ordinary
    total chirality over the `(List Str)`; *nobody's yet*, and correctly so: it
    belongs to whichever consumer needs one, not to the element that supplies
    the list.
  - **`envp`** — the same entry-stack walk yields it and would let `Env` shed
    its `os.environ` host binding (`impl_ports.py:96-103`;
    `.planning/SYSCALL-WIRING.md:65` — *"no syscall exists — env is exec-time
    stack data"*). Home: **E32** (`clock`/`exit`/`env`, catalog `:95`) — but
    note E32's ledger state is **`built`** (`docs/elements/ledger.md:170`), so the
    row will not be picked up again on its own; what is open inside it is the
    *native* leg, recorded at `SYSCALL-WIRING.md:65`. Unlocked by Phase B's stub
    walk. Not this element — and if the author wants it tracked rather than
    inherited, minting a row is that change's first commit (deferral rule).
  - **`auxv`** — on the same stack; nothing in the tree needs it. *Nobody's yet.*
  - **An `Args` porttype cap** — declined on the record; home is **E80**
    (`docs/elements/ledger.md:228`, state `design`), which explicitly left the door
    open for read-mediation if a profile ever needs it.
  - ~~**Promoting `openat`/`close` into `ports.chiral`**~~ — **no longer
    residue: this is §3 decision 2, REOPENED and blocking.** The declaration
    sites are `self-wield.chiral:13` (`openat`), `resolve.chiral:24-25`
    (`openat`+`close`), `test-runner.chiral:13` (`openat`),
    `samples/e106_drain_control.chiral:18-19` (`openat`+`close`), and
    **`term.chiral:137`** (`close`) — six declarations across five files, not
    four, and `term.chiral` is a **library** in `scriba`'s graph. The two
    declared types for `close` disagree (`(=> I64 Unit)` in the tree,
    `(=> I64 I64)` in the example), so any promotion also unifies a type.
  - **`(List Bytes)` arguments** — `bytes->str` assumes text. A
    `pkt->argv-bytes` sibling is two lines whenever a binary argument matters.
  - **Rewiring the entry points** — `B1 < blob`, `wield-main`'s stdin path
    (`self-wield.chiral:2-3`), `bin/scriba` (verified: no `"$@"`, no `$1`),
    `bin/chirality` as a real CLI. E150 ships the library they need; each rewire is
    its own change, and `scriba <file>` is the first consumer.
  - **Doc-tier corrections owed** (not this element's, but named so they are not
    lost), **re-checked at audit**: `docs/elements/ledger.md:190` still says the
    route is `open-rw` — it is `openat` (decision 2b), and
    `docs/elements/catalog.md:415` repeats it.
    `.planning/LANGUAGE-INVENTORY.md:107` **no longer** says a chirality program
    *"cannot read its own command line"* — it was corrected 2026-08-22 and now
    carries the scope correction; what is still wrong at `:107` is the same
    `open-rw` route, not the capability claim. (The earlier wording of this
    residue item was itself stale.)

- **Follow-on:** `scriba <file>` — ***nobody's yet***: checked at audit, no
  scriba row owns it (`docs/elements/ledger.md` carries only S11, S24, S28, S29),
  so this is a named consumer, **not** a minted dep; minting a row is that
  change's first commit (deferral rule). `bin/chirality` as a real CLI — likewise
  *nobody's yet*. **E32**'s native `env` leg (via Phase B's stack walk, and see
  the build-state caveat above); **E80** if a read-mediating `Args` cap is ever
  wanted (ledger state `design`, `docs/elements/ledger.md:228`).

- **Related:** [[E150-argv]] · [[E80-cap-to-main]] (the settled decision this
  follows, and the owner of any future `Args` cap) · [[E34]] (the psABI entry
  stub Phase B extends; ledger state `built`) · [[E32]] (the `Env`/`Clock`
  split this deliberately does *not* imitate, and the home of the `envp`
  residue) · [[capability]] (`docs/banks/capability.md`) ·
  [[pattern-boundary-sums]] (`ArgvR`) · [[E76]] (`sys-check.chiral`, the
  chokepoint decision 8 explains around).
