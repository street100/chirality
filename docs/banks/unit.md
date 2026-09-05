---
node: banks/unit
layer: bank
tier: depth
related: [banks/INDEX, banks/module, banks/capability, banks/port, banks/profile, banks/effect-and-alarm, banks/evidence-and-split, banks/verification, banks/text, goals/local-ai, decisions/decision-ai-tier, records/conformance-map, status-ledger]
status: current
updated: 2026-09-04
---

# Bank: unit

> The monolith this refracts: the agent, the model call, the neuron, the actor,
> the microservice, the LLM chain. Nineteen shards across `prog/manas/` (7,289
> lines over 40 files) and `prog/scriba/` (manas-mode.chiral, manas-runview.chiral).
> Eight of eleven catalog elements (E133-E141) are dated "built"; the whole
> subtree is compiled by `tools/test/run-tests.sh` Phase 7 and executed by none
> of it, and `records/conformance-map.md` never mentions E133 through E146 at
> all. That gap is measured below rather than rounded either way.

**Why this bank exists, and the cost is measured.** `docs/banks/INDEX.md`
listed twelve banks and a grep for `agent`, `model`, `orchestration` and `flow`
returned zero hits across all twelve. Earlier the same day, a session drafting
a worked example with no bank to read invented three phantom features against
this same concept, and roughly 45% of that session was rework. `docs/definitions/working-discipline.md`
states the rule this exists to serve: read the concept's bank before naming a
gap.

**The measurement, 2026-09-04**, against the working tree.

| measured | figure | command |
|---|---|---|
| lines under `prog/manas/` | **7,289** across 40 files | `wc -l prog/manas/**/*.chiral` |
| `.prog` fixture roots under `prog/manas/` | **18**, every one compiling `compile-main` | `find prog/manas -name '*-test.prog'` |
| roots under `prog/samples/` naming manas | **21** (`manas-*-live.prog`, `manas-run-conform.prog`, `manas-flow-conform.prog`, `agent-probe.prog`, `manas-parse-robust-test.prog`) | `find prog/samples -iname '*manas*' -o -iname '*agent-probe*'` |
| of those, executed by any `tools/test/*.sh` phase | **0** | `grep -rn 'manas-run-conform\|manas-flow-conform\|agent-probe' tools/test/` |
| E-numbers E133-E146 cited in `records/conformance-map.md` | **0** | `grep -n 'E13[3-9]\|E14[0-6]' records/conformance-map.md` |
| Phase 20's five executed roots that import `manas/*` | **0** | `grep -n '^(import' prog/samples/{e130_http_get,stream-ollama,e131_sse_framing,e131_sse_socketpair,e130_http_request_refused}.prog 2>/dev/null \| grep manas` |
| `lib/backend.chiral`, the map's own citation for the model-backend seam | **absent** (the file is `prog/manas/backend.chiral`) | `find . -iname backend.chiral` |

---

## 1. The concept in chirality

**Vocabulary already names the atom.** `docs/definitions/vocabulary.md`'s
`process` entry: "Is: the one unit of computation (P2)." A unit in this bank's
sense is narrower than that. It is a process, or more exactly a **value**
dispatched to a process, bound to a named **capability slot** inside an
orchestration graph: it consumes typed input, holds no state of its own
between calls, and emits typed output under a discipline (a gate that decides
whether it fires, a stop policy that decides whether it fires again, a lint
that flags it before either). Not every process is a unit in this sense.
Ordinary arithmetic is a process and answers to none of the machinery below.

**A unit IS a split pair.** It is never one thing on its own. The split runs
through every shard in this bank:

- **The shape is a value.** `Expert`, `Flow`, `PureFn`, `Skill`, `GateRule` are
  category-A data, `(data ...)` records with named constructors and zero
  crossings. `prog/manas/core/types.chiral`'s own header states it for the
  whole file: zero logic, holding no definitions, accessors or crossings of
  any kind. An `Expert`'s
  `sees` and `returns` fields are `Str`: prose descriptors the header names as
  a deliberate deferral, "typed I/O is target work" (`types.chiral:64`).
- **The execution is a process.** `run-flow`, `call-expert`, `bind-config`,
  `run-gate` are ordinary chirality `def`s and `extern`s, some `->`, one `=>`.
  They resolve a unit's slot to a bound model, assemble its prompt, cross the
  `Backend` port, and fold the answer into a record. This half carries every
  effect, every port, every altitude span a unit has, and it belongs to
  `prog/manas/`'s own module structure the way any other process does.

**A unit IS NOT a chirality module.** `docs/banks/module.md` §1 states what a
module is: "a process with a type, packaged, versioned, composed, replaced,"
individuated by the checker's type-identity judgment (conv). An `Expert` value
carries none of that. It has no effect row, no port-set, no altitude span, and
two `Expert`s with identical fields are the same `Expert` by ordinary
structural equality over a `Str`/`I64`/`List` record. The splitting law's
"same type shape" test plays no part in it. The module bank's shard 5 (individuation by
type) simply does not apply to a value that has no type beyond `Expert`
itself. What DOES belong to `banks/module` is the second half of the split:
`prog/manas/pipeline/runner.chiral` and the rest of the interpreting
machinery are `.chiral` files carrying `def`/`data`/`extern`/`porttype`
declarations, elaborated into the checker's `Sig` exactly like any other
module. So "the agent" collapses into two existing concepts rather than
naming a third: the shape a unit takes is a `banks/text`-shaped payload over a
closed sum (§3), and the machine that runs it is a `banks/module`-shaped
process. Neither needs a construct of its own.

