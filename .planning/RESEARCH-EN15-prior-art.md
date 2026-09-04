# RESEARCH: where the erased-word type lives, in the prior art

**Web research pass, 2026-09-04.** Evidence for an author call on the `apply-ty`
annotation defect. No recommendation, no SPEC, no element minted, nothing under
`docs/`, `lib/`, `prog/` or `records/` touched.

Every claim below is labelled **Read** (taken from a document that was fetched and
whose text was extracted) or **Inferred** (reasoning over what was read). Paper
text quoted from PDFs came through a local FlateDecode extractor, so inter-word
spacing was reconstructed by hand. Wording is verbatim. Spacing carries no
evidence.

---

## §1 · The question

`closconv-sig` groups higher-order call sites into families keyed by a shape that
erases every non-arrow type to one word, and `apply-ty` then spells the
synthesized `$apply` dispatcher's domain types from one family member's concrete
`Core` types. Those concrete types survive the peel, so four dispatchers carry a
tal type that contradicts what their own arms pass, and `ck-prog` correctly
refuses. The fork: whether the erased-word spelling belongs in the surface/core
type language, where a nominal `Word` would have to enter the kernel's `conv`
relation, or strictly at the lowering type level, where `tal-ty=?` already carries
representation compatibility.

---

## §2 · Thread 1. Pottier and Gauthier, and the dependent follow-up

**François Pottier and Nadji Gauthier, "Polymorphic typed defunctionalization",
POPL 2004, pages 89-98.**
<http://pauillac.inria.fr/~fpottier/publis/fpottier-gauthier-popl04.pdf>
Journal version: "Polymorphic typed defunctionalization and concretization",
*Higher-Order and Symbolic Computation* 19(1), 2006,
<https://link.springer.com/article/10.1007/s10990-006-8611-7>

This paper diagnoses chirality's exact situation by name.

**Read (§1, "The standard, limited workaround").** The family construction is the
simply-typed workaround, and the paper says why it breaks:

> The workaround commonly adopted in the simply-typed case consists in
> specializing `apply`. Instead of defining a single, polymorphic function, one
> introduces a family of monomorphic functions, indexed by ground types τ₁ and
> τ₂, each member of which has type ⟦τ₁→τ₂⟧ → ⟦τ₁⟧ → ⟦τ₂⟧.

> We note that ⟦·⟧ no longer commutes with substitution of types for type
> variables. Indeed, every distinct arrow type in the source program must now map
> to a distinct algebraic data type in the target program. As a result, there is
> no natural way of translating non-ground arrow types. These remarks explain why
> the approach fails in the presence of polymorphism.

**Inferred.** `shape-eq`'s erasure of non-arrows is a local answer to "there is no
natural way of translating non-ground arrow types". The paper predicts the
symptom: a family-indexed dispatcher cannot spell a polymorphic domain, and
`apply-ty` spells one anyway by picking a member.

**Read (§1, "Our solution").** Their construction keeps ONE polymorphic `apply`:

> We keep a single `apply` function, whose type is ∀α₁α₂. ⟦α₁→α₂⟧ → α₁ → α₂ …
> so ⟦τ₁→τ₂⟧ must be `Arrow` ⟦τ₁⟧ ⟦τ₂⟧, for some distinguished, binary algebraic
> data type constructor `Arrow`.

Each tag becomes a GADT constructor at its OWN concrete indices (`succ : Arrow int
int`), and the branch for `succ` is checked under the recovered equation `Arrow α₁
α₂ = Arrow int int`. The domain in the dispatcher's type is a quantified variable.
The concrete types live on the constructor.

**Cost, read (§1, Contributions).** The target type language needs guarded
algebraic data types. That is the whole cost. GADTs are the price of type
preservation for a polymorphic source.

**Compatible with erasure? Yes, read (§1 and §5).**

> because our version of defunctionalization employs a single, polymorphic
> `apply` function, it is not type-directed … it is possible to prove that our
> version of defunctionalization coincides with an untyped version of
> defunctionalization, up to erasure of all type annotations.

