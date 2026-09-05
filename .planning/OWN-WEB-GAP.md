# The own web: the feature-goal roster

**Opened 2026-09-05** from a design session with the author. This is an
**outline of coverage**. No row is specced, nothing is minted into
`docs/elements/catalog.md` or `docs/elements/ledger.md`, and no code is
touched. §7 is the mint queue that runs before any row here may be cited by a
spec, per the no-phantom-dep rule in `docs/definitions/working-discipline.md`.

The question this answers: **what does it take to replace the web design stack
and the browser with one design language and one native reader, over a fabric
whose addressing is not IP's.**

The question it does not answer: how any row is built, in what order beyond a
sketch, or whether it should be. Those are spec tier and author tier.

**Author statement, 2026-09-05.** The web layer is a forethought and gets
designed first. The layers under it are shaped by what a document, an address
and a reader turn out to be, so speccing transport first would guess all three.

**Inspiration ruling, author, 2026-09-05.** `/workspace/jala` and
`/workspace/jala-setu` are idea sources. Their language, their crate structure,
their daemon shapes and their surrounding policy plumbing stop at the door. §2
states what crossed.

Those two are the author's own design notes and
`docs/decisions/decision-inspiration-policy.md` has no tier for that case, so
the ruling above stands on its own. The policy does reach the reference class
behind them. Reticulum is external prior art, its rule of thumb applies
verbatim, and this roster takes it as **Tier P**: the protocol description is
the paper and the Python reference implementation is a kernel in a repo that
nothing here reads. Its license is unverified from this sandbox, which the
policy's own license floor requires stating.

**Scope ruling, author, 2026-09-04, still standing.** Rendering HTML, CSS, JS
or HTTPS from a foreign server is out. Every row below is a local primitive or
a crossing this tree declares for itself, so the ruling permits the roster and
§8 sorts the rows by what is reachable inside it.

---

## §1 · Measured baseline

Measured 2026-09-05 in the working tree.

| where | what |
|---|---|
| `lib/prelude/doc.chiral:77` | the closed six-constructor `Doc` algebra. `d-tag` carries a `Str` face key over an open keyspace |
| `lib/protocol/apc.chiral:48` | `block-id : (-> Rendering Str)`, FNV-1a-64 content-hash addressing over `r-section` and `r-hole`, derived and never stored, recomputed by the decoder and verified. 286 lines, E112, built |
| `lib/protocol/http.chiral:101` | `parse-url`, returning `url-ok host port path`. Requires a dotted quad and an explicit port |
| `lib/protocol/inet.chiral` | dotted-quad parse and the `sockaddr_in` packer, pure, sitting outside `ports/` because it computes over a crossing declared elsewhere |
| `lib/ports/sock.port:54-74` | the socket registry. Client-side AF_INET connect, unix listen and accept, send, recv, fd passing, socketpair, poll. Every cap linear |
| `lib/ports/sock.port:69` | `sock-recv` takes a `(refine I64 (> 0))`, so a read length carries its bound in the type |
| `lib/ports/pool.port:3-5` | the buffer supply carries its size in the port type. `(Pool 16384)` and `(Pool 4096)` are different types, and the header states that a target can demand a bound |
| `lib/typing/kernel.chiral:60` | `Profile` is a kernel type: `(name Str) (ports (List Str)) (target Str) (memory (Maybe Str)) (total Bool)` |
| `lib/lowering/compile-front.chiral:293-301` | `profile-ports` and `pm-isect`. A composite's admissible port set is the intersection of its profiles' |
| `lib/typing/totality-check.chiral:130-139` | the profile gate over the whole composite, reading `total` off each profile |
| `lib/protocol/wire.chiral` | the Wayland wire codec, 96 lines, zero libwayland |
| `lib/capability/secret.chiral` | Secret custody, E40. Its own header: "No crypto here" |
| `lib/crypto/chacha.chiral` | ChaCha20 green on both RFC 8439 vector rows in `tools/test/crypto.sh`. `native-protocol/N1` slice 1 |