**A unit IS NOT the neuron, the actor, the microservice, the LLM chain.** See
§4 for the correction on each.

**Why "unit" and not "agent."** `docs/decisions/decision-ai-tier.md`'s own
title already spends the word: "the agent tier is tracked, and it is distinct
from the human tier." `MAP.md` and `CLAUDE.md` use "agent" tree-wide for the
session working the repository. An orchestration node is a use it has always
lacked. Naming this
bank `banks/agent` would put two unrelated senses of the same word one
directory apart. `banks/unit` is unclaimed in `docs/definitions/vocabulary.md`
and matches the word vocabulary's own `process` entry already reaches for
("the one unit of computation"). It also survives the direction §5 records:
a transformer instance and a configurable neuron population are both units in
this sense, and only one of them is anything an "agent" word would fit.

---

## 2. The refraction: the shards, their homes, their build-state

**Ground truth, stated once.** `records/conformance-map.md` carries zero rows
for E133 through E146; a targeted grep confirms it (measured above). What it
does carry: a `manas profile (breaker + batch driver)` row at CONFORMS
tagged E67, and a `lib/backend.chiral (model-server seam)` row at CONFORMS
with no E#, whose own note says the file "belongs to slice F" (orchestration).
⚑ **That second row's path is stale.** `lib/backend.chiral` does not exist;
the file is `prog/manas/backend.chiral`, moved (or always misfiled) across the
2026-08-31 migration the way `.planning/MANAS-STATE-VS-GOAL.md`'s `scaffold/`
citations were. The verdict (CONFORMS) reads true against the live file; the
path does not resolve. Every other shard's state below is either the ledger's
own informal tag (`docs/elements/ledger.md`, "built" / "design," no CONFORMS
taxonomy) or a direct measurement against the tree, named as such.

**A fourth state, past the usual three.** `docs/banks/render.md` established
it: fixture-reached, a shard whose only caller is a root a test phase
compiles without running, one state further than built, unreached, absent. The manas subtree is in a
state one step past that. Its 18 `*-test.prog` roots and the 21
`prog/samples/manas-*` roots are all swept by Phase 7's
`grep -rl '^(def compile-main' lib prog`, which compiles each one and
discards stdout (`>/dev/null`): they gate on compiling and assert nothing.
Unlike render's shard K (compiled AND run by Phase 17), no phase anywhere in
`tools/test/run-tests.sh` executes a manas root. The one exception is
historical rather than mechanical: `docs/goals/local-ai.md` records a single
hand-run on 2026-09-02 of `prog/samples/manas-run-conform.prog` and
`manas-flow-conform.prog` against a live mesh endpoint, each exiting per its
own header, neither wired into any gate before or since. Below, **compiled**
names this state precisely: present, imported, forms a complete program,
compiled every suite pass, executed by none of it.

