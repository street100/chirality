# Shrednet recovery: what the author said, and where it went

A mining run over past Claude Code transcripts, 2026-09-22. It recovers author
statements about **shrednet**, about the **browser-like experience** the display
arcs serve, and about the **identity model**, and it says for each whether a
tracked file carries it today.

`.planning/FAILURE-MODES-2026-09.md:21` names the defect this answers as `A7`,
*"Lost a ruling given in session"*, and `records/lenses/problems.md` PRB-83
carries the worked instance in its 2026-09-13 amendment: *"The author had given
it on question C of `records/homing-triage.md` and the session had not written
it down"*, which cost a check 100 findings it should have reported as 99.

This run decides nothing. It does not reconcile the readings of shrednet, does
not pick one, proposes no goal, no arc and no roster row, and applies no ruling
to an open author call. Every quote is verbatim, including the author's
spelling.

## How to read a row

| label | means |
|---|---|
| `AUTHOR` | the user typed it. A `message.role` of `user` carrying a text block |
| `SESSION` | a past assistant turn said it. Evidence of what that session thought |
| `FILE` | the text of a file a session read into its context. Authored outside this tree, and neither of the two above |

A transcript address is `<project slug>/<session uuid>`, a line number in that
`.jsonl`, and the entry's own timestamp in UTC. The session that dispatched this
run is `-workspace-chirality/619b6457-a2f5-4f60-b744-4eb049f8dc14`, whose turns
carry a `2026-09-23T02:xx` UTC stamp and fall on 2026-09-22 local.

---

## §1 · Shrednet: what it is, and where it went

### A1 · The name enters this tree

> ok wait so we can expand then. If we do this i might as well do these first 1.
> chirality native network protocol (with crypto elements being a requirement,
> shrednet as base idea to pull from) 2. wayland window app (im naming it
> stupidly but not a terminal app and cant be browser)

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/43cf1dc1-77d4-4827-b10c-2c04b07adaa9`, line 58, 2026-09-03T04:06:10.960Z |
| tracked | partially. `docs/arcs/native-protocol-arc.md:16-17` opens the arc on it, and `docs/arcs/native-window-arc.md:16-17` opens the window arc on the second item |
| contradicts | `docs/arcs/native-protocol-arc.md:18` and `:63` render this as *"the shrednet mesh's identity model as the base idea"*. The author wrote *"shrednet as base idea to pull from"* and named no identity model |

The phrase the arc carries was minted by the session, six minutes later. §1 `S1`
holds it.

### A2 · Shrednet needs crypto before it can be claimed

> can crypto and shrednet go alongside this? to claim shrednet we need to have
> stuff for it. Most things we want for shrednet need crypto

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/ba6de7e9-2de0-4b34-8429-3275d936f7db`, line 899, 2026-09-04T00:26:56.072Z |
| tracked | `NOWHERE`. `docs/goals/own-web.md:46-50` states condition 4, the post-quantum primitives, and attributes it to no such statement. No tracked file says shrednet is a claim this tree has to earn |

### A3 · Shrednet is the outside-the-repo raw material

> can you orient for the visual design elements? we need to continue minting
> everything we need to build. I'm looking for fleshed out visual design ability
> as a separate connonical cousin binary to the main minimal. I am looking to
> build: literally our own form of the web. the idea here is to replace web
> design stacks and browsers with 1 design language and a native browser for a
> new form of web that isnt ip model. A lot of this is shrednet stuff (which is
> docced outside this repo mostly and is raw ideas).

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d-2349-4be1-a4e4-9913547c5d46`, line 6, 2026-09-05T18:52:20.887Z |
| tracked | in part. `docs/goals/own-web.md:15-18` carries *"replace the web design stack and the browser with one design language and one native surface, over a fabric whose addressing is not IP's"* |
| `NOWHERE` half | *"a separate connonical cousin binary to the main minimal"*. `docs/arcs/canvas-arc.md:86` (`canvas/Q2`) and `.planning/OWN-WEB-GAP.md:214` reach the closure-size half of it through `binary-split`'s method, and no tracked file states the author's own framing: the display ability is a second shipped binary beside the minimal one |
| `NOWHERE` half | *"A lot of this is shrednet stuff … docced outside this repo mostly and is raw ideas"*. No tracked file records that the author placed shrednet's content outside this repository and called it raw |

### A4 · Start from the web, and IP is a grudging transport

> Theres a lot of nuance here. The goal of this inline chat is to adjust what we
> have documented to be built to actually carefully specified things. Let's
> slice and go in depth on these layers. Like, for actually full functionality
> we do unfortunately have to integrate ip model as a transport but I don't
> really want to, so we're just going to scope what we need to for systems that
> assume ability to complete the chain. Can we actually start from web? kind of
> has to be a forethought from the getgo. Review shrednet thoughts

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 160, 2026-09-05T18:58:39.522Z |
| tracked | `.planning/REACH-MODEL.md:12-19` carries both rulings as rows, at `:14` and `:15`: *"the web layer is designed first"* and *"IP is mostly ignored, and enters as a primitive that breaks the model on purpose"*. `.planning/OWN-WEB-GAP.md:16-18` carries the first |

### A5 · The outside sources are inspiration and get retranslated

> again. its an inspo and idea thing. We arent going to use rust and a lot of
> the things outlined (like theme stuff) is irrelevant here. we need to pull
> thoughts and translate to chirality best form (because chirality literally
> allows the best for every best choice for something like this)

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 242, 2026-09-05T19:03:37.705Z |
| tracked | `.planning/OWN-WEB-GAP.md:20-24` and `.planning/REACH-MODEL.md:19` carry the inspiration ruling, naming `/workspace/jala` and `/workspace/jala-setu` as idea sources whose language and structure stop at the door |

### A6 · Stop attaching to old names

> stop whining about the name. we need to come up with the set of things and
> name them for chirality as apart of this so instead of whining suggest
> something besides attaching to old names. Lets address the model carefully. I
> am asking for you to go over it with me not fire off edits

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 354, 2026-09-05T19:15:06.842Z |
| tracked | `NOWHERE`. This is a standing naming directive and no tracked file carries it |
| contradicts | `docs/arcs/native-protocol-arc.md:18` and `:63` still attach the roster row to the old name eighteen days later, which is the practice this ruling closed |

### A7 · Shrednet is a tool set, sized by what the protocol needs

> Lets outline this from a what tools we want out of it perspective, like we're
> trying to get pq handled better to be tinier for the purposes of shrednet
> (very encrypted native chirality take on internet protocol with security,
> reference as many docs as you can, and the language level shamir stuff, and
> etc. use them to make a bunch of tables of exposed toolset identity to
> required primitives with feature that requires it as a column. ledge status as
> a column too

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/619b6457-a2f5-4f60-b744-4eb049f8dc14`, line 512, 2026-09-23T02:38:33.753Z |
| tracked | `NOWHERE`. `.planning/CRYPTO-MODEL.md` holds the twelve layers and no tracked file states shrednet as *"very encrypted native chirality take on internet protocol"* |