### What is absent

Grepped 2026-09-05 across `lib/` and `prog/`: zero hits for a document file
kind, zero for an address type, zero for a reader or user-agent program, zero
for a link state machine, zero for an identity bundle, zero for a destination.
`find . -name '*.profile'` returns nothing, so the kind `MAP.md` documents has
zero instances and zero consumers. That is `binary-split/B4`, measured as
`records/baseline-alignment.md` BA-10.

The layer above the link is empty in both trees. `/workspace/jala`'s own layer
diagram writes `application / service layer (outside jala)` at the top and
stops there. `docs/arcs/native-protocol-arc.md` stops at the handshake, the
framing and the quorum store. Nothing on either side owns the layer where a
document, an address and a reader meet.

---

## §2 · What crossed from the inspiration, and what stopped

Read 2026-09-05 from `/workspace/jala/.planning/` and
`/workspace/jala-setu/.planning/`. jala is a clean-room reimplementation of
Reticulum. Its ideas are the reference class for lanes X, L and J.

**What crossed, as ideas.**

| the idea | why it survives translation |
|---|---|
| the address is the hash of the identity | it removes the authority and the lookup in one move. A hash is a value, and this tree already computes one as an address at `apc.chiral:48` |
| no source field on the wire | the strongest form of the idea is structural. A constructor with no source field cannot be given one |
| pair-gating: strangers route and cannot address | it makes an access rule a consequence of key possession, so nothing has to enforce it separately |
| a foreign transport is a bridge that translates at its boundary | `MAP.md` already says a file belongs in `ports/` iff it declares a crossing, which is the same rule with a checker behind it |
| the bridge never sees the payload | expressible as a type. A bridge whose argument is opaque `Bytes` cannot be handed a decoded frame |
| MTU is per-interface and negotiated | `pool.port` already puts a buffer's size in the port type and lets a target demand a bound |
| the link as a long-lived session with an explicit teardown | every cap in `sock.port` is already linear, so a use-after-teardown is a type error here |
| announce-then-resolve instead of a resolver protocol | reaching and naming stay one mechanism |

**What stopped at the door.**

Rust, the crate layout, the `Interface` trait as a trait, tokio, the per-bridge
daemon shape, dinit supervision, the kavacha wrapper, the saksin audit sink,
the bija key-custody split, the TOML schemas, the shrednet config layer, and
the PQ library menu. The suite choice is a `native-protocol` question and this
roster takes no position on it.

**What the inspiration does not have.** jala's layer stack ends at the link and
hands the application layer to somebody else. Reticulum's own answer to the
layer above is NomadNet, whose pages are addressed by destination hash and
written in a markup called micron, and no file in `/workspace` mentions it.
Lanes M, F, G and Q have no source in the inspiration and are drawn from the
reference class in §3 plus what this tree already carries.

---

## §3 · The feature goals

Reference class per row. `OURS` means an in-tree baseline exists to compare
against. `EXTERNAL` means the comparator is another system.

**Kind** is what the row produces, and it is the anti-monolith column. A design
feature that is one subsystem elsewhere lands here as several rows in different
homes, per the refraction rule in `docs/banks/INDEX.md`.

| kind | what the row produces | where it lives |
|---|---|---|
| `primitive` | a type carrying an invariant, or a value | the module that owns the concept |
| `law` | a total function plus the property it satisfies | beside its primitive, with the property in the gate |
| `port` | a crossing, and its extern surface | `lib/ports/`, a `.port` file |
| `tool` | a program that consumes the primitives and reports | a `.prog` root, or a phase in `tools/test/` |
| `decision` | a fork the author settles before any row cites it | `docs/decisions/` |

### Lane M · the mark, what an author writes