| | shard | home | state |
|---|---|---|---|
| **A** | **the unit itself**: `Expert`, one record: id, lens, sees, returns, slot, tools | `prog/manas/core/types.chiral:66-68` | **compiled.** E133, ledger "built." `sees`/`returns` are `Str` prose by explicit deferral (`:64`, "typed I/O is target work"). Zero crossings, zero logic, by the file's own header. Map is silent |
| **B** | **the payload type**: `Ty`, `Shape` (`sh-prose` / `sh-list` / `sh-rec`), `Arrow` | `prog/manas/core/flow.chiral:32-77` | **compiled.** No E#, absent from the manas-layer table and from every ledger/catalog row measured. `ty-eq` compares by name only (`str-eq`), so two `Ty` values with the same name and different `Shape` are indistinguishable to the checker below (§5). Map is silent |
| **C** | **composition**: `Flow`, seven constructors, and `flow-ty : Flow -> (Maybe Arrow)`, the pure compositional checker | `prog/manas/core/flow.chiral:140-233` | **compiled.** No E#, no ledger row, no catalog row, no conformance-map row: `Flow`/`flow-ty` do not appear in any of the four authorities this tree keeps. Only the later `PureFn` additions on top of it (below) carry an informal "BUILT + tested" tag. `flow-ty` is total over all seven constructors, verified by reading every `case` arm (`flow.chiral:212-233`) |
| **D** | **the flat predecessor**: `Pipeline`, `Order` (fan-out / chain / branch), lifted by `pipeline->flow` | `prog/manas/core/types.chiral:52-55` (Order), `:82-89` (Pipeline), `flow.chiral:239-244` (the lift) | **compiled.** E133 (Pipeline, Order). `pipeline->flow` always emits one `flow-gate`, so `Order`'s three arms are carried in the type and only `order-fan-out`'s shape (a whole GATE block) is what the lift actually exercises; `order-chain` and `order-branch` are unread by it |
| **E** | **activation**: `GateRule`, `GateDecision`, `run-gate`, pure `->` | `prog/manas/core/gate.chiral:114-139` | **compiled.** E134, ledger "built." Total: an unrecognized condition falls to `else false` (`condition-fires`, `gate.chiral:72`). The membrane proves no `=>` reaches it; the router decides in code and a model never chooses |
| **F** | **the slot binding**: `Config`, `Binding`, `bind-config`, `bind-ok` / `bind-miss` | `prog/manas/core/bind.chiral:52-69` | **compiled.** E135, ledger "built." A missing slot is a value (`bind-miss`, carrying the config id and every missing slot); it never raises an exception |
| **G** | **the model crossing**: `Backend` as a linear porttype, `be-chat`, `be-chat-stream`, `be-peek` | `prog/manas/backend.chiral`, `porttype Backend` at `:32`, `be-chat` at `:116` | **compiled, and once live.** E137 (Backend linear, "DONE 2026-08-16"), E144/E145 (the carrier + laundering peel), ledger "built." A real crossing happened: five roots under `prog/samples/` were compiled and executed against `100.64.0.5:11434` on 2026-09-02 (`docs/goals/local-ai.md`, `records/baseline-alignment` BA-42), but none of those five imports `manas/*` (measured above); the crossing they exercised is the generic HTTP transport; this shard's own crossing sits elsewhere. `Backend`'s own live crossing is the 2026-09-02 hand-run of `manas-run-conform.prog`, unrepeated since |
| **H** | **naming and reuse**: `Skill`, `skill-base` / `skill-spec`, specialize as context injection | `prog/manas/core/skill.chiral:37-39` | **compiled.** No E#. Ledger/catalog silent; only `.planning/MANAS-SKILL-GROWER.md` (agent tier) names it. `resolve-skill` is fuel-bounded by the library size (`skill-count + 1`), so a cyclic `base` chain returns `none` rather than looping (`skill.chiral:78-96`) |
| **I** | **termination, two mechanisms sharing one name-space**: `StopPolicy` (the closed sum a `Skill`/run carries) vs `stop-policy` (a per-call decision function) | `StopPolicy` at `types.chiral:57-60`; `stop-policy` at `prog/manas/core/stop.chiral:25-29` | **compiled.** E136 for `stop.chiral`'s two functions (`overflow-guard`, `stop-policy`); E133 for the `StopPolicy` data type. ⚑ The two are unrelated mechanisms that share a name modulo case: the data type is what `run-flow-stop` and `Skill` carry (`stop-single` / `stop-capped` / `stop-until-dry`); the function decides one specific pipeline's per-expert retry by a hardcoded `"sharpen"`/`"example"` substring match. Neither calls the other |
| **J** | **the discipline**: `lint-expert`, `lint-pool` (static), `manifest-all-green?` (runtime, the tiny-model-green acceptance gate) | `prog/manas/core/flow.chiral:1359-1432` | **compiled.** No E#. `lint-expert` flags a lens that conjoins asks (`" and "`, `" then "`, `" & "`, `";"`), one over 160 characters, or an empty `sees`; advisory, and it never blocks a run. `manifest-all-green?` is the runtime twin: routing-error strings OR any `parsed-ok=false` call OR zero fired calls all read non-green (`routing-error?`, `:1414-1421`, closing a real masked-pass bug the comment names, Audit F1) |
| **K** | **the record**: `RunManifest`, `ExpertCall`, `RawCall`, and E141's golden conformance oracle | `types.chiral:131-182` (the data), `prog/manas/contract/manifest.chiral` (the codec), `prog/manas/contract/golden.chiral` (`manifest-conforms`) | **compiled.** E141, ledger "built." The oracle compares STRUCTURE only (pipeline-id, config-id, routing, fired-expert-ids, per-call expert-id/slot/bound-model) and ignores every non-deterministic field (shas, timestamps, durations, prose) by explicit decision, stated in the file's own header |
| **L** | **the corpus sink**: `be-log`, LOG-01 and LEARN-01, fire-and-forget POSTs to a worker distinct from the model endpoint | `prog/manas/pipeline/log.chiral` | **compiled, live once.** E139, ledger "built + LIVE." The worker itself, `/workspace/manas/manas-worker`, sits **outside this repository entirely**: a sibling project, Python, reached only over HTTP. `docs/goals/local-ai.md` records a verified SELECT-back against it on 2026-08-16 (1 interaction + 6 expert_calls rows, 0 empty text); nothing re-verifies it since, and no suite phase reaches it |
| **M** | **the conversational layer**: `Intent`, `ConvState`, `Routed` (router.chiral); `Plan` (orchestrate.chiral); `Chunk`/`Divided`/`Origin` (divide.chiral); `SkillEgress`/`Audit` (egress.chiral) | `prog/manas/chatter/{router,orchestrate,divide,egress}.chiral` | **compiled, unevenly grounded.** `router.chiral`'s C1-C4 slice (`Intent`, `route-message`, `intent->skill`) is E-less but carries an informal "BUILT + tested" ledger row. Everything past it, C5/C6 (`ConvState`, `Routed`, compound-intent `split-conjunctions`), `orchestrate.chiral`'s `Plan`, `divide.chiral`'s structural/semantic divider, and `egress.chiral`'s typed audit parse, appear in **zero** of catalog, ledger, or conformance-map. The only citation for any of it is `.planning/CHATTER-STATE.md`, an agent-tier document `working-discipline.md` names as non-authoritative for build state |
| **N** | **the cockpit**: `prog/scriba/manas-mode.chiral` (S14, `ManasDoc`/`ManasEdit`), `manas-runview.chiral` (S15, `RunView`), S16 compose, S17 streaming | `prog/scriba/manas-mode.chiral` (1,034 L), `manas-runview.chiral` (256 L) | **compiled, and reached from the real scriba binary.** No conformance-map/ledger build-state row for S14-S17; `docs/goals/local-ai.md` is the authority: SPECs and examples exist under `docs/elements/specs/` and `docs/examples/`, and "the six scriba roots compile under Phase 7." Unlike shards A-M, this one IS reached from a shipping program: `vim-mode.chiral` imports `ManasDoc`/`RunView` into its own mode sum, `init-loader.chiral:616` registers a "manas" mode with faces, and `scriba-main.prog` is the root `bin/scriba` builds from. `.planning/MANAS-STATE-VS-GOAL.md` §8 and its own remaining-work section contradict each other on whether this shard is started; treated here as a lead, and this bank does not read it as a source |
| **O** | **the registry**: `SkillEntry`, `all-skills`, `plannable-skills`, enumerable data | `prog/manas/profile/skills.chiral:22-27` (`SkillEntry`), `:34` (`all-skills`) | **compiled.** No E#, informal "BUILT + tested." This is `docs/goals/local-ai.md` criterion 3's own evidence: "a new skill is added by writing a value into the registry" |
| **P** | **the flat control loop**: `cycle-step` (the circuit breaker), `run-recorded`, `run-batch`, `drive-batch`; the thin one-turn loop `run-cycle` | `prog/manas/manas.chiral`, `prog/manas/coordinator.chiral` | **compiled.** E67, CONFORMANCE-MAP CONFORMS (the only manas-orchestration row the map carries under its own number). `cycle-step` is expressed as one `fsm.chiral` transition (shard below), so the whole stop/continue decision for a batch run is one Mealy step |
| **Q** | **the general FSM substrate**: `Step`, `drive`, `run-fsm`, a Mealy engine parametric over state/event/output | `prog/manas/fsm.chiral` | **compiled.** E66, "already chirality." Total, no domain knowledge of HTTP or manas: `cycle-step` (shard P) is its one instance in this tree |
| **R** | **persistence, total codecs**: `flow->json`/`json->flow` (`flow-persist.chiral`), `pipeline->json`/`config->json` (`pipeline/persist.chiral`) | `prog/manas/core/flow-persist.chiral`, `prog/manas/pipeline/persist.chiral` | **compiled.** No E#. Reused verbatim by shard H's `Skill` codec and shard N's scriba author mode (`command-loop.chiral` imports `pipeline/persist` for the value-to-buffer path) |
| **S** | **the self-extension wall**: `accept-gate` (decode, then `flow-ty`, then admit), `tool-builder-flow`, `project-builder` | `prog/manas/core/builder.chiral` | **compiled.** No E#, no ledger row; only `.planning/MANAS-SKILL-GROWER.md` names it (SG4/SG5). `accept-gate` is the wall between a model's emitted text and the skill library: every failure path (`json-parse-str`, `json->flow`, `flow-ty`) folds to `none`; nothing an agent emits is trusted before it decodes and type-checks |

