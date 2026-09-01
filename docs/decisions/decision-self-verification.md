---
node: decision-self-verification-hierarchy
layer: decision
related: [certificate-discipline, split-role, axis-altitude, decision-split-checker, decision-reflective-floor, modules-lowering, thesis, open-edges]
status: draft
updated: 2026-09-01
---

# Decision: self-verification is a hierarchy, and the residue is named

External judgment is cut (HANDOFF decision 5). That removes the anchor every prior
self-verification effort leaned on. Milawa leaned on HOL4. Harrison leaned on a
stronger metatheory. MM0 leans on a human reading 25 x86 instruction semantics.
chirality has none of those. This note says what shape is left.

## 0. The decision, recorded 2026-09-01

The author's call, made when the `Mach`→C backend was dropped (`d8bcec5` the
modules, `d0c5dd5` the four `e166_*` fixtures). Everything below §0 was written
before it and is kept as the analysis that led here. Where a passage reads as
though DDC or an external toolchain is the route, §0 overrides it.

**Self-verification here is N semantically distinct judgment cores that must
agree.** That is the route. The criterion on those cores is **different
FORMULATIONS**, and `CLAUDE.md` states the failure mode the criterion exists to
exclude: three encodings of one rule set would be worth nothing.

**What that rules out. Each was a plausible-looking wrong answer, which is why
each is named.**

- **A different TARGET is not a different formulation.** The C backend (E166) was
  built as the external-compiler DDC leg and dropped 2026-09-01. It shared
  `compile-front` and `compile-back` whole with the canonical instance and
  differed only at emit: one rule set, one implementation of it, two emitters. It
  bought toolchain provenance and bought nothing about whether the rules are
  right. [[decision-backend]] carries the same statement from the backend's side.
- **An external-toolchain leg is not a judgment core.** gcc and CompCert judge C.
  Neither holds an opinion about whether a chirality term type-checks, and that is
  the judgment wanting a second opinion. §5 item 5 makes the adjacent point about
  Thompson being an adversary and not a correctness bug; read forward, it says
  toolchain diversity answers a threat and formulation diversity answers an error.
  They are different purchases and one does not substitute for the other.
- **DDC is not the route.** §5 item 5 below is correct and stays: the committed
  binary is trust-on-first-use, and diverse double-compiling is the standard
  counter to Thompson. Nothing about that changed. What changed is its position.
  DDC answers the trusting-trust axiom, which `docs/decisions/decision-scope.md` puts on the
  deferred ownership-and-trust track. It is not the mechanism by which chirality's
  own judgments get a second opinion, and this note's earlier framing let it read
  as one.

**Where DDC does belong, and it is a real job.** `lib/evidence/ddc.chiral` is the
**referee** over a quorum, and the shape transfers: verdicts are values, a
divergence names WHICH two legs disagreed, and the quorum gate fires before any
byte is read. Its own ⚑ is precisely the argument N cores need, *agreement is not
a quorum, because two runs of the SAME compiler agree with each other by
construction*. What does not transfer is measured in [[open-edges]] and is not
small: `leg2-disjoint?` demands both `language` and `toolchain` differ, so a
quorum of chirality-native cores returns `ddc-bad-quorum "provenance not pairwise
disjoint"` every time; `Prov` has no FORMULATION axis, and the threat has moved
from a backdoored toolchain to a shared mistake in how the rule set was encoded;
and `ddc-fold` compares BYTES, where different formulations agree on a VERDICT.
Repointing it is open, and no element is minted for it.

**What this decision does not settle**, with §§1–7 as the reason each is hard: how
many cores; whether they are peers or ordered (§4 fixes one constraint, that only a
strict order may exchange soundness); what is owed per ordered pair (§4's encoding
plus adequacy plus conservativity triple); and whether the bridges run through a
hub (§4 recommends one). N is unchosen. The criterion is chosen.

**The bound in §1 is untouched.** N cores agreeing is a relative result, and the
hierarchy still terminates downward in an artifact a human reads. Adding cores buys
no self-consistency proof, and nothing in §0 should be read as though it might.

## 1. The bound

Two theorems fix it.