| id | goal | what the reference does | the chirality representation | kind | class |
|---|---|---|---|---|---|
| M1 | **The mark has a file kind, and the loader checks it** | HTML is identified by sniffing, by extension and by a `Content-Type` header that is frequently wrong, and the three disagree | one of `MAP.md`'s kinds, checked where `.manifest` is checked. A manifest is a module whose every `def` body is a literal, which the loader holds the terms to verify | `decision` | `OURS` (`.manifest`, `.planning/MANIFEST-DESIGN-MAP.md`) |
| M2 | **A generated document is a program that emits a mark** | JSX, Handlebars, Jinja and Svelte each add a template dialect with its own scoping, its own escaping and its own errors | the language is the template language. A document with loops in it is a `.prog` whose output is a mark, so the author writes ordinary chirality and the mark stays data | `law` | `EXTERNAL` |
| M3 | **The mark round-trips through its own text form** | `innerHTML` and `document.write` make the source and the DOM two different trees, and neither is the truth | parse then print is byte-identical, asserted as a law. `docs/examples/C1C2-style-round-trip.md` is the shape of the gate and reached exit 42 off-tree | `law` | `OURS` (E4, C1C2) |
| M4 | **An unknown mark is refused** | HTML ignores unknown elements and unknown attributes deliberately, which is how the platform grew and also how one document means two things in two readers | the constructor set is closed, so an unknown mark fails to load. Forward compatibility becomes M5's version field, checked once | `primitive` | `EXTERNAL` |
| M5 | **The mark declares its version, and the reader refuses one it cannot total** | a browser renders a page written for any version of anything, and degradation is per-feature and silent | the version is a field, the reader's handler is total over a closed version sum, and an unhandled version is a named refusal | `primitive` | `EXTERNAL` |
| M6 | **The mark carries a role and carries no style** | a page ships its own CSS and the reader's stylesheet loses almost every conflict | the mark carries a role from a closed sum. The theme is the reader's value, which is `display-calculus/C5` and `H4` pointed at a document the reader did not write | `law` | `OURS` (`Mode.faces`, discarded at `command-loop.chiral:96`) |

### Lane F · the document, the typed value a mark becomes

| id | goal | what the reference does | the chirality representation | kind | class |
|---|---|---|---|---|---|
| F1 | **The element vocabulary** | HTML content models are validated after parsing, and the parser's error recovery is normative | `display-calculus/E1` through `E4` already hold this. This row is the dependency and mints nothing of its own | `primitive` | `OURS` (display roster) |
| F2 | **A document carries a size bound the reader demanded** | a browser fetches a page of unbounded size and the parser streams to survive it | the bound rides the type, the way `pool.port` puts a buffer's size in the port type and `sock-recv` takes a `(refine I64 (> 0))`. **The measurement makes this load-bearing**: `records/author-calls.md` records ~1,747 B of arena per input byte with no reclamation on any compiled path, and ~6.3 GB projected at the default scope against 3.85 GB with no swap. A reader accepting an unbounded foreign document is the allocation gap pointed at the network | `law` | `OURS` (`pool.port:3-5`, the allocation gap) |
| F3 | **Every node has an address, derived from its content** | a URL fragment is a string the author assigns, nothing checks it, and it re-points silently when the page is edited | `block-id` is built and shipped: FNV-1a-64 over the node's identity bytes, derived and never stored, recomputed on decode and verified, and it deliberately excludes the `collapsed` bit so folding a section does not re-key it | `primitive` | `OURS` (`apc.chiral:48`, E112, built) |
| F4 | **A document has one text form and nothing renders from it** | HTML is its own serialization, which is the reason the parser must be lenient | `print` is mandatory per type. Save, diff and grep work on the one truth. This is `display-calculus/E4` and this row states its consequence for a document that arrived from elsewhere | `law` | `OURS` (U19, E4) |
| F5 | **A document is a value, so two readers agree by construction** | two browsers rendering one page differ, and the reference-test suites exist because of it | the mark is data and the reader is a total function, so disagreement between two readers is a difference in their code and is findable by comparing two display lists structurally | `law` | `OURS` (`prog/manas/contract/golden.chiral`) |

