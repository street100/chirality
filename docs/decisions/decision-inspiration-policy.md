# Decision: Inspiration & Reading Policy

**Status:** settled 2026-07-06, **amended 2026-09-22 by addition**: the ⚑ under
the Tier P rule of thumb, §Crypto, and the ⚑ closing §One-line summary per
catalog element. The four tiers, the license floor and every element assignment
are untouched. Governs *what external material chirality may read directly* when
building its own implementation of each element in `docs/elements/catalog.md`,
and, since the amendment, of each object §Crypto names where no element exists
to name. This is Step 2 of the plan/audit arc.

## The governing question

Not "may we look at prior art" (of course) but: **for each element, does reading a
specific external *implementation's source* threaten chirality's provenance, TCB, or
identity — or is it required for conformance?** The answer sorts every element into
one of four tiers. The sort is driven by **identity/provenance first, license as a
hard floor** — for the metatheory we stay paper-led even when the license would
permit reading source, because the load-bearing claim is *"this checker is ours."*

## The four tiers

### Tier R — Required reading (conform exactly)
Interface contracts and our own code. Not reading them is the error. Bit-exact
conformance is the goal or the thing literally *is* our source.

- **All `SPEC`** — x86-64 ISA (Intel SDM), Linux syscall ABI + struct layouts
  (`pollfd`, `msghdr`/`cmsghdr` for SCM_RIGHTS), ELF + SysV gABI, Wayland wire,
  PNG, SMT-LIB div/mod (Boute Euclidean). Elements E19–E21, E24, E28–E37.
- **All `OURS`** — our Python (`sexp/surface/runtime/lower/optimize/tal.py`, the
  checker modules as *port source*). Elements E1–E2, E13–E17, E23, E25, E49.
- **musl (MIT)** as the canonical *"how to issue a Linux syscall"* reference —
  treat as SPEC-adjacent for E28–E33. It documents the ABI more legibly than the
  man pages in places; permissive license, mechanical content, no identity stake.

### Tier O — Oracle-only (observe behavior, never read source)
Use as a **differential / golden oracle**: run it, compare our output to its output,
build accept/reject corpora — but do **not** read its source. Clean-room-safe
*regardless of that tool's license*, because we consume behavior, not structure.

- **Z3 / CVC5** — oracle for the refinement decision procedure (E9): emit our
  constraints in SMT-LIB, check our `entails`/`is_empty` verdicts against theirs on
  a generated corpus. Never read the solver internals.
- **Agda / Idris2 / Lean / Rocq(Coq)** — oracle for *what ought to typecheck,
  terminate, or count as strictly positive* (E3–E8, E11, E47, E50). Curate a suite
  of programs with known accept/reject verdicts; do not read their kernels.

This tier is how we get the correctness leverage of mature tools without taking on
their provenance. It is the single most valuable move in the policy.

### Tier P — Paper-led, source-avoided (identity-bearing metatheory)
Read the **papers**; reimplement clean; **deliberately do not read** the canonical
implementation's source even when its license permits. This is where chirality's
identity lives — the checker must be ours by construction.

| Element | Read (paper) | Avoid (source) |
|---|---|---|
| E3 NbE | Abel; Coquand "NbE for MLTT" | Agda/pi-forall evaluators |
| E4 bidirectional | Dunfield–Krishnaswami | Idris2 elaborator |
| E5 QTT semiring/linearity | Atkey; McBride "Plenty o' Nuttin'" | Idris2 quantity checker |
| E7 strict positivity | Agda/Coq *papers* | their positivity checkers |
| E11 termination | foetus / size-change (Lee–Jones–Ben-Amram); Abel sized | Agda `.Termination` |
| E9 refinement domain | Liquid Types (Rondon/Jhala); interval/octagon | LiquidHaskell src |
| E10 occurrence typing | Typed Racket (Tobin-Hochstadt–Felleisen) | TR impl |
| E38 coeffects | Petricek/Orchard; graded modal | — |
| E39 effect algebra | Koka/Frank/Eff *papers* | their runtimes |
| E40 capabilities | object-capability literature | — |
| E41 regions | Tofte–Talpin region calculus | MLKit |

Rule of thumb: **an algorithm from a paper is an idea we may take; a kernel from a
repo is a structure we build ourselves.**

⚑ **That rule sorts on the carrier, and a cryptographic standard's carrier holds
the kernel.** Measured 2026-09-22 against the pins in `.planning/sources/`.
`FIPS202.txt:21-26` is not a paper stating an idea beside a repo holding a
structure: Algorithms 1 through 7 are the five step mappings and the permutation
written out as steps, and the document has no version with the algorithm removed.
`RFC8439.txt:478-483` carries pseudocode and rules on its own status, *"the
textual explanation and the test vectors are normative"*. The paper-against-repo
test therefore sorts no crypto object, and §Crypto below sorts on content
instead. The rule stands unchanged for the eleven elements in the table above,
where the two carriers are two documents.