⚑ **Two elements are catalogued and unbuilt, and both bound this bank's near
future.** E142 (trust-zone capability tokens) and E143 (dependent
config-coverage type) are both "design," both deferred to E135's first cut,
both named in `docs/elements/catalog.md` and absent from the code entirely.
Neither has a shard letter above because neither has a home yet.

---

## 3. Cross-cuts: where a unit shard IS another concept's shard

**C1 · The slot is a capability, one tier up.** `bind-config` (shard F)
resolving a slot to a model is `docs/banks/capability.md`'s "authority is the
ports you hold" read at the orchestration layer: a `Config` is a **grant
table**, mapping a named authority (`"reasoner"`, `"combiner"`) to the actual
model that answers for it. `banks/capability` Shard C (attenuation via
subtyping) has no counterpart here; a `Config` cannot narrow a slot's power,
only rebind it, so this cross-cut is narrower than the capability bank's own
machinery. What DOES transfer whole: `bind-miss` (shard F) is exactly
`banks/capability`'s revocation-as-a-value pattern one layer up. A slot with
no bound model reads as a typed value the caller cases, the same shape as a
dead port raising an alarm rather than segfaulting. It never crashes the run.

**C2 · `Backend` is a port shard that lives outside the port registries.**
`docs/banks/port.md` shard 1 counts nine registries under `lib/ports/`. It
already names `backend-open` once, buried in its own §5 residue list of
"every cap has an ambient mint": `adopt-fd`, `adopt-pty`, `env-open`,
`secret-seal`, `backend-open`, `pool-create`, `sock-connect`/`sock-listen`/
`socketpair`. `Backend` (shard G) is that same porttype, declared in
`prog/manas/backend.chiral` rather than under `lib/ports/`, so the port
bank's "nine registries" undercounts by at least one live linear porttype.
`backend-open : (=> Str Backend)` mints from a bare `Str`, so `Backend`'s
non-forgeability sits at the same "0 of 4" mark the port bank's §5 measures
for the family: nothing stops a second `backend-open` on the same string,
only the linearity check (E8) stops the resulting handle from being
duplicated once minted. The laundering peel `be-peek` (E145) is the same
struct-return shape as `sock-recv`/`RecvR` the port bank cites as Shard 8's
one built session-typed instance: a crossing that hands back both a used
value and a fresh linear handle in one constructor, so a `case` accounts both
binders atomically.