**Gödel's second incompleteness theorem (1931).** For any consistent, recursively
axiomatized theory T interpreting a modest fragment of arithmetic, T does not prove
Con(T). chirality's core interprets arithmetic, so it is in scope. Forbidden as a
direct consequence: chirality proving its own consistency; chirality proving
normalization or canonicity of its own type theory (normalization implies
consistency, so it inherits the prohibition); chirality proving a semantic soundness
theorem for its own full judgment.

**Löb's theorem (Löb 1955).** If T proves □_T(A) → A, then T proves A. So T proves
the reflection schema only for sentences it already proves. Adding a global
reflection rule ("if the checker accepts A, then A") to T yields Con(T) and is
therefore unavailable to T. This is the Löbian obstacle, and it kills the naive
design where the checker's verdict is internalized as truth.

**What is not forbidden, stated precisely, because this is where the design lives:**

1. T proving a *different, weaker* system sound or consistent. Gentzen (1936) proved
   Con(PA) in PRA plus transfinite induction to ε₀. ZFC proves Con(PA). In type
   theory the standard form is that a theory with n+1 universes proves normalization
   for the theory with n (Palmgren 1998 on universes; Werner 1997 and Barras 2010 on
   set-theoretic models of Coq inside Coq).
2. T proving *faithfulness*, a syntactic statement: "if checker C accepts (p, φ),
   then φ is derivable in T's fixed rule set." This is a proof-transformation claim,
   not a truth claim, and it costs no extra strength. This is Milawa's entire
   mechanism.
3. T representing its own syntax and semantics. Self-representation is not
   self-consistency. (Brown and Palsberg 2016 built self-interpreters for strongly
   normalizing calculi; the incompleteness bound is untouched by that.)
4. T proving relative results: preservation, refinement, adequacy, conservativity,
   translation validation.
5. T proving properties of artifacts modulo an axiomatized machine model.

So a single self-certifying level is impossible, not merely hard. The two remaining
shapes are an external anchor (evicted) and an ascending sequence in which each level
certifies a *different* level, terminating downward in something audited rather than
proved. Feferman (1962) on transfinite progressions of theories by iterated
reflection is the formal statement that the sequence is the general shape. The
hierarchy is forced, not a workaround.

## 2. What the four projects actually did

**Milawa** (Davis 2009 dissertation; Davis and Myreen, JAR 2015). Eleven proof-checker
levels over **one fixed logic**. Level 1 accepts only primitive steps (instantiation,
cut, propositional rules). Later levels add clause manipulation and equivalence traces
(level 5), rewrite traces (8), unconditional then conditional rewriting (9, 10),
tactics (11). Each new checker is installed only after the *current* system proves it
faithful: given well-formed inputs, a non-NIL answer implies the alleged conclusion is
derivable in the fixed logic. Because the logic never changes and faithfulness is
syntactic, no level proves its own consistency and Gödel is not touched. Trusting
level 11 requires trusting level 1. At the bottom: a 2,000-line Lisp kernel and the
logic's axioms. Jitawa (Myreen and Davis, ITP 2011) is a verified Lisp runtime, about
7,500 lines of x86-64 machine code, HOL4-verified including JIT, GC, reader and
printer, which ran the 4 GB, ~16 hour bootstrap. The *semantic* soundness of the
Milawa logic, and the fidelity of the kernel to it, were proved **in HOL4**, outside
Milawa. That is the external anchor chirality does not have. The Milawa hierarchy
alone gives relative results only.

**Harrison, "Towards Self-verification of HOL Light" (IJCAR 2006).** Verified the HOL
inference system sound against a set-theoretic semantics, formalized inside HOL Light,
for the core without definitional mechanisms. Could not do it at equal strength. The
axiom-strength move: either drop the axiom of infinity from the *object* logic, or add
a universe axiom to the *meta* logic. Both are instances of permitted-move (1). Kumar,
Arthan, Myreen and Owens (JAR 2016) extended this to definitions and to a
CakeML-synthesized kernel, making the model parametric in the universe of sets.

**Metamath Zero** (Carneiro 2019, 2020, thesis). Shrink the thing a human must read
until reading it is feasible, then aim at a theorem about the binary:
`initialConfig VerifierElf k /\ succeeds k s 0 -> Valid s`, stated in Peano
Arithmetic, over about 25 x86-64 instructions. Notable for a project that commits its
own binary: even here the ELF loader is assumed, file reads other than stdin are
modeled nondeterministically, and the bootstrap proof was not complete at publication.
The lesson is not "verify the binary." It is "the audited surface is the deliverable,
and it is never zero."

