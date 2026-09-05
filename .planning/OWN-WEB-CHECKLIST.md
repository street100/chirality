# own web: the vocabulary and canvas checklist

**Minted 2026-09-05.** Row authority for the `M`, `F`, `G`, `P` and `Q` id
spaces. The arcs that own these rows are `docs/arcs/vocabulary-arc.md` and
`docs/arcs/canvas-arc.md`; their REQUIREMENTS sections and resume states govern
order and scope, and this file carries the rows with their state.

The design is `.planning/OWN-WEB-GAP.md`, with `.planning/REACH-MODEL.md` for
how a value moves and `.planning/CRYPTO-MODEL.md` for what every layer
consumes.

**State**, against `docs/decisions/decision-design-before-mint.md`:

| state | means |
|---|---|
| `design` | ready for an `element-design` run, writing `docs/arcs/parts/<arc>-<id>.md`. No `E#` exists yet and none is wanted |
| `blocked` | a named row or gate lands first |
| `decide` | an author call lands first |
| `owed` | **no row exists yet.** The work is named and nothing carries it |

Rows are grouped by pipeline stage rather than by arc, because
`OWN-WEB-GAP` lane P's stages are what the order follows. Stage 4 is the waist
and everything narrows through it.

---

### Stage 4 · the value

The vocabulary. Every lens reads into it and every view reads out of it.

| row | what | state | blocked on | size |
|---|---|---|---|---|
| **`vocabulary/F1`** | **closed element sums per context, so invalid nesting is unconstructible** | **`design`** | none. **Run this first** | ? |
| `vocabulary/M6` | a role carried as a required field, and no style | `design` | none | ? |
| `vocabulary/F2` | the size bound in the type, demanded before accepting | `design` | none | ? |
| `vocabulary/M5` | the version field, and a total handler over it | `design` | none | ? |
| `canvas/G4` | a closed `State` sum with a total transition table, and a closed `Request` sum | `design` | none. **Rostered under the canvas and it is vocabulary work**, since both sums are part of what a document holds | ? |
| `vocabulary/M1` | the mark has a file kind and the loader checks it | `decide` | the file-kind call. `.manifest` refuses a generated document, so either that is `M2`'s job or `MAP.md` grows a kind. `arcs/file-types-arc` owns those kinds | ? |
| `vocabulary/M4` | an unknown mark is refused | `blocked` | `F1` | ? |
| `vocabulary/M2` | a generated document is a program that emits a mark | `blocked` | `M1` | ? |
| `vocabulary/F3` | node addressing | `design` | none. The shard ships at `apc.chiral:48` with two importers under `tools/` and no shipping producer. This row measures reach, the class `display-calculus/A1` is | ? |
| `vocabulary/F4` | one text form, and nothing renders from it | `blocked` | `F1` | ? |
| `vocabulary/M3` | the round-trip law | `blocked` | `F1`, `F4` | ? |
| `vocabulary/F5` | two readers agree by construction | `blocked` | `F1` | ? |

### Stage 6 · the presentation

**Every row here is owed.** `Doc` is layout, `Rendering` is nine terminal
constructors, and `display-calculus/Z1` says a display list is a closed sum
without saying what is in it. Stage 5 targets it, so the canvas cannot be
designed past `G3` until it exists.

| row | what | state | blocked on | size |
|---|---|---|---|---|
| **owed** | **the display list: what constructors it carries** | **`owed`** | it is `display-calculus/Z1` and no arc is working it | ? |
| **owed** | the lowering from the vocabulary into `Doc`, for text surfaces | `owed` | `F1` | ? |
| **owed** | `display-calculus/R3`, the span primitive | `owed` | **an author call on which arc owns it.** Nothing draws varying content in linear time until it lands | ? |

### Stage 5 · the view

