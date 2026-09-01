> **ARCHIVED 2026-09-01. Superseded by `docs/definitions/status-ledger.md` (build state) and `.planning/archive/HANDOFF-RUNG1-FIXPOINT.md` (the arc that closed it).** The cockpit shipped: it is `prog/scriba/` and `prog/manas/`. What this file proposed exists as code.

---
node: assessment
title: chirality self-hosting + manas cockpit — assessment & plan
audience: a fresh chat starting cold
written: 2026-07-13
---

# Assessment & Plan — chirality self-hosting + the manas cockpit

> Handoff doc. Written for a **new chat with zero prior context**. Read top to
> bottom; the Orientation and Current-State sections make the rest legible.

## 0. The ask (what this chat is for)

Build a **chirality-native model interface + Emacs cockpit**, and — if scope allows —
**bundle it with driving chirality to full self-hosting** (chirality-in-chirality, no Python
host). This doc judges whether the bundle is too much and lays out the plan.

## 1. Verdict (TL;DR)

1. **The model interface is ALREADY chirality and proven live.** `backend.chiral` +
   `manas.chiral` + `coordinator.chiral` + `http.chiral` (+SSE) + `json.chiral` +
   `ports.chiral` are real chirality and the thin loop ran **7/7 live against the
   worker**. The cockpit is a *small additive build*, not a from-scratch effort.
2. **Full self-hosting is large but it is a PORT, not research** — the entire
   chirality implementation already exists in Python (`scaffold/chirality/*.py`) as the
   reference, **~half the ~50 catalog elements already have worked-example
   blueprints**, and **codegen is already chirality** (E19). The hard-but-bounded
   parts are the checker (NbE/QTT/refinement) and the native path (loader/ELF).
3. **Bundling is feasible AND synergistic.** The cockpit is the natural
   *acceptance workload* for self-hosting: "does the cockpit still run?" is a
   crisp gate at every layer. **Recommendation: bundle, but sequence
   cockpit-first** — ship the cockpit on the scaffold (fast product win +
   acceptance harness), then self-host in dependency order, re-running the
   cockpit each layer, ending with the cockpit as a **native self-hosted-chirality
   binary with no Python**.
