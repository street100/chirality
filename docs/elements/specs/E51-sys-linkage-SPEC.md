---
element: E51
slug: sys-linkage
title: **Sys-face linkage**: upper-effectful chirality reaches syscalls *through* `sys-tal`, retiring `impl_ports` as the transport (the true self-host gate — F7/C1)
kind: REPLACE-CRUTCH
example: examples/E51-sys-linkage.md
status: audited
updated: 2026-07-27
---

# E51 SPEC — **Sys-face linkage**: upper-effectful chirality reaches syscalls *through* `sys-tal`, retiring `impl_ports` as the transport (the true self-host gate — F7/C1)

> ⚑ **TRIAGE 2026-09-04 — DONE-ALREADY.** 0 of 5 steps are executable at HEAD.
> Step 2 landed as `lib/lowering/tal/sys-linkage.chiral`; Steps 1,3,4,5 name
> the cut `runtime.py`/`impl_ports.py`. Bucket and evidence:
> `records/spec-tier-triage.md`. This file was not rewritten and its `status:`
> was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** an upper-effectful extern that has a sys-linkage binding
  reaches its syscall *through* the hand-tal `sys-tal` crossing — the reference
  tal machine performs the real syscall — with **CPython out of the call path**;
  `impl_ports.py` is demoted from *the transport* to a migration-window fallback
  for still-unbound effectful externs, and the binding table + its C-bridge
  wrappers are themselves chirality data/code (`lib/sys-linkage.chiral`).