### A8 · The author asked what the tree thinks shrednet is

> Can you tell me about what you think shrednet is so we can make sure its
> aligned? should be very specific

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/619b6457…`, line 541, 2026-09-23T02:40:51.128Z |
| tracked | `NOWHERE`, and the question is the evidence that the three readings below were never reconciled |

### A9 · Shrednet is the sum of exposed tools

> retire that dir we need to outlined the actual goal. Shrednet wont be a bunch
> of things which is why i asked for tables. Stop current agent because it's not
> going to be effective if this wasnt docced properly. Shrednet is going to be
> the sum of exposed tools that come together for the type of "web browser"
> experience we are going to go for with chirality, as typed canvas that use a
> chirality native crypto identity model for shrednet. Are you able to look at
> past chats? there have been chats about this if you can recover info about
> where shrednet went as well as the web browser stuff that the display arcs are
> happening for

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/619b6457…`, line 572, 2026-09-23T02:44:58.669Z |
| tracked | `NOWHERE`. This is the first statement in any transcript that says what shrednet **is** inside chirality, and no goal, arc, decision or planning file carries it. The phrase `typed canvas` appears in zero tracked files |
| contradicts | `docs/arcs/native-protocol-arc.md:18`, where shrednet is an identity model borrowed from a mesh. Here shrednet is the whole exposed tool surface of the browser experience |

### A10 · Shrednet is DNS-shaped and socket-shaped, configurable, rarely touched by hand