### Lanes X, L and J · superseded

The address, the fabric and the crossing were drawn before
`.planning/REACH-MODEL.md` existed and **it is the authority for all three
now**. Their rows are kept nowhere here, because a roster row beside a worked
model is the second statement that drifts.

| what those lanes asked | where it is worked |
|---|---|
| the address, naming without an authority | `REACH-MODEL` §3, and the `Mark` and `Seal` split survives |
| open against gated reachability | `REACH-MODEL` §4, with `Grant` |
| media, the tether, and what IP costs | `REACH-MODEL` §5 |
| routes, the ceremony, the splice | `REACH-MODEL` §6 |
| routing, and the dumb hop | `REACH-MODEL` §7 |
| the crypto every one of them consumes | `.planning/CRYPTO-MODEL.md` |

### Lane G · the canvas, and the host that places it

**There is no browser and no widget toolkit.** A canvas is a **view function**
from a value to a presentation algebra, the same kind of thing
`lib/surface/pretty.chiral` already is for `Term`. A **host** puts a
presentation on a surface. State, ports and input belong to the program, and
never to the canvas.

| id | goal | what the reference does | the chirality representation | kind | class |
|---|---|---|---|---|---|
| G1 | **A canvas is a pure view function** | a widget is an object with mutable state, a mainloop and a registered callback, which is what makes widgets inseparable | `(-> Env State Node)`. The program holds the state, the host hands input in as data, and nothing is registered. **This is why canvases can be separate runtimes** | `primitive` | `OURS` (`pretty.chiral` is the working instance for a different value) |
| G2 | **A canvas does not own its surface** | a widget is bound to its toolkit's window, so re-hosting is a rewrite | the canvas emits a display list and a **host** places it. A window today, a DE layer later, and **the canvas is identical in both** | `law` | `EXTERNAL` |
| G3 | **The port set is the border** | GTK's `GdkDisplay` reaches through the whole stack, so "this widget does not touch the display server" is a convention | a **pure canvas has an empty port set**, an app-like one names its crossings, and the host owns the surface ports. Nesting **reduces** a port set, because a nested canvas needs no surface. `Profile` is live in the compiler: `kernel.chiral:60`, `compile-front.chiral:301`'s `pm-isect`, `totality-check.chiral:130`. **This is `display-calculus/H3` with a consumer, and the first `.profile` instance** | `tool` | `OURS` (live, zero instances) |
| G4 | **A document is data and carries no computation** | JS in the page is the entire security model of the web, and every mitigation since 1995 is a fence around it | no constructor holds a lambda. Behaviour is a **closed `State` sum with a total transition table** and effects are a **closed `Request` sum**, both data the program interprets. **The single highest-value invariant in this roster**, and it survives all the way to the app end | `primitive` | `EXTERNAL` |
| G5 | **The declared state is the every-state witness** | nothing in CSS or JS can state a property that holds across every reachable rendering | `arcs/display-calculus-arc.md` measures the cell lane's `(Env, State)` product at 1 and carries an open author call on which consumer witnesses `C9` and `H6`. A canvas declares a finite `State` because G4 forces it, so **the app-like end supplies the property instead of costing it** | `law` | `OURS` |
| G6 | **A canvas asks for nothing on a document's behalf** | cookies, storage, autoplay, notifications and geolocation are each a prompt bolted on after the fact, because the page can ask | a capability is held by the program, gated by a `Grant`. **One document, two hosts: a request a host's profile forbids is refused and the document still renders.** Graceful degradation with no negotiation | `law` | `EXTERNAL` |
| G7 | **`Grant` is one type at three layers** | ownership, authentication and authorization are three subsystems everywhere else | route formation, request honouring and value ownership all gate on the same value, and it **proves permission and never identity**, so anonymity survives at every one. `REACH-MODEL` §4 holds the route layer | `primitive` | `OURS` (E40 custody) |
| G8 | **One value reaches many hosts** | GSK routes one render-node tree to GL, Vulkan and cairo, and that split is what lets one vocabulary serve many surfaces | the terminal, a Wayland surface under a foreign compositor, and a DE layer. **`display-calculus/Z1`'s two-consumer test with three named**, so the display list is a proven seam | `law` | `OURS` (terminal live, the rest behind §8's two blockers) |