## 3. The hierarchy for chirality

Downward, with what each buys and what it owes.

- **L0, the audited base.** Two artifacts: `kernel-spec`, the rule table as data,
  small enough to read in one sitting; and an L0 re-checker that consumes a fully
  explicit derivation and checks each step against the table. No inference, no
  unification, no elaboration. Trusted for nothing except its own text. Buys: a
  fixed, non-negotiable meaning of "derivable."
- **L1, the working checker.** NbE conversion, bidirectional infer/check, implicits,
  quantity and universe inference, refinement discharge. Buys: checking real programs
  at usable speed. Owes L0 faithfulness, in Milawa's exact sense: accept implies an L0
  derivation exists. The cheap interim, and the one certificate-discipline already
  prescribes, is emission rather than proof: L1 emits the L0-checkable derivation, so
  the global theorem is replaced by an executed check per artifact. Weaker as a claim,
  immediately available, and non-gameable.
- **L2, producers.** Tactics, solvers, defaulting, staging, the elaborator. Trusted
  for nothing. Milawa levels 8 to 11. Everything here is an untrusted producer by
  construction.
- **Below L0, lowering.** `preserve-check` carries typeability upper to tal and is
  already a certificate L0-class machinery can check. Below tal is the single trusted
  drop (axis-altitude). It is not in the hierarchy. The move that shrinks it is
  **translation validation** (Pnueli, Siegel and Singerman 1998; Necula 2000): do not
  prove the backend, check each emitted artifact against its input, per compilation.
  That converts a compiler-correctness axiom into a per-run certificate plus a
  machine-model axiom. It does not remove the machine-model axiom.

The hierarchy terminates downward in an artifact a human reads, not in a proof. Gödel
guarantees that it must.

## 4. How cores relate

The certificate-discipline argument that re-derivation beats comparison is correct,
and the strongest external support is empirical: Knight and Leveson (1986) built 27
independently written versions from one specification, ran a million tests, and
measured coincident failures far above what the independence assumption predicts.
Verdict quorums also have the canonicality problem the doc names: typing admits many
derivations, so agreement is one bit per run.

But "core B re-checks a derivation emitted by core A" does not survive contact with
decision 5's *different formulations* criterion without an amendment. A derivation in
A's formulation is not a term in B's language. Something must translate, and the
translation is the whole game.

The literature name for the needed bridge is **adequacy**: a compositional bijection
between object derivations and their encodings (Harper, Honsell and Plotkin, JACM
1993). The archetype is Gentzen (1935): cut-elimination plus the standard translations
relate sequent calculus and natural deduction, worked out in detail by Prawitz (1965)
and Zucker (1974). The archetype nearest to chirality is soundness and completeness of
*algorithmic* typing against *declarative* typing: Coquand (1996); Abel, Öhman and
Vezzosi (POPL 2018) for formalized decidability of conversion; Dunfield and
Krishnaswami's bidirectional typing survey (ACM Computing Surveys, 2021).

Cross-formulation checking is also an existing engineering practice, not a novelty:
Dedukti and the λΠ-calculus modulo as a universal proof checker (Boespflug,
Carbonneaux and Hermant 2012; Blanqui et al. 2023), Logipedia translating Matita, HOL
and Coq developments through one kernel (Dowek and Thiré), OpenTheory as a portable
proof format across HOL implementations (Hurd 2011), and Foundational Proof
Certificates explicitly designed so one kernel checks certificates from provers with
unlike proof formats (Chihani, Miller and Renaud, CADE 2013). The design holds up.
Three amendments:

1. **What is owed per ordered pair (A, B)** is not "B accepts A's derivation." It is a
   triple: an encoding of A-derivations, an **adequacy theorem** for that encoding,
   and a **conservativity** direction (B proves nothing about A-terms that A cannot).
   Without adequacy, B's acceptance is evidence about the *encoded* object, and the
   encoder is the unaudited part. ⚑ The research read is that encoding adequacy in the
   Dedukti literature is largely pen-and-paper rather than machine-checked; that is a
   reading, not an established survey claim, and it needs checking before it is
   leaned on.
2. **Use a hub, not all pairs.** n formulations encoded into one shared derivation
   language (the L0 rule table) is n adequacy theorems. All-pairs is n². Logipedia's
   shape is the right shape.