> Dont make assumptions. The goal is we have things similar to what is normally
> sockets? but it would be made secure using crypto for all levels and angles of
> internet routing. We dont want people directly using shrednet manually all the
> time but be more like a configurable set of things that provide similar
> primitives to dns but with more of a crypto based identity and routing model.
> This would be used to create rules to allow a cavas to be put up on the
> chirality native internet (talking hypothetically)

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/619b6457…`, line 622, 2026-09-23T02:51:00.001Z |
| tracked | `NOWHERE`. `.planning/REACH-MODEL.md:52` replaces DNS with a holdings summary and states no configurable rule layer above it. No tracked file says a canvas is **put up** on the fabric by a rule |

### S1 · The session that invented "the shrednet identity model"

> On shrednet: the `/kb` doc is the subnet/bridge schema for the mesh, an
> addressing convention rather than a wire protocol. So "shrednet as base" means
> the mesh's identity model, and the protocol reference class is Noise/WireGuard:
> X25519 + ChaCha20-Poly1305 + BLAKE2s handshake.

| | |
|---|---|
| whose | `SESSION` |
| where | `-workspace-chirality/43cf1dc1…`, line 100, 2026-09-03T04:08:28.283Z |
| tracked | yes, and as an author statement. `docs/arcs/native-protocol-arc.md:18` reads *"Opened 2026-09-03 by author statement: a chirality-native network protocol, crypto required, the shrednet mesh's identity model as the base idea"*, and the identity-model half is this inference |
| also carried | `docs/arcs/native-protocol-arc.md:63`, `.planning/NATIVE-STACK-EXPANSION.md:12-13`, `.planning/NATIVE-PROTOCOL-CHECKLIST.md:35` |

The reasoning is visible in the quote and it is a leap: the `/kb` document held
an addressing convention, so the session decided the author meant an identity
model, and the author was never asked.

### S2 · Two days later, the same lineage is retracted

> Reviewed. Short version: the shrednet you remember is not in the folder called
> shrednet.

> The protocol thinking lives in `jala` and `jala-setu`. jala is a clean-room
> Rust reimplementation of **Reticulum**. That is the base idea
> `native-protocol/N4` points at when it says "shrednet identity model", and the
> tracked chirality docs never name it.

| | |
|---|---|
| whose | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 230, 2026-09-05T19:01:41.802Z |
| tracked | half. `.planning/OWN-WEB-GAP.md:394-395` carries the rescope finding and `:81-82` carries the jala lineage |
| contradicts | `docs/arcs/native-protocol-arc.md:18` and `:63`, still standing today |

### S3 · The session named the defect and left it in place

> **The name is a red herring.** `/workspace/shrednet` was rescoped on
> 2026-04-24 to TOML config schemas with no runtime, and it orphans its own
> 7-crate Rust mesh VPN. The protocol thinking is entirely in `jala` and
> `jala-setu`. `native-protocol-arc` row N4 currently cites "the shrednet
> identity model", and that citation points at a config schema. It wants jala.

| | |
|---|---|
| whose | `SESSION` |
| where | `-workspace-chirality/6ecf719d…`, line 350, 2026-09-05T19:11:54.701Z |
| tracked | `NOWHERE` as a correction. The session wrote the finding into `.planning/OWN-WEB-GAP.md` §9 and left `docs/arcs/native-protocol-arc.md` unedited, so the tree has held both readings since 2026-09-05 |

The author's reply to the message carrying this was A5, which ruled on the
inspiration policy and said nothing about the citation.

### F1 · What `/workspace/shrednet` says it is

> name: shrednet
> description: TOML config schemas (plus validate/compile/diff tooling) for
> describing a bhumi peer arrangement. Declarative. No runtime. No daemon.
> Consumed by jala + jala-setu + bhumi-net + sutra. Priority V (post-v0
> refinement).
> status: post-v0 — spec-in-progress — scope corrected 2026-04-24
> supersedes:
>   - "2026-01-17 7-phase Rust mesh VPN framing"
>   - "2026-04-22 manifest-based arranger + CLI framing"

| | |
|---|---|
| whose | `FILE`, `/workspace/shrednet/.planning/PROJECT.md`, read into `-workspace-chirality/6ecf719d…` at line 193, 2026-09-05T18:59:29.177Z |
| tracked | `.planning/OWN-WEB-GAP.md:394-395` states the rescope and its date. The two superseded framings are recorded nowhere in this tree |

The same file states *"Not a Rust mesh VPN. The 2.4 GB pre-rescope codebase at
`workspace/shrednet/shrednet/` is orphaned under this definition"*, and
*"Not a key-material store. bija holds keys; shrednet configs refer to
identities by public fingerprint only."*

### F2 · What `/workspace/jala` says it is

> name: jala
> description: Rust implementation of Reticulum — native secure-lines protocol
> spoken between bhumi peers. PQ-capable, pair-gated identity. Own codebase;
> separate from jala-setu (bridges) and shrednet (TOML config schemas).

| | |
|---|---|
| whose | `FILE`, `/workspace/jala/.planning/PROJECT.md`, read into `-workspace-chirality/6ecf719d…` at line 197, 2026-09-05T18:59:42.939Z |
| tracked | `.planning/OWN-WEB-GAP.md:81-82` |
| contradicts | that line reads *"jala is a clean-room reimplementation of Reticulum"*. The file the session read says *"Rust implementation of Reticulum"*, and the word `clean-room` is the session's own, first typed at `6ecf719d…` line 230 |

### F3 · The third reading: shrednet as a subnet schema

> # shrednet — Subnet + Bridge Schema (locked 2026-06-02)
>
> Authoritative naming convention for all docker bridges and per-service IPs
> across hosts in the shrednet mesh. Locked in
> `~/workspace/shrednet-bootstrap/DECISIONS.md` D-001 and D-002.
>
> ## Address shape
>
> `10.<host>.<bridge>.<service>`

| | |
|---|---|
| whose | `FILE`, `/kb/systems/shrednet-subnet-schema.md`, read into `-workspace-chirality/ba6de7e9…` at line 920, 2026-09-04T00:27:24.831Z |
| tracked | `.planning/OWN-WEB-GAP.md:396-397` names `shrednet-bootstrap/DECISIONS.md` D-001 to D-004 and calls it operational with no input to the roster |
| note | this is the document `S1` read when it concluded the author meant an identity model. It is an IPv4 allocation table |

### F4 · The fourth reading: shrednet is the running homelab tailnet

Three sibling projects show the name in live use as a DNS search domain and a
resolver, with no design content attached.

| where | what the transcript shows |
|---|---|
| `-workspace/7b91ed13-6ec2-4575-b2a1-c2608a7d73e0`, line 455, 2026-09-21T21:55:03Z | `search shrednet` in `resolv.conf`, `nameserver 169.254.1.1`, and `67.240.123.144 control.shrednet.conn` in `/etc/hosts` |
| `-workspace/7b91ed13…`, line 464, 2026-09-21T21:55:18Z | `100.64.0.5 shredtower.shrednet` |
| `-workspace-workstuffs/1974ed34-6356-4c14-95ef-182bf964b487`, line 1023, 2026-08-20 | the assistant calls `169.254.1.1` *"the shrednet resolver"* |
| `-workspace-manas/b5845bb8-6ae9-4c4b-96e7-3cb12049aa60`, line 45, 2026-08-30 | `container/firewall-shrednet.sh` in the manas tree |

| | |
|---|---|
| whose | `FILE` and `SESSION` |
| tracked | `NOWHERE`. No tracked file records that the name is in production use for the author's live mesh, which is a fifth thing the word has to carry |

---

## §2 · The browser-like experience

### B1 · The first ask: our own version of the HTML idea

> Can you inspect codebase with the goal being to judge how much work it would
> be to do our own version of the html idea? im curious how far from being able
> to easily give that kind of render the language is

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/43cf1dc1…`, line 11, 2026-09-03T03:32:04.624Z |
| tracked | `docs/arcs/native-document-arc.md:16-18` opens on it |

### B2 · CSS with dynamism, and it may be several new things