### Lane P · the pipeline, and the lenses over it

The compiler already runs this machine and the document path is its second
instance. Stage 4 is the waist: many lenses in, one value, many views out.

| # | stage | source instance, running | document instance |
|---|---|---|---|
| 1 | the written form | chirality source text | **nothing.** `M1` and decision `D2` |
| 2 | read, bytes to a surface AST | `sexp.chiral`, E1 | **free** for an s-expression lens |
| 3 | elaborate to the value | `parse.chiral` then `surface.chiral`, E2/E49 | its own elaborator, the same shape |
| 4 | **the value** | `Term` | **nothing.** `E1` and `E2`. `Doc` is a layout algebra where a document vocabulary is wanted |
| 5 | view, value to a presentation | `pretty.chiral`, E181, and **its output is source** | nothing |
| 6 | the presentation algebra | `Doc`, six constructors | `Rendering` at nine for the terminal. **A display list does not exist**, which is `Z1` |
| 7 | host, presentation to a surface | `render.chiral` emits SGR | `sprites.chiral` writes ARGB8888, behind §8's blockers |

| id | goal | the chirality representation | kind | class |
|---|---|---|---|---|
| P1 | **A lens is a reader and a view sitting beside the existing pair** | `pretty.chiral`'s header states the split: `surface/parse` reads, this writes. A lens is additive, one module pair and one gate, and nothing else moves | `primitive` | `OURS` |
| P2 | **A lens may re-spell the vocabulary and may not extend it** | the parse direction has nowhere to put a concept stage 4 cannot hold. So a design concept worth having belongs in the **vocabulary**, and the lens only makes it pleasant to write | `law` | `EXTERNAL` |
| P3 | **The round trip is what separates viewing from editing** | a read-only lens prints. An **editable** lens prints and parses and the trip closes, which is `E4` and `M3`. Manipulating a design surface is the parse direction running | `law` | `OURS` (`pretty.chiral` is the existing proof) |
| P4 | **Lenses come last** | a lens cannot be designed against a vocabulary that does not exist, which inverts the intuition that the authoring surface is designed first | `decision` | `OURS` |

### Lane Q · the harness

| id | goal | what the reference does | the chirality representation | kind | class |
|---|---|---|---|---|---|
| Q1 | **The round-trip gate** | browsers gate on reference tests: render two documents and compare pixels with a fuzz factor | a mark parsed and printed is byte-identical, with no fuzz factor because both sides are values. The gate root exits 1 on the unmodified tree and 42 once the property holds, which is the shape `C1C2` demonstrated | `tool` | `OURS` (C1C2) |
| Q2 | **The reader's closure carries no compiler** | a browser ships a JIT, and that is the point | counted as `^(end-module "` markers on the blob, which is `binary-split`'s method. `records/baseline-alignment.md` BA-16 measured two text tools carrying the whole x64 backend for a ten-line fd reader | `tool` | `OURS` (BA-16, BA-17) |
| Q3 | **The two-surface gate** | reference tests compare one renderer against a stored image | one document, two surfaces, two display lists, compared structurally. `prog/manas/contract/golden.chiral` already does this for run manifests | `tool` | `OURS` |
| Q4 | **The hostile-document corpus** | browser fuzzing corpora exist because the parser is lenient and the attack surface is the leniency | a corpus of malformed, oversized, wrong-version and adversarial marks, each refused by a **named** outcome. A refusal with no name is the silent arm `lookup-face` already demonstrates at `render.chiral:167` | `tool` | `EXTERNAL` |
| Q5 | **The every-state walk, instantiated** | nothing in CSS or JS can state a property that holds across every reachable rendering | `display-calculus/C9` and `H6` with the reader as the witness. Contrast, overflow, focus visibility and unstyled roles checked in every reachable `(Env, State)` pair | `tool` | `EXTERNAL` |