3. **The payoff is the theorem attempt, not the run.** Where formulations are
   extensionally equivalent by construction, agreement is worth close to nothing. The
   arc handoff already measured this instinct correctly (D1: NbE and algorithmic-η
   conversion agreeing is rank-4, implementation-derived). The value of a different
   formulation is that a *specification* error invisible in one is often visible in
   the other, and it surfaces as a **failed adequacy proof**, not as a differing
   verdict.

One hard constraint the bound imposes on core topology, which resolves part of the
arc's deliberately-undecided "peers or ordered": **peers may exchange derivations;
only a strict order may exchange soundness.** Soundness proofs raise strength, so a
cycle of cores certifying each other's soundness is the forbidden configuration in
disguise. Faithfulness and adequacy are syntactic and may go in any direction,
including both.

## 5. The axiom column

Named honestly, each with the only thing that could ever discharge it.

1. **Machine model.** Semantics of the emitted x86-64 subset, the ELF loader, the
   syscalls used, and the silicon matching the model. MM0 assumes the loader and
   models foreign reads nondeterministically; Jitawa's theorem is conditional on
   sufficient heap. Undischargeable from inside. Permanent.
2. **The tal to metal drop.** Codegen correctness. An axiom today by axis-altitude's
   own statement. Reducible, not eliminable, to per-run translation validation plus
   (1).
3. **Consistency of the top level's logic.** Never proved by chirality. If the
   universe hierarchy is strong enough, level n+1 proves level n's normalization, and
   the top remains an axiom forever. MetaCoq's phrasing is the honest label: this
   moves a trusted *code* base to a trusted *theory* base (Sozeau, Boulier, Forster,
   Tabareau and Winterhalter, POPL 2020).
4. **Fidelity of `kernel-spec` to intent.** Discharged only by human reading. The de
   Bruijn criterion (Barendregt and Wiedijk 2005) is why L0 must stay readable. Never
   a theorem.
5. **The committed binary.** `bin/chirality-bin` (HANDOFF decision 6) is
   trust-on-first-use. Recompile-and-byte-compare proves the binary is a fixpoint of
   itself, and Thompson's attack (CACM 1984) is precisely the attack that *survives* a
   fixpoint check. Diverse double-compiling (Wheeler, ACSAC 2005; thesis 2009) is the
   standard counter and requires a second, independently produced compiler for the
   same source. There is none. `lib/evidence/ddc.chiral` implements the compare core
   correctly, and its own `leg2-disjoint?` demands different language *and* different
   toolchain, which no available leg satisfies. ⚑ **DDC in this repo is a typed hole,
   not an operating control, and the note base must say so rather than let the file
   read as coverage.** ⚑ **HARDER SINCE 2026-09-01**, and §0 relocates the whole
   item. The C leg that was the one satisfying pair was dropped, so
   `ddc-verdict-code`, `ddc-fold`, `ddc-legs`, `ddc-compare`, `ddc-leg0/1/c/cc` and
   `DdcR` now have zero callers and zero assertions; `e166_ddc_legc.prog` was their
   only exercise. The file stays reachable because `test-floor.chiral:31` imports it
   for `bytes=?`. A verdict nothing consults is not a gate. And per §0 this axiom
   sits on the deferred ownership-and-trust track: it is an axiom to name, and it is
   not the route to self-verification. Three honest routes, in order of what they
   buy:
   - Grow one of decision 5's formulations into a minimal second compiler. It needs to
     compile exactly one program (the compiler source) exactly once. It does not need
     speed or completeness. This is the only route that produces a real DDC leg.
   - Shrink the seed instead. This is **E72**, already minted, and its phrasing is
     already the right one: no trusted binary in the forever-story. The
     bootstrappable-builds route reduces the unaudited binary to a 357-byte hex0 seed
     plus an audited chain (stage0, M2-Planet, GNU Mes; Guix Full-Source Bootstrap,
     2023). No second compiler required. Same instinct as MM0: shrink what a human
     must read. ⚑ E72 names DDC (E53) as the thing that verifies the climb, so E72
     inherits E53's missing leg and does not route around it.
   - Prove the binary against the spec in-logic (CakeML's bootstrap, Kumar, Myreen,
     Norrish and Owens, POPL 2014). Stronger on correctness, and **circular against
     Thompson**, because the proof is run by the possibly-compromised binary. State
     this cleanly: trusting-trust is an *adversary*, not a correctness bug. More
     self-proof does not touch it. Only diversity or a human-readable seed does.

   Until one of the first two is done, the honest split-role tier is: committed
   binary, trust-on-first-use, unmirrored, **asserted**.
