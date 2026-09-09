# Arc realignment for `goals/local-ai`

**Drafted 2026-09-01.** A proposal, and it settles nothing. `docs/goals/local-ai.md`
is the goal it serves. Two rows in `records/author-calls.md` block the assignment,
and both are named at the bottom of this file.

It answers three questions: which existing arcs already supply pieces of this
goal, which would have to be re-pointed, and which arcs are owed.

**Acted on 2026-09-02.** The three arcs of section 3 are open as
`docs/arcs/transport-arc.md`, `docs/arcs/scriba-arc.md` and
`docs/arcs/tuning-arc.md`. Two premises here were measured stale in the same
pass and the arcs carry the corrected reading: the transport gap is `BA-42` in
`records/baseline-alignment.md` and `S18` being unbuilt is `BA-43`. Section 1's
rule that an arc names exactly one goal was superseded by the many-to-many
relation in `docs/arcs/README.md`, and the conclusion it drew, that this
proposal re-points nothing, still stands.

---

## 1. The rule this proposal obeys

An arc names exactly one goal (`docs/arcs/README.md`). So an arc that supplies a
piece of `local-ai` while serving another goal is a **supplier**, and it stays
where it is. Re-pointing it would take it away from the goal it was written for,
and `docs/goals/README.md` says changing what a goal claims is a decision that
belongs in `docs/decisions/` first.

The proposal therefore re-points **nothing**, and says for each of the eight
existing arcs whether it supplies, and what.

## 2. The eight existing arcs

| arc | its goal | serves `local-ai`? | what it supplies, or why not |
|---|---|---|---|
| `diagnostics` | `readable-surface` | supplies | `Doc`, `pretty` and `Reason`. Every scriba surface prints, and E181's term printer under `surface/pretty` is what a config editor needs to show a typed value |
| `enforcement` | `enforcement` | supplies, later | E171 reaches the effect membrane from the kernel's apply and binder judgments. A model call is an `=>` crossing, and criterion 1's claim that the run has no host language beneath it is a claim about crossings |
| `file-types` | `readable-surface` | **supplies twice** | E163 `.manifest` is the kind a model binding set and a profile would be declared in. E146 value-to-source is the write-back half that `S14`'s SPEC decision D7 defers to it, so authoring a config in scriba can read and cannot save. Both are Lane B rows in `docs/decisions/decision-lane-split.md` |
| `zero-python` | `self-tooling` | **collides** | Its done condition and criterion 4 point opposite ways. Author call A, below. No re-point until it is ruled |
| `text-tools` | `self-tooling` | supplies | E173 slice 1 is built and its P2, P3 and P4 rows are blocked on the same missing element block this goal is blocked on. A tiny-step lint (criterion 5) is a text tool in shape |
| `presentability` | `presentability` | neutral | Reader-facing spine. Nothing here needs it and nothing here is exempt from it |
| `baseline-alignment` | `presentability` | **supplies, and is owed a row** | Two claims under this goal are already false in the tree: `records/conformance-map.md:209-210` records the skill registry and the chatter against `scaffold/lib/manas/` and `TUI/scriba/` paths that do not exist, and `.planning/METIS-PORT-SPEC.md` is cited five times and is absent. Both belong in `records/baseline-alignment.md` as BA rows |
| `binary-split` | `presentability` | supplies | Criterion 5 of `goals/presentability` is that a tool ships without the x64 backend. A resident chirality process that talks to a model server is the same shape and inherits the same split |