**C3 · The pure gate is an effect-membrane shard.** `run-gate`'s (shard E)
type is `-> (List GateRule) Str (List (Pair Str Str)) GateDecision`, no `=>`
anywhere in its spine. `docs/banks/port.md` shard 3: "is this a crossing? is
read off the type." So the claim "no model chooses which experts fire" is not
a design promise resting on discipline; it is the same derivation
`ty-crosses` performs on any `def`, applied to this one. The gap the port
bank's §5 names (a `->` def calling an `=>` def compiles today, E171 unbuilt)
applies here exactly as everywhere: nothing in the checker refuses `run-gate`
from calling `be-chat` if a future edit added the call. The proof is
structural discipline today, and enforcement stays future work.

**C4 · `Config` is a profile shard, one tier up.** `docs/banks/profile.md`'s
concept (a named set of modules over a frozen port set) has its orchestration
analogue in `Config`: a named set of bindings (`smoke-local`, `cheap-local`,
`quality-local`, `quality`) over a frozen slot set (shard F's `Binding`
records; `profiles.chiral` defines four, each holding its slot set fixed). Swapping `smoke-local` for `quality` runs the identical `Pipeline`
unchanged, the orchestration-layer restatement of the profile bank's central
claim that swapping a profile changes no code, only the composition. The
frozen-set discipline is the same shape; the frozen-set ENFORCEMENT is
`bind-config` returning `bind-miss` on an unresolved slot, a value check, not
the checker's `mf-check-ports`.

