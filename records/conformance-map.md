# chirality Conformance Map

**Method.** Every built and designed element of the chirality self-implementation was
classified against its principle-shaped end-state into one of five verdicts —
**CONFORMS** (frame matches the design, no work owed), **EXTEND** (payload drops
into an existing slot without reshaping it), **REFACTOR** (the shape of existing
code must change), **BUILD** (forward construction, nothing to reshape), and
**DECISION** (an author call is owed before any code is right). Baseline at
classification time: **281 tests green, ledger-lint clean (2026-07-21).** This map
is the input to a **worked-example series** (one pre-run per E-element under
`examples/`) and then a **refactor pass** that must respect the REFACTOR items
below. 83 rows were classified in that pass; several elements appear twice — once
as a built substrate row and once as its designed-unbuilt enrichment — and are
reconciled in the checklists (each unique element appears once, with both facets
noted).

**This header states two different things, and they must not be read as one.**
The classification pass is dated; the table is not frozen — rows have been minted
and revised since. So the snapshot tallies keep their date, and the live count is
recomputed with its method beside it.

**Snapshot, as of 2026-07-21.** Across the **83 rows** classified that day:
**CONFORMS 32 · EXTEND 7 · REFACTOR 8 · BUILD 29 · DECISION 7** (sum 83). These
five figures are historical and are not maintained; they describe the pass, not
the file's present contents.

**Live, recounted 2026-08-25 at `37102ac`.** The file holds **82 conformance
rows**, tallying **CONFORMS 35 · EXTEND 6 · REFACTOR 7 · BUILD 28 · DECISION 6**
(sum 82). These six figures are mechanized: `ledger-lint` **check Q** recounts
them from this file and fails on drift, so a newly minted row breaks the gate
instead of rotting the header the way the snapshot line rotted. Recompute by
hand with:

```
sed 's/\\[|]/~/g' records/conformance-map.md \
  | awk -F'|' 'NF==10 {gsub(/^[ *]+|[ *]+$/,"",$6);
      if ($6 ~ /^(CONFORMS|EXTEND|REFACTOR|BUILD|DECISION)$/) print $6}' \
  | sort | uniq -c
```

**Counting rule.** A conformance row is a `|`-line of exactly 8 cells whose
**Class** cell is one bare verdict. The `sed` first neutralises the single
escaped `\|` living inside a cell, without which that row's columns shift by one
and it is silently dropped (an independent Python count that splits on unescaped
pipes only agrees at 82). Counting *every* data row instead yields **89**,
because this file also carries a **separate 7-row `manas`-application-layer
table** further down — its own `Addition | Home file | …` header, no
`Principle`/`E#` cells, and by its own preamble not language self-implementation
elements. Those 7 are not conformance rows.