**`independent-judgment` is a cross-cut and stays separate.** The engine's own
`refute-claim` agents (E138's pool) and E141's golden conformance are
split-and-agree in shape, and they judge *model output*. `goals/independent-judgment`
is about the compiler's judgment cores. Folding one into the other would let
agreement between two agents count as agreement between two formulations of the
type theory, and `docs/goals/independent-judgment.md` already rules out one
formulation with two emitters.

## 3. Arcs owed

Three, in build order. Each row's work writes `UNASSIGNED` where an element
number would go, per the deferral rule.

### A. A transport arc, and it is the cheapest large win

**What.** Give `http-request`, `backend-open` and `chat-open` a runtime referent,
so the built engine runs in this tree.

**Why first.** 9,930 lines under `prog/prapanca/` and 26 modules under `prog/scriba/`
compile and lower today and have nothing to run against: none of those three
externs appears in `lib/lowering/tal/crossing-wraps.chiral`. Every "live verified"
line in `.planning/MANAS-STATE-VS-GOAL.md` was measured through the CPython
transport the migration cut. This arc converts the largest built-and-unreachable
body in the repository into a running one, and it adds no new orchestration.

**Read the bank first, because most of this is already shards.** The socket floor
is built: `sock-send`, `sock-recv`, `socketpair`, `sock-connect` and
`nb-sock-connect-in` are all registered at
`lib/lowering/tal/crossing-wraps.chiral:37-41` (E125, E126, E127, E129).
`lib/protocol/http.chiral` already handles Ollama's chunked transfer (`:258`) and
reads either the OpenAI delta or Ollama's `message.content` (`:600`, `:610`). The
catalog carries E130 native HTTP/1.1 over the native socket cap and E131 native SSE
as rows. So the owed work may be adoption of rows that exist rather than a new
capability, which is what `docs/banks/port.md` and `docs/banks/capability.md`
should be read against before a single row is minted.

**Rows.** UNASSIGNED. Candidate homes among existing rows: E130, E131, E51.

### B. A scriba arc, and it needs no element block

**What.** `S18`, the `Scriba` state record, then the surface rows that sit on it.

**Why it is unblocked.** `S#` is namespaced by its own letter
(`docs/elements/ledger.md`, Referencing), `docs/elements/specs/S18-scriba-record-SPEC.md`
already exists, and `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` numbers `S18`
through `S30` with gates and a serial order. Author call B does not block this
half.

**What it buys.** `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` §0 measures the cost
`S18` removes: 11 loop-state parameters threaded positionally through 436 argument
sites, with 74 of 144 defs in `command-loop.chiral` carrying them. Five surfaces
have already been smuggled into a `VimMode` payload to avoid adding a twelfth.
Criterion 2 asks for full interaction, and every new surface pays that tax first.

**Rows.** `S18`, then `S19` buffer list, then the checklist's order. `S11`
init-file load stays gated on E132 (runtime dynamic loading, unbuilt) and on
D-S1, which `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md:280` records as resolved
2026-08-22.

**A tracked home is owed with it.** `docs/examples/INDEX.md` lists `S13` through
`S17` and says `S18` has a SPEC with no example. The scriba ledger the S-series
needs is `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md`, which is the agent tier. An
arc file under `docs/arcs/` is the tracked half that `docs/arcs/README.md`
requires.

### C. A tuning arc, and it cannot open yet

**What.** Criterion 4: fine tuning, model creation, and the growing and changing
set of interactions over transformer types.

**Why it cannot open.** Author call A decides its shape completely. Under the
spawned-external-process reading it is a ports arc built on E33, which is already
BUILT native (`lib/runtime/proc.chiral`, `raw-proc-spawn` to `nb-run-cmd` at
`crossing-wraps.chiral:54`), and it mints no `.py` file. Under the other reading
it is a `tools/`-shaped arc that `goals/self-tooling` forbids. The two readings
share no first row.

**What is measured today.** `prog/prapanca/backend.chiral:17` records `train-start`
and `train-status` as documented and unbuilt on the worker side, and nothing in
this tree names them. There is no float type (`lib/protocol/json.chiral:4`; `F64`
and `Float` grep-clean under `lib/surface/` and `lib/typing/`), no tensor form
(`tensor` grep-clean under `lib/` and `prog/`), and no autodiff. Those four
absences are why the author's phrase wraps Python for this and does not ask
chirality to do it.

**Rows.** UNASSIGNED, and none should be written before author call A.

## 4. What this proposal does NOT propose

- **No new framework arc.** The framework criterion is largely built and naming a
  gap here would be a phantom feature. `prog/prapanca/core/flow.chiral:114-127`
  carries seven `Flow` constructors including `flow-branch`, whose `backtrack`
  field pairs consolidate-and-audit into the type, and `flow-branch-pure` for a
  deterministic split. Recursion is in the type, so a branch is a sub-pipeline.
  `prog/prapanca/profile/skills.chiral` is the enumerable registry over seven skill
  profiles. Four of the five L0 rows in `.planning/MANAS-SKILL-GROWER.md` are
  therefore already answered by the tree; row 5, the tiny-step lint, is the one
  that is genuinely absent, and it belongs with `text-tools` in shape.
- **No re-point of `zero-python`.** Its goal is written down and its done
  condition is absolute. Softening it to fit criterion 4 is exactly the author
  call, and a proposal cannot take it.
- **No element numbers.** `docs/decisions/decision-lane-split.md` reserves
  `E184-E189` and `E190-E195`. Everything owed here writes `UNASSIGNED` and stops.

## 5. The two blocking author calls

Both are rows in `records/author-calls.md`, added by this pass, and that file
holds their statement. Summarised here only far enough to say what each blocks.

**A. Python: outside the tree, or inside it.** `docs/goals/self-tooling.md`
states done as no `.py` file anywhere under `/workspace/chirality`, with
`tools/` deleted. Criterion 4 wants Python for fine tuning. Two readings survive
the author's sentence, a spawned external process whose scripts live outside
this repo and `.py` files inside the tree under a carve-out, and
`records/author-calls.md` states what each permits and costs. It blocks arc C
entirely, and it decides whether `goals/local-ai` and `goals/self-tooling`
conflict at all.

**B. The element block.** `docs/decisions/decision-lane-split.md` reserves
`E184-E189` for Lane A and `E190-E195` for Lane B, and nothing else. Arcs A and
C write `UNASSIGNED` and stop. `arcs/text-tools-arc`'s P2, P3 and P4 rows are
stopped on the same thing and that arc already has its own row, so one ruling
covers both. Arc B is exempt: `S#` is its own namespace.