**Count: 28 rows across five lanes. 9 primitives, 12 laws, 6 tools, 1 decision.** The
address, the fabric and the crossing left this roster for
`.planning/REACH-MODEL.md`, and the pipeline lane arrived with them gone.

Nine rows are pointers into rosters that already exist: F1, F4, G4, G6 and Q5
into `arcs/display-calculus-arc.md`, J5 into `arcs/native-protocol-arc.md`, and
Q2 into `arcs/binary-split-arc.md`. They mint nothing and they record the
dependency so a spec cannot cite a row that has no home.

---

## §4 · What crosses a lane and what does not

**Crosses.** Lane M and lane F entire. The mark, the document value, the
address of a node and the text form are the same machinery whether the document
came off local disk or off a crossing. The reader's port set (G1) crosses,
because the profile mechanism is indifferent to what the ports are for.

**Does not cross.** The property vocabulary, per the display roster's own lane
ruling. A reader on a character grid and a reader in a window share the
document and share the calculus, and they share no property set.

**The consequence, and it is the shape of the whole roster.** The mark is
parameterised over a property algebra per surface. Two readers share a
document. They do not share a stylesheet.

### What Reticulum settles, and what it does not

| take | why |
|---|---|
| identity-as-address | it deletes the resolver, the authority and the certificate at once |
| no source on the wire | the property is unreachable once the field is gone, and a field is cheap to not have |
| pair-gating as the default | it makes reachability and addressability two different things, which IP conflates |
| transport as a pluggable edge | it is the same rule `MAP.md` already states about `ports/` |

| refuse | why |
|---|---|
| flooding announcements | jala already names it as an upstream limit to correct, and the correction is open |
| the destination hash as the only address form | D1. Node-granularity content addressing is built here and answers a question Reticulum does not ask |
| a protocol that stops at the link | the layer above is where this project's whole claim lives |
| a canonical hardware story | jala names RNode entanglement as a limit to correct, and this tree has no hardware |

---

## §5 · Decisions owed

| id | decision | why it is a decision |
|---|---|---|
| D1 | ~~Endpoint or value~~ | **Answered in `REACH-MODEL` §3.** It was a false fork: a `Mark` addresses a value and a `Seal` addresses a party, they are different types, and a party's answer is a document with a mark, so the mutable layer returns immutable values |
| D2 | **Which file kind a mark is** | M1. `.manifest` fits a static document and refuses a generated one, because a manifest's every `def` body is a literal. Either a mark is a manifest and generation is M2's separate `.prog`, or `MAP.md` grows a sixth kind. `.planning/MANIFEST-DESIGN-MAP.md` and `.planning/FILE-KIND-STRUCTURES.md` are the inputs |
| D3 | **Where the size bound is enforced** | F2. `pool.port` puts it in the port type and `sock-recv` puts it in a refinement, so the tree has two precedents and they are at different layers. The allocation figure in `records/author-calls.md` makes the choice load-bearing rather than stylistic |
| D4 | **Does the mark carry any style at all** | M6. The strong form is that it carries a role and nothing else, and the reader owns every visual decision. The weak form lets an author express intent the reader may honor. The strong form is the recommendation and it is the one that makes a reader's theme total |
| D5 | **What a canvas's `State` sum is** | G4 and G5. `arcs/display-calculus-arc.md` carries an open author call on which consumer witnesses `C9`, and this roster proposes a canvas. The call stays open until a `State` sum is written down, because a walk over an undeclared product proves only that the phase runs |
| D6 | **Public documents and pair-gating** | moved to `REACH-MODEL` §4's open-against-gated axis, and it stays open there |
| D7 | **Whether authoring and viewing share a host** | G3. A host that also authors holds the write path and the untrusted-input path in one port set, which is the boundary a profile exists to draw |
| D8 | **Which host comes first** | G2. A terminal host exists today. A Wayland host is behind §8's two blockers. A DE-layer host is behind the window arc. The first host decides how much of lane G is reachable now |
| D10 | **Where the doc-like to app-like spectrum is cut** | G4. Behaviour as a closed `State` sum with a total transition table, and effects as a closed `Request` sum, keeps a document pure data at the app end. Whether both sums are one vocabulary or two is the fork |
| D11 | **Whether a canvas declares which display-list constructors it may emit** | G3. That would make surface capability checkable the same way the port set is, at the cost of a second declaration per canvas |
| D9 | **Whether `Role` carries an address-bearing arm** | inherited from the display roster's D10, unchanged and now with a second consumer. `docs/banks/text.md:75-77` records that `d-tag`'s open keyspace is what lets an address ride on rendered output at zero width. Closing the keyspace closes that, and F3's `block-id` is the other addressing surface in play |