> actually we should probably figure out what we want to make first. My thought
> is something like css, but with a way for dynamicism to be a thing. Also I'm
> curious about the gap for the more freeform in shape stuff. whatever we do
> it's new things and maybe multiple

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/43cf1dc1…`, line 32, 2026-09-03T03:35:37.775Z |
| tracked | `docs/arcs/native-document-arc.md:17-18` reads *"a typed document vocabulary and a style calculus with dynamism in the substrate"*, which is this statement |
| note | `docs/arcs/native-document-arc.md:16` says the arc was *"sequenced last of the three by the same statement"*. The statement it cites is A1, which names two items. The sequencing is a reading of *"i might as well do these first"* against B1 and B2, and no transcript line states three items in an order |

### B3 · The GTK ask: widgets, windows, theming, and the same thing for web

> so, yknow how like gtk and whatever exist? first check if there is docs about
> the chirality css implement idea and then i want to try to figure out how
> difficult it would be to do the gtk thing for chirality on wayland in a way
> when i do my own compositor we can plug it in and do the same stuff. Which
> would be like, widgets and windows to start. I need a thing that can theme
> everything in preemption for that, and if it can be the same thing flexible
> for web stuff (the css idea was to replace what css through javascript can do
> for web design, for chirality ontop of its own internet protocol and window
> system) that would be great. Yes, it's basically rewalking the steps of no
> browser to browser and web but for chirality. Also, I want to eventually make
> it become a piece of the actual compositor later on when i do that, so it has
> to be that kinda shape. A lot of reqs here

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/4215ae1a-e117-45a7-90ee-fc5838730f61`, line 27, 2026-09-04T07:13:41.036Z |
| tracked | `docs/goals/display.md:11-15` carries the goal it opened |
| `NOWHERE` half | *"rewalking the steps of no browser to browser and web but for chirality"*. That framing appears in no tracked file |
| `NOWHERE` half | *"I want to eventually make it become a piece of the actual compositor"*. `records/author-calls.md:61` rules the window arc is a client on a stock compositor and that *"one of our own is later"*, and no tracked file says the display layer is shaped so it can later **become part of** that compositor |

### B4 · What the author was asking for, restated

> Wow wait this is wildly small of an amount of work for features. Are we
> certain we know what i am asking for? I'm talking about display ability like
> jss with native internet protocol with things using the first set of elements
> for being a window, and being the instances of the web i'm making behind it?
> like i want to be able to do my widget system in this and window system and
> create some websites + ways to render outside websites (and talk to https and
> ip).

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/4215ae1a…`, line 107, 2026-09-04T07:23:27.672Z |
| tracked | `NOWHERE` |
| contradicts | `.planning/OWN-WEB-GAP.md:381-382`, *"Out of the immediate roadmap entirely, per the 2026-09-04 scope ruling: HTML, CSS parsing, JS, DNS, TLS, and any foreign document"*. Four minutes before that ruling the author asked for *"ways to render outside websites (and talk to https and ip)"*. The tracked sentence turns a roadmap exclusion into a categorical one |

### B5 · The scope ruling, in the author's own words

> Immediate roadmap would exclude non-chirality. Also would be local only
> primitives focus until crypto and enforcement finishes

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/4215ae1a…`, line 138, 2026-09-04T07:27:10.358Z |
| tracked | `.planning/OWN-WEB-GAP.md:34-37` and `:381-382` carry it as the standing scope ruling |
| `NOWHERE` half | *"local only primitives focus until crypto and enforcement finishes"*. The tracked ruling states the exclusion and drops the condition that lifts it |

### B6 · A separate binary, and less desktop

> focusing less on desktop. the thing we need here is display features and
> ability to harness in different places. Like, this would be a different
> compiled binary than cononical minimal main. And we would be focus on "this is
> metis with the native abilities that make css and jss and etc. web design
> languages (and i think gtk uses css right? same idea)

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/4215ae1a…`, line 172, 2026-09-04T07:32:56.408Z |
| tracked | `NOWHERE` as stated. `docs/arcs/canvas-arc.md:38-44` makes the `.profile` instance the mechanism and cites `binary-split/B4`, and no tracked file records that the author asked twice for a second compiled binary |

### B7 · Drawing is its own lane

> terminal parsing is a lot simpler than being able to draw and shade and layer
> and do 3d these are separate lanes for display

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/4215ae1a…`, line 207, 2026-09-04T07:38:19.575Z |
| tracked | `docs/arcs/display-calculus-arc.md` splits the lanes, and the `raster` category at `:220` is one of them. The `3d` half is carried nowhere |

### B8 · Primitives plus tools, no monolith

