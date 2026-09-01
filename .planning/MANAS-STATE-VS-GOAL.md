# manas — state vs. goal

> **Started 2026-08-15.** The map from what the chirality side of manas *is* today to
> what it must become: a gated Mixture-of-Experts orchestration engine, driven from
> scriba, where **every task is split into individual single-lens agents** — no
> monolithic one-chat-one-model-one-goal run. Catalog: `SELF-IMPLEMENT-CATALOG.md`
> §VIII-b (E133–E143). Design of record: `/workspace/manas/.planning/METIS-PORT-SPEC.md`.
> Library of record: `/workspace/manas/orchestration/{SCHEMA,agents,processes,configs}.md`.
>
> **⚑ ARC COMPLETE (2026-08-16) — product + all cleanups done.**
> **Product:** A (live orchestration run + golden conformance) + B (scriba cockpit
> S14 author · S15 run-view · S16 compose · S17 token-streaming) — all live-verified.
> **Cleanups (§8.C–E):** **C** = E145 (`be-peek` crossing) → E137 (Backend is a linear
> `porttype`, threaded end-to-end, `CONFORM: true` live) ✅; **D** = E100 (poly-HO
> defunctionalization — type-kinded captures erased; the `foldl` workaround dropped,
> `map-list` live again, verified end-to-end) ✅; **E** = be-log persists LIVE to the
> running worker (`:8080`, `SELECT`-verified rows) ✅. **B1 compile-perf lane CLOSED**
> — no problem (scriba compiles ~0.36s; the "minutes" was sandbox thrash; see
> `.planning/B1-COMPILE-PERF.md`). **Training-corpus text — RESOLVED 2026-08-16 (option a):**
> the worker's LEARN-01 `prompt`/`raw_response` now carry the ACTUAL SEES prompt + model
> response (not empty digests). A new `RawCall` type sources the raw text from the live run
> and is threaded out beside the manifest (`FanR`/`RunR`/`GRunR` gain a plain `raws` field);
> be-log zips it with the digest-only `ExpertCall`s. The manifest/`ExpertCall` STAYS
> digest-only by design, so E141 golden conformance is untouched. See §8.E + the E139 catalog
> row. Compiles are FAST
> (~0.36–1s); the real hazard is fd exhaustion from STACKED heavy ops — run ONE at a time.
>
> **⚑ STATUS (2026-08-16) — Step A DONE; NOT fully complete.** The engine now
> **runs one real orchestration end-to-end** against a live model (§8.A closed): a
> `guarded-run` under the `smoke-local` profile routed → gated (6 experts fired) →
> bound each to `qwen2.5:0.5b` → made 7 real mesh calls (100.64.0.5:11434) → combined
> → emitted a typed `RunManifest` + yield, exit 0 in ~9s — and that run **conforms to a
> frozen golden** via the real E141 oracle (`manifest-from-json` → `manifest-conforms`,
> `CONFORM: true`). So it is a **working first-cut orchestrator**, not a skeleton. What
> **Steps A + B are now BOTH DONE (2026-08-16).** The scriba manas cockpit is complete:
> author a typed config (S14) → compose a pipeline + bind a config under a pure E135
> pre-flight (S16) → fire and watch the typed `RunManifest` render inline with the GATE
> decision pre-network (S15), all over the live engine. That is the product goal (§8.B).
> "Full completion = A + B" is **reached**; **S17 (token-streaming run-view) is now
> also DONE (2026-08-16, `13b8a4f`→`9b32ec7`→`69236ce`)** — the run-view streams
> token-by-token, experts and combiner both. What remains is cleanup/polish only:
> **C** (E145→E137 linear Backend), ~~**D** (E100 map-list)~~ **DONE 2026-08-16**, ~~**E** (be-log endpoint)~~ **DONE 2026-08-16 — LIVE persistence**.
> **Pick up at §8.C** (compiler hardening — the last cleanup on the product path).

## 1. The goal (one sentence + the law)

Talk to an orchestrator; it **matches** a request to a process (or composes one),
**gates** which narrow agents fire, **binds** each to a model via a config profile,
**runs** the pipeline (fan-out → combine) under a stop policy with nothing skipped,
and **yields** a typed result + a run manifest — all in chirality, over local/mesh
models, driven and observed inside scriba.

The law is the schema's recursion:

