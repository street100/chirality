# native protocol: the N lane checklist

**Minted 2026-09-03.** Row authority for the `N` id space. The arc that owns
these rows is `docs/arcs/native-protocol-arc.md`; its REQUIREMENTS section and
its resume state govern order and scope, and this file only carries the rows
in the shape the pack adapter reads. State is `design` (specced-able now),
`blocked` (named gate first), or `decide` (an author decision lands first).
Row format: `N# · Element · State · Gate · Size`.

The working constraint from the arc holds for every row: zero compiler
changes, and the `op-mulhi` surface binding stays unbuilt.

---

### Layer K: the pure kernels

| N# | Element | State | Gate | Size |
|----|---------|-------|------|------|
| **N1** | **Crypto kernels: an AEAD cipher, a hash, a key exchange, the WireGuard suite as reference class.** Pure category A throughout. Limbs are kept small enough that every product fits signed I64. The assertion gate carries the published RFC vectors; a kernel with a missing vector row is unproven and says so. | design | none | ? |

### Layer X: the crossings

| N# | Element | State | Gate | Size |
|----|---------|-------|------|------|
| **N2** | **The entropy crossing.** `getrandom` as a declared crossing. The tree today has zero RNG paths and every compiled path is deterministic; this row spends that property deliberately, through one declared site. | design | none | ? |
| **N3** | **Listen-side AF_INET and UDP externs**, landing beside `nb-sock-connect-in` in the socket registry. The registry today carries client connect only. | design | none | ? |

### Layer P: the protocol

| N# | Element | State | Gate | Size |
|----|---------|-------|------|------|
| **N4** | **Handshake and framing.** Noise reference class, the shrednet identity model as base. Key material lives behind Secret custody from mint to reveal, per E40's rule. | design | N1 · N2 · N3 | ? |

### Layer J: the judgment

| N# | Element | State | Gate | Size |
|----|---------|-------|------|------|
| **N5** | **The constant-time judgment: a secret-dependent branch or index is refused mechanically.** The language-development row; it leans on the information-flow deferral recorded in the Secret custody header. | design | none | ? |