> any other type system would do just as well, provided it is powerful enough to
> encode typed defunctionalization and has a type erasure semantics.

GADT-typed defunctionalization presupposes a type-erasure runtime. It passes no
types and costs nothing at run time. It is the opposite of type-passing.

**Are families still available? Yes, and now optional. Read (§6, Discussion).**
This is the passage closest to the defect:

> if τ₁ and τ₂ are arbitrary (non-ground) types, whose free type variables are β̄,
> then one may define a specialized function `apply`_{∀β̄.τ₁→τ₂}, whose type is
> ∀β̄. ⟦τ₁→τ₂⟧ → ⟦τ₁⟧ → ⟦τ₂⟧, and whose code is identical to that of `apply`,
> except it contains branches only for the tags corresponding to source functions
> whose type is an instance of τ₁→τ₂. The resulting program is still well-typed:
> indeed, as pointed out by Xi, a type system equipped with guarded algebraic data
> types supports identification and elimination of dead branches … Thus, whereas,
> in the simply-typed case, type-based specialization was mandatory in order to
> achieve type preservation, it is now optional.

**Inferred.** The prior art's family key is "is an instance of the scheme
∀β̄. τ₁→τ₂", and the specialized dispatcher's domain is spelled with the QUANTIFIED
VARIABLES β̄. `shape-eq`'s "both non-arrow" is a coarse approximation of that
instance test, and `apply-ty`'s concrete member type is where the approximation
stops being represented in the annotation.

**Read (§6).** The paper also records the alternative chirality's design note
rules out. Monomorphisation before defunctionalization is the ML practice, cited
to Tolmach 1997, Tolmach and Oliva 1998, Cejtin/Jagannathan/Weeks 2000, and it
"involves code duplication, whose cost may be difficult to control"; with
polymorphic recursion or System F it "becomes impossible, because an infinite
amount of code duplication might be required."

### The dependent follow-up

**Yulong Huang and Jeremy Yallop, "Defunctionalization with Dependent Types",
PLDI 2023, PACMPL 7, Article 127.** <https://doi.org/10.1145/3591241>,
<https://www.cl.cam.ac.uk/~jdy22/papers/defunctionalization-with-dependent-types.pdf>

Relevant because chirality's kernel is dependent.

**Read (§2.3).** The GADT recipe scaled to inductive families is type-correct and
still rejected. Universe checking rejects the constructor whose captured argument
inhabits a larger universe than the datatype; positivity checking rejects it
because the arrow family is indexed by itself; termination checking rejects the
`$` case. Their words: "even if we do not make use of dependency, the same
problems with universes and positivity arise."

**Read (§2.4).** Their fix is to stop encoding the dispatcher as a source-language
datatype:

> we will define a target language, the Defunctionalized Calculus of Constructions
> (DCC), in the style of lambda calculus, but with a new construct for
> defunctionalized labels (representing indexes into a label context) in place of
> lambda abstractions.

The abstraction body and its typing live in a separate label context `D`, indexed
by label identifier. They follow Minamide et al. 1996 and Bowman and Ahmed 2018 in
"abstract" style: a specialized target language "avoiding the unnecessary
restrictions imposed by more concrete settings."

**Inferred.** For a dependent source, the published answer moves the defunctionalized
machinery into a target language below the source calculus. That is the "strictly
below" side of chirality's fork, taken by the one paper that addressed a dependent
kernel.

---

## §3 · Thread 2. GHC's `Any`, `unsafeCoerce#`, and `TYPE`/`RuntimeRep`

**Read (`ghc-prim`, `GHC.Types` source).**
<https://hackage.haskell.org/package/ghc-prim-0.9.0/docs/src/GHC.Types.html>

```haskell
type family Any :: k where { }
```

with the comment:

> The type constructor `Any` is type to which you can unsafely coerce any lifted
> type, and back. More concretely, for a lifted type `t` and value `x :: t`,
> `unsafeCoerce (unsafeCoerce x :: Any) :: t` is equivalent to `x`.