**C5 · `RunManifest` plus the golden oracle is an evidence-and-split shard,
and `manifest-all-green?` is a verification shard.** E141's `manifest-conforms`
(shard K) is P5 at the orchestration layer: two independent truths (a frozen
golden, a live run) compared structurally, disagreement being how divergence
gets noticed, exactly `docs/banks/evidence-and-split.md`'s concept. And
`manifest-all-green?` (shard J) is a verification instrument in
`docs/banks/verification.md`'s sense: layered, blind above its own branch
point (it reads a `RunManifest`'s routing string and call list, nothing about
what the model actually said), ranked below the golden oracle rather than
replacing it. Neither shard needed new machinery to exist; both are the
general-purpose bank's own shape, instantiated once each.

**C6 · `Ty` and `Shape` are a `banks/text` shard, and the seam is looser than
either bank alone shows.** `docs/banks/text.md` (unread in full here per its
own do-not-re-document convention) owns "a payload, a way to name a part of
it, total functions between those." `Shape`'s three constructors (`sh-prose`,
`sh-list`, `sh-rec`) are exactly that: a document-structure vocabulary,
narrower than `banks/text`'s own but the same shape. What crosses this bank's
own line, and does not appear in `banks/text`: `ty-eq` (shard B) compares two
`Ty` values by NAME alone (`str-eq`); `Shape` plays no part in it. So `flow-ty`'s
composition check (shard C), the thing this bank calls "the pure compositional
checker," verifies that two adjacent `Ty` names agree and is silent on whether
their `Shape`s do. A `flow-chain` whose first step emits `(ty "x" sh-prose)`
and whose second step expects `(ty "x" (sh-list sh-prose))` type-checks
today. This holds against the live tree rather than as a hypothetical: nothing in `flow.chiral`'s own test file
exercises the case, and it is exactly the class of gap a payload-and-address
bank exists to name.

**C7 · Boundary-as-closed-sum is the substrate pattern this concept leans on
hardest.** `docs/definitions/pattern-boundary-sums.md` states a standing
author directive: retype a which-of-N classification as a closed sum at the
boundary; a `Str` tag plays no part in it. Every shard in this bank is built on it: `Origin`
(shard M) carries HOW a chunk was divided; `Audit` (shard M) carries a
parsed verdict rather than a `Str`; `PlanOutcome` (implicit in shard F/D's
composition), `Plan` (shard M), `BindResult` (shard F), `PureFn` (shard C) are
each a closed sum a `case` exhausts. The pattern holds by design throughout. It is
what lets `manifest-all-green?` (shard J) read a run's health off values
rather than re-parsing prose, and what lets `accept-gate` (shard S) refuse an
agent's output by exhaustive `case` rather than a runtime type-check. The
pattern doc should link into this bank as its heaviest concrete instance;
today it does not (§6).

---

## 4. Native → chirality translation (the misfire → the correction)

