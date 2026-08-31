---
node: decision-license
layer: decision
related: [thesis, certificate-discipline]
status: decided
updated: 2026-08-31
---

# Decision: AGPL-3.0-or-later, with a runtime exception

**2026-08-31.** Replaces Business Source License 1.1, which this work carried
from its start.

## What BUSL was doing

Three things, and only two of them survive.

1. Anyone may use it, including commercially, for their own work.
2. Programs you build with it are yours, granted in as many words: *"building,
   running, and distributing your own works created with the Licensed Work."*
3. Nobody may sell chirality as a product, offer it as a hosted service, or make
   any offering where chirality "however wrapped or rebranded, is the substance
   of what is being sold."

Change Date was **Never**, so it never converted. BUSL is source-available and
is not an open source license.

## Why goal 3 cannot survive

The Open Source Definition §6 forbids discrimination against fields of endeavor:
a license may not stop anyone using the program in a specific field, business
included. Goal 3 is exactly such a restriction. **No OSI-approved license
preserves it.** Any move to open source gives it up, and picking a different
license does not change that.

So the question is not which license keeps the clause. It is what to substitute
for the thing the clause protected.

## What AGPL substitutes

AGPLv3 does not stop a competitor. It removes their advantage: a party that
sells or hosts chirality must convey the complete corresponding source of their
modified version, and §13 extends that to users interacting with it over a
network. The proprietary fork that BUSL forbade outright is now permitted but
worthless as a proprietary asset.

That is the closest achievable substitute, and it is the standard one. Projects
leaving BUSL for OSI land go to AGPL for this reason.

Rejected:

- **GPL-3.0**: same copyleft without §13, so a hosted service returns nothing.
  The hosted case is half of what goal 3 named.
- **MPL-2.0**: file-level copyleft. A competitor keeps their additions closed
  by putting them in new files.
- **Apache-2.0 / MIT**: goal 3's opposite. Good patent grant (Apache), and the
  first proprietary fork keeps everything.

## The runtime exception, and why goal 2 needs one

The compiler resolves imports into one flat compilation unit, so an emitted
binary contains this work's prelude and port floor. Under plain AGPL that makes
every chirality program a derivative work, which would destroy goal 2 outright.

`LICENSE.EXCEPTION.md` is an additional permission under §7 lifting exactly
that, modeled on the Bison parser exception and the GNU Classpath exception.
The boundary it draws is `LAYOUT.md`'s own two tiers: the universal shelf is
runtime and is excepted; `typing/`, `surface/`, `module/` and `lowering/` are
the language implementation and are not. A work containing those is a compiler,
and the exception does not reach it.

## Honest limits

- Goal 3 is gone. A competitor may sell or host chirality. They must publish
  their source; nothing stops them charging for it.
- The exception has not been reviewed by a lawyer.
- The exception's boundary is a prose reference to `LAYOUT.md`'s tier table. If
  that table changes, the licensing boundary changes with it, silently. Making
  the tier machine-checkable would close that, and nothing does it today.
- AGPL is a real adoption cost for a language. Some organizations refuse it by
  policy, exception or not. That cost is accepted here in exchange for staying
  open source, which was the instruction.

## Not decided here

Whether to dual-license commercially. AGPL leaves that open: the copyright
holder may always sell a separate proprietary grant, which recovers goal 3's
revenue intent without a field-of-use restriction in the public license.