### Tier F — Free-to-read (permissive, mechanical, non-identity)
Substrate/mechanical elements with no identity stake and a permissive license — read
source freely, borrow structure, cite it.

- **dlmalloc** (public domain), bump/arena allocators — E22.
- **LLVM / Cooper–Torczon / Appel** for reg-alloc, DCE, SSA — E16–E17 (ideas).
- **Existing assemblers** (nasm tables, LLVM MC) for x86 encoding cross-checks — E19,
  as a *check* against the Intel SDM, which remains the authority.

## License floor (hard constraint, verify before relying)

Reading source is gated on license regardless of tier. Believed licenses (VERIFY —
ccbox egress is blocked, these are from memory): Agda MIT · Idris2 BSD-3 · Lean4
Apache-2.0 · **Rocq/Coq LGPL-2.1** · Z3 MIT · CVC5 BSD-3 · musl MIT · dlmalloc
public-domain · Wayland MIT · LLVM Apache-2.0-with-LLVM-exception. The one to note is
**Coq/Rocq is LGPL** — fine, since it sits in Tier O (oracle-only, we never read it).
**No GPL/AGPL source enters the reading set for any clean-room element.** If a
tempting reference is GPL, it drops to Tier O automatically.

## Crypto

⚑ **Added 2026-09-22. This policy settled 2026-07-06 holding no crypto at all**,
and a case-insensitive grep of it that day for `crypto`, `cipher`, `hash`,
`keccak`, `chacha` and `constant-time` returned nothing.
`docs/arcs/crypto-primitives-arc.md` opened 2026-09-07 and stands at 36 rows and
8 requirements whose subjects are published external objects, seven of them
dispatching to the `translate` skill, and `lib/crypto/chacha.chiral` and
`lib/crypto/poly1305.chiral` are built and gated at
`tools/test/run-tests.sh:367`. All of it was read under no tier.

**Nothing below is keyed on an element, and that is measured rather than
chosen.** Every row on that roster carries `element: unminted`, and the `CRY`
band `E114`-`E119` at `docs/elements/ledger.md:357-363` is six `?` slots the
ledger calls *"slots rather than elements"* at `docs/elements/ledger.md:47-48`.
There is no `E##` to sort. So this section keys on the object, the way Tier R
already keys musl and Tier O already keys Z3, and §One-line summary per catalog
element below is unchanged.

### The axis the four tiers do not separate

Each tier states what may be read and what must be reproduced under one label,
and across the original catalog the two move together: an interface contract is
read *because* something outside holds us to it, and a kernel is avoided
*because* nothing does. Crypto decorrelates them. A standard must be read to
build anything at all, and whether what we ship is held to its bytes is a
question about whether there is a counterparty.

⚑ **That question is unanswered, and this section does not answer it.** No
document in `docs/decisions/` states whether chirality's crypto outputs must be
byte-identical to a published instantiation. A mark that must interoperate with
a foreign implementation reads `FIPS202` as Tier R and conforms bit for bit; a
mark that must only be ours reads the same document as Tier P and rebuilds
clean. `.planning/CRYPTO-MODEL.md:347-358`'s interoperation is
chirality-node-to-chirality-node across differing configurations and settles
nothing about a foreign one. The fork is carried to [[records/author-calls]] by
[[records/crypto-primitives]] `CP-05`, and the two tables below are drawn around
it.

### What the stated criteria decide

| object | tier | the criterion that decides it |
|---|---|---|
| the permutation and the sponge construction as specified: `FIPS202` §3 and §4, `KECCAKSUM`, `ASCONSPEC` | **R** | `.planning/CRYPTO-MODEL.md:440` keeps *"the conformant entries"* as *"the same machine at the parameters a downstream scheme requires"*. A conformant entry is unreachable unless the machine reproduces the published one bit for bit, which is Tier R's own goal. ⚑ This is derived from a settled design rather than stated by a ruling, and the FLAG below offers it to the author |
| `RFC8439`, for the two built modules | **R** | §Why this shape already holds that *"Specs are always read — conformance is not a clean-room concern"*, and this RFC declares its own vectors normative at `.planning/sources/RFC8439.txt:482-483`. `docs/translations/aead-chacha20-poly1305.md:105-106` records *"RFC 8439's published vectors apply unmodified"* and they run at suite phase 31. The posture was taken in 2026-09 under no tier and Tier R is the one it took |
| a published known-answer test set: an RFC's vectors, `FIPS202` Appendix A, a validation-program file | **O** | Tier O's argument is *"we consume behavior, not structure"*, and that holds of a frozen vector exactly as it holds of a running solver. Tier O says *"run it"*, which names a mechanism and not a criterion, and a vector file is the mechanism with the running already done. Reading one is clean-room-safe whichever way the fork falls |
| analysis and bounds documents carrying no implementation: `RFC9771`, `AEADLIMITS` | **P** | Tier P is *"read the papers, reimplement clean"* beside an avoid column, and these have no canonical implementation to avoid, so only the read column applies. `docs/translations/aead-chacha20-poly1305.md:119-133` already reads both this way |
| any third-party implementation source: XKCP, libsodium, BoringSSL, a reference C drop | **O** | the rule of thumb's right half survives here intact, *"a kernel from a repo is a structure we build ourselves"*, and running one to generate a differential corpus without reading it is Tier O entire. Independent of the fork |
| a structure borrowed from a named permissive implementation and cited: poly1305-donna's five 26-bit limbs at `lib/crypto/poly1305.chiral:11` | **F** | Tier F is *"no identity stake and a permissive license — read source freely, borrow structure, cite it"*, dlmalloc is its precedent, and the citation Tier F demands is in the module header. ⚑ Provisional: it rests on crypto carrying no identity stake, which the second FLAG below disputes |