| "chirality needs…" | what it actually is |
|---|---|
| an agent framework / an Agent class | shards A + G split apart: `Expert` is inert data (shard A), and the process that runs one (`call-expert`, shard G) is an ordinary `=>` def over a linear port. Nothing sits between them that a class would add |
| a model-call abstraction | `be-chat`/`be-chat-stream` (shard G), a linear porttype over an OpenAI-compatible contract. Swapping Ollama for llama.cpp changes the base URL a `Config` carries; the type stays fixed either way |
| a neuron / a differentiable unit | absent, and honestly so. `Tensor` and `tensor` are grep-clean across `lib/` and `prog/` (`docs/goals/local-ai.md`); nothing in this tree differentiates anything. §5 states what closing this gap would need |
| an actor (mailbox, isolated state, message-passing) | a unit here holds no state across calls; `RunManifest` (shard K) is the accumulated record; an actor's internal memory is a different shape entirely. The nearest actor-shaped thing is `Backend` (shard G), a linear handle threaded exactly once per call, closer to a session token than a mailbox |
| a microservice (a network boundary, its own deploy) | the model server (shard G) and the corpus worker (shard L) are the two real network boundaries, and both are OUTSIDE this repository: an OpenAI-compatible endpoint and `/workspace/manas/manas-worker`. Nothing inside `prog/manas/` is a microservice; it is the typed client of two |
| an LLM chain (LangChain-shaped: prompt template, output parser, chain composition) | `assemble-prompt` (shard A's Expert plus `assemble.chiral`) is the template; `parse-findings` / `SkillEgress` (shard M) is the output parser; `Flow` + `flow-ty` (shard C) is the chain, except the chain type-checks before it runs rather than failing mid-execution |
| a workflow engine (DAG, retries, backoff) | `Flow`'s five structural constructors (chain, fan, branch, gate, step) are the DAG; `StopPolicy` (shard I) is the retry policy; there is no backoff; every retry here is capped and local, on a fixed schedule rather than a timed one |
| a supervisor tree | `cycle-step` (shard P) IS one, expressed as a single Mealy transition (shard Q) rather than a tree of processes: a consecutive-failure counter that halts a batch. It supervises calls only; nothing in this tree supervises a crashed process the way an actor-system supervisor does |
| a plugin system for adding new agents | shard H's `specialize-skill` (context injection) plus shard S's `accept-gate` (the type-checked admission wall). A new skill is a new `Flow` value plus a `Config` binding, admitted by decoding and type-checking; no class is ever registered |

---

## 5. What is genuinely unbuilt: the honest residue

1. **Typed I/O on `Expert`. Deferred by the type's own header, `unminted`.**
   Shard A. `sees`/`returns` are `Str` prose today; `types.chiral:64` names
   the deferral directly. Closing it would let `flow-ty` (shard C) check an
   `Expert`'s declared contract against its actual `Ty` instead of trusting
   the prose to match.

2. **`ty-eq`'s blind spot: name equality without shape equality. Unminted,**
   found by this bank (§3 C6). `flow-ty`'s composition check accepts two
   `Ty` values whose names agree and whose `Shape`s do not. No test in
   `flow-test.prog` exercises it.

3. **Trust-zone capability tokens (E142) and dependent config-coverage
   (E143). Both `design`, both deferred to E135's first cut, both absent from
   the code entirely.** Neither has a shard letter in §2 because neither has
   a home. E142 would carry a `Config`'s trust boundary (local vs cloud) in
   the type rather than in `PreflightResult`'s `preflight-cloud` runtime
   check (`types.chiral:104-107`); E143 would make "does this `Config` cover
   this `Pipeline`'s slots" a checked type rather than `bind-config`'s
   runtime value.

4. **`Config`/`Pipeline`/`Skill` value-to-source (E146). `design`, unbuilt,
   blocks S14 write-back and S16 compose (both named in the catalog row).**
   The deserializers (shard K, R) go source-JSON-to-value; nothing goes
   value-to-source. Scriba's author mode (shard N) can read a `Config` into
   a buffer and cannot save an edited one back out.

5. **The corpus worker is outside self-hosting scope, and that boundary is
   undocumented here until now.** Shard L. `/workspace/manas/manas-worker` is
   Python, a sibling project, reached over HTTP. `docs/decisions/decision-scope.md`
   holds the track to self-hosting only; whether a Python worker across a
   network boundary sits inside or outside that scope stays an open question
   this bank found no ruling on, and the goal doc's own author-call A (Python: outside the
   tree, or inside it) sits directly over this shard without naming it.

6. **The allocation gap threatens every unit in this bank at scale, and no
   arc owns it.** `records/author-calls.md`: "~1,747 B of arena per input
   byte, no reclamation on any compiled path... it blocks manas and scriba
   from running once transport lands." A `RunManifest` (shard K) and a
   `ConvState` (shard M) are both unbounded-growth values over a bounded-state
   substrate; nothing in this bank measures how many turns a conversation
   survives before the arena the whole engine runs in is exhausted.