---

## §6 · Proposed goal, arcs and rows

Following `docs/decisions/decision-work-ids.md`: an arc holds rows with
arc-local ids, and a row maps to an element or to nothing. No arc below holds a
reserved element block, so every row maps to `unminted` until the author
assigns one. `records/author-calls.md` already carries that call for ten arcs
and these would extend it.

**Proposed goal: `goals/own-web`.** The done-condition, one sentence: **a
document authored in this tree, addressed without a global namespace, carried
over a crossing the fabric does not trust, and read by a program whose port set
forbids it from doing anything else.**

Its relation to the two goals that exist:

- `goals/display` supplies the calculus and the element vocabulary. Its
  **seam** condition gets its second consumer here (G6), which is the
  two-consumer test `Z1` states and the display roster defers.
- `goals/native-stack` supplies the wire. Its **document** condition and this
  goal overlap, and `records/author-calls.md` already carries the open call on
  whether `arcs/native-document-arc` survives. This roster gives that call a
  third option: the document arc closes into this goal.

### The arcs

The section boundary is the done-condition, per the display roster's own rule:
an arc is one sentence that becomes true.

| arc | what becomes true | rows | state |
|---|---|---|---|
| **the vocabulary** | a document is a typed value with one text form, and nothing that reads it can be surprised | M1 to M6, F1 to F5, Q1 | **mint this one.** It is stage 4, the waist everything narrows through |
| **the canvas** | one value reaches many hosts through view functions whose port sets are frozen and checked | G1 to G8, P1 to P4, Q2 to Q5 | mint this one once the vocabulary closes |
| reach | one instance gets a value from another | `REACH-MODEL` | **worked in depth there.** It holds no rows here |
| crypto | the primitives every layer consumes | `CRYPTO-MODEL` | **worked in depth there.** It holds no rows here |

**Two arcs are proposed for minting and three stay as conditions in the goal
file.** `records/author-calls.md:27` records nine arcs already writing rows
against no reserved block, logged as a defect. Three more arc files nobody can
start would repeat it. A condition in a goal file is citable and costs nothing.

**The mark arc is reachable inside the current scope ruling.** Every row in it
is a local primitive over a file on disk, with no crossing and no compiler
change. The reader arc is reachable to the extent D8 says so.

---

## §7 · The mint queue

Runs before any row above is cited by a spec.

1. **A decision doc for D1**, `docs/decisions/decision-address-form.md`. It is
   cited by X1, X3, X4, X5, F3 and the whole address arc, so it is first. The
   display roster's D1 went first for the same reason and settled in one pass.