> See Note [Any types] in GHC.Builtin.Types. … Note that this must be a *closed*
> type family: we need to ensure that this can't reduce to a `data` type for the
> results discussed in Note [Any types].

**The structural facts, read.** `Any` is a closed type family with NO equations. It
reduces to nothing. It has no constructors. It is kind-polymorphic, so `Any ::
Type`, `Any :: Type -> Type` and so on are all available.

**Inferred, and load-bearing for the fork.** `Any` is related to `Int` by nothing
in Haskell's type equality. The identification happens at the TERM level, through
an explicit `unsafeCoerce` the programmer writes. GHC took the option of an inert
opaque type plus an explicit cast, and declined the option of a type that converts
with others.

**What breaks outside the invariants. Read (`Unsafe.Coerce`, base 4.22).**
<https://hackage-content.haskell.org/package/base-4.22.0.0/docs/Unsafe-Coerce.html>
Legitimate: coerce a lifted type such as `Int` to `Any`, store it, coerce back.
Prohibited: casting to an algebraic data type unless the source is also algebraic.
The documentation's own example is "do not cast `Int->Int` to `Bool`, even if you
later cast that `Bool` back to `Int->Int` before applying it", and its advice is to
use `Any` for that case "which is not an algebraic data type."

**Inferred.** The prohibition tracks an invariant the optimizer relies on. A value
at a known ADT type is assumed to be a properly tagged constructor application, and
a coercion through an ADT hands the optimizer a false invariant. `Any` carries no
such invariant because it has no constructors. The exact reason is in Note [Any
types], which this pass failed to retrieve (§8).

**`unsafeCoerce#`, read.** Documented as "highly, terribly dangerous coercion from
one representation type to another … You don't want this function. Really." It is
representation-polymorphic across all runtime representations, which is why the
safe wrapper is restricted to lifted types.