6. **Runtime side conditions.** Sufficient memory and termination of the checker
   itself. Jitawa's conditional theorem is the precedent for stating these rather than
   hiding them.
7. **The existing B seams** (hardware, foreign, DMA) are unchanged and already
   governed by split-role. Not new here.

## 6. Where this sits against the catalog

⚑ Three of this note's sections restate elements that are already minted, and the
first draft named one of them as an open question it had already answered. Read this
section before treating anything above as new.

- **E52 is L0/L1/L2.** "Kernel-core certificate split: kernel-spec artifact + small
  trusted core re-checking untrusted producers' certificates + certificate /
  proof-object format (LCF / de Bruijn)." §3's three levels are E52's three parts. What
  §3 adds is the *ascending sequence* with per-level faithfulness, which E52 does not
  have.
- **E52 already resolved the conversion question**, and this note's first draft listed
  it as the largest open decision. Author call 2026-07-26, **per-instance**: the
  evidence tier is chosen per certificate site, `rerun` where the check is decidable
  and cheap (conversion, NbE), `trace` for undecidable producer output (solvers,
  elaboration), `cached` only where perf dominates. The TCB is the union of the
  tier-checkers actually used. So L0 computes conversion by default and demands a
  witness only where rerunning is not available.
- **E71 is the frame the cores sit in**, and it dissolves the apparent conflict with
  `decision-split-checker`. Spec-as-golden, provisional 2026-07-26: the kernel-spec is
  the golden object and every executor, including a chirality reference executor, is
  first-among-executors with none privileged. Three formulations under one golden spec
  is not the quorum that note rejected. The quorum had no canonical comparable object;
  here the spec is it.
- **E72 already owns the seed-shrinking route** in §5. "Re-bootstrap artifact: the
  shipped form contains its own re-derivation, kernel-spec + a reference semantics
  simple enough to reimplement in a weekend in any language, + DDC (E53) to verify the
  climb; no trusted binary in the forever-story." §5's second route is E72, not a new
  option.
- **E53 is marked `built` and cannot run.** The ledger records BUILT 2026-07-28 on the
  evidence that the pure compare core `lib/evidence/ddc.chiral` exists. The core is
  real. The leg is not: `ddc-verdict-code:185` names `ddc-leg1`, the Python leg, which
  decision 5 evicted, and `leg2-disjoint?` refuses the two C legs as a pair because
  they share a language. So the element that owns trusting-trust reports coverage it
  cannot deliver, and the state needs correcting before anything is built on it.

## 7. What is not decided

- **How many levels.** Milawa's eleven were driven by proof-effort granularity, not
  taste. chirality's granularity is unknown until the first faithfulness proof is
  attempted.
- **Faithfulness or soundness between levels.** Faithfulness is Milawa's move, costs
  no strength, and is the recommendation for the working hierarchy. Soundness is
  Harrison's move and requires the axiom-strength step. Which one goes where decides
  whether this project is claiming a Milawa-shaped result or a Harrison-shaped one,
  and that is the author's call.
- **Peers or ordered**, beyond the one constraint in §4. Still open, as the arc
  handoff already says.
- **Hub versus all-pairs** for the cross-formulation bridges. Hub is recommended, not
  decided.
- **Second DDC leg, seed shrinking, or named axiom.** Cannot be deferred silently
  while `ddc.chiral` sits in the tree looking like a control. ⚑ 2026-09-01: still
  undecided, and now louder. The C leg is gone, `ddc.chiral` has zero callers, and
  §0 has moved DDC off the self-verification route and onto the deferred
  ownership-and-trust track without discharging it. [[open-edges]] records the
  repointing question.
- **Whether chirality's universe hierarchy is strong enough for level n+1 to prove
  level n's normalization.** Standard for MLTT-style universes. Not established in the
  literature for QTT plus refinement types plus the erasure story, and the research
  found no result that covers it. Treat as unresearched, not as inherited.