4. **Velocity note (load-bearing for scope):** the *entire* chirality scaffold —
   checker + compiler + runtime + the lib/*.chiral app layer — was built in
   **~2 days**. Estimate scope assuming heavy agent-orchestrated throughput, not
   solo-human pace. Ambitious is the right default here.

## 2. Orientation (cold-start)

**Repos / lanes**
- `/workspace/chirality` — the **chirality language** (self-hosting lives here).
- `/workspace/manas` — the **orchestration + worker** (what chirality talks to).
- `/workspace/shredtower-setup` — **host infra** (the GPU tower, podman/dinit).

**Live infrastructure (reachable from the sandbox over the headscale mesh —
internet egress is blocked, the mesh is not):**
- **manas-worker** `http://100.64.0.5:8080` — `/v1/chat/completions` (Ollama
  proxy), `/internal/embed|search|log|health`.
- **ollama** `http://100.64.0.5:11434` — `qwen3:8b` resident (Q4_K_M, 40k ctx).

**chirality layout**
- `scaffold/chirality/*.py` — the **Python host** (the "crutch" self-hosting replaces).
- `scaffold/lib/*.chiral` — the **chirality app + floor** (real chirality source).
- `scaffold/demo/`, `scaffold/tests/` — demos + the test suite.
- `.planning/SELF-IMPLEMENT-CATALOG.md` — **the self-host map** (E-numbered
  elements across 5 sections; the authoritative list).
- `examples/` — the **worked-example corpus** (one conventional-vs-chirality blueprint
  per element) + `INDEX.md` + `tools/pack/pack.py` + the `worked-example` skill.

## 3. Current state (built + proven)

### 3a. The chirality app layer = the model interface (DONE, proven live)
- `backend.chiral` — the OpenAI-compat seam: `be-chat / be-health / be-models /
  be-embed / be-search`, grounded in the real `manas-worker` router.
- `http.chiral` — the HTTP effect (`http-request`, process arrow `=>`) + **SSE
  streaming** (`ChatStream`, pull-based).
- `manas.chiral` — the MoE cycle (`gen-turn`, `run-batch`, breaker/fail-limit).
- `coordinator.chiral` — the **runnable** end-to-end loop:
  `(model,prompt) → retrieve+inject → chat-stream → ChatR`, streams via `put`.
- `ports.chiral` — a real **socket floor**: `sock-listen/accept/recv/send/close`,
  `poll2`, `spawn`, `env-get`, `time-mono`. Server *and* client primitives.
- **Proof:** chirality's thin loop ran **7/7 live** against `100.64.0.5:8080`.

### 3b. The chirality floor (partial)
- **Codegen already chirality** (E19): `emit-core / mach / mach-x64 / emit-x64 /
  asm-reloc`.
- `sys-tal.chiral` — syscall floor built: `write / read / lseek / memfd_create /
  ftruncate`.

### 3c. The Python crutch (what self-hosting replaces — `scaffold/chirality/*.py`)
- **Checker:** `sexp, surface, kernel, data, effects, refine, terms`.
- **Compiler/runtime:** `runtime, lower, optimize, tal, native`.
- **Floor crutches:** `impl_ports` (sockets / http-via-urllib / poll / spawn),
  `impl_pure` (i64 / bytes), `native` (mmap/mprotect ctypes loader).

### 3d. The self-host map
- `SELF-IMPLEMENT-CATALOG.md` — ~50 elements, 5 sections: checker stack, compiler
  pipeline, substrate floor, syscall layer, external formats. Each carries a
  reference class (OURS/SPEC/PAPER/IMPL).
- **25 elements already have worked-example blueprints** (`examples/`, status
  `drafted`). The rest: run `tools/pack/pack.py E<#> <slug>` (the `worked-example`
  skill) to blueprint, then implement.

### 3e. manas backend (the thing chirality talks to)
- Python **worker** (Phase 1) + Python **orchestrator** (Phase 2, MoE pipelines,
  `doc-refine`) — LIVE, proven. The `orchestrator/` Python driver is the
  **NORMATIVE** MoE implementation; chirality's `manas.chiral`/`coordinator.chiral`
  **conform to its golden run-manifests** (`CHIRALITY-CONTRACT.md`). Keep this
  conformance in view: chirality-native orchestration must reproduce the manifests.

## 4. The cockpit — pieces to MAKE (small, all additive)

1. **`lib/cockpit-server.chiral`** (new chirality) — the one missing module:
   `sock-listen` on a unix socket → accept loop → read request → `json` decode →
   dispatch to `coordinator/run-cycle` (or `be-*`) → stream deltas back over
   `sock-send` (instead of stdout `put`) → loop. **Pure composition of modules
   that already exist and are proven.**
2. **The cockpit protocol** (tiny) — newline-delimited JSON over the socket:
   `{op,model,prompt}` in; `{delta:…}` per token, then `{done,usage}`.
   `json.chiral` ↔ elisp `json` on each side.
3. **`manas-cockpit.el`** (new elisp) — the Emacs half: `make-network-process
   :family 'local` to the socket, a streaming chat buffer, a pipeline runner
   showing the gate→experts→combiner trace, memory-search + log views.
4. **Launch** — run `cockpit-server` on the scaffold host, env-pointed at the
   worker + a socket path; a dinit service later.

**Acceptance:** prompt → streamed completion in an Emacs buffer, over chirality,
against the live worker.

## 5. The bundled roadmap (self-hosting, with the cockpit as the through-line)

Self-host in dependency order; **re-run the cockpit as the acceptance test at
each layer.**

- **Phase C — Cockpit on scaffold.** The 3 pieces in §4. Product win + acceptance
  harness. *Runs on the Python host with syscall crutches.*
- **Phase S1 — Self-host the syscall floor the cockpit uses.** E29 sockets, E28
  mmap/mprotect, E31 poll, E32 clock/exit/env; an **HTTP+SSE client in chirality over
  raw sockets** (retire `impl_ports` http-request/sockets *for the cockpit path*).
  *Acceptance: the cockpit path touches no `impl_ports` crutch.*
- **Phase S2 — Self-host the runtime.** E15 reference interpreter, E13 de-Bruijn,
  eval/terms in chirality. *Acceptance: chirality programs run via a chirality-written
  interpreter (scaffold bootstraps it).*
- **Phase S3 — Self-host the checker (shrink the TCB).** E1 reader, E2 elaborator,
  E3 NbE, E4 bidirectional, E5 QTT, E6–E11 data/positivity/linearity/refinement/
  totality, E12 effects. *Acceptance: chirality typechecks chirality, validated against
  the scaffold's judgments.* **← the genuinely hard phase.**
- **Phase S4 — Compiler + go native.** E16 lowering, E17 optimizer, E18 TAL
  checker (E19 codegen already chirality), E20 loader, E34 ELF output. *Acceptance:
  chirality compiles chirality to a native ELF; the cockpit runs as a self-hosted native
  binary, no Python.*

**End state:** the cockpit is a **native chirality binary, no Python**, talking to the
worker + Emacs. chirality is fully self-hosted, *proven by the cockpit running*.

## 6. Is the bundle too much? (honest weighing)

**For:** reference impl exists (port, not research) · ~half the elements
blueprinted · codegen already chirality · the app layer + thin loop already proven
live · a 2-day precedent for the whole scaffold · the cockpit makes self-hosting
concrete instead of abstract.

**Against / risk:** the checker self-host (NbE/QTT/refinement, E3/E4/E5/E9) is the
real difficulty · the native path (E20 loader, E34 ELF) is unbuilt (blueprint
only) · "no Python at all" has a long tail (every syscall, edge formats E30/E34).

**Call:** **bundle it**, sequence cockpit-first, treat each S-phase as
independently shippable with the cockpit as its gate. Do **not** block the cockpit
product on full self-hosting. The bundle is the roadmap; the cockpit is the wire
that runs through every phase and tells you it still works.

## 7. First actions for the new chat

1. **Decide your lane dedication + process — do this FIRST, it scopes everything
   below.** This plan spans two lanes: `chirality` (self-hosting) and the
   manas cockpit (which reaches into `/workspace/manas`). Nothing here is
   pre-committed for you — decide:
   - **Which lane(s) you own:** both (chirality + the manas cockpit as one effort), or
     **chirality-only** (treat the cockpit as a downstream consumer someone else wires).
   - **How you'll run it:** formalize through GSD (`gsd-spec-phase` /
     `gsd-discuss-phase` → `gsd-plan-phase`), or direct-build Phase C and route the
     S-phases through GSD. Pick per the scale of what you take on.
   Write the decision down (a short note at the top of this file or a STATE entry)
   before executing. The rest of §7 assumes you've chosen; adjust to your scope.
2. **Sanity-check the substrate:** `curl 100.64.0.5:8080/internal/health`; confirm
   the chirality thin loop still runs (scaffold tests / the `coordinator` path).
3. **Phase C:** design the protocol → write `lib/cockpit-server.chiral` → write
   `manas-cockpit.el` → prove end-to-end against the live worker.
4. **Open the self-host track:** blueprint the remaining ~half of the catalog with
   `tools/pack/pack.py`, then start **Phase S1** (the floor the cockpit needs).
5. **Hold conformance:** chirality orchestration must reproduce the Python driver's
   golden manifests (`manas/CHIRALITY-CONTRACT.md`).

## 8. Pointers

- **chirality:** `scaffold/lib/{backend,coordinator,manas,http,json,ports}.chiral` ·
  `scaffold/chirality/*.py` (host) · `.planning/SELF-IMPLEMENT-CATALOG.md` ·
  `examples/` + `tools/pack/pack.py` + `.claude/skills/worked-example`.
- **manas:** `orchestrator/` (Python driver, normative) · `manas-worker/` ·
  `orchestration/*.md` (SCHEMA/experts/pipelines/configs) · `CHIRALITY-CONTRACT.md` ·
  `.planning/{STATE,ROADMAP}.md`.
- **infra:** `shredtower-setup/host/setup/` runbooks; worker + ollama dinit
  services on the tower (uid 1002, `ollama` user).
- **memory (auto-loaded):** `chirality-worked-example-pipeline`, `manas-worker-live`,
  `manas-lane-scope`, `manas-model-selection`.

## 9. Related open threads (other lanes — not the focus, but don't lose them)

- **hermes-coordinator host fix (shredtower):** the Hermes web-UI container binds
  `--host 100.64.0.5` on bridge net (unreachable); the fix is a rebuilt recipe
  binding `0.0.0.0` + mesh publish + a runroot pin (`storage.conf` +
  `hermes-runtime-dir` service). Designed, **not yet applied**. The real recipe
  was recovered from `podman history` (Artix base-dinit + install.sh + npm
  hermes-web-ui). A future "orchestrator + pop-up" 3-tier container design was
  sketched but deferred.
- **manas Phase 3** (cycle completion — git-commit per cycle, model/adapter
  registry, more pipeline families) is the next planned manas phase, separate from
  this cockpit/self-host effort.