> ok so the gtk and design language elements are a reasonable arc? it is
> important that we're taking design language features and making primitives for
> them + tools to harness them. no monolith shit. chirality structure and logic
> should always reflect to programs

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/4215ae1a…`, line 403, 2026-09-04T07:58:35.604Z |
| tracked | `docs/goals/display.md:30-33` carries it as the shape condition, *"a design feature arrives as primitives plus tools that harness them"*, with three checkable consequences |

### B9 · Doclike and applike, and the lens problem

> ok yeah this is where it gets less straightforward. The idea here is that we
> have many things you can do. Doclike where the focus is just being a thing,
> sometimes with interactible and dynamic stuff, applike where the focus is
> being the surface for a thing that does stuff outside the surface, but the
> thing is that is less straightforward because we build raw primitives for
> chirality then if we wanted like specific lenses for designing throught they
> would have to be pre-prett-parser states

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 1212, 2026-09-05T22:32:24.360Z |
| tracked | `NOWHERE`. The doclike and applike split, and the claim that a design lens is a pre-pretty-parser state, appear in no tracked file. `docs/arcs/canvas-arc.md:21-26` defines a canvas as a view function and a host as a surface, which is a different cut |

### B10 · The browser half, and the widget insight

> to continue refining the picture: needs to snap in with the ownership and user
> type auth stuff that we're going to add as another layer. (an app would get
> the extra nuance of the user layer in literally the same way). Also, an
> important piece is the browser half. We need a {thing?} that can be whatever.
> Or something. Help me out. end game is this integrates into endgame chirality
> os (long road) so we need to define it's border. A browser is kind of a stupid
> thing that exists as a stupid extra layer never integrated into a DE like it
> should be. like people should be able to have bookmark widgets or something
> and everything in that cascade. the issue is that i am on niri until we have a
> DE so stuff doesnt really split in a helpful way. Maybe the chirality version
> of the gtk idea as a surface for this makes it straightforward? actually yeah
> it does because then we can make gtk system a hypermodular set of chirality
> runtimes where the widgets are all perfectly truly individual holy shit

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 1236, 2026-09-05T22:41:57.899Z |
| tracked | partly. `docs/goals/own-web.md:17-18` carries *"integrate the result into a chirality desktop rather than bolting a browser beside one"*, and `docs/arcs/canvas-arc.md:22-24` carries the separate-runtime property, *"which is what lets canvases be separate runtimes with nothing shared between them"* |
| `NOWHERE` | the word `bookmark` appears in zero tracked files. The author's replacement for a bookmark is a **widget in the desktop cascade**, and nothing records it |
| `NOWHERE` | *"a hypermodular set of chirality runtimes where the widgets are all perfectly truly individual"*, and the ownership plus user-type auth layer as a thing that snaps in. `.planning/OWN-WEB-GAP.md:184` (`G7`) carries `Grant` at three layers and does not carry the user layer the author names here |
| `NOWHERE` | *"end game is this integrates into endgame chirality os (long road) so we need to define it's border"*. No tracked file names an endgame OS or asks for that border |

### B11 · What a canvas is, and what it becomes

> panes would be confusing. canvas is prob fine. Honestly this solves a lot of
> DE stuff too we might actually get to that with no GC drivers wtf. For now a
> canvas can be spawned for each endpoint as a movable window, for each widget
> we do on desktop, and for each "browser" feature we would want. Later, a
> canvas can become layers of the DE itself

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 1243, 2026-09-05T22:47:25.557Z |
| tracked | half. `docs/goals/own-web.md:51-52` condition 5 reads *"A canvas is a layer of the environment rather than a window beside it"*, which is the last sentence |
| `NOWHERE` | the naming call itself, the author choosing `canvas` over `panes`. `docs/arcs/canvas-arc.md:18` says *"Opened 2026-09-05 by author statement"* and records no naming decision |
| `NOWHERE` | **one canvas per endpoint**, spawned as a movable window. That is the closest thing in the whole history to what replaces a tab, and no tracked file carries it |

### B12 · A canvas is how a program is rendered

> wait for understanding check, you mean canvas is just the way a prog is
> rendered right? if so then yeah thats the point of the pretty parser lenses
> for different views. To keep the actual mechanics just chirality

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 1264, 2026-09-05T22:49:57.709Z |
| tracked | `docs/arcs/canvas-arc.md:21-22` states a canvas is a view function of the kind `lib/surface/pretty.chiral` already is |

### B13 · The pipeline, in the author's own brackets

> yeah we need to work on making this legible as a process. like {doc view lense
> chirality -> pretty parse to chirality primitives -> primitives and tools
> build resulting rendered thing}

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 1277, 2026-09-05T22:54:40.507Z |
| tracked | `NOWHERE` as a pipeline. `docs/arcs/canvas-arc.md` holds the canvas half and no tracked file states the three-stage chain from a lens through the pretty parser to a rendered thing |

### B14 · Types of canvas, and a graphical scriba

> scriba is terminal main with pluggability, graphical form would be considered
> a fully alternate version because grahical vs terminal changes structure a
> decent bit. Slow down though. That's not the only goal and i want to fully
> round. graphical scriba + types of canvas with pluggability into scriba for
> convenient devel (lsp but we shouldnt do what an lsp normally is because we
> can make the feedback loop about the state much faster and more correct if we
> outline what we need from error diagnostics and etc.) + graphical scriba gets
> to have pieces to actually fully render stuff in addition to the raw canvas
> code format or whatever it ends up

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/0cc5f49e-b95c-4bfe-a5cb-e6b44f031a75`, line 643, 2026-09-15T17:47:09.780Z |
| tracked | `NOWHERE`. *"types of canvas"* is the phrase A9 later sharpens to `typed canvas`, and neither phrase appears in a tracked file. The graphical scriba as a fully alternate version, and the raw canvas code format, are carried nowhere |

---

## §3 · The identity model

The three readings of shrednet make this the thinnest of the three subjects. No
author turn in any chirality transcript contains the word `jala`, `petname` or
`pair-gating`. What the author did state is below.

### I1 · A router learns nothing

> ME ASKING A QUESTION IS NOT QUE TO DECIDE A BUNCH OF SHIT YOURSELF. How can we
> pq crypto everything while retaining the model with features we want is not
> straightforward. We want a speedy system. We also want a secure system. We
> need to wrap up a lot of information in a way that can only be dissected where
> it should be. A router shouldn't be able to gather a bunch of actual info
> about whatever its carrying

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 476, 2026-09-05T19:40:55.024Z |
| tracked | `.planning/REACH-MODEL.md:17` carries it as a ruling row, *"a hop learns nothing about what it carries"*, pointing at §7, §9 and §10 |

### I2 · Destinationless hops, and compute at the ends

> 1. we want a system where the discovery system is very nunanced and we can use
> it as a means of low cost high value cover traffic. 2. does it have to be
> delayed or fast in a way we can guarentee consticency relevant to it? kinda
> hard to word what im reaching for 3. yeah this isnt specific at all. To have
> sourceless routing is a decenetly easy question but we want destinationless
> from hops. As in, hops cannot do anything except for be a hop by putting the
> destinination responsibility purely on message creation mechanically 5. yes it
> is research 6. encryption is medium cheap but the discussion is important
> because we need to make sure we have docced all crypto primitive requirements
> + a pq bundle is large so we need to do something to put the compute load on
> the message creation and reading instead of amount of send

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 489, 2026-09-05T19:47:59.104Z |
| tracked | `.planning/REACH-MODEL.md:16` carries the compute ruling, *"compute belongs at message creation and at reading"*. §8 carries discovery as the cover stream, and `:52` carries *"a query has no destination, so route drops out of the model"* |

### I3 · The public form, the guarded form, and chirality-native crypto