**⚑ The 83 → 82 delta is real and is NOT reconciled here.** Exactly two rows
carry a post-snapshot mint marker — E53 (*"Row minted 2026-07-28 — E53 postdated
the map snapshot"*) and E166 (*"Row minted 2026-08-25"*). A frozen 83 plus those
two would be 85 against 82 live, so rows have also been merged or dropped since
the snapshot **without leaving a marker**, and which ones is not reconstructible
from this file alone. Author call owed: whether this header should become a
maintained live tally (and the drift reconstructed from git) or stay a dated
snapshot line that post-snapshot mints never touch. Until that is decided both
figures stand, each labelled with its date and its method.

> **Reconciliation (2026-07-21, post-authoring):** the `—` / "needs E-number"
> cells below were assigned **E51–E68** in the same-day catalog pass — see
> `SELF-IMPLEMENT-CATALOG.md` §IV (E51), §VII (E52–E63: certificate split, split-role,
> C-bridge evidence, custody, staging, reflect-typed, taint/constant-time, adhikara,
> bootstrap-floor, cheri), §VIII (E64–E68: orchestration substrate). The catalog is
> the live source of E-numbers; this map is a dated snapshot and its per-row "needs
> E-number" flags predate the assignment. **Code state is unchanged** — the numbers
> exist, the elements do not.

---

## Full map

### A — Kernel core

| Element | Principle | Planned end-state | Current state | Class | Size | E# | Blast radius / notes |
|---|---|---|---|---|---|---|---|
| NbE eval/quote/conv (+eta) | P1,P2 | Full NbE core; the settled scaffold shape | Built complete; unknown value-forms fall through to conv/quote hooks | CONFORMS | S | E3 | Judgment core depends only on terms.py; extensions reached via declining hooks |
| Bidirectional infer/check + universes | P1,P2 | Cumulative universes, membrane at apply/binder/erased | Built; `Type l:Type l+1`, cumulativity via subtype, rules via sig.rules | CONFORMS | S | E4 | No universe polymorphism (not a scaffold goal); frame holds |
| Data: ctors, coverage, param unification | P2,P1 | Datatypes behind term-former seam, exhaustiveness, ctor-param inference | Built; coverage enforced, `_infer_ctor_params` solves bare params | CONFORMS | S | E6 | Scaffold limits (no dependent fields) recorded honestly, not defects |
| Strict positivity / variance | P2 | Positivity guard, per-param variance cache | Built; `_positivity` + `_compute_sp_params` run at check_data | CONFORMS | S | E7 | Conservative-by-design (App variance refused) |
| Linear-kind decision for data | P2,P3 | Linearity a property of the TYPE; ports need q=1 | Built; `is_linear` + depth-bounded abstract walk, deferral sound | CONFORMS | S | E8 | Deferral = same sound answer as cycle-break |
| Refinement decision procedure | P4,P2 | FULL predicates (v<n+1, inter-var arith, bases beyond I64) | Built as named fragment: interval+holes+syntactic symbolic, I64-only, literal/bare-Var operands | REFACTOR | L | E9 | refine.py constraint tuple + all functions over it swap to octagon/solver; base+operand gates widen; **kernel UNTOUCHED** (value-form seams isolate). Adding same-shape atoms would be EXTEND (see row E9-var below); the named full-predicate end-state is a procedure swap = REFACTOR |
| Path-sensitivity / occurrence typing | P4 | Guarded branch narrows compared var to proven bound | Built; `_narrow` + `_LEARN`, `Ctx.narrow` swaps ascribed type only (sound) | CONFORMS | S | E10 | Predicate richness rides on E9's fragment; no reshape here |
| Totality: structural + numeric-measure | P2 | Termination ENFORCED, not just classified | Built + classifying; enforces on demand (`require_total` / profile `(total)`), default OFF | EXTEND | M | E11 | Payload owed = flip enforcement default; GATED on E47+E50 proving more measures first (else regresses lexicographic/mutual/non-unit loops) |
| Sized types (termination promotion) | P2 | Size annotations so non-structural size-decreasing recursion is total | Not built; `_totality_reason` returns not-proven for these | BUILD | L | E47 | Forward construction inside existing checker; no reshape. Prereq for E11-by-default |
| Mutual/lexicographic termination | P2 | Lexicographic descent, size-change, mutual-group | **Cheap tier BUILT (E50, 2026-07-28)**: mutual groups + lexicographic tuples prove via a DECLARED shared measure (interim `(measure …)` declare attribute; edges ranked strict/equal/unknown, group verdict = no unknown edge + equal-only subgraph acyclic; false measure rejected, hard error under require_total). Full size-change graph (argument-permuting) deferred to its own element | CONFORMS | L | E50 | Declared-not-inferred per certificate-discipline; the rung-1 self-applicability gate (infer/check, eval/quote/conv shapes) is open. (Dup: G row classes it EXTEND — reconciled below) |
| DDC differential harness | P5 | Diverse double-compilation: provenance-declared legs, agreement-or-named-divergence | **BUILT (E53, 2026-07-28)** — pure compare core `lib/ddc.chiral` (Prov/Leg/DdcR/LegOut + first-divergence fold; every fn proven total; reference-floor re-derivable) + untrusted driver `scaffold/tests/ddc.py` (leg 0 native artifact/observables vs leg 1 TalMachine; `function@byte_offset` localization via emitter offsets; provenance gate before compare). Row minted 2026-07-28 — E53 postdated the map snapshot | CONFORMS | M | E53 | Near-term legs only: true Stage1==Stage2 fixpoint + leg-running are E70-gated; leg 2 → E72; cert-over-Adhikara → E52. D-1/D-2 determinism debts remain pre-port gates — this harness convicts them, it does not pay them |
| Term de-Bruijn machinery | P1 | Pure syntactic layer beneath judgment | Built; `uses_below`/`shift_close` over all formers incl. EXT_TERMS | CONFORMS | S | E13 | Syntax-beneath-judgment line drawn cleanly |
| Pretty-printer (display) | P1 | Display only, kernel-error paths, cannot unsound checker | Built; no judgment path consults it (lazy shims) | CONFORMS | S | E14 | Low priority; no work owed |
| Reflective floor | P1 | Boundary below which running chirality cannot mutate the judgment core | Not built; Sig exposes every seam as mutable Python attrs | BUILD | L | E45 | Directly load-bearing for P1's second clause. Row gave no E#; reconciled to **E45** (G row). DECISION-gated (edge 5, draw the A/B line) before BUILD |

### B — Effect / quantity

| Element | Principle | Planned end-state | Current state | Class | Size | E# | Blast radius / notes |
|---|---|---|---|---|---|---|---|
| QTT quantity semiring (0/1/w) + usage vectors | P2 | Resources ride in the type; 0/1/w lattice is the scaffold semiring | Built; qadd/qmul/qjoin/qfits + usage vectors, enforced at binder exit + case-join | CONFORMS | S | E5 | Anchor row for the quantity side. CONFORMS as scoped at 0/1/w; enrichment is E38 |
| QTT usage-vector linearity (membrane half) | P2,P4 | 0/1/w accounting + linear-kind enforcement — frozen base E38 enriches | Built + sound; linear-kind wired at on_binder (q=1), erasure forces q=0 pure | CONFORMS | S | E5 | Same element as above, quantity-half-of-membrane facet |
| Graded / cost coeffect semiring | P2 | Enrich q from {0,1,w} to product coeffect semiring (usage×time×space×info-flow, cost=ℕ∞), parametric | Not built; qadd/qmul/qjoin/qfits hardcoded to 3-point lattice, W a bare string | REFACTOR | L/M | E38 | Decision SETTLED (decision-graded-kernel.md, option A). kernel.py semiring arithmetic + usage-vector ops + terms.py q slot + surface.py QUANTS + effects.py q comparisons reshape from lattice to grade-tuple; **judgment seams (conv/infer/check) do NOT reshape** — containment win. Edges 2,3. (3 rows: 2 REFACTOR-L, 1 REFACTOR-M — reconciled) |
| Effect membrane (pure `->` vs process `=>`) | P2,P3 | One coarse pure/process bit at 3 seams (apply/binder/erased) | **Carried everywhere, refused nowhere — corrected 2026-08-25 (was `CONFORMS`, "no work owed").** The eff bit rides Pi pos 2 and the seats/`ty-crosses`/`sheet-crossings` readers are built, but the three seams that REFUSE (`on_apply`/`on_binder`/`erased_allow`) exist only in the retired oracle (`scaffold/chirality/effects.py:23,38,46`); the native compiler says so itself — `kernel.chiral:897` *"No allow_eff/erased_allow/on_binder -- the row/membrane layer is E12, kept as the seat"*, `:998` likewise, `:14-15` still lists the seams among what is owed to E12 — and `scaffold/lib/effects.chiral` is the E12 model its own header calls ungated (*"effects.py stays the oracle … The membrane only GATES -- it interprets nothing"*). Measured against `scaffold/build/B1` at `4f64d91`, resolved with `bin/chirality-resolve.sh` and RUN: a `(-> I64 I64)` def calling the `=>` extern `backend-open` exits 42; one calling the bound crossing `put` writes to stdout; `(def check (-> Str I64) (lam (s) (observe s)))` beside `(def observe (=> Str I64) …)` prints and exits 7 | EXTEND | S | E12 | **Work IS owed, and it is E171** — extend the seams into the compiler that compiles everything, so a `->` body cannot reach a crossing transitively (P2's no-exemption clause, P3's port-check-is-the-type-check). The prior note read "no work owed within E12's coarse-bit scope", which was true of `effects.py` and false of the tree. Independent of the row upgrade (E39) and of alarms (E26), both of which assume this gate already stands |
| Effect algebra / typed rows | P2,P3 | Replace eff bool with a typed effect ROW; handlers subtract effects; halt+alarm counter-effects named | **Carrier edit BUILT (E39 steps 1–6, 2026-07-28)**: Pi pos-2 = frozen `Seats(row, grades·totality reserved)` (`row.py`); conv keeps equality, `subtype` gained the VPi row-subsumption case (contravariant domains); `effects.py` gates by set-containment; rows call-graph-inferred at elaboration (deterministic canonical sorted form, `sig.def_rows` = the E51/E70 artifact). Non-spine `=>` arrows carry the DYN row (`"*"` — precise rows there are row polymorphism, rowvar seat frozen). **Step 7 (Console reification) pending the E51-vs-Console ordering author call**; handler machinery/subtraction rides E26 | REFACTOR | L | E39 | Steps 1–6 landed 2026-07-28, zero new kernel forms, 301-test membrane regression clean + 7 gate tests. Gates E26 (now unblocked at the row level). **Edge 16 resolved 2026-07-21** (`docs/decision-effect-facets.md`) — see G/DECISION |
| Alarms as a typed effect | P2,P3,P5 | Alarm = typed effect on the membrane, total, handler from named counter-effect set | Python host exceptions (MetisExit/Halt/PortError); halt declared in chirality but no effect row / no handler machinery | BUILD | M | E26 | Forward construction; Python exceptions are floor plumbing to replace. Hard-gated on E39 (its effect row); sequence after E39 |

### C — Lowering / backend

| Element | Principle | Planned end-state | Current state | Class | Size | E# | Blast radius / notes |
|---|---|---|---|---|---|---|---|
| Lowering connector + preserve-check | P1,P2 | pure→tal, reg/slot alloc, non-tail case outlining, re-check at floor | Fully built; monotonic single-assignment slots, `lower_all` holds body to declared type via `tal.check_fn` | CONFORMS | S | E16 | Narrow eligibility (pure, non-dependent, ground) is the honest scaffold slice; widening (closures/HO) is separate forward work |
| Optimizer: fold/DCE/specialize/pregen | P2,P1 | Each a tal→tal transform re-run through preserve-check | Built; fold/dead/specialize fixpoint, SSA guard, folds bit-identical to runtime | CONFORMS | S | E17 | Meaning-preserving only, NO graded-cost claim — cost-typed account is E38, not a defect here |
| TAL floor: checker + trusted interpreter | P1,P5 | Typed TAL checked independently of kernel; reference = full Typed Assembly | Built; `check_fn` types every instr, `TalMachine` trusted drop, sysface marked | CONFORMS | S | E18,E19 | One honest soundness limit vs Morrisett: no typed-init on byte cells (authored lib only writes fresh) — bounded hardening, not owed by E18 |
| x86-64 as modular Mach | P4,P1 | Encoding/SysV/reloc behind frozen Mach; new target = conforming value | Built in chirality; emit-core ISA-agnostic, mach-x64 + mach-listing two conforming targets, asm-reloc target-independent | CONFORMS | S | E19 | Strongest P4 exemplar. Diverges from decision-backend's LLVM/Cranelift (see DECISION) |
| Third conforming `Mach`: the C-emitting verification target | P4,P5 | A backend value that emits C-as-portable-assembly, so an EXTERNAL C compiler (gcc AND CompCert 3.17 — both built, `ccomp` the default since 2026-08-25) can build a second DDC leg whose provenance is disjoint from chirality's own | **BUILT (E166, 2026-08-24)** — `lib/mach-c.chiral` (all 37 `Mach` arms) + `lib/c-assemble.chiral` + `lib/emit-c.chiral` + the `compile-driver-c` root drive `emit-core` UNCHANGED, the same way `mach-listing` does; the freestanding runtime shim is `scaffold/rt/chirality-rt.c` **plus** `scaffold/rt/chirality-rt.s` (split 2026-08-25 at `aa055ec`: the three GNU-asm constructs CompCert refuses — `m_sys`, `m_trap`, `_start` — moved to assembly). ⚑ **They are ONE trusted drop and are counted at their SUM**, 89 C code lines + 27 asm code lines = **116**, against the SPEC's ~150; a file boundary must not be able to shrink the number that measures the trust; the leg is one command (`scaffold/tests/ddc-c-leg.sh`) and `run-native.sh` Phase 10; `ddc.chiral` carries `ddc-legc` (`(leg "c-external" (prov "c" "gcc-12" "shred" 2026))`) **and `ddc-legcc`** (`(leg "c-compcert" (prov "c" "compcert-3.17" "shred" 2026))`) — ⚑ *not two legs*: they share `"c"`, `leg2-disjoint?` needs both axes, so a quorum is leg 0 plus exactly one. Row minted 2026-08-25 — E166 postdates the map snapshot | BUILD | M | E166 | Canonical backend is UNCHANGED — `mach-x64` stays the shipping target and `docs/decision-backend.md`'s fork is scoped to the canonical shred instance; this is an additive verification instance. The runtime shim is NEW TRUSTED CODE, so its size IS the element's honesty check (SPEC Step 3: *"if it passes ~150 L, stop and say so"*), and since the 2026-08-25 split that size is the **sum of the `.c` and the `.s`**. `emit-core.chiral` sits ABOVE the branch point and is common-mode to this differential — its external cover is E167 (`tal-c`), not this row |
| Category A pure host bindings + arithmetic laws | P2 | Pure prims owned by prelude decls; single Euclidean+two's-complement source shared by fold+runtime | Built; wrap64/i64_div/i64_mod imported by optimizer folder | CONFORMS | S | — | Trivial plumbing behind owned decls; arithmetic law settled (do not relitigate) |
| Byte cells [len][payload] + chirality byte/tal lib | P1,P5 | Native arena cells + bytes-tal.chiral, bytearray a crutch | Real path built + self-hosted; nb-* prims preserve-checked at load, arena cells execute; bytearray is golden oracle | CONFORMS | S | E25 | bytearray in reference interp is deliberate differential oracle, not unmet crutch. Membrane at floor enforces P3 |
| W^X loader | P3,P4 | Loader becomes chirality-side over sys slices, retiring ctypes+mmap | **Memory fully chirality-side (E20, 2026-07-29)**: code buffer + arena mapped via `nb-sys-mmap`, sealed via `nb-sys-mprotect`, all on the reference tal floor; Python's `mmap` module + ctypes `_mprotect` both gone from `native.py`. ONLY the `CFUNCTYPE` entry trampoline stays Python | REFACTOR | M | E20 | Memory management self-hosted end to end; sole remainder = the `CFUNCTYPE` call-in, which moves with a real entry point (E23/E34). Was unblocked by E28 mprotect |
| FFI trampoline / native entry | P1,P3 | chirality emits real ELF/entry point; ctypes trampoline deleted | Crutch working; CFUNCTYPE over loaded addr, ctypes decode, no ELF/entry | BUILD | L | E23 | Forward: ELF/object emitter + real entry point do not exist. Shuttle stays; ctypes gate+decode retire. Coupled to E20 |
| lib/backend.chiral (model-server seam) | P3,P4 | Replaceable OpenAI-compatible backend contract | Built complete (be-chat/stream/health/models/embed/search over http+json) | CONFORMS | S | — | Filename coincidence — this is the manas/orchestration model-backend (belongs to slice F), NOT the E19 codegen backend. Flagged so not double-counted |

### D — Ports / bridge / custody / security

| Element | Principle | Planned end-state | Current state | Class | Size | E# | Blast radius / notes |
|---|---|---|---|---|---|---|---|
| Category C port membrane (typed face + host bindings) | P3 | Named crossings (sockets/poll/memfd/spawn), opaque linear porttypes in frozen set; CPython transport→sys-face without touching decls | Built + correctly shaped; ports.chiral declares Sock/LSock/Fd/(Pool n), impl_ports binds host referents; linearity+frozen-set enforced by checker. **E29 v1 (2026-07-31)**: the fallible sock-* face hardened — every op carries its error as a `*-err` constructor (ConnR/LisR/SendR + recv-err/acc-err) instead of raising PortError; `sock-recv` length refined `(> 0)`; success/half-close thread the live socket, an error is a corpse (drops the operand). NetCap capability-gating deferred (blocked on cap-reification-to-main). **E30 (2026-07-31)**: fd-passing self-hosted at the floor — `nb-sys-send-fd` (sendmsg(46)+SCM_RIGHTS, msghdr/cmsghdr/iovec packed at ABI offsets via the new `nb-put-u32/u64/ptr` store-at-offset helpers), differential st_ino roundtrip; `sock-send-fd → SendFdR` (sfd-err returns Sock+Fd recoverable). Referent still CPython (transport swap = E51) | CONFORMS | S | E29,E30,E31,E32,E33 | Crossing SHAPE conforms to P3. Transport swap is E51 lane, not a reshape; spawn/staging SEEDED. E29+E30 error-arm hardening landed 344 green (impl_ports stays the referent) |
| Inbound bridge integrity-verification | P3,P5 | Membrane verifies every host-returned value matches declared result type | Built; `bridge.verify()` depth-bounded tag-check, mismatch→PortError alarm | CONFORMS | S | — | Integrity/inbound half only; no E#. Outbound confinement not built — **the convergent build obligation: edges 14/17/2/15 all reduce to it. Now element E73 (catalog §XI, ratified from docket D8 2026-07-26) — the outbound-membrane build, dual to this inbound half; see `.planning/BUILD-OBLIGATIONS-2026-07-25.md`** |
| C evidence bridges (attest/freshness/audit/isolation/reflect-raw) | P5,P3 | Named evidence-producing crossings where proof runs out at B | Zero code; docs-only, only inbound tag-check exists | BUILD | L | E55 | Forward, not a refactor of verify(). **E55** *(assigned 2026-07-21, catalog §VII; row text predates)* — bridge-evidence family; overlaps E44 outbound-confinement |
| Secret custody (minimal, type-level) | P3,P4,P5 | Opaque linear Secret, one greppable exit (secret-reveal), leak path type-rejected, zeroize hygiene | Built for seeded slice; Secret porttype (no ctor), seal/reveal/wipe, send-revealed sole legal exit | CONFORMS | S | E40 | SEEDED slice conforms as far as it claims; host-copy hygiene inherently partial (documented limit). Tagged E40 in code |
| Custody redundancy / datum-policy / memory custody | P3,P5 | Custody-split redundancy, per-datum flow policy, register-root/zeroize as type obligation | Vapor beyond secret seed | BUILD | L | E56 | New modules, not payload into Secret slot. **E56** *(assigned 2026-07-21, catalog §VII; row text predates)* — modules-custody bulk; adjacent E42 register-root. redundancy is an instance of split-provider agreement |
| Security trio: info-flow / taint / constant-time | P3,P5 | IFC non-interference (revealed Secret never reaches socket), taint, constant-time as preserve-check's first customer | Zero code; constant-time named but not wired to built preserve-check | BUILD | L | E44,E59,E60 | IFC→E44 (edge 18 open). Constant-time reuses built preserve-check (lower/optimize) but unconnected. **taint E59 / const-time E60** *(assigned 2026-07-21, catalog §VII; row text predates)* — IFC stays E44 |
| Grants / revocation / delegate + broker | P3,P4 | Capability ports w/ attenuation/grants/delegate + revocation; broker AUTH/AUDIT | Only Move (linearity) built; subtype mechanism present but NOT applied to grant narrowing; broker spawn/teardown only | BUILD | L | E40,E43 | Subtype-present-but-unapplied could make grant-narrowing partial EXTEND; revoke/delegate/broker genuine BUILD. permission-model doc's "done" is stale overclaim, not a live fork |

### E — Runtime / staging / sys-face

| Element | Principle | Planned end-state | Current state | Class | Size | E# | Blast radius / notes |
|---|---|---|---|---|---|---|---|
| Reference interpreter / evaluator + linker | P2 | Golden tree-walk w/ TCO over checked terms, erases q=0 lets, link-check externs, main-is-process gate | Fully built as E15 | CONFORMS | S | E15 | This is E15 (golden semantics), NOT the E42 supervisor — keep distinct |
| Runtime supervisor as specified | P2,P3 | Distinct artifact: critical sections, register-root custody, scheduler (seL4-shaped) | Not built; runtime.py is evaluator+linker, no crit-sections/GC-roots/scheduling | BUILD | L | E42 | Forward, separate artifact. Reference class PAPER (seL4/microkernel) |
| Staging / binding-time modality | P2 | Binding-time as first-class modality (Fork C); link/load vs runtime carried in type | Ad-hoc slice only (link-at-load extern check); no type-level representation | BUILD | M | E57 | **E57** *(assigned 2026-07-21, catalog §VII; row text predates)* — Fork C staging. Distinct from E51 (concrete upper→sys wire) |
| Component broker / adhikara | P3,P5 | Broker AUTH/AUDIT with grant/revoke/audit on adhikara protocol | spawn/teardown/link-at-load only, ad hoc; no grant/revoke/audit | BUILD | L | E43 | Ties edge 8 (broker), 7/17 (permission). Atop E40. (Dup: G row classes DECISION on edge-8 decomposition) |
| E51 sys-face linkage | P3,P1 | Upper-effectful chirality reaches syscalls THROUGH sys-tal, impl_ports retired as transport | **Seam BUILT (v1, 2026-07-30)**: the `sysbind` dispatch (runtime.py `Prim` mint: a bound extern mints its hand-tal wrapper closure, not a `pap`) routes the three ambient writers (put/print/trace) through `nb-sys-write` on the reference tal machine — CPython out of the crossing path, byte-identical differential, `bridge.verify` re-seated (Decision 3, factored across both transports). `sys-bindings` table is chirality data; `build_sys_linkage` assembles the wrapper machine; MET_SYSLINK=1 opt-in during the migration window. impl_ports writers demoted to fallback-only. **Remaining**: lane-A crossings (E29/E30/E31/E33 wrappers, needing floor-built result sums), full impl_ports retirement, native-floor execution | REFACTOR | L | E51 | v1 slice landed 328 green; extern→sys-tal table + apply1 dispatch + bridge.verify done. **THE real self-host gate. E51** *(assigned 2026-07-21, catalog §IV; v1 built 2026-07-30 — examples/E51-sys-linkage.md · SPEC)*. **Edge 16 resolved 2026-07-21; fd-view (step 1) deferred to lane A (no v1 consumer)** |
| Self-hosted syscall floor (sys-tal) | P3 | Port impls move into tal-floor sys crossings behind TalFn.sysface; complete mmap/munmap/mprotect/close | Built + membrane-sound; all nine memory/fd crossings present (write/read/lseek/memfd/ftruncate/mmap/munmap/**mprotect/close**, E28 implemented 2026-07-28, differential pairs incl. -EBADF error observable; the reference _sys now inverts libc's -1+errno so BOTH floors agree on error paths); E21 arena done | CONFORMS | M | E28 | Membrane discipline CONFORMS (P3 structural). E28 flipped EXTEND→CONFORMS 2026-07-28; E20's mprotect dependency satisfied. Sockets/poll/spawn are E29/E31/E33, not this row |

### F — Surface / profiles / orchestration

| Element | Principle | Planned end-state | Current state | Class | Size | E# | Blast radius / notes |
|---|---|---|---|---|---|---|---|
| S-expression reader | P4 | Scaffold reader; superseded (not deleted) by E49 | Complete for scope; every lib parses through it | CONFORMS | S | E1 | Regularity=P4. Real syntax is E49 |
| Surface elaborator | P4,P1 | Name→deBruijn, desugar all forms, drive toplevels; reused verbatim under E49 | Fully built; elab/resolve, arrow/lam/let/case/do/cond/the/refine | CONFORMS | M | E2 | The stable core the real surface feeds; only concrete syntax (E49) owed |
| Profiles + verify (frozen-port manifest) | P3,P5 | Additive manifest over frozen port set; satisfies target (subtyping); memory/(total) clauses | Built + enforced; rejects pure ports/unknown disciplines, checks target rows + port-set + per-def totality | CONFORMS | M | E2 | Frozen-port manifest = P3 core, correctly shaped. Whole-assembly conformance is E44/edge-18 (slice G) |
| CLI / entrypoint / staging connector | P3 | check/run/verify/lower/spawn-run toolchain driver | Built; all 5 commands, _spawn_run stages profile + hands node-main one Sock | CONFORMS | S | E2 | Trivial plumbing. Self-hosted spawn is E33 |
| Prelude (category-A floor) | P2 | Pure fragment in chirality source, host binds impls at link | Built + stable; data decls + 20 pure externs + helpers | CONFORMS | S | E5 | A-floor realized; per-prim crutch-shedding is native-slice work |
| Memory discipline: linear (Pool, mem-put-checked) | P3,P5 | `(memory linear)` points somewhere real; bounds-checked write discharges bound at compile time | Built; mem-put-checked takes `(refine I64 (>=0)(<n))`, collapses runtime check for literal/guarded offsets | CONFORMS | S | E22 | Discipline-as-profile-choice (P3: space is a port). F8 offset half lands via E9 refinement |
| Region types (retire runtime bounds) | P3,P5 | Typed cursor/offsets discharge capacity check statically (region calculus) | Discipline lib built + shaped, but check still RUNTIME (`(<=i (+ used len) cap)` halts on overflow) | REFACTOR | M | E41,E22 | Region data gains refined cursor; mem-alloc runtime branch→type obligation; offsets→`(refine I64 …)`. Gated on E9 arithmetic-expression bounds, e.g. cursor+size ≤ cap (edge 3; bare-var symbolic landed 2026-07-06). (Dup: G row classes BUILD for region-types-in-kernel) |
| JSON value tree | P2 | Full JSON; \u BMP limit closes when bitwise prims exist | Built + chirality-native; runs on RT interp; documented \u surrogate-pair gap | EXTEND | M | E64 | Additive (surrogate pairing) once bitwise floor prim lands; no reshape. **E64** *(assigned 2026-07-21, catalog §VIII; row text predates)* |
| HTTP effect + SSE streaming | P3 | Typed process crossing; transport behind backend interface, swappable to sys-face | Built + shaped; http-request extern, SSE as pull w/ opaque linear ChatStream + named end; CPython urllib shim underneath | CONFORMS | M | E65 | Module is the swap-point + conforms; transport swap is E51. **E65** *(assigned 2026-07-21, catalog §VIII)* |
| Wayland wire codec + niri IPC | P3 | Compositor a foreign counterpart across one typed port, no libwayland | Built, already-chirality; wenc/wsplit1, registry, niri line stream, err carries diverged | CONFORMS | S | E35,E36 | Demo-scoped but complete; depends on bytes prims (prelude externs) |
| FSM engine (Mealy spine) | P2 | Reusable control spine; a Step a machine cannot forget to emit | Built + fully general; Step(go\|halt), structurally-recursive drive | CONFORMS | S | E66 | Two-ctor Step forces the decision (P2/P5). **E66** *(assigned 2026-07-21, catalog §VIII; substrate spine)* |
| manas profile (breaker + batch driver) | P2,P3 | Conformance instance driving http+json+collections+fsm+backend headlessly | Built; cycle-step breaker as fsm Step, functional core + imperative shell over real backend | CONFORMS | M | E67 | Substrate conforms. Owed: real-worker run + E51 transport self-host. **E67** *(assigned 2026-07-21, catalog §VIII)* |
| Coordinator (one-turn cycle) | P3 | Minimal cycle whose seams fill to the full cycle (router/log/persistence) | Built as minimal one-turn loop; no batch/breaker/router/log yet (by design) | EXTEND | M | E67 | Additive into named seams, no reshape of run-cycle. **E67** *(assigned 2026-07-21, catalog §VIII — coordinator rides E67)* |
| Collections (List/Pair; checker-registry seed) | P2,P4 | Maps/sets in chirality replace CPython dicts; checker Sig registries move onto these | **Map/Set core BUILT (E27, 2026-07-28)**: AVL persistent `Map K V` over an explicit total comparator + `Set` surface (`Map K Unit`); deterministic ascending `m-fold` (the D-2 canonical order), pure insert-once (`m-insert-new`, collision-as-value), every def proven total; alist seed marked superseded in place. `bytes-cmp` E25-gated; `tyv-cmp` = the assigned D-1 follow-on | EXTEND | M | E27 | Remaining payload = migrate the checker's Sig dict/set registries onto the core — deliberately the port arc's job (SPEC §6; couples D-1/D-2), not the library element's. string-utils folded here |
| Orchestration self-host linkage | P1,P3 | Replace CPython transport with self-hosted sys face (E29/E31/E28) — TCB-shrink arc | Not built; whole substrate runs chirality-logic-over-CPython | BUILD | L | E51 | Forward, gated on E28/E29/E31. Overlaps the E51 REFACTOR (runtime dispatch reshape); this is the transport-replacement forward-build half. **E51** *(assigned 2026-07-21, catalog §IV; drafted — examples/E51-sys-linkage.md)* |

### G — Designed-unbuilt

| Element | Principle | Planned end-state | Current state | Class | Size | E# | Blast radius / notes |
|---|---|---|---|---|---|---|---|
| Graded cost / coeffect semiring (cost-typed) | P2 | Cost/space/termination ride in type as graded coeffect enriching QTT | Settled on paper, unbuilt; only 0/1/w in kernel | REFACTOR | L | E38 | Same element as B/E38; enrichment reshapes existing semiring |
| Effect algebra / typed rows (mechanism) | P2,P3 | Effects as typed rows over named counter-effect set; recoverable/fatal in type | Coarse bool only; **mechanism RESOLVED 2026-07-21 (edge 16 → `docs/decision-effect-facets.md`)**: two facets + graded continuations + synthesized cancel | DECISION | L | E39 | Slot exists (bool bit); edge 16 picked 2026-07-21, E39 row-shape now buildable → EXTEND of the bit. Ties edge 14 |
| Capability / permission model | P3,P4 | Capability ports, grant/attenuate/delegate, revocation, adhikara-over-wire | Only Move built; rest designed-only; subtype present but unapplied to grant narrowing | BUILD | L | E40 | permission-model.md over-claims done; edges 7,8,17 attach. Same element as D/grants |
| Region types (kernel) | P2,P3 | Space a typed port; lift pool-offset/byte-index bounds from runtime into type | Discipline lib only; region *types* deferred (edge 3) | BUILD | L | E41,E22 | E9 variable-bound refinement is the enabling sub-capability. Reconciles w/ F/region (lib=REFACTOR, kernel-types=BUILD) |
| Runtime supervisor as specified | P1,P3 | Supervisor: crit-sections, register-root custody, scheduler | runtime.py is a different artifact (evaluator+linker) | BUILD | L | E42 | Same element as E/supervisor |
| Component broker AUTH/AUDIT | P3,P5 | Broker w/ 4-part AUTH/AUDIT, spawn/teardown first-class, grant/revoke/audit | spawn/teardown/link only; **4-part decomposition UNDECIDED (edge 8)** | DECISION | L | E43 | Edge 8 decomposition settled before broker internals build. Same element as E/broker (which is the BUILD facet once decided) |
| Whole-assembly conformance | P4,P5 | Profile conformance covers non-interference / tier-weight compositionality | Named-crossings + (total) clause only; **which properties are compositional UNPINNED (edge 18)** | DECISION | L | E44 | Edge 18 governs default-attempt interaction proofs; cheap-subtyping vs dedicated-argument is the open part. **The `tier carrier` (how a per-axis tier rides the type) is a distinct unbuilt mechanism edges 4/17/18 share — E44 holds only the compositionality property, not the carrier, now element E74 (catalog §XI, minted from docket D9 2026-07-26)** |
| Reflective floor (pin the line) | P1 | Pin exactly what is/isn't reconfigurable from inside; line at the small trusted core | Direction resolved (edge 5), exact line **not drawn**; no code | DECISION | M | E45 | live-environment is forcing workload; draw A/B kernel line before reflect-raw/typed. DECISION-gates the A/E45 BUILD |
| reflect-typed: staged metaprogramming | P1 | Staged metaprogramming over typed terms, bounded by reflective floor | Docs-only; gated on edge 5 + staging spine | BUILD | L | E58 | **E58** *(assigned 2026-07-21, catalog §VII)*. Depends on E45/edge 5 |
| Proof-presentation / auditor (Isar-equiv) | P5 | Auditor-facing proof-presentation layer | Not built; docs-only | BUILD | L | E46 | Bounded novel work, no off-the-shelf equivalent |
| Sized types | P2 | Sized types promoting numeric recursion past termination bar | Not built | BUILD | M | E47 | Same element as A/sized. Feeds edge 9 |
| Dependent records / telescopes | P1 | Σ-types; field type may depend on earlier fields | Scaffold limit — no field dependence (data.py:134) | BUILD | M | E48 | Forward in data.py |
| Real surface syntax (stage 4) | P4,P1 | Human-facing concrete syntax replacing scaffold s-expr, same kernel terms | Scaffold s-expr only | BUILD | L | E49 | New front-end feeding existing elab() unchanged; supersedes sexp.py, not a kernel/core reshape. Same element as F/real-surface |
| Mutual / lexicographic termination | P2 | Termination over mutual recursion + lexicographic measures | **BUILT (E50, 2026-07-28)** — additive over the existing check exactly as predicted: measure edges accumulate per group, verdict at group completion; single-function path byte-identical (all prior verdicts unchanged) | CONFORMS | M | E50 | Same element as A/E50 — both rows flipped 2026-07-28; size-change graph is the deferred residue |
| Variable-bound / arithmetic refinements | P4,P2 | Predicates over inter-var arithmetic (v<n+1); pool offsets become types | SEEDED: const or bare-var only; arithmetic-expression bounds out | EXTEND | M | E9 | Textbook refine-fragment→more-predicates EXTEND (entails slot exists). Same element as A/E9 (REFACTOR): additive atoms = EXTEND, full solver swap = REFACTOR — two tiers of one element. Enables E41 |
| Kernel-core certificate verifier + discipline | P5,P1 | Small trusted kernel-core re-checks untrusted certificate producers (LCF/de-Bruijn) | Settled in docs; kernel.py is single trusted checker, no producer/consumer split | BUILD | L | E52 | **E52** *(assigned 2026-07-21, catalog §VII; row text predates)* — tier-climb machinery, F2-flagged. Decision made; forward build |
| split-provider / split-role | P5 | Guarded combine over independent sources, per-axis tiers, agreement-or-certificate | Docs-only | BUILD | L | E54 | **E54** *(assigned 2026-07-21, catalog §VII)*. Gated edge 4 (tier auto-selection) + edge 11 (independence) |
| C-bridge evidence-half | P5,P3 | One bridge elaborator per evidence element, each re-checks cert via bridge-preserve-check | Inbound dynamic tag-check only; evidence modules docs-only | BUILD | L | E55 | **E55** *(assigned 2026-07-21, catalog §VII; family follows same shape)*. Edge 12 (bridge-preserve-check statement) residual. Dup of D/C-evidence-bridges |
| Security trio: IFC / taint / constant-time | P3,P4 | IFC lattice + non-interference, taint, constant-time at lowering (first preserve-check customer) | Nearly vapor; preserve-check built but constant-time unwired | BUILD | L | E44,E59,E60 | **taint E59 / const-time E60** *(assigned 2026-07-21, catalog §VII)*. Same element as D/security-trio (E44 for IFC only) |
| Custody redundancy + datum-policy | P5,P3 | Redundancy (copies agree, divergence detect) + per-datum policy | Only secret slice seeded | BUILD | M | E56 | **E56** *(assigned 2026-07-21, catalog §VII)*. redundancy = instance of split-provider. Same element as D/custody-redundancy |
| Adhikara: capability protocol over wire | P3 | Adhikara maps exactly to capability-type discipline, distribution native | Docs-only; **edge 7 resolved-in-direction 2026-07-22** (residue: E61 authority-style choice + wire lowering) | DECISION | M | E61 | **E61** *(assigned 2026-07-21, catalog §VII; row text predates)*. Edge 7 direction landed 2026-07-22; couples E40 |
| cheri-floor: types into silicon | P3,P5 | Metal level on CHERI hardware enforcing B mark at bottom | Docs-only, hardware-dependent | BUILD | L | E63 | **E63** *(assigned 2026-07-21, catalog §VII)*. Requires CHERI hw; out of scope for CPU/RAM-only sandbox |
| bootstrap-floor: cross-checked runtimes | P5,P1 | Unverifiable base as cross-checked set of tuned runtimes (agreement over residue) | Direction only; **internals open (edge 11)**: count/independence/relation to supervisor | DECISION | L | E62 | **E62** *(assigned 2026-07-21, catalog §VII; row text predates)*. Edge 11 independence (shared-compiler residuals may void agreement) is real; answered in direction by split-role |
| ELF / AOT executable format | P1 | AOT ELF / SysV gABI output instead of JIT-in-mmap | Not built; current path is W^X JIT-in-mmap | BUILD | L | E34 | SPEC-class (conform to ELF gABI); orthogonal to the built JIT loader |

### Flow engine + chatter additions (2026-08-17, manas-layer — NOT E# self-implement rows)

> These are **manas-application-layer** additions (the L0 skill-grower Flow engine +
> the general chatter), not language self-implementation elements, so they carry no
> `Principle`/`E#` — the row schema above is keyed to the E1–E68 self-host catalog.
> They ride the orchestration substrate (E64–E67, slice F). Authority for the
> narrative + build order: `.planning/MANAS-SKILL-GROWER.md` (Flow engine + refinement
> pass) and `.planning/CHATTER-STATE.md` (chatter C1–C4 + remaining C5/C6). Build-state
> of each below is **BUILT + tested** (deterministic mesh-free via evidence-sift-refined),
> logged here so the map stays the single build-state index.

| Addition | Home file | Build-state | Commit | Notes |
|---|---|---|---|---|
| `flow-pure` + `PureFn` closed sum (`pf-has-any`/`pf-tally`/`pf-all-present`/`pf-line-after`/`pf-split-numbered`) | `scaffold/lib/manas/core/flow.chiral` | BUILT + tested | `8060a3a`/`803d986`/`7fa4bec`/`dd754ee` | A deterministic code Flow step (no backend). `PureFn` is a VALUE (closed sum), so the SG1 JSON codec (`flow-persist.chiral`) stays total. Threads the linear Backend untouched, synthesizes one green ExpertCall so 1+2N+2 holds. The "model extracts, code decides" refinement pass |
| `flow-branch-pure` (pure perspectivist) | `scaffold/lib/manas/core/flow.chiral` | BUILT + tested | `dd754ee` | A branch whose perspectivist is `pf-split-numbered` (deterministic list split), not a model; otherwise identical to `flow-branch` (per-perspective recursion + backtrack). Makes `evidence-sift-refined` end-to-end model-free + deterministic (evidence=2/speculation=2, verified span-by-span). The model `flow-branch` stays for unstructured prose |
| Robust `parse-perspectives` (field recovery, junk skip) + str-sub segfault fix | `scaffold/lib/manas/core/flow.chiral` | BUILT + tested | `595cb96`/`a04c054` | On JSON-parse failure recovers each object's target/body (`next-field`/`recover-key`), skips structural lines, then a clean-line fallback. `item-ish?` (must contain a space) filters recovered field-enum junk. Fixed a real segfault: `str-sub` is `(START, END)` exclusive, not `(START, LEN)` — a length-as-END with START>value read out-of-bounds |
| `refine-ok` sharpening (structured Ty seam) | `scaffold/lib/manas/core/flow.chiral` | BUILT + tested | `a04c054` | `ty-verdict`/`ty-part` now require JSON-ish output (`[`/`{`/`kind`) so a mistyped `flow-pure` producing free prose refine-FAILS at the runtime seam, not only statically. Opaque text types (ty-doc/ty-text/ty-span) stay non-empty |
| Gate-hole fix — `manifest-all-green?` zero-calls = NON-green | `scaffold/lib/manas/core/flow.chiral` | BUILT + tested | `22509a7` | `routing-error?` now covers the full structural-failure vocabulary AND a ZERO-CALL manifest is non-green (nothing ran ≠ green), catching a masked case where a non-numbered doc produced 0 verdicts yet read GREEN. Aligns the top-level gate with `perspective-failed?` |
| Skill registry (routed/enumerable Flow library) | `scaffold/lib/manas/profile/skills.chiral` | BUILT + tested | `7838921` | `all-skills` (`SkillEntry` = name+Flow+Config+pool+sample), `skill-by-name`, `all-skill-configs`. The surface that lets scriba enumerate/view/run the 6 skills and the chatter route to them |
| Chatter C1–C4 (pure router + turn loop + verbalize + `:ask`) | `scaffold/lib/manas/chatter/{router,turn}.chiral`, `TUI/scriba/command-loop.chiral` | BUILT + tested | `c68332f`/`d9b3629`/`62e7ebe`/`8cc6c1a` | See `.planning/CHATTER-STATE.md`. General chatter, no general mode: every message classified + routed to a named pipeline, in code |

---

## Categorical checklists

### REFACTOR — ordered by blast radius (the refactor pass must respect these)

- [ ] **E38 graded/cost coeffect semiring** — kernel.py qadd/qmul/qjoin/qfits + usage-vector ops (uadd/uscale/ujoin) + terms.py q slot + surface.py QUANTS + effects.py q!=1/q!=0 comparisons reshape from 3-point lattice to a parameterized product semiring; **judgment seams (conv/infer/check) stay put — the containment win the settled decision promises** — L
- [ ] **E39 effect algebra / typed rows** — conv keeps effect-equality, row subsumption lands in subtype (kernel.py:315) *(E39-SPEC correction 2026-07-22)*, effects.py on_apply/erased_allow boolean→set-containment, allow_eff threading bool→row across infer/check, surface.py:372 per-arrow effect attachment, terms.py:33 Pi position-2 field type, prim_is_port derivation; gates E26 — edge 16 resolved 2026-07-21 (`docs/decision-effect-facets.md`) — L
- [~] **E51 sys-face linkage** — **v1 slice built 2026-07-30**: the `sysbind` dispatch seam + put/print/trace through sys-tal (byte-identical, 328 green), extern→sys-tal binding table (chirality data), bridge.verify re-seated; **the real self-host gate**, seam now exists. Remaining: lane-A crossings (floor-built result sums) + full impl_ports retirement — edge 16 resolved 2026-07-21 (`docs/decision-effect-facets.md`) — L
- [ ] **E9 refinement full-predicate procedure** — refine.py constraint tuple (lo,hi,excluded,sym) + every function over it (_atom/_sym_atom/build/satisfies/is_empty/entails/_eval_refine) swap to octagon/solver-backed facts; base gate + operand parser widen past I64/bare-var; **kernel.py untouched (value-form seams isolate)** — L
- [ ] **E41/E22 region types (mem-region lib)** — Region data gains a refined/indexed cursor, mem-alloc's runtime `(<=i (+ used len) cap)` branch becomes a type-level proof obligation, mem-write/mem-stow/region-avail offsets become `(refine I64 …)`; **gated on E9 arithmetic-expression bounds (edge 3; bare-var symbolic landed 2026-07-06)** — M
- [~] **E20 W^X loader self-host** — memory fully chirality-side 2026-07-29 (mmap allocation + mprotect seal both via crossings; Python mmap/ctypes-mprotect gone); sole remainder = TalFn→CFUNCTYPE entry, moves with E23/E34 — M

### EXTEND — payload into an existing slot

- [x] **E28 self-hosted syscall floor** — mprotect + close landed 2026-07-28 (same sysface tfn + ti-sys pattern; sockets/poll/spawn are their own elements E29/E31/E33) — M
- [ ] **E11 totality enforce-by-default** — flip `require_total` default to ON — **gated on E47 + E50** proving lexicographic/mutual/non-unit-symbolic measures first (else regresses real code) — M
- [ ] **E9 variable-bound / arithmetic refinements** — add inter-variable arithmetic atoms (v<n+1) into the existing `entails` slot; enables E41 typing (this is the additive tier of E9; the full-solver swap is the REFACTOR row) — M
- [x] **E50 mutual / lexicographic termination** — landed 2026-07-28 (declared shared measure, cheap tier + lexicographic; size-change graph deferred) — M
- [ ] **E27 collections** — core LANDED 2026-07-28 (ordered Map/Set, deterministic fold); remaining: migrate the checker's CPython dict Sig registries onto it (rides the port arc with D-1's tyv-cmp) — M
- [ ] **E64 JSON surrogate pairing** *(assigned 2026-07-21, catalog §VIII)* — add \u surrogate pairing into the existing parser once a bitwise floor prim lands — M
- [ ] **E67 Coordinator cycle** *(assigned 2026-07-21, catalog §VIII)* — slot router (N2) / log-step (N3) / streaming-into-cycle / persistence-retry into the existing named seams of run-cycle — M

### BUILD — forward construction

- [ ] **E42 runtime supervisor** — critical sections, register-root custody, scheduler; a separate artifact from the evaluator (seL4-shaped) — L
- [ ] **E23 FFI/ELF native entry** — ELF/object emitter + real process entry point; ctypes call-gate + Python decode retire (coupled to E20) — L
- [ ] **E34 ELF / AOT executable format** — ELF / SysV gABI emitter (SPEC-class; orthogonal to the JIT loader) — L
- [ ] **E40 + E43 capability model + broker** — grant/attenuate/delegate + revocation (subtype mechanism present-but-unapplied may make grant-narrowing partial EXTEND); broker grant/revoke/audit — L
- [ ] **E44 security trio** — info-flow lattice + non-interference, taint tracking, constant-time wired to the built preserve-check — **taint E59 / const-time E60 assigned 2026-07-21** (IFC = E44) — L
- [ ] **E47 sized types** — size annotations in the termination checker (prereq for E11-by-default) — L
- [x] **E50 mutual/lexicographic termination** — cheap tier landed 2026-07-28 (E47 remains the other E11-flip prereq; full size-change graph deferred) — L
- [ ] **E45 reflective floor mechanism** — immutability boundary on Sig seams so running chirality cannot reconfigure the judgment core — **DECISION-gated (draw the A/B line, edge 5)** — L
- [ ] **E48 dependent records / telescopes** — Σ-types with field dependence in data.py — M
- [ ] **E49 real surface syntax** — concrete-syntax front-end feeding the existing elab() unchanged; supersedes sexp.py — L
- [ ] **E46 proof-presentation / auditor** — Isar-equivalent proof-presentation layer — L
- [ ] **E26 alarms as a typed effect** — chirality-level typed alarm + counter-effect handlers replacing Python exceptions — **hard-gated on E39** — M
- [ ] **E52 certificate verifier / kernel-core split** *(assigned 2026-07-21)* — split kernel.py into kernel-spec + kernel-core with a certificate verifier (LCF/de-Bruijn producer/consumer) — L
- [ ] **E54 split-provider / split-role** *(assigned 2026-07-21)* — guarded agreement over independent sources, per-axis tiers — gated edge 4 + edge 11 — L
- [ ] **E55 C-bridge evidence-half** *(assigned 2026-07-21)* — attestation/isolation/freshness/audit/reflect-raw as one bridge elaborator per element, each re-checking a cert via bridge-preserve-check — L
- [ ] **E56 custody redundancy + datum-policy + memory custody** *(assigned 2026-07-21)* — redundancy (copies-agree/divergence), per-datum flow policy, register-root/zeroize as type obligation — M/L
- [ ] **E57 staging / binding-time modality** *(assigned 2026-07-21)* — type-level representation of link/load-vs-runtime (Fork C) — M
- [ ] **E51 orchestration self-host linkage** *(assigned+drafted 2026-07-21)* — replace CPython transport with the self-hosted sys face (E51 forward-build half, gated on E28/E29/E31) — L
- [ ] **E58 reflect-typed** *(assigned 2026-07-21)* — staged metaprogramming over typed terms — depends on E45/edge 5 — L
- [ ] **E63 cheri-floor** *(assigned 2026-07-21)* — types carried into silicon on CHERI hardware (out of scope for the CPU/RAM-only sandbox) — L

### DECISION — author call owed before any code is right

- [ ] **Backend fork (E19)** — does the hand-emitted chirality x86-64 backend SUPERSEDE the LLVM/Cranelift decision (re-settle) or is it a stopgap TOWARD LLVM/Cranelift-as-library (reopen)? Large blast radius across the E19 lib if the latter. No E# maps the reconciliation itself (FABLE F7/C1 OPEN)
- [x] **Effect mechanism (E39 / edge 16)** — **RESOLVED 2026-07-21** (`docs/decision-effect-facets.md`): two facets (possession + exercise) joined by construction, graded continuations, synthesized cancel; unblocks the E39 refactor, E26 alarms, and E51 sys-face linkage
- [ ] **Broker decomposition (E43 / edge 8)** — the 4-part AUTH/AUDIT internal decomposition before broker internals build
- [ ] **Whole-assembly conformance (E44 / edge 18)** — which target properties are compositional/subtyping-checkable vs needing a dedicated global argument
- [ ] **Reflective floor line (E45 / edge 5)** — draw the exact A/B kernel line (what the trusted core will not certify) before reflect-raw/reflect-typed/the floor mechanism build
- [ ] **Adhikara correspondence (E61 / edge 7)** — resolved-in-direction 2026-07-22 (capability discipline lowered onto B; residue = E61 authority-style choice + wire lowering); couples E40 — E61 assigned 2026-07-21
- [ ] **bootstrap-floor internals (E62 / edge 11)** — how many runtimes, how independent, relation to the supervisor; shared-compiler residuals may void agreement-as-evidence — E62 assigned 2026-07-21

### CONFORMS — done, named so the map is complete

NbE eval/quote/conv (E3) · bidirectional infer/check + universes (E4) · QTT quantity semiring 0/1/w (E5) · QTT usage-vector linearity (E5) · data ctors/coverage/param-unification (E6) · strict positivity/variance (E7) · linear-kind decision (E8) · path-sensitivity/occurrence typing (E10) · term de-Bruijn machinery (E13) · pretty-printer (E14) · effect membrane pure/process (E12) · lowering connector + preserve-check (E16) · optimizer fold/DCE/specialize (E17) · TAL floor checker + interpreter (E18/E19) · x86-64 modular Mach (E19) · category-A pure host bindings + arithmetic laws (—) · byte cells + chirality byte/tal lib (E25) · lib/backend.chiral model-server seam (—) · category-C port membrane (E30–E33) · inbound bridge integrity-verification (—) · secret custody seed (E40) · reference interpreter/evaluator+linker (E15) · s-expression reader (E1) · surface elaborator (E2) · profiles + verify (E2) · CLI/entrypoint/staging connector (E2) · prelude A-floor (E5) · memory-linear discipline (E22) · HTTP + SSE streaming (—) · Wayland wire codec + niri IPC (E35/E36) · FSM engine (—) · manas profile (—)

---

## Worked-example queue

Pre-run ONE worked example per element (under `examples/`) BEFORE the refactor pass,
in this order — DECISION-gated items assume their author call lands first:

1. **E38** graded/cost coeffect semiring — the biggest reshape; establish the grade-tuple arithmetic pattern first
2. **E9** refinement — do both tiers in one blueprint: the EXTEND (inter-var arithmetic atoms) and the REFACTOR (solver-backed procedure); unblocks E41
3. **E47** sized types + **E50** mutual/lexicographic termination — the two prerequisites that must land before E11 enforcement
4. **E11** totality enforce-by-default — after E47/E50
5. **E28** self-hosted syscall floor (mprotect/close) — unblocks E20
6. **E20** W^X loader self-host
7. **E39** effect algebra / typed rows — *edge 16 resolved 2026-07-21 (`docs/decision-effect-facets.md`)*
8. **E51** sys-face linkage — *assigned+drafted 2026-07-21 (examples/E51-sys-linkage.md); edge 16 resolved 2026-07-21*
9. **E41/E22** region types — after E9
10. **E23** FFI/ELF native entry + **E34** ELF/AOT format
11. **E48** dependent records/telescopes
12. **E49** real surface syntax
13. **E26** alarms as typed effect — *after E39*
14. **E42** runtime supervisor
15. **E40/E43** capability model + broker — *broker blocked on edge-8*
16. **E44** security trio — *taint E59 / const-time E60 assigned 2026-07-21*
17. **E27** collections; **E46** proof-presentation

**E-number block CLEARED (2026-07-21 catalog extension, E51–E68):** E51
sys-face linkage / orchestration self-host (E51, drafted) · certificate verifier /
kernel-core split (E52) · split-provider/split-role (E54) · C-bridge evidence-half (E55) · custody
redundancy + datum-policy (E56) · staging/binding-time modality (E57) · reflect-typed (E58) · security
trio (taint E59, const-time E60, IFC=E44) · adhikara (E61) · bootstrap-floor (E62) · cheri-floor (E63) · the orchestration
substrate modules (json E64 / http E65 / fsm E66 / manas+coordinator E67 / backend E68).

---

## Cross-cutting risks

- **The graded-kernel/quantity story (E38) is the single reshape touching the most.** It rewrites the semiring arithmetic + usage-vector ops in kernel.py, the q slot in terms.py, QUANTS in surface.py, and the q-comparisons in effects.py simultaneously. The settled decision (option A) promises the judgment seams stay put — that containment claim is the thing the worked-example must actually prove before the refactor, because if it leaks into conv/infer/check the blast radius explodes across the whole kernel.
- **The effect-row reshape (E39) cannot be scoped by a single worked example alone** — its mechanism decision is made (edge 16, resolved 2026-07-21, `docs/decision-effect-facets.md`) and the decision ripples through conv equality, the membrane's boolean seams, surface's single-effectful-arrow rule, and the Pi field type together, while gating E26 alarms and the E51 self-host seam downstream.
- **E51 self-host is a three-way coupling** (runtime dispatch reshape + impl_ports retirement + E28/E29/E31 sys slices) and edge 16 is resolved (2026-07-21, `docs/decision-effect-facets.md`); it is the honest gate on "true chirality-in-chirality". **The seam now exists (v1 built 2026-07-30)**: the ambient writers cross through sys-tal with CPython out of the path; retirement of the remaining crossings (lane A, needing floor-built result sums) and of impl_ports is the outstanding half.
- **RETIRED (2026-07-21): the E-number gap is closed** — the same-day catalog extension assigned E51–E68 (E51 linkage/drafted, E52 certificate split, E54 split-provider, E55 C-bridge evidence, E56 custody, E57 staging, E58 reflect-typed, E59/E60 security trio beside E44, E61 adhikara, E62 bootstrap-floor, E63 cheri-floor, E64–E68 orchestration modules); the worked-example series can target every formerly-unnumbered element.
