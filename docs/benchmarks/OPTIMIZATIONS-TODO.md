# OPTIMIZATIONS-TODO — the continuation contract

**CAMPAIGN CLOSED 2026-08-02 (author call).** Two days took the three
kernels from 4.4x/57x/24x behind gcc -O2 to ~1.4x on compute and 5–8x on
memory/branch (run 10, the closing verification: ratios reproduce as a
band; RESULTS tenth-run section). Work moves to self-hosting; this doc
stays as the RESUMPTION contract. The entry point on resumption is
rd-packed, whose certificate format is already RATIFIED
(`../docs/rd-packed-cert.md` — move-script certificate + forward-walk
checker; design done, zero code written). Everything below is the parked
menu, unchanged.

Written 2026-08-02 as a session handoff. Read with: `OPT-LEDGER.md` (what
landed + structural elements), `TRAIT-OPTS.md` (trait survey),
`RESULTS-2026-08-01.md` (nine measured runs), `../docs/reg-disciplines.md`
(the pluggable-backend design + three settled calls), `position-chart.html`
(the documented positioning figure).

## Where things stand (run 9, rd-param, quiet guest)

- vs gcc -O2: **arith 1.38× · bytesum 5.2× · states 6.7×** (from 4.4/56.6/24
  at run 1 — two days of work). Ratios only; absolutes don't travel.
- Honest spread: compute is the BEST kernel. On memory/branch work chirality is
  behind mature unchecked own-backend languages (OCaml/Go/MLton 1.5–3×) and
  ~tied with CakeML's 4–10× band. Say "1.4× on compute, 5–7× on
  memory/branch, trending down" — never just the 1.38×.
- Three register disciplines, one conformance gate (`test_regdisc.py`):
  rd-truthful / rd-cache / rd-param (`NativeBackend(discipline=…)`,
  `MET_RD=` on the bench). rd-param passed the same gate as the debug
  discipline — fast-in-tiny holds; still no default declared (call #1:
  decide only when a tier forces a cost).
- 390 tests green (the "393" in the rd-param commit message was a
  miscount — the tree at that commit already held exactly today's 390);
  every transform preserve-checked; DDC byte-identity green through the
  whole campaign; TCB grew by zero lines.

## Tier A — conventional passes still on the table

1. **rd-packed** (slot-retiring allocation) — the remaining ambient gap on
   all three kernels (bytesum's 5.2× is mostly slot traffic on the
   dependency chain; arith's flat residual is acc-in-rdx killed by mulhi
   each iteration). Per the tier rule (reg-disciplines call #2) it is NOT a
   trusted-emitter plugin: build it as the first certificate-shaped
   producer — untrusted allocator proposes placements, a small placement
   checker verifies. This doubles as the pilot for the whole
   checked-producer pattern.
2. **Cross-function inlining** — tal→tal pass in optimize.py; SSA renaming
   machinery exists (`_remap_block`); size caps like autospec.
3. **Loop-invariant motion** — needs loop identification at tal level
   (tail-call back-edges make loops explicit — the pattern `f` calling `f`
   in tail position IS the loop header).
4. **b-operand residency + operand-aware chunking** — peephole pattern B is
   pinned but DORMANT (b-reload sits mid-chunk behind the a-load; run 8).
   Real fix belongs to rd-packed territory.
5. **Instruction scheduling** — only after perf counters exist (blocked in
   ccbox; bare-metal run owed on host).
6. **jtb tuning** — jump-table threshold n≥4 measured within-noise at n=5
   (indirect-branch prediction; run 8); revisit with real dispatch-heavy
   workloads, not microkernels.
7. **Macro-benchmark** — json-parse / FSM workload so the landed trait tier
   (CSE, autospec, tables, comparison folding) gets measured on the terrain
   it was built for. Also: run CakeML/OCaml/Go on OUR kernels on the host
   to convert the position chart's hollow dots to solid.

## Tier B — the superoptimizer road (the realization of 2026-08-02)

chirality is purpose-built for this: the LCF/certificate shape (small trusted
checker, untrusted producers) means the search engine NEVER enters the TCB —
CompCert proves the transformer once and must be conservative; chirality checks
every artifact and can search recklessly. Theoretical ceiling: above gcc -O2
(Souper/STOKE beat -O3 on windows without chirality's carried facts). Three
missing pieces, all with reserved seats:

1. **Semantic equivalence oracle** — preserve-check proves TYPES, not
   meaning. Needed: SMT encoding of bounded straight-line tal windows
   (i64 ops → SMT-LIB; division is ALREADY Euclidean-for-SMT-LIB by the
   settled decision; `refine.py` is the solver-adjacent lineage). Bounded
   windows keep it decidable; differential floor backstops end-to-end.
2. **Cost model** — E38, the graded-cost kernel semiring
   (decision-graded-kernel: cost = kernel enrichment). The superoptimizer
   is its first customer: rank verified candidates. Fork A, seats reserved.
3. **Search driver + cache** — untrusted by construction (stochastic /
   enumerative / LLM-proposed rewrites all legal); verified winners land in
   the pregen/autospec cache as a deterministic pattern library (D-2 holds).
4. **Checked emission** (for full CompCert-parity on compiler trust) — the
   last trusted gap is tal→bytes (differentially validated today).
   Translation validation per artifact: checked encoding table or
   decode-and-compare; E19 encoding-oracle territory.

## Standing author decisions (open, never self-resolve)

- ~~rd-packed's certificate format~~ RESOLVED 2026-08-02: move-script
  certificate + forward-symbolic-walk checker
  (`../docs/rd-packed-cert.md`, ratified from dispositioned options).
- Unbounded auto-pregen policy = the staging modality (Fork C).
- `(regs …)` profile clause — when two profiles actually diverge.
- Default register discipline — only when a tier forces a cost (none has).
- Fact-carrying lowering (E9×E16): refinement/quantity facts surviving into
  tal — unlocks Euclidean-correction elision, bounds-free byte ops beyond
  constants, and T5 linear in-place reuse. The architectural prize; also
  strengthens the superoptimizer oracle.

## Discipline for the next session

One item at a time; every change lands with preserve-check + differential +
the regdisc gate + a dated RESULTS section; commit per verified unit
(narrow `git add` — a parallel spec-lane agent may share the tree); ratios
only, name the guest load (noop ns); negative results get recorded with
their mechanism, not shrugged at (runs 6 and 8 are the models).