> wait maybe discovery is wrong. What models do we need to look at for answering
> the ease of integration question? something that might change this: we're
> trying to imply level of auth beforehand. We want to be able to have a very
> easily accessible public site form that can provide security for boths ends,
> plus a secure model underneath where routing is secured, while just being
> reachable. We also need more guarded forms where you cannot just route to it
> without some form of authorization that is built into the model. The project
> is probably outlining for us to do chirality native crypto and heavily
> intertwine it with this as the networking model

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 583, 2026-09-05T20:07:19.860Z |
| tracked | `.planning/REACH-MODEL.md:98-116` §4 is this statement worked out: one security model, two positions, and the gate at route formation |
| note | *"chirality native crypto"* here is a **networking** model. A9's *"chirality native crypto identity model"* is the same phrase attached to a canvas and an identity, seventeen days later |

### I4 · Sealed and public are one model

> so i know you dont understand because public is not a separate thing from
> sealed. This is what i mean. I said we're trying to retain the secure model
> for public. The bit is anonymity being possible for both, one side has
> naturally easy routing that provides security for both ends, and one side has
> a requirement of actually forming the ability to route before anything else.

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 596, 2026-09-05T20:11:22.988Z |
| tracked | `.planning/REACH-MODEL.md:18` carries *"the security model does not vary with reachability"*, and `:100-116` states it once |

### I5 · Per-hop packet identity

> So we also need per hop packet identity to be unique right? there should be no
> way to see two correlatable packets at any point. is that possible? like in
> the packet from one hop to another sense.

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 718, 2026-09-05T20:32:03.025Z |
| tracked | `.planning/REACH-MODEL.md:458` §9 carries it under `Bitwise unlinkability` |

### I6 · The ceremonial route, and a key entered by hand

> does it have to cost stateless or can we just build an orientation ceremony
> type of thing? as in, build an easy way for routers to use a ceremonial path
> in addition to the normal ones so you can just... use a secure route already
> established (also we can do like a key entering process where if someone knows
> the number verbally or from another source they can just have it and enter on
> the other end to already be able to derive)

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 826, 2026-09-05T20:55:17.991Z |
| tracked | `.planning/REACH-MODEL.md:209` §6 `The ceremony` and `:258` §6 `Key entry` are this statement, both halves |

### I7 · A new identity reaching a private endpoint over public nodes

