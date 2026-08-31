# FINDING: the secure-datum model's threat split is drawn in the wrong place

**2026-08-31.** Raised by the author: *"if one has DMA then CPU code execution is
like a given."*

Correct, for the write half. The document's in-scope capability grants the
capability it declares out of scope, and the document's own §1 says why that is
fatal rather than untidy.

## What the document claims

`docs/definitions/secure-datum-model.md` §2:

- **In scope:** peripheral DMA with **read**, **write** (tamper, replay/rollback),
  and access-pattern observation.
- **Out of scope:** *"CPU code execution (kernel exploit, SMM, microcode,
  speculation reading registers). Once the attacker runs code on the CPU,
  registers are reachable and this model's root falls."*

§1: *"The only dependency any layer may share is the register root (§3), and that
is unreachable by the threat."*

§3: the master secret lives only in registers; RAM holds ciphertext only.

## Why the split does not hold

The target machine is stated as *"no TPM, no IOMMU relied on"*. On that machine,
DMA write is **arbitrary physical memory write**. Arbitrary physical write is a
well-trodden path to CPU code execution: overwrite kernel text, a function
pointer, or a page-table entry and the CPU executes the attacker's code on its
next pass. This is not hypothetical or exotic. It is what PCILeech's kernel
implants do, and PCILeech is named in §2 as the in-scope tool.

So the out-of-scope list is not a set of powers the attacker lacks. It is a
consequence of a power the model hands them. Once code runs on the CPU, registers
are readable directly, and a forced context switch spills them to RAM regardless.

The document already states the conclusion in §2 and does not apply it: *"Once
the attacker runs code on the CPU, registers are reachable and this model's root
falls."*

By §1's Rule B — *"defeating one must not help defeat another"* — every layer in
§4 shares one dependency, the register root, and against a write-capable
adversary that dependency is reachable. §1's own words for this case: *"N layers
that share a weakness collapse to one."* The stack does not multiply. It is one
layer, and it is already defeated.

## What survives, and it is not nothing

Split the adversary. The two halves have genuinely different answers, and
collapsing them is the whole error.

**A_read — DMA read, snapshot, continuous read, access-pattern observation.**
The model holds completely. DMA cannot read registers, so the register root is
real, and every §4 confidentiality multiplier is sound: encryption with the key
in registers, uniform entropy, chaff, the bounded interrupt-disabled window,
short residency, moving target, ORAM for the watcher. This is the evil-maid and
Thunderbolt-snapshot adversary, which is the common real one. Nothing here needs
retracting.

**A_write — DMA write.** Subsumes CPU code execution, therefore subsumes register
read. Confidentiality against this adversary is **not available** from CPU + RAM
alone, at any cost multiplier, because the root is reachable rather than
expensive. What remains is **detection**: MACs, versioning, and the several-truths
reconciliation of PRINCIPLES §5 can notice tampering after it happens. They
cannot prevent it, and their keys are themselves register-derived, so a
write-capable attacker who has taken CE can forge them too. Honest residue: A_write
detection works only against an attacker who writes *before* taking CE, which is
an ordering assumption, not a guarantee.

## Why this is P5's own lesson, turned on the document

PRINCIPLES §5 already carries the verb-honesty clause: *"this principle is
detection, where P1 through P4 are prevention… In the DMA example the actual
safety comes from the IOMMU denying the write."*

PRINCIPLES has it right. The datum model does not inherit it. §1 promises
*"exponentially expensive, guaranteed, generally"* over an adversary set that
includes write, and that promise is not true for the write half at any exponent.

## Owed

1. **Split §2's adversary into A_read and A_write**, and state the guarantee per
   half. §1's headline promise then belongs to A_read only.
2. **Move write/tamper/rollback out of the confidentiality stack** in §4 and into
   an integrity section whose verb is *detect*, with the CE-ordering assumption
   named.
3. **Say what A_write actually requires**: an IOMMU denying the write, which the
   document currently lists as an alternative it does not rely on rather than as
   the only answer to half its own threat model.

Not yet minted as an `E#`. This is a document-tier correction, not an element,
so nothing above is deferred to a phantom. If the split turns into a language
obligation (a type that carries which adversary a datum is defended against),
that mints a row.

## What is NOT wrong

The register root, the derive-not-store discipline, the interrupt-disabled
critical section, and the whole cost-multiplier framing are correct and worth
keeping. The error is one line in §2 that puts write in scope beside read, and
one line in §1 that calls the shared root unreachable without qualifying which
adversary it is unreachable by.