### What the stated criteria do not decide

The first column is the object; the second is the decision it waits on, and no
tier is assigned until that decision lands.

| object | waits on |
|---|---|
| `FIPS202`'s named instantiations, SHA3-224 through SHAKE256 | the byte-identity fork. `.planning/CRYPTO-MODEL.md:432-433` makes a standard's named instantiation *"a value in a table rather than the thing implemented"* and `:437` makes the mark *"our rate, our capacity, our domain separator"*. Whether a published vector for a named instantiation binds anything chirality ships is the fork itself |
| the post-quantum standards and their validation vectors | the byte-identity fork, and `.planning/CRYPTO-MODEL.md` `C3`, which picks ML-DSA against SLH-DSA. A tier cannot name an object nobody has chosen |
| the memory-hard derivation `crypto-primitives/K34` renders | the byte-identity fork. Nothing is pinned for that row and its gather has not run |
| the PAKE and the hybrid combiner, `K11` and `K12` | the byte-identity fork, and `.planning/CRYPTO-MODEL.md` `C5` for the combiner's construction |

### The license floor over these objects

The floor reads **source licenses** and sorts MIT, BSD, Apache and LGPL, and
every license in it carries its own VERIFY caveat because ccbox egress is
blocked. **No license is asserted here.** Three things were measured inside the
pins on 2026-09-22, and not one of them is a license claim:

- `.planning/sources/FIPS202.txt:6` carries the standard's own §10, *"Implementations
  of the SHA-3 functions in this Standard may be covered by U.S. or foreign
  patents"*, and a §11 export-control clause beside it. A patent claim over a
  published algorithm is not a source license, and the floor holds no slot that
  reads one.
- `.planning/sources/FIPS202.txt:5` §8 makes conformance a matter of validation:
  *"Only implementations of these functions that are validated by the
  Cryptographic Algorithm Validation Program will be considered as complying"*
  with the standard.
- `.planning/sources/RFC8439.txt:65-72` places the document under BCP 78 and the
  IETF Trust's Legal Provisions rather than under any named source license.

What is asserted is narrower than a license and it is a gap in the floor: the
floor's instrument reads a source license, two of these three objects publish no
source license to read, and a floor that returns nothing over an object is not a
floor that permits it.

## One-line summary per catalog element

- **R (read/conform):** E1, E2, E13–E21, E23–E25, E28–E37, E49.
- **O (oracle-only):** the *verification* of E3–E11, E47, E50 (behavioral corpora).
- **P (paper-led, source-avoided):** E3–E12, E22*, E26, E27, E38–E48, E50.
- **F (free-to-read):** E22 (allocator), E16–E17 (opt ideas), E19 (encoding checks).

(*E22 splits: region *types* are Tier P (Tofte–Talpin); the concrete bump/arena
allocator is Tier F (dlmalloc).)

⚑ **No crypto element appears in the four lines above and none can today.**
Measured 2026-09-22: every row of `docs/arcs/crypto-primitives-arc.md` carries
`element: unminted`, and the `CRY` band `E114`-`E119` is six unfilled slots.
§Crypto above sorts the same work by object, which is the only key that exists.
This summary gains its crypto line when that band mints, and until then the two
are consistent because one of them is empty rather than because they agree.

## Why this shape

- Keeps the **TCB-shrink prize** (the checker, E1–E14) clean-room by construction —
  the thing we most want to be able to say is ours, is.
- Still gets **mature-tool correctness** via Tier O without a provenance cost.
- Doesn't waste purity on **substrate** (allocators, encoders) where conformance and
  permissive reuse are the honest, faster path — *compose, don't reinvent* applies
  exactly where identity isn't at stake.
- **Specs are always read** — conformance is not a clean-room concern.