> 1. this is what the public perspective i brought up was a thing 2. I mean that
> exchange transfers to a different emphemeral route on the network. Like, if
> many people use the public setup which would be the point, why not make the
> infra able to handle {new identiy -> private endpoint} by having {new identity
> connected to the web -> ephemeral route over public nodes that keeps up
> encryption goals -> private endpoint} (so you have {key} sent to differently
> fully complete ephemeral line to {priv endpoint}

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/6ecf719d…`, line 839, 2026-09-05T21:02:15.736Z |
| tracked | `.planning/REACH-MODEL.md:230` §6 `The splice` carries the mechanism, and `:709` §13 walks reaching a gated endpoint |
| note | this is the only author turn in the corpus that uses `identity` as a thing a person holds and moves with. It is unnamed and untyped in the quote |

### I8 · Identity and routing inside the encrypted part

> Wait can i get a mechanical explanation of why 40% is optimum? i meant like,
> making the things we are trying to put in the empty space over time a separate
> pass and store using types, and then apply the logic one would apply for
> something like how riticulum puts identity and routing in the contents of the
> encrypted piece, to the logic for filling up all bits

| | |
|---|---|
| whose | `AUTHOR` |
| where | `-workspace-chirality/036d10bc-e770-4ee5-a34f-c44807e823a0`, line 2117, 2026-09-09T04:31:44.036Z |
| tracked | `NOWHERE` as an author reference. `.planning/OWN-WEB-GAP.md:27-31` and `:245` treat Reticulum as external prior art at Tier P and cite no author statement about it. This is the only turn in which the author names Reticulum, and he names it for its envelope layout |

### I9 · Crypto identity as the thing a canvas routes on

A9 and A10 in §1 are both identity statements. A9 gives the identity a job,
*"typed canvas that use a chirality native crypto identity model"*. A10 gives it
a shape, *"similar primitives to dns but with more of a crypto based identity
and routing model"*. Neither is tracked.

### What the tracked tree has instead

`.planning/REACH-MODEL.md:62-82` §3 defines **the mark**, a four-field typed record
of `alg`, `digest`, `size` and `chunk`, and states at `:84` that *"A mark does
not carry … no location, no party, no time, no name, no transport, no path"*.
That is content addressing, and it names no person and no endpoint.
`.planning/REACH-MODEL.md:115-117` says a `Grant` *"proves permission and never
proves identity"*, which is the tree's position on identity today: it has none,
deliberately. The word `petname` occurs once in the whole tree, in
`.planning/OWN-WEB-GAP.md:399`, as an unread source.

**So the tree holds no chirality-native crypto identity model.** It holds an
address that is a hash of content and a capability that refuses to name anyone.
A9 asks for a third thing and no file carries it.

---

## §4 · The `NOWHERE` list

Author statements no tracked file carries. Highest value first.

| # | the statement, short | session | date |
|---|---|---|---|
| 1 | *"Shrednet is going to be the sum of exposed tools that come together for the type of "web browser" experience we are going to go for with chirality, as typed canvas that use a chirality native crypto identity model for shrednet"* | `chirality/619b6457…`:572 | 2026-09-23T02:44Z |
| 2 | *"similar primitives to dns but with more of a crypto based identity and routing model … used to create rules to allow a cavas to be put up on the chirality native internet"* | `chirality/619b6457…`:622 | 2026-09-23T02:51Z |
| 3 | *"stop whining about the name. we need to come up with the set of things and name them for chirality as apart of this so instead of whining suggest something besides attaching to old names"* | `chirality/6ecf719d…`:354 | 2026-09-05T19:15Z |
| 4 | *"a canvas can be spawned for each endpoint as a movable window, for each widget we do on desktop, and for each "browser" feature we would want"* | `chirality/6ecf719d…`:1243 | 2026-09-05T22:47Z |
| 5 | *"panes would be confusing. canvas is prob fine"*, the naming call itself | `chirality/6ecf719d…`:1243 | 2026-09-05T22:47Z |
| 6 | *"people should be able to have bookmark widgets or something and everything in that cascade"* | `chirality/6ecf719d…`:1236 | 2026-09-05T22:41Z |
| 7 | *"we can make gtk system a hypermodular set of chirality runtimes where the widgets are all perfectly truly individual"* | `chirality/6ecf719d…`:1236 | 2026-09-05T22:41Z |
| 8 | *"needs to snap in with the ownership and user type auth stuff that we're going to add as another layer. (an app would get the extra nuance of the user layer in literally the same way)"* | `chirality/6ecf719d…`:1236 | 2026-09-05T22:41Z |
| 9 | *"end game is this integrates into endgame chirality os (long road) so we need to define it's border"* | `chirality/6ecf719d…`:1236 | 2026-09-05T22:41Z |
| 10 | *"{doc view lense chirality -> pretty parse to chirality primitives -> primitives and tools build resulting rendered thing}"* | `chirality/6ecf719d…`:1277 | 2026-09-05T22:54Z |
| 11 | *"Doclike where the focus is just being a thing … applike where the focus is being the surface for a thing that does stuff outside the surface"*, and lenses as pre-pretty-parser states | `chirality/6ecf719d…`:1212 | 2026-09-05T22:32Z |
| 12 | *"graphical scriba + types of canvas with pluggability into scriba"*, and the raw canvas code format | `chirality/0cc5f49e…`:643 | 2026-09-15T17:47Z |
| 13 | *"this would be a different compiled binary than cononical minimal main"*, said twice with *"a separate connonical cousin binary to the main minimal"* | `chirality/4215ae1a…`:172 and `chirality/6ecf719d…`:6 | 2026-09-04, 2026-09-05 |
| 14 | *"i want to be able to do my widget system in this and window system and create some websites + ways to render outside websites (and talk to https and ip)"* | `chirality/4215ae1a…`:107 | 2026-09-04T07:23Z |
| 15 | *"local only primitives focus until crypto and enforcement finishes"*, the condition that lifts the scope ruling | `chirality/4215ae1a…`:138 | 2026-09-04T07:27Z |
| 16 | *"I want to eventually make it become a piece of the actual compositor later on when i do that, so it has to be that kinda shape"* | `chirality/4215ae1a…`:27 | 2026-09-04T07:13Z |
| 17 | *"it's basically rewalking the steps of no browser to browser and web but for chirality"* | `chirality/4215ae1a…`:27 | 2026-09-04T07:13Z |
| 18 | *"to claim shrednet we need to have stuff for it. Most things we want for shrednet need crypto"* | `chirality/ba6de7e9…`:899 | 2026-09-04T00:26Z |
| 19 | *"very encrypted native chirality take on internet protocol with security … and the language level shamir stuff"* | `chirality/619b6457…`:512 | 2026-09-23T02:38Z |
| 20 | *"A lot of this is shrednet stuff (which is docced outside this repo mostly and is raw ideas)"* | `chirality/6ecf719d…`:6 | 2026-09-05T18:52Z |
| 21 | *"how riticulum puts identity and routing in the contents of the encrypted piece"*, the only author citation of Reticulum | `chirality/036d10bc…`:2117 | 2026-09-09T04:31Z |
| 22 | *"Can you tell me about what you think shrednet is so we can make sure its aligned?"*, the question itself | `chirality/619b6457…`:541 | 2026-09-23T02:40Z |

### An author ruling on an open call, found in history

Row 3 is the one. *"stop whining about the name … suggest something besides
attaching to old names"* is a directive given 2026-09-05 that decides how this
tree names the borrowed set. `records/author-calls.md` holds no row for it,
`docs/arcs/native-protocol-arc.md:63` is in violation of it today, and A9 is the
author executing it himself seventeen days later by giving shrednet a chirality
definition.

No transcript contained a ruling on any of the 38 open calls in
`.planning/CRYPTO-MODEL.md` §13, `.planning/CRYPTO-TRANSLATION.md` §16,
`.planning/REACH-MODEL.md` §15 or `records/author-calls.md`. The author turns
that touch those subjects are questions and design prompts, and every one of
them predates the document that records the call.

---

## §5 · Contradictions between history and the tracked tree

| # | the tracked claim | what history shows |
|---|---|---|
| 1 | `docs/arcs/native-protocol-arc.md:18` attributes *"the shrednet mesh's identity model as the base idea"* to an author statement of 2026-09-03 | the author wrote *"shrednet as base idea to pull from"* (`43cf1dc1…`:58). The identity-model reading was the session's, six minutes later (`43cf1dc1…`:100), from a `/kb` document that is an IPv4 allocation table |
| 2 | `docs/arcs/native-protocol-arc.md:63` and `.planning/NATIVE-PROTOCOL-CHECKLIST.md:35` still cite the shrednet identity model for `N4` | `.planning/OWN-WEB-GAP.md:394-395` says the name *"holds none of the protocol thinking"*, and the session that wrote that said in the same run *"that citation points at a config schema. It wants jala"* (`6ecf719d…`:350). Both readings have stood in the tree for seventeen days |
| 3 | `.planning/OWN-WEB-GAP.md:81-82` says *"jala is a clean-room reimplementation of Reticulum"* | the file the session read says *"Rust implementation of Reticulum"* (`6ecf719d…`:197). `clean-room` is the session's word and no source in the transcript supports it |
| 4 | `.planning/OWN-WEB-GAP.md:381-382` puts HTML, CSS parsing, JS, DNS and TLS *"Out of the immediate roadmap entirely"* | the author asked for *"ways to render outside websites (and talk to https and ip)"* four minutes before the ruling it cites (`4215ae1a…`:107 at 07:23, ruling at 07:27) |
| 5 | `.planning/OWN-WEB-GAP.md` records the scope ruling with no expiry | the author's words attached one: *"local only primitives focus until crypto and enforcement finishes"* (`4215ae1a…`:138) |
| 6 | `docs/arcs/native-document-arc.md:16` says the arc was *"sequenced last of the three by the same statement"* | the statement it cites names two items (`43cf1dc1…`:58). The document idea is the author's earlier turns at `:11` and `:32`, and no turn orders three |
| 7 | `docs/arcs/native-protocol-arc.md:18` treats shrednet as a mesh with an identity model | four different things wear the name across the corpus: a rescoped TOML config project (`F1`), a `/kb` IPv4 subnet convention (`F3`), a live tailnet search domain and resolver (`F4`), and the sum of exposed tools the author defined on 2026-09-22 (`A9`) |

---

## §6 · What this does not recover

Searched, and found nothing.

| subject | what was searched | result |
|---|---|---|
| the author on jala | every chirality session, regex `jala`, user-role turns only | **zero author turns.** Every one of the 49 hits is a tool result, a session's own text, or a tool call. The jala lineage in `.planning/OWN-WEB-GAP.md` rests on session reading and was never confirmed by the author in any transcript |
| petnames | regex `petname` across every project transcript and the whole tree | zero author turns. One tracked occurrence, `.planning/OWN-WEB-GAP.md:399`, an unread source |
| pair-gating | regex `pair-gat`, `pairing` | zero author turns. It enters the tree from the jala PROJECT.md description read at `6ecf719d…`:197 |
| what replaces a URL | regex `URL`, `address`, `bookmark`, `tab`, `link` over author turns | the author never named a replacement for a URL, a tab, a link or a page. The nearest statements are B11, one canvas per endpoint, and A10, rules that put a canvas up. `.planning/REACH-MODEL.md` §2 supplies the mark as the URL replacement, and it is session work |
| `mark`, `seal`, `give`, `reach` as named verbs | regex over author turns | zero. All four are session vocabulary invented in `.planning/REACH-MODEL.md` on 2026-09-05 and the author has never used them |
| `announce` | regex over author turns | zero |
| the shrednet rescope reasoning | `/workspace/shrednet/.planning/NOTE.md`, the file `F1` points at for the 2026-04-24 correction | never read into any chirality transcript. What the rescope decided is recoverable only from the PROJECT.md summary quoted at `F1` |
| the pre-rescope shrednet design | the 7-crate Rust mesh VPN `F1` calls orphaned | no transcript reads it. Whether it held an identity model is unknown from history |
| `shrednet-bootstrap/ARCHITECTURE.md` and `DECISIONS.md` | read at `6ecf719d…`:181, 2026-09-05T18:59:18Z | the result is in the transcript and holds homelab migration content. It carries no identity or protocol thinking, which matches `.planning/OWN-WEB-GAP.md:396-397` |
| a shrednet statement before 2026-09-03 | every project, every session | none. The earliest author use of the word in any transcript is `43cf1dc1…`:58 |
| a browser-experience statement outside chirality | `-workspace-metis-the-lang`, `-workspace-workstuffs`, `-workspace-manas`, `-workspace-chirality-prog`, `-workspace`, `-workspace-moneyplans`, `-workspace-shredtower-setup` | zero author turns on any of the three subjects. Every hit in those projects is operational: a resolver, a hosts file, a firewall script, a directory listing |

---

## §7 · What was searched, and what was skipped

| project | files with a hit | how it was searched |
|---|---|---|
| `-workspace-chirality` | 13 top-level, plus 14 subagent files | every top-level `.jsonl` scanned line by line for `shrednet`, `jala`, `browser`, `canvas`, `web`, `identity`, `petname`, `pair-gat`, `announce`, `Reticulum`, `bookmark`, `presentab`, filtered to user-role text turns, then read at the line numbers found |
| `-workspace-metis-the-lang` | 2 top-level, 3 subagent | scanned. Both hits are a hosts file and a repository listing |
| `-workspace-workstuffs` | 3 top-level, 1 subagent | scanned. All hits are mesh DNS troubleshooting from 2026-08-19 and 2026-08-20 |
| `-workspace-chirality-prog` | 1 top-level, 2 subagent | scanned. Hits are a manas directory listing |
| `-workspace-manas` | 1 | scanned. Hit is `container/firewall-shrednet.sh` in a listing |
| `-workspace` | 1 | scanned. Hits are tailnet resolution probes from 2026-09-21 |
| `-workspace-moneyplans`, `-workspace-shredtower-setup` | 0 transcripts | neither project holds a `.jsonl` at all. The hit each contributes to the brief's census is an auto-memory file: `memory/tempartix-productization-gap.md` records `SEARCH_DOMAIN=shrednet` and `shrednet-ca.crt` as overridable defaults in tempartix, and `memory/manas-worker-live.md` names `firewall-shrednet.sh`. Both are `F4`'s reading and hold no design content |

**Subagent transcripts were skipped.** A file under
`<session>/subagents/` holds an orchestrator's prompt and an agent's work, and
no user-typed turn, so it cannot carry the evidence this run is after. The 14
chirality subagent files with `shrednet` hits were skipped for that reason.

`9fa15336-d71e-4159-9008-3742828e2b46.jsonl` was skipped on instruction.
`619b6457-a2f5-4f60-b744-4eb049f8dc14.jsonl` was **not** skipped. The brief said
it held nothing new, and it holds five author turns about shrednet, four of them
`NOWHERE` rows and two of them the only definitions of shrednet in the whole
corpus. They are `A7`, `A8`, `A9` and `A10`.

No transcript was read whole. Every read was a bounded line range located by a
prior scan.