**The modern answer to "when may two types share a representation". Read
(`GHC.Types`, and the users guide on representation polymorphism,
<https://downloads.haskell.org/ghc/latest/docs/users_guide/exts/representation_polymorphism.html>).**

> GHC maintains a property that the kind of all inhabited types tells us the
> runtime representation of values of that type. … Note that `TYPE` is
> parameterised by `RuntimeRep`; this is precisely what we mean by the fact that a
> type's kind encodes the runtime representation.

The enforced rule is that no variable may have a representation-polymorphic type,
because the code generator cannot choose a width or a register for an unknown
representation. Representation lives in the KIND, and abstraction over it is
restricted at binding sites.

**Read (GHC.Core.Coercion, `UnivCo` / `UnsafeCoerceProv`).**
<https://hackage.haskell.org/package/ghc-lib-parser-0.20220501/docs/GHC-Core-Coercion.html>
`UnivCo` "serves two rather separate functions: the implementation for
`unsafeCoerce#` and placeholder for phantom parameters in a `TyConAppCo`". At
Representational role "it asserts that two (possibly unrelated) types have the same
representation and can be casted to one another, which is necessary for
`unsafeCoerce#`." `mkUnsafeCo` builds it with the `UnsafeCoerceProv` provenance.

**Inferred.** GHC does admit an unsound-by-design identification. It lives in
Core/System FC, it is a coercion carried by a term-level cast, and its provenance
is recorded so a reader can see why the coercion is untrustworthy. Haskell's own
type equality never learns it. This is the two-level shape, with the escape hatch
below the source checker and explicit at the point of use.

**Read (AOSA GHC chapter, <https://aosabook.org/en/v2/ghc.html>).** The reason Core
is typed at all is Core Lint, "a very powerful consistency check on the compiler
itself" and "an 100% independent check on the type inference engine". A typed
intermediate language is a compiler-bug detector.

---

## §4 · Thread 3. Typed Assembly Language and TALx86

**Morrisett, Walker, Crary, Glew, "From System F to Typed Assembly Language",
TOPLAS 21(3), May 1999.** <https://www.cs.princeton.edu/~dpw/papers/tal-toplas.pdf>

**Read.** The extracted text of the TOPLAS paper contains no uniform word type, no
top type, and no representation-compatibility relation. Full System F types survive
to assembly: `∀`, `∃`, and type variables appear in register-file types, and the
checker holds a type variable abstract.

**Read (§5.1, closure conversion).**

> To avoid the complexities of type environments, we adopt a type-erasure
> interpretation of polymorphism as in The Definition of Standard ML. In a
> type-erasure interpretation, we need not save the contents of free type
> variables in a type environment; instead, we substitute them directly into code
> blocks … as types will ultimately be erased, these "copies" are represented by
> the same term at runtime, resulting in no run-time cost.

**Inferred.** TAL's answer to "a value whose source type is erased but whose
representation is known" is a type VARIABLE held abstract by the checker. Erasure
is a property of the runtime, and the static annotation stays exact.

**Read (Pottier §1, summarising Minamide, Morrisett and Harper, "Typed closure
conversion", POPL 1996, pages 271-283).**

> the type of a closure is a pair of a first-order function type and of a record
> type, packed within an existential type, so that closures whose value
> environments have different structure may still receive identical types.

The unifier for heterogeneous environments is `∃`. The environment's field types
stay concrete inside the pack.

### TALx86 puts the word size in the kind

**Morrisett, Crary, Glew, Grossman, Samuels, Smith, Walker, Weirich, Zdancewic,
"TALx86: A Realistic Typed Assembly Language", WCSSS 1999.**
<https://www.cs.cornell.edu/talc/papers/talx86-wcsss.pdf>

**Read.** `B4` is the type of a 4-byte integer. `T4` is the KIND of 4-byte types.
`Ts` is the kind of stack types. The callee-save encoding is the exact analogue of
chirality's problem, one register holding a value of unknown type and known width:

> ∀α:T4 ρ:Ts. {ebp: α, esp: sptr{ebp: α, …}, …} where `T4` means that α can be any
> 4-byte type.

The polymorphic `map` is typed `∀α:T4 β:T4 ρ:Ts. …`, so every erased element
position is a variable at the word kind.

**Read.** Type variables are abstract to the checker and instantiation is explicit:

> Consequently, each type-variable is explicitly labeled with a kind so that we may
> check that only appropriate types are used to instantiate the bound type
> variables. … By treating the type variables as abstract types, we ensure that
> the code will be type-correct for any appropriate instantiation.

> One must explicitly instantiate a polymorphic precondition before control can be
> transferred to the corresponding label.

**Read.** TALx86 has exactly one relation resembling representation compatibility,
and it is directional and narrow: "The type system treats singleton integer types
as subtypes of `B4` so that they may be used wherever a `B4` is required."

**Inferred.** TALx86 answers chirality's question with "one word" as a KIND and the
erased position as a variable at that kind. It has no type meaning "some one-word
value", because a variable at kind `T4` already is that, and unlike a nominal
`Word` a variable cannot be confused with a concrete type by an equality check.

Karl Crary, "Toward a Foundational Typed Assembly Language", POPL 2003
(<https://www.cs.cmu.edu/~crary/papers/2003/talt/talt.pdf>) builds values from
byte-sized units with a product former. Not read past the abstract.

---

## §5 · Thread 4. ILs that carry a deliberate representation-level type

### MLton: two levels, and the lower one uses subtyping

**Read (`doc/guide/src/SSA.adoc`, verbatim).** "SSA is a `FirstOrder`,
`SimplyTyped` `IntermediateLanguage`. It is the main `IntermediateLanguage` used
for optimizations." SSA is reached from SXML by `ClosureConvert`, and SXML is
reached from XML by `Monomorphise`.

**Inferred.** MLton monomorphises BEFORE defunctionalizing, so its dispatchers
never see a polymorphic domain and can be spelled exactly. Its route is the one
chirality's design note at `closconv.chiral:359-360` rules out, and Pottier names
its cost.

**Read (`doc/guide/src/RSSA.adoc`, quoted at one remove; see §8).** RSSA "is an
`IntermediateLanguage` that makes representation decisions explicit", giving
"bit-level control over layout and associated packing of data representations",
with "singleton types that denote constants, other atomic types for things like
integers and reals, and arbitrary sum types and sequence (tuple) types." The
change that matters: "type checking is now based on subtyping, not type equality",
illustrated by a singleton `0xFFFFEEBB` being a subtype of `Word32`.

**Read (`mlton/backend/rep-type.sig`).** The module is `RepType`, with
`val equals: t * t -> bool`, `val isSubtype: t * t -> bool`, and `val width: t ->
Bits.t`, plus `isObjptr` / `isCPointer` / `deWord` / `deObjptr` and integration
with `Runtime` and `CType`.

**Inferred.** `RepType.isSubtype` and `width` are the closest thing in a shipping
compiler to chirality's `tal-ty=?` and `tt-word`. MLton runs an exact
type-equality level (SSA) above a coarser representation level with its own
directional relation (RSSA). The coarse relation sits strictly below and never
touches SML's type checker.

### OCaml: drop the discipline, then put layout in the kind

**Read (<https://ocaml.org/docs/compiler-backend>).** Lambda is untyped: the first
code generation phase "eliminates all the static type information into a simpler
intermediate lambda form", and Cmm is "simple C-like code". Value representation
is a runtime convention, an immediate with the low bit set or a pointer to a header
plus block, and it is enforced by the compiler's own correctness. `Obj.magic` is
the escape hatch, and it lives outside the type system.

**Read (OxCaml unboxed types, <https://oxcaml.org/documentation/unboxed-types/intro/>,
and the Jane Street ML'22 talk).** The current direction puts representation where
GHC put it: "Every type has a layout … A kind is a type's 'type', and kinds have
several components, among them layout, which describes the shape of the data at
runtime."

### CakeML: the representation change is a language change

**Read (<https://github.com/CakeML/cakeml/blob/master/compiler/backend/README.md>).**
The backend ILs in order are flatLang, closLang, BVL, BVI, dataLang, wordLang,
stackLang, labLang. closLang is "the last intermediate language that has closure
values"; dataLang is "the last language with a functional-programming-style data
abstraction"; wordLang programs "operate over machine words, a list-like stack and
a flat memory", where "all values are machine words and memory is a flat finite
mapping."

**Inferred.** CakeML never annotates an erased value at all. The transition to a
uniform word representation is a change of LANGUAGE, and correctness rests on a
per-phase semantics-preservation proof. That is a third option beyond chirality's
two, and it costs the checker.

### GRIN

**Read at README and abstract level only.** Boquist and Johnsson, "The GRIN
project: a highly optimising back end for lazy functional languages", IFL 1996,
LNCS 1268. <https://grin-compiler.github.io/> GRIN is a whole-program
defunctionalized IL with tags for constructors, function applications and partial
applications, a single `eval` dispatcher, and heap-points-to analysis that
specializes it per call site. A variable's static description is a computed SET of
tags. GRIN has no declared type annotation to be wrong.

### Java and Scala: the closest mainstream analogue

**Read (JLS 21 §4.6, <https://docs.oracle.com/javase/specs/jls/se21/html/jls-4.html#jls-4.6>).**

> The erasure of a type variable is the erasure of its leftmost bound.

Unbounded gives `Object`. Erasure also maps method signatures, and "the erasure of
the signature of a generic method has no type parameters."

**Read (JVMS 21 §4.10.1.2, verification type system).** The verifier's own type
system carries `top` (an unusable value), `oneWord` and `twoWord`, related by
`isAssignable`, which admits identity, reference subtyping, and null. The verifier
does not track generic type information; generics live in a `Signature` attribute
it ignores.

Bridge methods are the shape chirality's `$apply` has: one erased-signature method
that delegates to the concrete override, synthesized so virtual dispatch resolves.

**Inferred, and the sharpest point in this section.** Java's erased position IS
spelled with the lower language's top-ish type, `Object`. That is only sound
because `Object` is a genuine SUPERTYPE in the JVM's own directional relation, and
because the verifier's `oneWord`/`twoWord`/`top` lattice is a separate type system
from javac's. Java's source equality never learns that `List<String>` equals
`List<Integer>`. The two-level split is what makes the coarse spelling safe.

---

## §6 · Thread 5. The general principle, and what the weight of it says

**No published statement of the principle as a principle was found (see §8).**
The evidence is convergent practice.

| system | the coarse thing | where it lives | the relation |
|---|---|---|---|
| JVM | `top`, `oneWord`, `twoWord`, `Object` | verifier, below javac | `isAssignable`, directional |
| MLton | `RepType`, `width` | RSSA, below SSA | `isSubtype`, directional |
| TALx86 | word size | the KIND `T4` | equality, plus `∀` over a `T4` variable |
| GHC | `RuntimeRep` | the KIND, via `TYPE r` | equality, plus a Core `UnivCo` cast |
| Pottier and Gauthier | none | the domain is a quantified variable | GADT equations recover concreteness |
| Huang and Yallop | none | a new target calculus (DCC) below the source | label context, below the source |
| OCaml, CakeML | none | the type discipline is dropped at that level | proof or convention |

**On the fork, the weight is one-sided.** Not one of these systems adds a type to
the SOURCE conversion or equality relation that identifies two distinct ground
types. Seven out of seven keep the coarse relation below the source checker, and
every one of them uses something other than source-level equality to express it:
a directional relation, a kind constraint plus a quantified variable, an explicit
term-level cast, or no static relation at all.

**Inferred, on the kernel `conv` option.** Conversion is an equivalence relation,
so it is transitive. A `Word` that converts with `I64` and with `(List Str)` makes
`I64` convert with `(List Str)`. That is the collapse GHC avoids by making `Any` a
closed family with no equations, and that Java avoids by making `Object` a
supertype in a directional relation.

**Where the prior art is genuinely mixed.** It splits on how the erased position
is SPELLED, given that the coarse relation is below.

- **A quantified type variable.** Pottier and Gauthier's specialized
  `apply`_{∀β̄.τ₁→τ₂}; TAL's abstract `α` in a register-file type; TALx86's
  `∀α:T4`. The dispatcher is polymorphic and the concrete types sit on the
  constructor.
- **A coarse top or word type of the lower language.** Java's `Object`; the JVM
  verifier's `oneWord`; MLton's `RepType` with `isSubtype`.
- **Nothing.** OCaml Lambda, CakeML closLang, GRIN.

**Inferred, from source read at HEAD.** `term->ntalty` already maps `(t-var i)` to
`(nt-word)` at `lib/lowering/compile-front.chiral:70`, with the comment "B1: an
erased type variable in a KEPT position", and maps `t-pi` to `nt-word` on the next
line. The first branch of the split therefore reaches `tt-word` through machinery
this tree already has. Whether that is the right call is the author's, and this
document does not make it.

---

## §7 · The second instance: the `$kI_J` capture constructor's field types

The prior art speaks to this directly, and both answers keep the fields CONCRETE.

**Read (Pottier §1, "Our solution").** The GADT constructor carries its concrete
field types and its concrete arrow indices together. `succ : Arrow int int` is the
whole point: the constructor's type records the domain and codomain of the one
abstraction it stands for, and the dispatcher's branch recovers `α₁ = int` and
`α₂ = int` from the equation `Arrow α₁ α₂ = Arrow int int`. Huang and Yallop's
Fig. 1 does the same with a label context entry `L3{f:B→C, g:A→B} x:A ↦ f@(g@x):C`,
where the captures keep their source types.

**Read (Minamide, Morrisett and Harper, POPL 1996, via Pottier §1).** Typed closure
conversion hides a heterogeneous environment behind `∃`. The record's field types
stay concrete inside the pack, and the pack is what gives closures with different
environments one type.

**Inferred, on why the two instances differ.** A capture constructor is applied at
exactly one place, its own definition site, so nothing forces its field types to
merge with another constructor's. Only the shared dispatcher's argument position is
constrained by every member of the family at once. The prior art therefore erases
NEITHER the constructor's fields NOR the dispatcher's domain; it makes the
dispatcher polymorphic and lets the constructor stay concrete.

**Inferred, on the measured `$apply7` case.** That one reddens through the capture
constructor's field check rather than the argument check. Under the Pottier and
Huang-Yallop shape the constructor field would be the concrete side and the
dispatcher the varying side, which is the opposite arrangement to the one measured.
Whether the two instances are one defect or two is an author call this evidence
does not settle.

---

## §8 · What could not be found

Named searches and fetches that came back empty or partial.

- **GHC's "Note [Any types]" itself.** The `ghc-prim` source comment points at it
  in `compiler/GHC/Builtin/Types.hs`. `gitlab.haskell.org/ghc/ghc/-/raw/master/…`
  returns an Anubis anti-bot challenge page. `raw.githubusercontent.com/ghc/ghc/master/…`
  returns 404 for that path. A keyword search on the note's title returned only the
  Haddock text that cites it. The note's own reasoning was never read, so the
  account in §3 of why `Any` must not reduce to a `data` type is inference from the
  `Unsafe.Coerce` prohibition, and no quotation backs it.
- **A published statement of the thread-5 principle.** Searched
  `"type-preserving compilation" target type system less expressive than source
  … compiler is only producer` and `Morrisett ATTAPL "Typed Assembly Language"
  chapter … target type system role`. Both returned type-preservation literature
  with no statement of a soundness RULE for a two-level discipline whose lower
  level is coarser. The table in §6 is convergent practice assembled here, and no
  paper stating it as guidance was located.
- **The ATTAPL chapter text.** Morrisett, "Typed Assembly Language", chapter 4 of
  Pierce (ed.), *Advanced Topics in Types and Programming Languages*, MIT Press
  2005. The lecture-notes PDF at `cs.ioc.ee/yik/schools/win2005/morrisett/tal.pdf`
  failed with `unable to verify the first certificate`, and no other full text was
  reachable. The TAL claims in §4 rest on the TOPLAS paper and the TALx86 paper.
- **mlton.org.** Both `https://mlton.org/RSSA` and `http://www.mlton.org/RSSA` fail
  TLS hostname verification; the certificate covers a SourceForge shared-host list.
  The RSSA text was reached through `raw.githubusercontent.com` on
  `doc/guide/src/RSSA.adoc`, and the fetcher declined to reproduce the file
  verbatim, so RSSA's type-checking wording in §5 is quoted at one remove from a
  summary of that file. `SSA.adoc` came back verbatim and is quoted directly.
- **No prior art for chirality's exact construction.** Searches for a
  family-keyed dispatcher whose family key ERASES non-arrow domains returned
  Pottier's single polymorphic `apply` and the simply-typed ground-indexed family,
  with nothing occupying the middle. The erasure-keyed family looks unattested in
  the literature searched.
- **Adding a nominal word or top type to a DEPENDENT theory's conversion
  relation.** Searched around conversion, top types and unsound escape hatches.
  Results were about subtyping and about gradual typing, neither of which is a
  conversion relation over a kernel of this shape. No paper was found that
  analyses the consequence directly.
- **Follow-ups located but not read.** "Modular Polymorphic Defunctionalization"
  (ResearchGate listing only) and the 2006 HOSC journal version of Pottier and
  Gauthier. Only the POPL 2004 PDF was read in full.
- **GRIN.** Read at README and abstract level. Boquist's thesis "Code Optimisation
  Techniques for Lazy Functional Languages" stayed closed, and the Acta Cybernetica
  2020 paper "A Modern Look at GRIN" was read only to its abstract, so §5's claim
  about GRIN's computed tag sets is weakly sourced.
- **CakeML per-IL type discipline.** The README section that was fetched lists the
  ILs and their data abstraction levels and says nothing explicit about typed
  versus untyped. The statement that closLang is an untyped lambda calculus came
  from a search snippet of the same README, and remains unconfirmed against the
  fetched section text.
- **Scala.** Only secondary sources were found for Scala 3 erasure and bridge
  methods. `dotty/tools/dotc/transform/Erasure.scala` was located and not read. §5
  therefore cites Java's primary specifications and treats Scala as the same
  mechanism without a citation of its own.