```
PROCESS  (ordered, gated STAGES — no skip, no reorder)
  └ STAGE     (a PIPELINE that moves the artifact one state, gated)
     └ PIPELINE  (GATE → AGENTS → COMBINER, under a STOP policy)
        └ AGENT   (the atom: LENS · SEES · RETURNS · SLOT · TOOLS)
```

**The operating principle (the user's directive, 2026-08-15):** *no more one chat to
one AI for one goal — everything is split into its individuals.* Mechanically:

| Monolith (what we must NOT do) | Split-into-individuals (the engine) | Home |
|---|---|---|
| one prompt to one model | GATE picks the **set** of narrow agents that fire (sparse) | E134 |
| one model does everything | each agent is **one lens**, bound to a SLOT→model by config | E135 |
| answer in one shot | fan-out N agents (parallel/chain/branch), then a COMBINER reconciles | E138 |
| trust the single answer | adversarial **refute-claim (Nx)** kills plausible-but-wrong findings | E138 (agent pool) |
| one model, one machine | a config profile **mixes backends** per slot (0.5B verifier + 8B reasoner + coder combiner) | E135 + E140 |
| "it worked" | golden run-manifest conformance — two independent truths compared | E141 |

## 2. What is BUILT (the substrate — verified in-tree 2026-08-15)

The engine is an ordinary chirality **program** over primitives that already exist. The
substrate needs **nothing new** (research verdict, grounded, not the spec's say-so):

- **Pure core deps:** `collections` (map/filter/foldl/find/alist-\*/str-join + AVL
  `Map` E27), `prelude` (`str-eq`/`str-find`/`str-cat`), `cond` (`surface.chiral`).
- **Effectful deps:** `backend` seam (`be-chat`/`be-chat-stream`/`be-health`/
  `be-models`/`be-embed`/`be-search`), `http` + **native sockets** (E129 AF_INET,
  E130 HTTP/1.1, E131 SSE — zero CPython in the model path), `json`, `fsm` (`Step`),
  `manas.chiral` breaker (`cycle-step`/`run-batch`), `coordinator` (reference cycle).
- **Discipline deps:** `ports` (linear `porttype`, `Pool n` size-in-type refinement,
  `halt`/Exit), `effects` (`row-sub`/`row-join`, QTT quantities, E39).
- **Agent tools already native:** `read`/`write`/`edit`/`bash` (`agent/tools-fs.chiral`
  + `nb-run-cmd`) — if experts ever execute tools rather than read pre-assembled SEES.
- **The one B1 blocker is cleared:** 2-type-param lowering (E100, follow-up literally
  "unblocks the orch stack") — so `alist`/`map-list`-heavy pure core compiles.

**Also built (the single-agent line, done + verified vs ollama):** the Pi-minimal
tool-call loop (`agent/agent.chiral`) — but this is exactly the monolith the directive
retires: one model, one hardcoded tool set, one goal. It becomes *one agent* in the
pool, not the engine.

## 3. What is NOT built (the delta — the engine = E133–E143)

Nothing in chirality reads `agents/processes/configs`, runs a gated multi-agent pipeline,
binds slots to models, or fans out to individuals. That whole layer is the delta:

| Wave | Elements | What it lands | Chirality debt |
|---|---|---|---|
| 1 | **E133** | the pure data model (13 types; failures are variants) | none — pure `data` |
| 2 | **E134** GATE/router · **E135** config-bind · **E136** match/assemble/stop | the pure `->` core — split, backends, composition, stop; unit-testable with no backend | none |
| — | **E137** | Backend `data`→linear `porttype` (REFACTOR; ripples coordinator/manas) | a refactor, not a new capability |
| 3–4 | **E138** run loop (N1) · **E139** `be-log` (N3) | GATE→fan-out→COMBINER under STOP + breaker; the run record crossing | **E139 = the only new seam op** (deferrable; worker endpoint = manas lane) |
| 5 | **E140** | the 4 config profiles + `doc-refine` pipeline as **typed values** | none — pure data |
| 6–7 | **E141** | golden-manifest deserialize + conformance test oracle | none — over `json` |
| defer | **E142** zone tokens · **E143** dependent config-coverage | compile-time upgrades of E135's honest sum-type first cuts | gated on refinement reach |

**Critical path to a first split-into-individuals run:** E133 → E134 → E135 → E136
(pure core, no network — fully testable alone) → E138 (+E139 stubbed to local write)
→ E140 (`smoke-local` profile, every slot on the one resident model) → run the
`doc-refine` process on a real doc → E141 (assert it conforms to a golden manifest).
E137 hardens the handle in parallel; E142/E143 are later.

## 4. "Add backends and test em" — the two explicit threads

- **Add backends** = E135 (slot→model binding, the swappable seam) + E140 (the config
  profiles as typed values). A backend is a `Backend(base)` × a `Config` binding each
  SLOT to a `(model, num_ctx)`. The **same pipeline runs under any profile** — that IS
  the mixing. First target profiles: `smoke-local` (guaranteed-runnable, all on
  `qwen2.5:0.5b`), then `cheap-local`, `quality-local`. Each new backend endpoint is a
  new `Backend` value; each new model mix is a new `Config`.
- **Test em** = E141 (golden-manifest conformance) is the primary gate — every golden
  run in `orchestrator/golden/` is a test case the chirality pipeline must reproduce
  structurally. Below it: E136's pure core is unit-testable with **no backend at all**
  (GATE decisions, bindings, match, overflow, stop are pure `->` functions); E140's
  `smoke-local` proves the live end-to-end path against a single resident model.

## 5. Where scriba fits (the cockpit — after the engine exists)

Scriba's manas mode is read-only syntax coloring today (Tier 1). Once E133–E141 give
the engine **typed values** to manipulate, scriba becomes the authoring + run cockpit:
edit the agent/pipeline/process/config library as structured data, compose a pipeline
(pick agents, set GATE/ORDER/COMBINER/STOP), pick a config (bind backends), fire a
process, and watch the run-manifest stream inline (request → pipeline_choice → gate →
per-agent calls → combiner → yield). Scriba can't configure pipelines until the
engine gives it pipelines to configure — so the engine (this doc) is the gate, and
the scriba cockpit is the slices after it. Cataloged in `SCRIBA-SLICES.md` as three
split slices (not one monolithic mode): **S14** manas author mode (structured
config/pipeline editing, gate E133+E140), **S15** manas run-view (the run-manifest
cockpit / Tier 2, gate E138+E141), **S16** manas compose (pick pipeline + bind
backend + run, gate S14+S15+E134+E135). Slice 12's Tier-1 colorer is the seed.

## 6. Open questions (from METIS-PORT-SPEC §12, still live)

1. **Markdown loader** — leaning: DON'T port it (no regex crossing); keep `.md` as
   human docs, `.chiral` typed copies, golden manifests as the sync check.
2. **Config coverage** — first cut `BindResult` sum (E135); target dependent type (E143).
3. **Backend porttype** (E137) — worth it, ripples coordinator/manas callers.
4. **Zone tokens** (E142) — `PreflightResult` sum first (E135), token upgrade later.
5. **Streaming** — no new types; the `(=> Str Unit)` on-delta threads through as today.
6. **File home** — `scaffold/lib/manas/` inside chirality; import `manas/core/gate`.

## 6b. Compiler FLAGs surfaced during the build (for the "then debug" pass)

- **`map-list` does not lower in an isolated/leaf blob (E100) — RESOLVED 2026-08-16.**
  Root cause was poly-HO defunctionalization **erasing type-kinded captures**: a captured
  type variable (q0 / `Type`-valued) has no runtime witness but was word-ified into a
  `$clo` ctor field → `t-type` field → `term->ntalty`=none → `$clo` data dropped →
  `$apply` vanished → map-list pruned → "no emitted label". Fixed by DROPPING type-kinded
  captures across `closconv.chiral`/`closconv-driver.chiral` (one `field-erased?` predicate
  at every materialization point + the `$apply` arm de-Bruijn re-addressing re-derived for
  the reduced capture count), plus the `lower-defs` `le-skip` blame-chain fix. Verified by
  the runtime gate `scaffold/tests/samples/e100_poly_ho.chiral` (5 cases, exit 0); fixpoint
  holds at gen3. The `foldl`/`append` workaround in the manas core + `backend.chiral`'s
  `chat-body` has been dropped back to `map-list`; manas-run-conform is `CONFORM: true`
  live. Only pre-existing, orthogonal residue: capturing an HO *function* into a
  partial-app closure (nested defunctionalization) still fails identically on the old
  compiler — not part of E100.

## 7. Build progress (live — updated 2026-08-15)

Cadence: one full-element agent per element (example → audit → spec → audit → implement
→ B1-verify + a real behavioral test), then independent reproduce → commit, strictly
serial. Order reordered after the pure core: **E140 before E138** (typed values unblock
the runner + give a network-free integration test); **E137 last** (a risky refactor of
built code, off the critical path, cleanest once the runner exists).

| E# | element | status | evidence |
|----|---------|--------|----------|
| E133 | core types | ✅ committed `fe6194a` | 16 pure `data`, golden-matched, B1 exit 0 |
| E134 | GATE / router | ✅ committed `c6d1510` | pure `->`, sparse fire + `gate-no-match`, test exit 0 |
| E135 | config-bind | ✅ committed `feea861` | swappable-backend proven (smoke-local vs cheap-local) |
| E136 | match/assemble/stop | ✅ committed `302116b` | pure core complete; match/overflow/stop tests exit 0 |
| E140 | profiles + doc-refine | ✅ committed `dd94863` | **library is typed chirality**; real data through gate→bind→match |
| E138 | run loop (N1) | ✅ committed | pure spine test exit 0 + effectful runner B1-lowers; live fan-out run deferred to integration |
| E141 | golden conformance | ✅ committed | reads the real goldens, structural compare, exit 0 + discrimination checks |
| E144 | non-word (Str) porttype carrier | ✅ committed | `porttype-str?`→`nt-str` in `term->ntalty` + tal-erase `nb-id` peels; self-host fixpoint holds. Delivers the CARRIER but is **not sufficient** for E137 (below) |
| E137 | Backend porttype | ⛔ blocked on **E145** | two attempts: E144 fixed the carrier; then (2026-08-16) linear `(1 b Backend)` threading fails `linear binder usage mismatch` — the `nb-id`-peeled base used in a `qw` op QTT-scales the `q1` handle to `qw`. Needs the struct-returning laundering crossing E145 (`be-peek → BePeekR`, `sock-recv`-shaped). Deferred; engine runs on plain-data Backend meanwhile |
| E145 | be-peek laundering crossing | ⏸ prerequisite (new) | `sock-recv`-shaped `ti-cona` struct-return so a linear str-porttype can be used+threaded without `qw`-scaling; gates E137. Compiler-floor + fixpoint |
| E139 | be-log (N3) | ✅ committed — **LIVE + real corpus** | LOG-01 + LEARN-01 fan-out persist to the running worker (`:8080`); LEARN-01 `prompt`/`raw_response` carry the REAL SEES prompt + model response via `RawCall` threaded from the run (manifest stays digest-only, E141 intact); verified LIVE via SELECT-back (1 interactions + 6 expert_calls rows, 0 empty text) against identical worker code |

## 8. Honest status + the checklist to FULL completion (pickup point)

**Do not call this complete.** What is TRUE: 8 elements (E133–E136, E138–E141, E140) are
committed, each **B1-compiles** and its **pure logic / structural conformance is
unit-tested** (network-free). What is NOT true: this is a working orchestrator. It is a
**compile-verified, unit-tested skeleton** — the pure decision core runs over real
library data, but **the engine has never executed one real orchestration.** Specifically
NOT done / NOT proven:

- ✅ **The engine now runs against a live model (2026-08-16).** `scaffold/samples/manas-run.chiral`
  drives `guarded-run`/`smoke-local`/`doc-refine` against 100.64.0.5:11434 — 6 experts fanned
  out + curate-merge combiner = 7 real `qwen2.5:0.5b` calls, exit 0 in ~9s, real yield.
  `scaffold/samples/manas-run-conform.chiral` re-runs it live and asserts the manifest
  conforms to `scaffold/tests/golden/manas-smoke-doc-refine.golden.json` via E141
  (`CONFORM: true`). The load-bearing gap is CLOSED — this is the first real orchestration.
- ❌ **Scriba cockpit (S14–S16) — the actual product goal — is not started.** The whole
  point was scriba driving manas; today scriba only color-codes the `.md` docs (Tier 1).
- ❌ **E137 (linear Backend) not landed** — needs E145 (compiler crossing) → E137.
- ✅ **`parse-findings` — structured findings landed (2026-08-16).** `runner.chiral`'s
  `parse-findings : (-> Str (List Finding))` now appends a fixed "return ONLY a JSON array
  of {kind,target,body}" instruction to the prompt, `json-parse-str`s the response, and maps
  each `j-obj` to a `Finding` (missing field → `""`). Any non-conforming response (parse
  failure / not a `j-arr` / empty array) falls back to the one `(finding "raw" "" t)` raw
  finding — never regresses or crashes (a 0.5b model hits this often; the CODE PATH is the
  deliverable). `parsed_ok` is untouched (still TRUE on `chat-ok` — it means "be-chat
  succeeded", and the breaker trips on a false one). Proven by
  `scaffold/tests/samples/manas_parse_findings.chiral` (canned JSON → 2 findings; `"not json"`
  → 1 raw finding; exit 0, network-free) and by the golden conform still passing (`CONFORM:
  true` — findings are NOT a conformance field). Commit: **structured parse-findings** (this
  commit; `runner.chiral` + `manas_parse_findings.chiral` + this §8).
- ⚠️ **`stop-until-dry` multi-pass — OPEN author-decision (NOT a trim, unscoped).** Driving
  the loop-until-dry policy makes `expert_calls` count **model-dependent** (it stops when
  findings stop changing), which conflicts with the E141 oracle's deterministic-structure
  assumption. Needs an author call before it can be built: **does the golden pin the
  pass-count, or does `manifest-conforms` ignore call-count?** Left unscoped — no element
  minted until that decision lands.
- ✅ **Streaming (`be-chat-stream` / `on-delta`) — DONE via S17 (2026-08-16).** An
  `on-delta` callback is only observable once scriba displays the stream; it needs no new
  types. S15's first cut rendered PER-EXPERT incrementally (each `be-chat` returns → repaint
  that row); S17 upgraded it to TRUE token-by-token streaming — `call-expert-stream`/
  `call-combiner-stream` twins in `runner.chiral` thread the `(=> Str Unit)` on-delta through
  `fan-render`/`runview-drive` with `(lam (d) (put d))`, painting tokens transiently (no
  stored text; the authoritative text arrives in the returned `ChatR`), an `rv-streaming`
  marker drives the open `>>` row, and the settle repaint reconciles to S15's typed row.
  Shipped `13b8a4f`→`9b32ec7`→`69236ce`; PTY-smoke-verified against the live mesh.
- ⚠️ **Retrieval (`be-search` / RAG) — needs-scoping (no element minted).** A real feature
  requiring a corpus + index; `assemble-prompt`'s context arg stays `nil` until it exists.
  Mint a catalog element when it is actually pursued (per CLAUDE.md's deferral rule — no
  unminted `E#` named here).
- ⚠️ **Compiler workaround live**: the `map-list` → `foldl` substitution — already cataloged
  as **E100** (the `$apply` residual) = pickup item **D** below. Left as-is.

### Remaining work, ordered (a fresh session can pick up here)

**A. Live-model integration run — ✅ DONE (2026-08-16). THE gate — passed.**
`scaffold/samples/manas-run.chiral` calls `guarded-run` with `smoke-local` + `doc-refine`
against the mesh (`100.64.0.5:11434`) on a real doc, prints the `RunManifest`
(`manifest-to-json`+`json-show`); `scaffold/samples/manas-run-conform.chiral` re-runs it
live and asserts conformance to `scaffold/tests/golden/manas-smoke-doc-refine.golden.json`
via E141 `manifest-conforms` (`CONFORM: true`, exit 0). Build recipe (chirality_blob closure +
`tal-ir` + the 5 linkage libs + the sample; B1 ~seconds since no agent tree) is in each
sample's header. Trims below (single-pass, no retrieval) held up
fine for the first run and are the honest next-cut work, NOT blockers.
`parse-findings` is no longer a trim — structured findings + raw fallback landed 2026-08-16
(see §8 above).

**B. Scriba cockpit — S14 → S15 → S16 → S17 — ✅ DONE (2026-08-16).** Each shipped via the full
pipeline (example→audit→spec→audit→implement), serial. **S14** manas author mode
(`908ba01`→`dbcfd83`) — edit a typed `Config`/`Pipeline`, an invalid edit un-representable;
**S15** run-view (`233d441`→`6f43601`) — fire a pipeline, render the `RunManifest` inline,
GATE decision proven pre-network (live PTY t~1.06s < first outcome t~1.37s); **S16** compose
(`c14276b`→`83d187f`) — pick pipeline + bind config, pure E135 `bind-config` pre-flight gates
the effectful fire (`bind-miss` seen before any model runs), then hand off to the run-view.
**S17** token-streaming (`13b8a4f`→`9b32ec7`→`69236ce`) — upgrades S15's per-expert
incremental render to TRUE token-by-token: additive `call-expert-stream`/`call-combiner-stream`
twins over `be-chat-stream`, an `rv-streaming` marker + open `>>` row, tokens `put` inline
then settled to S15's typed row (manifest byte-identical). Each: unit test exit 0 + `bin/scriba`
builds clean + live PTY smoke. **The product exists — and it streams.**

**C. E145 → E137 — linear-Backend hardening** (compiler-feature chain). E144 carrier is
committed; build E145 (`be-peek → BePeekR` laundering crossing, `sock-recv`-shaped
`ti-cona` struct-return; compiler-floor + fixpoint), then the E137 refactor
(backend.chiral porttype + thread every `be-*` caller). Pure hardening — sequence after A/B
or in a dedicated compiler session.

**D. E100 `$apply` residual** — the `map-list` leaf-blob non-lowering (§6b); fixing it
drops the `foldl` workaround across the manas core + `backend.chiral`. Compiler cleanup.

**E. be-log live endpoint** — ✅ **DONE 2026-08-16.** The manas worker is UP (`:8080`,
distinct from the model `:11434`); `/internal/log` (LOG-01) + `/internal/log/expert`
(LEARN-01) both persist. be-log was rewired from the mis-wired linear-model-Backend POST
to a plain worker-base `Str` sink (fire-and-forget: no single-flight invariant), with pure
LOG-01/LEARN-01 serializers (`contract/manifest.chiral`) mapping the `RunManifest` onto the
worker's `interactions`/`expert_calls` columns, and the deferred per-call fan-out now fired.
Verified LIVE via `samples/manas-run-log.chiral` + SELECT-back against a local instance of
the identical worker (1 interactions row + 6 expert_calls rows, fields correct).
**REAL CORPUS TEXT — RESOLVED 2026-08-16 (option a):** the worker's LEARN-01
`prompt`/`raw_response` now carry the ACTUAL SEES prompt + model response, not empty
digests. Source: a new `RawCall` type (`core/types.chiral`: `eid/slot/model/prompt/response`)
captured in the run loop (`runner.chiral` `call-expert` — `prompt = assemble-prompt`'s output,
`response = t`, or the error body on a chat-bad) and threaded as a plain `(List RawCall)`
through `fan-experts → run-pipeline → guarded-run` (a new `raws` field on `FanR`/`RunR`/`GRunR`,
beside — never inside — the linear `Backend`). be-log now takes the `(List RawCall)` and zips
it with the manifest's `ExpertCall`s (parsed_ok/accepted/duration from the digest record,
prompt/raw_response from the raw record). The manifest/`ExpertCall` STAYS digest-only —
`manifest-to-json`/`from-json`/`conforms` untouched, so E141 golden conformance is intact
(round-trip test still exit 0; `manas-run-conform` still `CONFORM: true` live). SELECT-back
confirmed all 6 LEARN-01 rows have non-empty real prompt + response (0 empties).

**"Full completion" = A + B done, C + D + E cleaned up.** ✅✅ **A + B both pass** — a real
doc-refine run executes end-to-end against a live model and conforms to a golden (A), and
scriba can author, compose, fire, and watch it inline (B). The product goal is REACHED. What
remains is cleanup/polish, none of it on the product path: **C** (Backend linearly
disciplined — E145→E137), **D** (compiler `map-list`/`$apply` workaround gone — E100). **E**
(be-log worker endpoint so runs persist) is ✅ **DONE 2026-08-16 — runs now persist LIVE.**
**S17 (token-streaming run-view) is DONE
(2026-08-16).** The engine is **proven end-to-end and driven from the cockpit — streaming
token-by-token**, not merely first-cut.

### Commit trail (this arc)
`fe6194a` E133 · `c6d1510` E134 · `feea861` E135 · `302116b` E136 · `dd94863` E140 ·
`cf35261` E138 · `74607d1` E141 · `f379222` E139 · `e73a664` E144 · `478cb2d` E145-mint ·
**(A) live run + golden conformance** (this commit: `manas-run.chiral`,
`manas-run-conform.chiral`, `manas-smoke-doc-refine.golden.json`).
Not committed / not built: E137, E145, S14–S16, E100 fix.