2. **A decision doc for D2**, `docs/decisions/decision-mark-kind.md`. It
   decides whether `MAP.md` grows a kind, and `MAP.md` is the tree contract, so
   nothing in lane M can be specced around it.
3. **The goal file** `docs/goals/own-web.md`, with the five conditions and the
   honest-limits section the schema requires.
4. **The two arc files** for the mark and the reader, each with its measured
   what-is-in-the-tree table.
5. **`records/author-calls.md`**: the inspiration ruling, D1, D2, D6, D7, D8,
   and the third option this roster gives the native-document merge call.
6. **A document bank, owed now.** The precedent's condition is met: §1 lists
   thirteen shards across ten homes, and F3 alone is a built and shipped
   addressing surface that a naive pass would propose building. `banks/render`
   exists and covers the render monolith. The document, the address and the
   reader refract into other homes, so that bank holds none of them. Skipping the bank is what cost
   the display roster a finding, recorded in `banks/render`'s own header.

---

## §8 · Sequencing sketch

Not a build order. Sorted by the standing scope ruling.

**Reachable now**, with no crossing and no compiler change:

| | rows | why now |
|---|---|---|
| the mark, end to end | M3, M4, M6, F1, F4, Q1 | a document on local disk needs no network. The round-trip law is the same shape `C1C2` already proved off-tree |
| the two measurements | moved to `REACH-MODEL` §14 | `parse-url` and the IP crossing are measured there |
| the profile instance | G3, Q2 | `Profile` is live in the compiler and `.profile` has zero instances. The first instance closes `binary-split/B4` and `BA-10` as a side effect |
| the built shard | F3 | `block-id` ships today with two importers under `tools/`. Measuring its reach is the same class of row as `display-calculus/A1` |
| the one decision | D2 | the file kind. It unblocks lane M's first three rows and stage 1 of lane P |

**Behind `native-protocol`**, per the arc's own resume state: every row in lanes
L and J beyond the two measurements. `N2` entropy and `N3` listen-side AF_INET
come before any of it.

**Two blockers stand between a canvas and a screen**, both measured, neither
owned.

| blocker | measurement |
|---|---|
| nothing reaches a screen | `lib/lowering/tal/crossing-wraps.chiral` has 44 lowered crossings and **`sock-send-fd` is absent from them**. `prog/demo/wl-client.chiral:201` calls it to hand the pool's memfd to the compositor, so that demo does not lower. `sock-listen`, `sock-accept` and `bind` are missing too, and nothing under `tools/test/` reads `prog/demo/`, which is why it went unnoticed |
| nothing draws varying content in linear time | `display-calculus/R3`, the measured wall. The pure `Bytes` surface is twelve externs with no `pack-u8`, no builder and no fill-with-function. `brepeat` makes a solid span and varying content has no linear-time path. It gates six rows in the raster lane, one in text and all of composite |

Sprites work. Real drawing does not, and the terminal host is unaffected by
either.

**Out of the immediate roadmap entirely**, per the 2026-09-04 scope ruling:
HTML, CSS parsing, JS, DNS, TLS, and any foreign document.

---

## §9 · Sources

Read 2026-09-05. In-tree citations carry their own file and line above.

- `/workspace/jala/.planning/PROJECT.md`, `ARCHITECTURE.md`: the layer stack,
  the identity model, pair-gating, the packet shape
- `/workspace/jala-setu/.planning/PROJECT.md`: the bridge boundary, the
  payload-opacity rule, the through-the-fabric rule
- `/workspace/shrednet/.planning/PROJECT.md`: the 2026-04-24 rescope. The name
  now denotes TOML config schemas and holds none of the protocol thinking
- `/workspace/shrednet-bootstrap/DECISIONS.md`: D-001 to D-004, the homelab
  address schema. Operational, and no input to this roster
- Reticulum protocol and NomadNet: <https://reticulum.network/manual/>
- Petname systems: Stiegler, *An Introduction to Petname Systems*
