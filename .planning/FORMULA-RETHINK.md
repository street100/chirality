# Formula rethink: the semantic pass, one formula at a time

Opened 2026-09-03 by author direction: semantically complicated before
mechanically complicated. The cipher cores stay bit-faithful transcriptions;
everything around them gets rethought in the language's own machinery
(refinements, quantities, custody, porttypes, typestate). This file is the
worklist. One formula per row, worked one at a time, each producing either a
measured probe, a design in the N7/N6 pipeline artifacts, or a dated
rejection here.

## The list

| # | formula | conventional form | the rethink question | feeds | state |
|---|---|---|---|---|---|
| 1 | 32-bit lane arithmetic (add mod 2^32, rotl) | wrapping uint32 | a refined Lane32 the checker holds: can `refine` carry bounds through band, +, *, shl | N6, re-seats slices 1-2 | WORKED 2026-09-03, shape 2 |
| 2 | prime field 2^130-5, five 26-bit limbs | donna-shape C | a Limb type whose bound rides the type; carry fold as a typed op; whether per-op output bounds are expressible | N6, poly1305 | shaped by row 1: boundary types |
| 3 | prime field 2^255-19, ten 25.5-bit limbs | ref10-shape C | same as 2, harder; the ladder's structure ties to the constant-time judgment | N6 then slice 4 | shaped by row 1: boundary types |
| 4 | GF(256) (xor add, peasant or table mul) | byte tables | field as a closed algebra with anchor vectors; representation under decimal literals | N7 | in N7 pre-run now |
| 5 | polynomial split and Lagrange at 0, t of n | array loops | threshold in the type, the `(Pool n)` precedent: shares as values indexed by t and n so an under-quorum reconstruct is untypeable | N7, N8 | open, high value |
| 6 | AEAD composition (encrypt then MAC) | convention plus care | the nonce as a LINEAR mint: one use by quantity, reuse unrepresentable; keys behind Secret custody at the API | N6 seam, re-seats slice 2 | open, cheap, novel |
| 7 | keys public and secret | both are byte arrays | distinct types, secret half behind custody, reveal sites greppable (E40 built) | N6, slice 4, N4 | open |
| 8 | hash and KDF (BLAKE2s, keyed mode) | mechanical | mostly transcription; keyed-mode parameters typed rather than offset conventions | slice 3 | mostly mechanical |
| 9 | the handshake state machine | enum plus discipline | typestate porttypes, the Sock/LSock precedent: one wire, each protocol state its own type, transitions linear | N4 | open, the big one |
| 10 | entropy | a syscall | a declared crossing spending determinism deliberately; whether the amount and the consumer ride the type | N2 | open |
| 11 | constant time | author discipline in C | a judgment: secret-dependent branch or index refused; leans on E44 deferral and the typed TAL floor | N5 | open, blocked on enforcement R3 for depth |
| 12 | quorum agreement and the return track | ad hoc consensus glue | category C evidence: reconstructions cross-checked, disagreement a named outcome, the evidence-and-split bank shape applied to data | N8 | open, design with N4 |

## Where to start, and why

**Row 1 first.** It is the floor every mechanical row sits on, and it is
measurable tonight with one probe file: write refined lane types and see what
the checker accepts through band, +, * and shl. Its answer forks everything:
bounds the checker holds mean N6 is a typed floor; bounds it cannot hold mean
N6 stays prose-plus-gates and says so honestly. Either outcome is progress
and the probe costs an hour.

**Row 6 second.** The linear nonce mint uses machinery that already exists
(quantities, porttype mints, Secret), touches no compiler, and is the
highest-novelty-per-line item on the list: a nonce that cannot be reused is a
sentence the reference implementations cannot say.

**Row 5 third.** Threshold in the type feeds N7 while its pipeline is warm;
the `(Pool n)` size-in-type precedent is already load-bearing in the tree.

Rows 9 and 12 are the deep water and wait for N4/N8 design time. Row 11 waits
on the enforcement arc's R3 for its strong form.

## Worked

**Row 1, 2026-09-03. Verdict: shape 2, refined boundaries with checked-cast
entry and bare I64 kernel interiors.** Seventeen probe files against
`bin/chirality check`, two re-run by the orchestrator. What is real today:
range refinements over I64 with up to five comparison atoms conjoined by
listing (`parse-refine`, `lib/surface/parse.chiral:385`; ops at
`lib/typing/refine.chiral:10`), boundary-exact literal checking (4294967295
accepted, 4294967296 refused), entailment between refinements, variable
operands instantiated at call sites (`lib/memory/mem-linear.chiral:27` is
live prior art), guard narrowing that stacks two `case` guards to a full
Lane32 range, and the checked-cast-into-a-sum idiom
(`lib/runtime/proc.chiral:42` prior art). What is dead: arithmetic never
narrows. The deciding probe: `(band x 4294967295)` against a Lane32 return
is `load: cannot prove refinement`; every arithmetic extern returns bare
I64 (`prelude.chiral:58-71`) and `refine.chiral:7` defers the solver to
unbuilt E41. Two working constraints for N6: declare every def (check
mode), and keep guarded case results out of let bindings (FD-02, reconfirmed).
Decision produced: N6's prim module carries Lane32/Limb26 as boundary
types with guarded entry casts; kernel interiors stay bare I64 with the
bounds argued in the module header and pinned by vector gates; E41 is the
named upgrade path to checker-held interiors.