7. **The neuromorphic direction: what a unit needs to cover a transformer
   instance and a neuron population under one abstraction.** Researched
   2026-09-04, given as reference class, verified nowhere else in this tree:

   | prior art | what it establishes |
   |---|---|
   | Intel's Lava | a Process (stateful, typed input/output ports, async message channels, CSP-derived) with one or more ProcessModels per Process implementing it per backend/precision. Structurally the module-and-profile split this tree already has |
   | NIR (Neuromorphic IR) | composable primitives as hybrid systems, continuous-time dynamics plus discrete events, as signal-flow graphs, across 7 simulators and 4 hardware platforms |
   | PyNN | a dual-level API: populations and projections above, individual neurons and synapses below |
   | Kahn Process Networks | determinism over unbounded FIFO channels, blocking read, non-blocking write; an output history depends only on input history, with timing playing no part |
   | three-factor learning / e-prop | an update factored into a synapse-local eligibility trace times a broadcast learning signal, enabling online updates with no stored unrolled history |

   **Four axes separate a transformer instance from a neuron population, and
   both are bounded state over an unbounded stream, which is what makes one
   abstraction possible at all.**

   | axis | transformer instance (this bank, today) | neuron population (unbuilt) |
   |---|---|---|
   | what flows | tokens (`Str`, `Msg`, shard G) | spikes (unrepresented) |
   | state | a `Backend` handle plus prompt history, held nowhere between calls (shard G is stateless per-call by construction) | membrane potential, held continuously |
   | time | a logical step (one `run-flow` recursion, shard C) | an event timestamp |
   | update | offline: nothing in this tree trains anything (`docs/goals/local-ai.md`: "there is no tensor form and no autodiff") | online, local (e-prop's own shape) |

   **The one observation to check: does a `RunManifest` plus a combiner
   verdict already read as three-factor learning at the orchestration level?**
   Measured against the actual types (shard K, M): `ExpertCall` (the call
   record) carries `parsed-ok` and `accepted-into-merge`, both booleans set
   once at call time and never revised; nothing folds a later verdict back
   into an earlier call's weight. `CombinerOutcome` (shard D) decides which
   ids were `accepted-into-merge` but that decision is written once into
   `ExpertCall.accepted-into-merge` and read by nothing downstream; even
   `manifest-all-green?` (shard J) skips it, reading `parsed-ok` alone. The
   eligibility-trace-times-broadcast-signal shape needs a value that
   ACCUMULATES across calls and a signal that MULTIPLIES against it; this
   tree has a value that is written once and a signal that is read once, and
   the two never meet in a second pass. **The reading does not hold. It is a
   stretch**, and the reason is structural rather than conceptual: nothing in
   `prog/manas/` closes the loop the three-factor shape requires: a learning
   signal has to reach back and revise an eligibility trace; this engine's
   manifest only ever appends.

   **What a unit would need to be universal over both.** A state field typed
   by discipline rather than by shape (a `(0 or 1 or many)`-quantity slot
   generalizing `Backend`'s single-flight handle to a KV cache on one pole and
   a membrane-potential vector on the other); a time parameter carried in the
   type the way `(Pool n)` carries a size (a logical-step count on one pole, a
   timestamp on the other, both indexing the same porttype family); and a
   revision channel the current `ExpertCall`/`RunManifest` pair does not have,
   so a later verdict CAN fold back into an earlier record rather than only
   ever appending beside it. None of the three exists today. All three are
   additive to the existing shard set (A, B, G, K), extending it rather than replacing it.

---

## 6. Relational anchors: thin notes that should link INTO this bank

- [[goals/local-ai]]: the four minimums and two conditions this whole bank
  measures against; its own "Honest limits" section and this bank's §2 ground
  table agree everywhere they overlap.
- [[decisions/decision-ai-tier]]: the reason this bank is named `unit` and not
  `agent` (§1).
- [[banks/capability]]: the slot-as-grant-table cross-cut (§3 C1).
- [[banks/port]]: `Backend` as an unlisted tenth porttype family, and the
  `be-peek` struct-return shape (§3 C2).
- [[banks/effect-and-alarm]]: the pure-gate proof and its E171 gap (§3 C3).
- [[banks/profile]]: `Config` as the orchestration-layer profile (§3 C4).
- [[banks/evidence-and-split]] / [[banks/verification]]: the golden oracle
  and the tiny-model-green gate (§3 C5).
- [[banks/text]]: `Ty`/`Shape` and the name-only equality gap this bank found
  (§3 C6).
- `docs/definitions/pattern-boundary-sums.md`: the substrate pattern every
  closed-sum shard in this bank instantiates (§3 C7). Should point here; does
  not yet.
- `records/conformance-map.md`: silent on E133-E146 entirely (§2); carries the
  one CONFORMS row this bank has (E67, shard P) and one stale path (shard G's
  citation).
- `records/author-calls.md`: author call A (Python inside or outside scope,
  §5 item 5) and the allocation-gap row (§5 item 6), both directly over this
  bank's shards without naming them.
- `.planning/MANAS-STATE-VS-GOAL.md`: read as a lead here. It is never treated as a source (§2 shard N); it
  contradicts itself on the scriba cockpit and cites `scaffold/` paths the
  2026-08-31 migration deleted.