- **Non-goals (residue → §6):** the socket/poll/fd-passing/spawn/clock wrappers
  (their hand-tal is lane A, E28–E33 — this element only *wires* what exists);
  the effect-row's tal-shadow representation (E70) and the concrete row shape
  (E39); native-floor execution of the wrappers (reference machine first — the
  native crossing follows once codegen carries the sysface mark); deleting
  `impl_ports.py` outright (demoted here, deleted when lane A closes the bank);
  the loader/ELF endgame that removes the last Python shuttle (E20/E34).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** the E51 row is **REFACTOR / size L**, "seam does
  not exist; port externs resolve to Python `IMPLS`; sys-tal crossings only
  tal-machine/test-reachable," pinning the four touchpoints —
  `runtime.py` extern-binding + `IMPLS` composition + the `apply1` `pap`-branch
  dispatch re-routed through the sys-tal `talf` path + `bridge.verify` placement.
  The **Category-C port-membrane** row is **CONFORMS** ("transport swap is E51
  lane, not a reshape") — the typed face is frozen; this run must not touch decls.
  Edge 16 is **resolved** (`docs/decision-effect-facets.md`, 2026-07-21); the
  only remaining external gate is the E39 row *shape*, which this SPEC defers
  where it is load-bearing.
- **Live code (compose, do not respec):**
  - `scaffold/lib/sys-tal.chiral` — the destination crossings already exist and
    are differentially tested: `nb-sys-write/read/lseek/memfd/ftruncate/mmap/munmap`
    + `sys-lib`; each is a `TFn` the tal machine runs.
  - `scaffold/chirality/tal.py` — `TalFn.sysface` (set at check time, lines 151/156)
    is the floor confinement: the backend refuses the `sys` instruction outside a
    sysface-marked function. This mark is the confinement E51 threads a port through.
  - `scaffold/lib/ports.chiral` — the frozen typed face (`Fd`/`Sock`/`Pool n`
    porttypes; `RecvR`/`PoolR`/`AccR` per-family result sums; effectful externs).
    Linearity + frozen-port-set enforced by the checker. **Unchanged by E51.**
  - `scaffold/chirality/runtime.py` — the dispatch: extern names mint
    `("pap", name, [], prim_arity)` at `run()` **line 133**; `apply1`'s `pap`
    branch (**lines 153–165**) calls `IMPLS[name](*args)` then `bridge.verify`;
    the `talf` branch (**lines 147–152**) already dispatches to `tal_machine.call`.
    The `missing` check (**line 50**) currently hard-requires every extern in `IMPLS`.
  - `scaffold/chirality/impl_ports.py` — the crutch to demote (`IMPLS` host referents).
  - `scaffold/chirality/bridge.py` — `result_type` + `verify` (the inbound membrane,
    line 78 already admits `clo`/`pap` referents).
- **True delta = the seam, not the crossings.** New surface: (a) the
  **extern→wrapper binding table** (`sys-bindings`) + per-crossing **C-bridge
  wrappers** in `lib/sys-linkage.chiral`; (b) a sysface-only **`fd-view`** primitive
  that threads a linear port back while exposing its raw int to the wrapper;
  (c) **link-at-load**: the `pap`-mint at runtime.py:133 consults the table and,
  for a bound extern, produces the wrapper (a `talf`-backed closure) instead of a
  `pap`; (d) **`bridge.verify` re-seated** on the wrapper's declared-type return;
  (e) `impl_ports` **demoted** to the fallback taken only by unbound effectful
  externs (line-50 check relaxed to "bound-in-table OR in `IMPLS`").

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled doc (cite it); genuinely novel
design goes to NEEDS-AUTHOR and is surfaced, never answered on the author's behalf.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **`fd-view` privilege** — which layer may open a linear port atom to its raw integer, and how is it inexpressible elsewhere so opacity is not decorative? | **RESOLVED** | Derivable from the *built* confinement stack, no new author call needed. `fd-view` is a **bridge-internal runtime primitive** (registered by the linkage layer, present ONLY as a referent for sysface wrappers), **never a surface extern** in `ports.chiral` — so it is absent from the checker-enforced frozen-port-set / extern set (map row: "linearity + frozen-set enforced by checker"). Its raw int can only *feed* `nb-sys-*`, and the actual `sys` instruction is already refused outside a `sysface`-marked `TFn` (`tal.py:151/156`). Two locks in series (not-in-frozen-surface + sysface floor gate) make it inexpressible in app code without adding a mechanism. It must thread the port back result-shape-style (QTT has no borrow — the example's `FdView`/`RecvR` pattern is forced). |
| 2a | **errno sum granularity** — one shared `SysR` vs per-family sums? | **RESOLVED** | Per-family, conforming to the *existing* `ports.chiral` result-sum shape (`RecvR`, `PoolR`, `AccR` are already per-family). No new convention; the wrappers mirror the face they stand behind. |
| 2b | **errno alarm-vs-value** — which errnos are ordinary values vs alarms (counter-effect)? | **DEFERRED → E39** | `decision-effect-facets.md` fixes "alarms are crossings" but explicitly leaves *recoverable-vs-fatal placement in the type* to E39 (`error-and-alarm`'s fourth commitment, doc §160–163). Until the row lands, every wrapper returns errno **as an ordinary value** in its result sum (the example's `write-err`); no path is classified as an alarm by E51. |
| 3 | **`bridge.verify` depth on the sys-tal return** — re-check at the same depth as host impls? | **RESOLVED** | Yes — same declared-type boundary. Example §2 finding 2: "the linkage re-seats the *same* check on the sys-tal return — the membrane stays, the transport changes." The wrapper returns a chirality-native sum (well-typed by construction), so `bridge.verify` at the extern's declared result type is a tag/shape check identical to the `pap` path — kept as defense-in-depth against a lying wrapper, and to preserve the frozen-port-set observable the gate checks. |
| 4 | **row⇄sysface correspondence** — exact mapping once E39's row shape lands. | **DEFERRED → E39 (row shape) + E70 (tal shadow)** | The concrete row representation is E39-owned and now fixed by its audited SPEC (disposition a: canonical crossing-name row; 2026-07-27 audit); the row's tal shadow — the lowered claim carried to the floor — is E70 (doc §130–134: "the tal shadow is the future compiler's admission ticket to the floor"; the example §2's phrasing: "named here, not designed here"). E51's binding table keys on **extern name** (already a stable identifier), which is forward-compatible with either row shape; the effect-claim thread references E39's row but binds nothing that E39 has not yet built. |
| 5 | **The bound set vs the frozen face** (surfaced by the spec audit, 2026-07-27) — `fd-write`/`fd-read`/`fd-seek` are declared **nowhere** in `scaffold/lib` or `scaffold/chirality` (grep: zero hits), yet the example's skeleton and this SPEC's step 2 / gate treat them as the externs being bound. The only declared write path today is `pool-write : (-> (0 n I64) (=> (1 p (Pool n)) I64 Bytes (Pool n)))`, whose result type carries no error constructor — so the errno-as-value sums (Decisions 2a/2b) have no declared home either. Does E51 (a) **add** `fd-write`/`fd-read`/`fd-seek` + their per-family result sums to the typed face — a decl change the Category-C map row ("transport swap is E51 lane, not a reshape … without touching decls") and §2's own "must not touch decls" reserve against — or (b) keep the face frozen and bind only what exists today (`pool-create`), deferring the fd-level read/write face to a separate EXTEND? | **RESOLVED (author, 2026-07-27) → (b) keep the face frozen** | A POSIX fd-level read/write/seek face is a **phantom** — the design already refracted those paths: the write path IS the pool family (memfd-backed, `pool-create`/`pool-write`), the stream path IS sockets (`sock-*`, E29), and stdout/stderr are the ambient writers (`put`/`print`/`trace`). Extending the face inside the linkage element would grow the frozen security surface against both the Category-C map row and §2's own reserve. E51 binds only externs whose full crossing path exists today (step 2); errno-as-value demonstration moves to the first bound crossing whose declared sum carries an error constructor (E29 sockets; Decisions 2a/2b stay the convention those wrappers follow). |

All five dispositioned; none open. Decision 5 was surfaced by the spec audit
(2026-07-27) and resolved by the author the same day: the face stays frozen,
the v1 bound set is what exists (step 2), and the fd-level face is recorded in
§6 as a phantom, not a deferred feature. The E39-Step-7 ordering question was
resolved by the author 2026-07-28: **this SPEC's v1 binding of the ambient
writers lands FIRST**; E39's Console reification then re-threads the bound
wrappers (its SPEC carries the dated note).

## 4. Change plan (ordered, commit-sized)

### Step 1 — `fd-view` bridge primitive (sysface-only raw-port view)
- **Target:** `scaffold/chirality/runtime.py` (`IMPLS`/link layer registration) +
  `lib/lowering/tal/sys-linkage.chiral` (the `FdView` datatype + `fd-view` referent decl).
- **Change:** add a runtime referent that, given a linear `Fd` atom, returns
  `(fd-view-r raw f2)` — the raw int plus the *same* port threaded back (no
  double-use; matches `RecvR`'s result-shape threading). Register it ONLY as a
  linkage-internal referent, NOT in `ports.chiral` and NOT in the surface extern
  set, so the frozen-port-set check never sees it as callable app-side (Decision 1).
- **Size:** S
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

### Step 2 — the binding table + C-bridge wrappers (`lib/sys-linkage.chiral`)
- **Target:** NEW `lib/lowering/tal/sys-linkage.chiral` — `SysBinding`, `sys-bindings`,
  `FdView`, and the v1 wrappers `wrap-put`/`wrap-print`/`wrap-trace`.
- **Change:** the v1 bound set (Decision 5: bind ONLY externs whose FULL
  crossing path exists today) is the three ambient writers — `put`/`print`
  (stdout, fd 1) and `trace` (stderr, fd 2), each `(=> Str Unit)`, each wrapped
  over the existing `nb-sys-write` (`str->bytes`; `print` AND `trace` append
  the newline byte — only `put` omits it, matching the host impls
  `_print`/`_trace` (`s + "\n"`) vs `_put` (`impl_ports.py:35–56`); no port
  machinery needed). The example §5 skeleton supplies the
  wrapper/table *shape*; its `wrap-write`-over-`fd-view` body is the pattern
  lane-A fd-taking wrappers will follow. Everything else stays a commented row
  until its path exists: `pool-create` (its three crossings
  memfd/ftruncate/mmap all exist, but its wrapper must MINT `(Pool n)`/`Fd`
  port atoms — the port-mint seam, `fd-view`'s dual, is lane-A wiring);
  `fd-close`/`pool-close` (no `nb-sys-close` — E28 EXTEND residue);
  sockets/poll/spawn/clock (lane A, E29–E33). errno as ordinary value
  (Decision 2b) and per-family sums (Decision 2a) remain the convention the
  lane-A wrappers follow; no v1 wrapper has an error path to encode
  (`Unit` results).
- **Size:** M

### Step 3 — link-at-load dispatch through the table
- **Target:** `scaffold/chirality/runtime.py` — the extern mint at `run()` **line 133**
  (`return ("pap", t[1], [], self.sig.prim_arity[t[1]])`).
- **Change:** consult the loaded `sys-bindings` table; for a **bound** extern name,
  mint the wrapper closure (its lowered def, which internally reaches `nb-sys-*`
  via the existing `talf` path) instead of a `pap`. Unbound externs still mint a
  `pap` (migration fallback). CPython leaves the path for every bound crossing.
- **Size:** M

### Step 4 — re-seat `bridge.verify` + relax the missing-impl check
- **Target:** `scaffold/chirality/runtime.py` — `apply1` (**lines 147–165**) and the
  `missing` check (**line 50**).
- **Change:** ensure the wrapper's final return crosses `bridge.verify(sig, name,
  v, result_type)` at the extern's declared type — same depth as the `pap` branch
  (Decision 3); factor the verify so both the `talf`-backed wrapper return and the
  `pap` return pass through it. Relax line 50: an extern is satisfied if it is
  **bound in `sys-bindings` OR present in `IMPLS`** (so demoting a crossing out of
  `IMPLS` is not a load error). During the window, an unbound effectful extern
  still falls to `IMPLS`; when lane A closes the bank, flip unbound→**link error**.
- **Size:** M
- 2026-09-04: cut Python oracle, no live successor.

### Step 5 — demote `impl_ports` for the bound crossings
- **Target:** `scaffold/chirality/impl_ports.py` (`_poolwrite`/`_fdclose`/... referents).
- **Change:** the bound effectful referents are no longer *the* transport — leave
  them registered as the fallback (do NOT delete: sockets/poll/spawn still use them
  until lane A). Add a comment marking each as migration-fallback-only. Full
  deletion is §6 residue, gated on lane A completion.
- **Size:** S

## 5. Conformance gate

> Rewritten 2026-07-27 per Decision 5 (author: face frozen, bind what exists):
> the demonstrator crossings are the ambient writers `put`/`print`/`trace`;
> the errno-shape demonstration moves to §6 residue until an error-carrying
> sum binds (E29).

- **Golden behavior (differential, both transports hit the same kernel —
  "floor" reserved for reference/native, and the native floor is §6 residue):**
  1. **Byte-identical observables through the sys-face.** A crossing reached
     THROUGH the linkage table (`put`/`print` to a captured stdout pipe,
     `trace` to stderr) produces byte-identical bytes-on-the-wire versus the
     `impl_ports` path — because the reference tal machine performs the *same*
     real `write` syscall the Python referent did.
  2. **Frozen-port-set unchanged.** `verify`'s frozen-port-set check sees the
     **same crossing names** before and after the swap (the typed face in
     `ports.chiral` is untouched); `fd-view` is NOT among them (Decision 1).
  3. **Runtime-floor demo.** A small effectful `main` that logs a line through
     `put` runs with CPython absent from the crossing path (assertable: the
     bound extern mints a `talf`-backed wrapper, never a `pap`/`IMPLS` call).
- **Tests to add** (`scaffold/tests/test_process_externs.py` + `test_e2e.py`):
  - `test_sysface_put_byte_identical` — same stdout bytes via table vs `IMPLS`
    (differential, captured pipe).
  - `test_sysface_trace_stderr_byte_identical` — same for `trace` on fd 2.
  - `test_frozen_port_set_stable` — crossing-name set identical pre/post; `fd-view` absent.
  - `test_bound_extern_no_pap` — a bound extern resolves to the wrapper, not a `pap`.
- **Green line:** 281 → ≥ 285; `tools/ledger-lint/ledger-lint.py` clean (E51 row flips
  REFACTOR→built via the CONFORMANCE-MAP after implementation, not in this SPEC).
- **Done when:** every currently-bindable effectful crossing routes through
  `sys-tal` with CPython out of its path and byte-identical observables, the
  frozen-port-set is unchanged, and `impl_ports` is fallback-only for the
  not-yet-authored (lane A) crossings.

## 6. Residue & links

- **Deliberately unbuilt:**
  - A POSIX fd-level `read`/`write`/`seek` face — **NOT owed; a phantom**
    (Decision 5, author 2026-07-27): the write path is the pool family, the
    stream path is sockets, stdout/stderr are the ambient writers. Recorded so
    no later run re-names this gap.
  - The **port-mint seam** (`fd-view`'s dual: a wrapper minting `(Pool n)`/`Fd`
    atoms) + the `pool-create` composite wrapper over memfd/ftruncate/mmap —
    lane-A wiring, the seam's first consumer.
  - The **errno-as-value demonstration** (the observable for Decisions 2a/2b)
    — rides the first bound crossing whose declared sum carries an error
    constructor (E29 sockets).
  - Socket / poll / fd-passing / spawn / clock wrappers — **lane A (E28–E33)**;
    their `nb-sys-*` hand-tal does not exist yet, so the table leaves their rows
    commented. E51 binds them when the tal lands (the table is the wiring point).
  - errno **alarm-vs-value** classification (counter-effect crossings) — **E39**
    (`decision-effect-facets.md` §160–163, `error-and-alarm`'s fourth commitment).
  - The effect-row's concrete **row shape** and its **tal shadow** — **E39** and
    **E70** respectively; E51 keys the table on extern name, forward-compatible.
  - **Native-floor** execution of the wrappers — reference machine first; the
    native crossing follows once codegen carries the `sysface` mark down.
  - Full **`impl_ports.py` deletion** — demoted here; deleted when lane A closes
    the crossing bank and unbound-effectful becomes a hard link error.
  - The last Python **shuttle removal** (loader/ELF) — **E20/E34**.
- **Follow-on this unblocks:** the manas self-host transport (E67 "real-worker
  run + E51 transport self-host"), the orchestration self-host linkage
  (BUILD row, gated E28/E29/E31), and every lane-A crossing's *wiring*.
- **Related:** [[E51-sys-linkage]] · [[E39-effect-row]] (row that names crossings)
  · [[E70]] (effectful lowering / tal shadow) · [[E28-mmap-crossings]]
  [[E29-sockets]] [[E30-fd-passing]] [[E31-poll]] [[E33-process-spawn]] (lane-A
  crossings this table will bind) · [[E21-arena]] (first self-hosted crossing
  chain this generalizes) · [[E20-loader]]/[[E34]] (Python-shuttle endgame) ·
  `docs/decision-effect-facets.md` (edge 16, the resolved gate).