| row | what | state | blocked on | size |
|---|---|---|---|---|
| `canvas/G3` | the port set is the border, and nesting reduces it | `design` | none. **The first `.profile` instance**, closing `binary-split/B4` and `BA-10` | ? |
| `canvas/G2` | a canvas does not own its surface | `design` | none. It is the host split and it needs no vocabulary | ? |
| `canvas/G1` | a canvas is a pure view function | `blocked` | `F1`, and stage 6 for anything past the terminal | ? |
| `canvas/G5` | the declared `State` is the every-state witness | `blocked` | `G4` | ? |
| `canvas/G6` | a canvas asks for nothing on a document's behalf | `blocked` | `G3` | ? |
| `canvas/G8` | one value reaches many hosts | `blocked` | stage 6, and stage 7's blockers for the second host | ? |

### Stage 7 · the host

| row | what | state | blocked on | size |
|---|---|---|---|---|
| **owed** | **what a host is, and how canvases compose into one surface** | **`owed`** | it is `goals/own-web` condition 5 and it holds no arc | ? |
| **owed** | the fd-passing crossing | `owed` | **an author call on which arc owns it.** `sock-send-fd` is absent from the 44 lowered crossings, so nothing reaches a screen | ? |

The terminal host exists at `lib/protocol/render.chiral` and is unaffected by
both, so every `design` row above is reachable through it.

### Stages 1 to 3 · the lens

| row | what | state | blocked on | size |
|---|---|---|---|---|
| `canvas/P2` | a lens re-spells the vocabulary and never extends it | `design` | none. It is a law and statable now | ? |
| `canvas/P4` | lenses come last | `design` | none. A stated ordering | ? |
| `canvas/P1` | a lens is a reader and a view beside the existing pair | `blocked` | `F1` | ? |
| `canvas/P3` | the round trip separates viewing from editing | `blocked` | `M3` | ? |

Stage 2 arrives free for an s-expression-shaped lens, because
`lib/surface/sexp.chiral` is generic over s-expressions.

### The harness

| row | what | state | blocked on | size |
|---|---|---|---|---|
| `canvas/Q2` | a host's closure carries no compiler | `design` | none. `binary-split`'s marker count, `BA-16` | ? |
| `vocabulary/Q1` | the round-trip gate | `blocked` | `M3` | ? |
| `canvas/Q4` | the hostile-document corpus, every refusal named | `blocked` | `F1` | ? |
| `canvas/Q3` | the two-host gate, compared structurally | `blocked` | `G8` | ? |
| `canvas/Q5` | the every-state walk, run as a phase | `blocked` | `G5` | ? |

---

## Rows owed elsewhere

Named in the models, carried by no arc, and each needs a row before it can hold
a state.

| what | where it is named | who should carry it |
|---|---|---|
| **reach as an arc** | `REACH-MODEL` entire, with requirements and rows already written | an `arc-open` run against `goals/own-web` condition 3 |
| **the primitives as an arc** | `CRYPTO-MODEL` entire | an `arc-open` run against condition 4 |
| the fourth verb, ask-by-seal, and pointer freshness | `REACH-MODEL` `R23` | the reach arc |
| what bounds holder storage | `REACH-MODEL` `R19`, the one unbounded resource in the model | the reach arc |
| what a `Seal` is, and pairing end to end | `canvas/G7`'s precondition | the reach arc, or the canvas arc |
| the refusal vocabulary | both models' notes to cover | whichever arc reaches it first |

## The design exercise owed

**The authoring walk.** `REACH-MODEL` §13 walks fetching and found the fourth
verb and the freshness problem by walking it. Authoring has never been walked:
make a thing, address it, hold it, let someone else get it. That path crosses
the lens, the vocabulary, the mark, the holder, the pointer and the signature.
It is the cheapest way left to find what is missing, and it costs one pass.

## Order

1. `vocabulary/F1`. Everything narrows through it.
2. The stage 4 `design` rows beside it: `M6`, `F2`, `M5`, `G4`, `F3`.
3. The authoring walk, which needs only `F1` to be shaped.
4. The stage 6 `owed` rows, since stage 5 cannot pass `G3` without them.
5. `canvas/G3` and `G2` in parallel with any of the above, since neither needs
   the vocabulary.
6. Everything else unblocks behind those.

The four author calls in `records/author-calls.md` block implementation and
block none of the design above.
